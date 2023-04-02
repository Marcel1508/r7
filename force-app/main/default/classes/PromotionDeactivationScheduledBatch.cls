/**
* @author : Maud Vasseur - IBM Lille
* @date : 04/2021
* @description : Class to schedule the PromotionDeactivationBatch 
* @TestClass : PromotionDeactivationScheduledBatch_TST
**/
public without sharing class PromotionDeactivationScheduledBatch implements Schedulable {
    public void execute(SchedulableContext sc) {
		PromotionDeactivationBatch classBatch = new PromotionDeactivationBatch();
        Database.executeBatch(classBatch);
    }
}