public without sharing class BatchToDeleteRecordsObjectScheduled implements Schedulable {
    public void execute(SchedulableContext sc) {
    BatchToDeleteRecordsObject classBatch = new BatchToDeleteRecordsObject();
        Database.executeBatch(classBatch,2000);
    }
}