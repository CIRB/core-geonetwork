package org.fao.geonet.kernel.search.index;

import java.io.IOException;

import jeeves.utils.Log;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.NRTManager.TrackingIndexWriter;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.UpdateIndexFunction;

public class LuceneIndexWriterFactory {

    private LuceneIndexLanguageTracker tracker;

    public LuceneIndexWriterFactory( LuceneIndexLanguageTracker tracker ) {
        this.tracker = tracker;
    }
    public void addDocument( String locale, Document doc ) throws Exception {
        if(Log.isDebugEnabled(Geonet.INDEX_ENGINE)) {
            Log.debug(Geonet.INDEX_ENGINE, "Adding document to "+locale+" index");
        }
        tracker.addDocument(locale, doc);
    }

    public void deleteDocuments( final Term term ) throws Exception {
        if(Log.isDebugEnabled(Geonet.INDEX_ENGINE)) {
            Log.debug(Geonet.INDEX_ENGINE, "deleting term '"+term+"' from index");
        }
        tracker.withWriter(new Function() {
            @Override
            public void apply(TrackingIndexWriter input) throws CorruptIndexException, IOException {
            		synchronized(input) {
                        input.deleteDocuments(term);
//                      input.getIndexWriter().commit();
//                      input.getIndexWriter().getReader().reopen();
            		}
            }
        });
    }

    public void createDefaultLocale() throws IOException {
        tracker.open(Geonet.DEFAULT_LANGUAGE);
    }

    public void update(String id, UpdateIndexFunction function) throws Exception {
        tracker.update(id, function);
    }
}