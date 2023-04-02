public without sharing class BatchLVHOPromoScheduled implements Schedulable {
    public void execute(SchedulableContext sc) {
		BatchLVHOPromo classBatch = new BatchLVHOPromo();
        Database.executeBatch(classBatch,2000);
    }
}