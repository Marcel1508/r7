@isTest
public class CreneauScheduledBatchableTest {
    @isTest
    private static void test() {
        Test.startTest();
        CreneauScheduledBatchable abs= new CreneauScheduledBatchable();
        String sch = '0 0 5 1/1 * ? *';
        String jobId = System.schedule('jobName', sch, abs);
        abs.execute(null);
        Test.stopTest();
    }
}