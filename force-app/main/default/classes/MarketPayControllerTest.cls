/**
* @author       jan.straka@bluewolf
* @date         2021-07-02
* @description  Test class for MarketPay component controller
**/

@IsTest
private class MarketPayControllerTest {
    
    @IsTest 
    private static void testPreauthorizeSuccess() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
 		User usr = [Select Id,UserRoleId from User where UserRoleId=:portalRole.Id Limit 1];

        System.runAs(usr){
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .put(Magasin__c.Pourcentage_additionel_carte__c, 5.5)
                .put(Magasin__c.API_Key__c, 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq')
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
                .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();
        Contact testContact = (Contact)
            new SObjectBuilder(Contact.SObjectType)
                .put(Contact.AccountId, testAccount.Id)
                .put(Contact.Roles__c, 'Autre')
                .create().getRecord();
        
        
        Profile customerCommunityPlus = [SELECT Id FROM Profile WHERE Name = 'Customer Community +'];
        User customer = (User)
            new SObjectBuilder(User.SObjectType)
            .put(User.ProfileId, customerCommunityPlus.Id)
            .put(User.FirstName, 'The')
            .put(User.LastName, 'Customer')
            .put(User.UserName, 'theCustomer@carrefour.com')
            .put(User.ContactId, testContact.Id)
            .create().getRecord();
        
        Order testOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.Magasin_actif__c, testMagasin.Id)
                .put(Order.AccountId, testAccount.Id)
                .create().getRecord();
    
        MP_PreauthorizeResponse result;
        System.runAs(customer) {
            Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, 'preauthorize'));
            Test.startTest();
                result = MarketPayController.preauthorize(testOrder.Id);
            Test.stopTest();
        
        }
        
        System.assertNotEquals(null, result.body, 'Body of Preauthorize API should be populated');
        System.assertNotEquals(null, result.uuid, 'Uuid of Preauthorize API should be populated');
        System.assertNotEquals(FALSE, result.success, 'Bad success state of Preauthorize API should be populated');

        Order resultOrder = [SELECT Preauthorize_Response__c, Preauthorize_Uuid__c, Preauthorize_Status__c FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals(result.body, resultOrder.Preauthorize_Response__c, 'Bad Preauthorize response of processed order');
        System.assertEquals(result.uuid, resultOrder.Preauthorize_Uuid__c, 'Bad Preauthorize uuid of processed order');
        System.assertEquals(MarketPayController.PREAUTHORIZED_AWAITING_CALLBACK, resultOrder.Preauthorize_Status__c, 'Bad Preauthorize status of processed order');
    }
    }
    @IsTest 
    private static void testPreauthorizeInStockOrderNotFound() {
        Exception caughtException;

        Test.startTest();
        try {
            MarketPayController.preauthorize(null);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('In-stock order Id is not defined', caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of caught exception');
    }

    @IsTest 
    private static void testPreauthorizeMagasinNotFound() {

       OrderTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .put(Magasin__c.Pourcentage_additionel_carte__c, 5.5)
                .put(Magasin__c.API_Key__c, 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq')
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
                .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();

        Order testOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.Magasin_actif__c, null)
                .put(Order.AccountId, testAccount.Id)
                .create().getRecord(); 
                
        Exception caughtException;

        Test.startTest();
        try {
            MarketPayController.preauthorize(testOrder.Id);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('Magasin was not found [Order ID: ' + testOrder.Id + ', Magasin ID: null]', caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of caught exception');
    }

    @IsTest 
    private static void testPreauthorizeContactNotFound() {
       
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .put(Magasin__c.Pourcentage_additionel_carte__c, 5.5)
                .put(Magasin__c.API_Key__c, 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq')
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
              //  .put(Account.Magasin_actif__c, testMagasin.Id)
                .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();

        Order testOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.Magasin_actif__c, testMagasin.Id)
                .put(Order.AccountId, testAccount.Id)
                .create().getRecord(); 
        Exception caughtException;

        Test.startTest();
        try {
            MarketPayController.preauthorize(testOrder.Id);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('Contact was not found [Order ID: ' + testOrder.Id + ', Contact Id: null]', caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of caught exception');
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        private String callType;
        
        public HttpCalloutMockImpl(Integer statusCode, String callType) {
            this.statusCode = statusCode;
            this.body = body;
            this.callType = callType;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            switch on this.callType {
                when 'preauthorize' {
                    this.body = '{"success": true, "uuid": 10}';
                }
                when else {
                    this.body ='';
                          }
            }
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}