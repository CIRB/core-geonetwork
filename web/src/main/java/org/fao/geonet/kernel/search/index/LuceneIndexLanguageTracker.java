package org.fao.geonet.kernel.search.index;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import jeeves.utils.Log;

import org.apache.commons.io.FileUtils;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.NRTManager.TrackingIndexWriter;
import org.apache.lucene.search.Sort;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.search.TopFieldCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.LockObtainFailedException;
import org.apache.lucene.store.NRTCachingDirectory;
import org.apache.lucene.store.NativeFSLockFactory;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.LuceneConfig;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.UpdateIndexFunction;
import org.fao.geonet.kernel.search.index.GeonetworkNRTManager.AcquireResult;
import org.fao.geonet.kernel.search.spatial.Pair;


/**
 * Keeps track of the lucene indexes that currently exist so that we don't have to keep polling filesystem
 * 
 * @author jeichar
 */
public class LuceneIndexLanguageTracker {
    private final Map<String, NRTCachingDirectory> dirs = new HashMap<String, NRTCachingDirectory>();
    private final Map<String, TrackingIndexWriter> trackingWriters = new HashMap<String, TrackingIndexWriter>();
    private final Map<String, GeonetworkNRTManager> searchManagers = new HashMap<String, GeonetworkNRTManager>();
    public static Object MUTEX = new Object();
    private final Lock optimizingLock = new ReentrantLock();
    private final Timer commitTimer;
    private final LuceneConfig luceneConfig;
    private final File indexContainingDir;
    private final SearcherVersionTracker versionTracker = new SearcherVersionTracker();

    public LuceneIndexLanguageTracker(File indexContainingDir,LuceneConfig luceneConfig) throws CorruptIndexException, LockObtainFailedException, IOException {
        this.luceneConfig = luceneConfig;
        this.indexContainingDir = indexContainingDir;
        this.commitTimer = new Timer("Lucene index commit timer", true);
        commitTimer.scheduleAtFixedRate(new CommitTimerTask(), 60*1000, 60*1000);
        commitTimer.scheduleAtFixedRate(new PurgeExpiredSearchersTask(), 30 * 1000, 30 * 1000);
        init(indexContainingDir, luceneConfig);
    }
    private void init(File indexContainingDir, LuceneConfig luceneConfig) throws IOException, CorruptIndexException,
            LockObtainFailedException {
        indexContainingDir.mkdirs();
        Set<File> indices = listIndices(indexContainingDir);
        for (File indexDir : indices) {
            open(indexDir);
        }
    }
    private void open(File indexDir) throws IOException, CorruptIndexException,
            LockObtainFailedException {
        indexDir.mkdirs();
        String language = indexDir.getName();
        
        Directory fsDir = FSDirectory.open(indexDir);
        double maxMergeSizeMD = luceneConfig.getMergeFactor();
        double maxCachedMB = luceneConfig.getRAMBufferSize();
        NRTCachingDirectory cachedFSDir = new NRTCachingDirectory(fsDir, maxMergeSizeMD, maxCachedMB);
        IndexWriterConfig conf = new IndexWriterConfig(Geonet.LUCENE_VERSION, SearchManager.getAnalyzer(language, false));
        conf.setMergeScheduler(cachedFSDir.getMergeScheduler());
        IndexWriter writer = new IndexWriter(cachedFSDir, conf);
        TrackingIndexWriter trackingIndexWriter = new TrackingIndexWriter(writer);
        GeonetworkNRTManager nrtManager = new GeonetworkNRTManager(luceneConfig, language, trackingIndexWriter, null, true);

        dirs.put(language, cachedFSDir);
        trackingWriters.put(language, trackingIndexWriter);
        searchManagers.put(language, nrtManager);
    }
    private Set<File> listIndices(File luceneDir) {
        Set<File> indices = new HashSet<File>();
        final File[] files = luceneDir.listFiles();
        if (files != null) {
            for (File file : files) {
                if (new File(file, "segments.gen").exists()) {
                    indices.add(file);
                }
            }
        }
        return indices;
    }
    private static String normalize( String locale ) {
        if(locale == null) {
            locale = "none";
        }
        return locale;
    }
    
    synchronized Pair<Long, GeonetworkMultiReader> aquire(long versionToken, String searchLanguage) throws IOException {
        long finalVersion = versionToken;
        Map<AcquireResult, GeonetworkNRTManager> searchers = new HashMap<AcquireResult, GeonetworkNRTManager>(
                (int) (searchManagers.size() * 1.5));
        IndexReader[] readers = new IndexReader[searchLanguage!=null ? 1 : searchManagers.size()];
        int i = 0;
        boolean tokenExpired = false;
        boolean lastVersionUpToDate = true;
        for (GeonetworkNRTManager manager : searchManagers.values()) {
            if (!luceneConfig.useNRTManagerReopenThread()
                    || Boolean.parseBoolean(System.getProperty(LuceneConfig.USE_NRT_MANAGER_REOPEN_THREAD))) {
                manager.maybeRefresh();
            }
            AcquireResult result = manager.acquire(versionToken, versionTracker);
            lastVersionUpToDate = lastVersionUpToDate && result.lastVersionUpToDate;
            tokenExpired = tokenExpired || result.newSearcher;
            if (searchLanguage!=null) {
                if (!((NativeFSLockFactory)((NRTCachingDirectory) result.searcher.getIndexReader().directory()).getLockFactory()).getLockDir().getName().equals(searchLanguage)) {
                	continue;
                }
            }
            readers[i] = result.searcher.getIndexReader();
            i++;
            searchers.put(result, manager);
        }

        if (tokenExpired) {
            if (lastVersionUpToDate) {
                finalVersion = versionTracker.lastVersion();
            } else {
                finalVersion = versionTracker.register(searchers);
            }

        }
        return Pair.read(finalVersion, new GeonetworkMultiReader(readers, searchers));
    }

    synchronized void commit() throws CorruptIndexException, IOException {
        for (TrackingIndexWriter writer : trackingWriters.values()) {
            writer.getIndexWriter().commit();
        }
    }
    synchronized void withWriter(Function function) throws CorruptIndexException, IOException {
        for (TrackingIndexWriter writer : trackingWriters.values()) {
            function.apply(writer);
        }
    }
    synchronized void addDocument(String language, Document doc) throws CorruptIndexException, LockObtainFailedException, IOException {
        open(language);
        trackingWriters.get(language).addDocument(doc);
    }
    synchronized void open(String language) throws CorruptIndexException, LockObtainFailedException, IOException {
        language = normalize(language);
        if(!trackingWriters.containsKey(language)) {
            File indexDir = new File(indexContainingDir, language);
            open(indexDir);
        }
    }
    
    public synchronized void reset() throws IOException {
        close();

        FileUtils.deleteDirectory(indexContainingDir);
        indexContainingDir.mkdirs();
        dirs.clear();
        trackingWriters.clear();
        searchManagers.clear();
        init(indexContainingDir, luceneConfig);
    }
    public synchronized void close() throws IOException {
        List<Throwable> errors = new ArrayList<Throwable>(5);

        for (GeonetworkNRTManager manager: searchManagers.values()) {
            try {
                manager.close();
            } catch (Throwable e) {
                errors.add(e);
            }
        }
        for (TrackingIndexWriter writer: trackingWriters.values()) {
            try {
                writer.getIndexWriter().close(true);
            } catch (OutOfMemoryError e) {
                writer.getIndexWriter().close(true);
            } catch (Throwable e) {
                errors.add(e);
            }
        }
        for (NRTCachingDirectory dir: dirs.values()) {
            try {
                dir.close();
            } catch (Throwable e) {
                errors.add(e);
            }
        }
        
        if(!errors.isEmpty()) {
            for (Throwable throwable : errors) {
                Log.error(Geonet.LUCENE, "Failure while closing luceneIndexLanguageTracker", throwable);
            }
            throw new RuntimeException("There were errors while closing lucene indices");
        }
    }
    public synchronized void optimize() throws CorruptIndexException, IOException {
		// System.out.println("Optimizing the Lucene Index started...");
		if (optimizingLock.tryLock()) {
			System.out.println("Lock successfully");
			synchronized (MUTEX) {
				// System.out.println("** START SYNCHRONIZED optimize.");
				try {
					for (TrackingIndexWriter writer : trackingWriters.values()) {
						try {
							writer.getIndexWriter().forceMergeDeletes(true);
							writer.getIndexWriter().forceMerge(1, false);
						} catch (OutOfMemoryError e) {
							reset();
							throw new RuntimeException(e);
						}
					}
				} finally {
					optimizingLock.unlock();
					System.out.println("Unlock successfully");
				}
			}
		}
    }

    private class CommitTimerTask extends TimerTask {

        @Override
        public void run() {
            for (TrackingIndexWriter writer: trackingWriters.values()) {
                try {
                    try {
                        writer.getIndexWriter().commit();
                    } catch (Throwable e) {
                        Log.error(Geonet.LUCENE, "Error committing writer: "+writer, e);
                    }
                } catch (OutOfMemoryError e) {
                    try {
                        Log.error(Geonet.LUCENE, "OOM Error committing writer: "+writer, e);
                        reset();
                    } catch (IOException e1) {
                        Log.error(Geonet.LUCENE, "Error resetting lucene indices", e);
                    }
                    throw new RuntimeException(e);
                }
            }
        }
        
    }

    private class PurgeExpiredSearchersTask extends TimerTask {
        @Override
        public void run() {
            synchronized (LuceneIndexLanguageTracker.this) {
                Collection<GeonetworkNRTManager> values = searchManagers.values();
                for (GeonetworkNRTManager geonetworkNRTManager : values) {
                    geonetworkNRTManager.purgeExpiredSearchers(versionTracker);
                }
            }
            Log.info(Geonet.LUCENE, "Done running PurgeExpiredSearchersTask. " + versionTracker.size()
                    + " versions still cached.");

        }
    }

    public void update(String id, UpdateIndexFunction function) throws Exception {

        function.prepareForUpdate();
        Map<String, Document> originalDocs = new HashMap<String, Document>();

        final Term idTerm = new Term("_id", id);
        synchronized (this) {
            final TermQuery query = new TermQuery(idTerm);
            for (Map.Entry<String, GeonetworkNRTManager> e : searchManagers.entrySet()) {
                String language = e.getKey();
                GeonetworkNRTManager manager = e.getValue();
                AcquireResult result = manager.acquire(-1L, versionTracker);
                try {
                    IndexSearcher searcher = result.searcher;
                    TopFieldCollector results = TopFieldCollector.create(Sort.INDEXORDER, 2, true, false, false, false);
                    searcher.search(query, results);
                    TopDocs docs = results.topDocs();
                    if (docs.totalHits > 1) {
                        Log.error(Geonet.LUCENE, "The " + language
                                + " index has more than one document for the metadata with id: " + id);
                    } else if (docs.totalHits == 1) {
                        Document doc = searcher.doc(docs.scoreDocs[0].doc);
                        originalDocs.put(language, doc);
                    }

                } finally {
                    manager.release(result.searcher);
                }
            }
            HashMap<String, Document> updatedDocs = new HashMap<String, Document>();
            for (Entry<String, Document> entry : originalDocs.entrySet()) {
                Document updated = function.update(entry.getKey(), entry.getValue());
                if (updated != null) {
                    updatedDocs.put(entry.getKey(), updated);
                }
            }

            for (Entry<String, Document> entry : updatedDocs.entrySet()) {
                String lang = entry.getKey();
                Document doc = entry.getValue();

                if (doc != null) {
                    TrackingIndexWriter writer = this.trackingWriters.get(lang);
                    if (writer == null) {
                        throw new IllegalStateException("Error updating document with id: " + id
                                + ". The document was loaded for language: " + lang
                                + " but there was no writer for writing the doc");
                    }
                    Log.debug(Geonet.LUCENE, "Updating lucene document for "+lang+" index. Update strategy is: "+function);
                    writer.updateDocument(idTerm, doc);
                }
            }
        }
    }

}
