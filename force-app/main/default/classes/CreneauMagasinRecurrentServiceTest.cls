@isTest
public class CreneauMagasinRecurrentServiceTest {

    @isTest
    private static void testFindMagasin() {
        CreneauMagasinRecurrentService.findMagasinRecords('magasinName');
    }
    
    @isTest
    private static void testGetMagasinServices() {
        MagasinTriggerHandler.bypassTrigger=true;
        Magasin__c  magasinRec =TestDataFactory.createGenericMagasin('magasinName');
        Insert magasinRec;

        Test.startTest();
        String str = CreneauMagasinRecurrentService.getMagasinServices(magasinRec.Id);
        Test.stopTest();
        System.assertEquals('autres', str, 'Service disponible is not equals to autres');
    }

    @isTest
    private static void testGetMagasinServicesKO() {
      
        Test.startTest();
        String str = CreneauMagasinRecurrentService.getMagasinServices('');
        Test.stopTest();
        System.assertEquals(null, str, 'Service disponible is not equals to autres');
    }
}