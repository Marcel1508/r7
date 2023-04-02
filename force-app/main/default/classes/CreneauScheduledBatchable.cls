public without sharing class CreneauScheduledBatchable implements Schedulable {
    public void execute(SchedulableContext sc) {
        //batchable b = new batchable(); database.executebatch(b);
        Database.executeBatch(new GenerateSlotsBatch(Date.today()), 1000);
    }
}