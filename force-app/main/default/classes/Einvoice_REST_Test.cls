@IsTest
public class Einvoice_REST_Test {

    @testSetup 
    static void setup() {

        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        magasinRec.Code_etablissement__c = '2051';
        insert magasinRec;

        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        accTest.Numero_Client__c = '000111';
        insert accTest;
       
        Facture__c facture = TestDataFactory.createFactureRecord(accTest.Id);
        facture.invoiceCheck__c ='01987623';
        facture.ExternalId_Facture__c = 'PMC202300000000';
        facture.Numero_externe_facture_de_vente__c ='220322';
        facture.Magasin__c = magasinRec.Id; 
        facture.Code_carte_client__c = accTest.Id ;
        facture.Date_de_facture__c = DateTime.newInstance(2023, 12, 31, 0, 0, 0);
        insert facture;
      
    }

    @IsTest
    private static void webServiceTestKO1() {
        String jsonBody = '{ "invoiceID": "PMC0111" , "invoiceCheck":"01987623" , "invoiceNumber" : "10987", "codeMagasin":"2051", "numeroClient":"" }';
     
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/api/einvoice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;

        RestContext.response = new RestResponse();
        RestResponse response = RestContext.response;

        Test.startTest();
        Einvoice_REST.webServiceEinvoice();
        Test.stopTest();

        String expectedJson = '[{"success":false,"message":"Veuillez renseigner le numéro client"}]';
        System.assertEquals(expectedJson, response.responseBody.toString(), 'Bad message of REST response');
        System.assertEquals(200, response.statusCode, 'Bad status code of REST response');
    }

    @IsTest
    private static void webServiceTestKO2() {

        Facture__c fac = [Select ID , TECH_FluxOneInFac11__c FROM Facture__c WHERE ExternalId_Facture__c = 'PMC202300000000'];
        fac.TECH_FluxOneInFac11__c = true;
        update fac;

        String jsonBody = '{ "invoiceID": "PMC202300000000" , "invoiceCheck":"01987623" , "invoiceNumber" : "220322", "codeMagasin":"2051", "numeroClient":"000111" }';
     
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/api/einvoice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;
        
        RestContext.response = new RestResponse();
        RestResponse response = RestContext.response;

        Test.startTest();
        Einvoice_REST.webServiceEinvoice();
        Test.stopTest();

        String expectedJson = '[{"success":false,"message":"Doublon : flux déjà reçu"}]';
        System.assertEquals(expectedJson, response.responseBody.toString(), 'Bad message of REST response');
        System.assertEquals(200, response.statusCode, 'Bad status code of REST response');
    }

    @IsTest
    private static void webServiceTestKO3() {

        //the codeMagasin doesn't exist
        String jsonBody = '{ "invoiceID": "PMC202300000000" , "invoiceCheck":"01987623" , "invoiceNumber" : "220322", "codeMagasin":"1", "numeroClient":"000111" }';
     
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/api/einvoice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;
        
        RestContext.response = new RestResponse();
        RestResponse response = RestContext.response;

        Test.startTest();
        Einvoice_REST.webServiceEinvoice();
        Test.stopTest();

        System.assert(response.responseBody.toString().contains('Upsert failed. First exception on row 0; first error: INVALID_FIELD, Foreign key external ID'), 'Bad message of REST response');
        System.assertEquals(200, response.statusCode, 'Bad status code of REST response');
    }


    @IsTest
    private static void webServiceTestOK() {
        String jsonBody = '{ "invoiceID": "PMC202300000000" , "invoiceCheck":"01987623" , "invoiceNumber" : "220322", "codeMagasin":"2051", "numeroClient":"000111" }';
     
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/api/einvoice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;

        RestContext.response = new RestResponse();
        RestResponse response = RestContext.response;

        Test.startTest();
        Einvoice_REST.webServiceEinvoice();
        Test.stopTest();

        String expectedJson = '[{"success":true,"message":"OK"}]';
        System.assertEquals(expectedJson, response.responseBody.toString(), 'Bad message of REST response');
        System.assertEquals(200, response.statusCode, 'Bad status code of REST response');
    }

}