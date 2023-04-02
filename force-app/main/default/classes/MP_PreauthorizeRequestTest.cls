/**
* @author       jan.straka@bluewolf
* @date         2021-07-12
* @description  Tests for MP_PreauthorizeRequest
**/
@IsTest 
private class MP_PreauthorizeRequestTest {
    
    @IsTest
    private static void testGetRequestBodyString() {
        
        MarketPay_Setting__mdt testMpSetting = (MarketPay_Setting__mdt)
            new SObjectBuilder(MarketPay_Setting__mdt.SObjectType)
            .put(MarketPay_Setting__mdt.staticResourceSuccessName__c, 'SUCCESS_RESOURCE')
            .put(MarketPay_Setting__mdt.staticResourceErrorName__c, 'ERROR_RESOURCE')
            .put(MarketPay_Setting__mdt.preauthorizeCallbackUrl__c, 'CALLBACK_URL')
            .build().getRecord();
        
        Magasin__c  testMagasin = TestDataFactory.createGenericMagasin('magasinTest');
        Insert testMagasin;
        
        User testUser = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account accTest = TestDataFactory.createGenericAccountRecord('TEST ACCOUNT','Lead',testMagasin);
        Insert accTest;
        Contact testContact = TestDataFactory.createContactRecord(accTest.Id);
        testContact.lastName = 'USER';
        Insert testContact;
        
        Order testOrder = TestDataFactory.createOrderRecord(accTest.Id);
        Insert testOrder;
        
        testOrder = [
            SELECT Id, OrderNumber, Preauthorize_Uuid__c, CurrencyIsoCode, GrandTotalAmount, Description, BillingAddress, ShippingAddress, Account.Name
            FROM Order WHERE Id = :testOrder.Id];
        
        Test.startTest();
        String result = MP_PreauthorizeRequest.getRequestBodyString(testOrder, testContact, testUser, testMagasin, testMpSetting);
        Test.stopTest();
        
        String expectedJson = 
            '{"currency":"EUR",' +
            '"successUrl":null,' +
            '"merchantTransactionId":"' + MP_PreauthorizeRequest.timeNOW + '_' + testOrder.Id + '",' +
            '"merchantMetaData":" ",' +
            '"language":"en_US",' +
            '"errorUrl":null,' +
            '"description":"' + testOrder.OrderNumber +'",'+
            '"customerProfileData":{' +
            '"customerIdentification":"' + testContact.Id + '"' +
            '},' +
            '"customer":{' +
            '"shippingPostcode":"ShipZipCode",' +
            // '"shippingPhone":"001122334455",' +
            '"shippingLastName":"USER",' +
            '"shippingFirstName":"TEST",' +
            '"shippingCountry":"FR",' +
            '"shippingCompany":"TEST ACCOUNT",' +
            '"shippingCity":"ShipCity",' +
            '"shippingAddress1":"ShipStreet",' +
            '"lastName":"USER",' +
            '"identification":"' + testContact.Id + '",' +
            // '"gender":"M",' +
            '"firstName":"TEST",' +
            '"email":"test@carrefour.com",' +
            '"company":"TEST ACCOUNT",' +
            '"billingPostcode":"BillZipCode",' +
            // '"billingPhone":"001122334455",' +
            '"billingCountry":"FR",' +
            '"billingCity":"BillCity",' +
            '"billingAddress1":"BillStreet"' +
            '},' +
            '"callbackUrl":"CALLBACK_URL",' +
            '"amount":"0.00"}';
        
        System.assertEquals(expectedJson, result, 'Bad request');
    }
}