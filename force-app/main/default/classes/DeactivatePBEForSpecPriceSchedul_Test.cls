@isTest
public class DeactivatePBEForSpecPriceSchedul_Test {
    @isTest
    public static void testSchedulUpdatePriceBook(){
        
        Test.startTest();
 
        String jobId = System.schedule('ScheduledApexTest',
            '0 0 23 * * ?',
            new DeactivatePBEForSpecificPriceSchedulable());
        
        Test.stopTest();
    }
}