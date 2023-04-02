/**
* @author       jan.straka@bluewolf
* @date         2021-07-12
* @description  Tests for MP_StatusNotificationREST
**/
@IsTest 
private class MP_StatusNotificationRESTTest {

    @IsTest
    private static void testIncomingStatusNotification_uuidNotFound() {
        String jsonBody = '{ "uuid": null }';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/mpPreauthorizeCallback';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        MP_StatusNotificationREST.incomingStatusNotification();
        Test.stopTest();

        RestResponse response = RestContext.response;
        System.assertEquals('Uuid is required', response.responseBody.toString(), 'Bad status code of REST response');
        System.assertEquals(500, response.statusCode, 'Bad status code of REST response');
    }

    @IsTest
    private static void testIncomingStatusNotification_orderNotFound() {
        String jsonBody = '{ "uuid": "123" }';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/mpPreauthorizeCallback';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        MP_StatusNotificationREST.incomingStatusNotification();
        Test.stopTest();

        RestResponse response = RestContext.response;
        System.assertEquals('Cannot identify order with Uuid = 123', response.responseBody.toString(), 'Bad status code of REST response');
        System.assertEquals(500, response.statusCode, 'Bad status code of REST response');
    }

    @IsTest
    private static void testIncomingStatusNotification_responseSuccess() {
      Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        Insert magasinRec;
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        Insert accTest;
        Order testOrder = TestDataFactory.createGenericOrderRecord(accTest.Id);
        Insert testOrder;

        String jsonBody = '{ "uuid": "123", "result": "OK" }';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/mpPreauthorizeCallback';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        MP_StatusNotificationREST.incomingStatusNotification();
        Test.stopTest();

        RestResponse response = RestContext.response;
        System.assertEquals('OK', response.responseBody.toString(), 'Bad status code of REST response');
        System.assertEquals(200, response.statusCode, 'Bad status code of REST response');

        Order resultOrder = [SELECT Preauthorize_Callback_Response__c, Preauthorize_Status__c FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals('Preauthorized - Success', resultOrder.Preauthorize_Status__c, 'Bad preauthorize status of processed order');
        System.assertEquals(jsonBody, resultOrder.Preauthorize_Callback_Response__c, 'Bad preauthorize callback response of processed order');
    }

    @IsTest
    private static void testIncomingStatusNotification_responseFailure() {
         Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        magasinRec.Pourcentage_additionel_carte__c = 20;
        Insert magasinRec;
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        Insert accTest;
        Order testOrder = TestDataFactory.createGenericOrderRecord(accTest.Id);
        Insert testOrder;

        String jsonBody = '{ "uuid": "123", "result": "INVALID" }';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/mpPreauthorizeCallback';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        MP_StatusNotificationREST.incomingStatusNotification();
        Test.stopTest();

        RestResponse response = RestContext.response;
        System.assertEquals('OK', response.responseBody.toString(), 'Bad status code of REST response');
        System.assertEquals(200, response.statusCode, 'Bad status code of REST response');

        Order resultOrder = [SELECT Preauthorize_Callback_Response__c, Preauthorize_Status__c FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals('Preauthorized - Error', resultOrder.Preauthorize_Status__c, 'Bad preauthorize status of processed order');
        System.assertEquals(jsonBody, resultOrder.Preauthorize_Callback_Response__c, 'Bad preauthorize callback response of processed order');
    }
}