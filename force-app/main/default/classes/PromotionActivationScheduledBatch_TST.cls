@isTest class PromotionActivationScheduledBatch_TST {
    @IsTest
    static void testBatch(){
        Test.startTest();
        new PromotionActivationScheduledBatchable().execute(null);
        Test.stopTest();
    }
}