@IsTest
public class Einvoice_ServiceManager_Test {

    @IsTest
    private static void test() {

        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        Insert magasinRec;
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        Insert accTest;
       
        Facture__c facture = TestDataFactory.createFactureRecord(accTest.Id);
        facture.invoiceCheck__c ='0001111';
        facture.TECH_FluxOneInFac11__c = true;
        facture.ExternalId_Facture__c = 'PMC202300000000';
        facture.Numero_externe_facture_de_vente__c ='220322';
        facture.Date_de_facture__c = DateTime.newInstance(2023, 12, 31, 0, 0, 0);
        insert facture;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new Einvoice_CalloutMock_TST());  
            
            PageReference testPage = Page.FacturePDF; 
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('Id', String.valueOf(facture.Id));
            ApexPages.StandardController stdController = new  ApexPages.StandardController(facture);  
            Einvoice_ServiceManager einvoiceSM =  new Einvoice_ServiceManager(stdController);
           
            Einvoice_ServiceManager.getInfoFacture(facture.Id);
            Einvoice_ServiceManager.calloutApiEinvoice(facture.invoiceCheck__c,  facture.ExternalId_Facture__c );
      
        Test.stopTest();

        System.assertEquals(facture.id, stdController.getId(), 'factureId '+facture.id +'isn\'t equals '+stdController.getId());
      }
    
      public class Einvoice_CalloutMock_TST implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/pdf');  
            response.setStatusCode(200);
            return response; 
        }
    }

}