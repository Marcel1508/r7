@isTest class PromotionDeactivationScheduledBatch_TST {
    @IsTest
    static void testBatch(){
        Test.startTest();
        new PromotionDeactivationScheduledBatch().execute(null);
        Test.stopTest();
    }
}