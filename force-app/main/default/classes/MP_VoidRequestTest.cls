/**
* @author       jan.straka@bluewolf
* @date         2021-07-12
* @description  Tests for MP_VoidRequest
**/
@IsTest 
private class MP_VoidRequestTest {
    
    @IsTest
    private static void testGetRequestBodyString() {
       Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;

        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert accTest;
        Order testOrder = TestDataFactory.createOrderRecord(accTest.Id);

        Test.startTest();
            String result = MP_VoidRequest.getRequestBodyString(testOrder);
        Test.stopTest();

        String expectedJson = 
            '{"referenceUuid":"123",' +
            '"merchantTransactionId":"' + MP_VoidRequest.timeNOW + '_' + testOrder.Id + '"}';

        System.assertEquals(expectedJson, result, 'Bad request');
    }
}