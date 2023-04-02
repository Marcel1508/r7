/**
* @author : Maud Vasseur - IBM Lille
* @date : 04/2021
* @description : Class to schedule the PromotionActivationBatch 
* @TestClass : PromotionActivationScheduledBatch_TST
**/
public without sharing class PromotionActivationScheduledBatchable implements Schedulable {
    public void execute(SchedulableContext sc) {
		PromotionActivationBatch classBatch = new PromotionActivationBatch();
        Database.executeBatch(classBatch);
    }
}