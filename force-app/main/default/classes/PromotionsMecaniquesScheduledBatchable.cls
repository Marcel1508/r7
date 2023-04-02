public without sharing class PromotionsMecaniquesScheduledBatchable implements Schedulable {
    public void execute(SchedulableContext sc) {
		PromotionsMecaniquesBatch classBatch = new PromotionsMecaniquesBatch();
        Database.executeBatch(classBatch);
    }
}