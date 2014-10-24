INSERT INTO Settings VALUES (956,1,'clustering',NULL);
INSERT INTO Settings VALUES (957,956,'enable','false');
INSERT INTO Settings VALUES (958,956,'jmsurl','failover://tcp://localhost:61616');
UPDATE Settings SET value='2.8.1' WHERE name='version';
UPDATE Settings SET value='SNAPSHOT' WHERE name='subVersion';
