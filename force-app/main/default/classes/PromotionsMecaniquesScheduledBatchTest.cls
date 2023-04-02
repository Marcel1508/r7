@isTest public class PromotionsMecaniquesScheduledBatchTest {
    @IsTest
    static void testBatch(){
        Test.startTest();
        new PromotionsMecaniquesScheduledBatchable().execute(null);
        Test.stopTest();
    }

}