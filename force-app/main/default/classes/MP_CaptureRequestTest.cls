/**
* @author       jan.straka@bluewolf
* @date         2021-07-12
* @description  Tests for MP_CaptureRequest
**/
@IsTest 
private class MP_CaptureRequestTest {

    @IsTest
    private static void testGetRequestBodyString() {
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        Insert magasinRec;
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        Insert accTest;
        Id pricebookId = Test.getStandardPricebookId();
        Order testOrder = TestDataFactory.createOrder(pricebookId);
        testOrder.Preauthorize_Uuid__c = '123';
        testOrder.CurrencyIsoCode= 'EUR';
        Insert testOrder;
        
        testOrder = [SELECT Id, OrderNumber, Preauthorize_Uuid__c, CurrencyIsoCode FROM Order WHERE Id = :testOrder.Id];

       Facture__c testFacture = TestDataFactory.createFactureRecord(accTest.Id);

        Test.startTest();
            String result = MP_CaptureRequest.getRequestBodyString(testOrder, testFacture, 25);
        Test.stopTest();

        String expectedJson = 
            '{"currency":"EUR",' +
            '"referenceUuid":"123",' +
            '"merchantTransactionId":"' + MP_CaptureRequest.TimeNOW + '_' + testOrder.Id + '_25",' +
            '"merchantMetaData":" ",' +
            '"description":"' + testOrder.OrderNumber +'",'+
            '"amount":"1000"}';

        System.assertEquals(expectedJson, result, 'Bad request');
    }
}