/**
* @author       jan.straka@bluewolf
* @date         2021-07-09
* @description  Test class for Batch apex for MarketPay capture API callout
**/
@IsTest 
private class MP_CaptureCalloutBatchTest {
    
    @IsTest 
    private static void testBatch_magasinNotFound() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c  testMagasin = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'Test Magasin')
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
            .create ()
            .getRecord(); 
        
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
            .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            .create ()
            .getRecord();
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.Magasin_actif__c, null)
            .put(Order.AccountId, testAccount.Id)
            .count(10).create().getRecords();
        
        Set<Id> orderIds = Pluck.ids(orders);
        
        Test.startTest();
        Id batchId = Database.executeBatch(new MP_CaptureCalloutBatch(orderIds));
        Test.stopTest();
        
        List<Order> resultOrders = [
            SELECT 
            Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c,
            Capture_Response_Attempt_1__c, Capture_Response_Attempt_2__c, Capture_Response_Attempt_3__c, Capture_Uuid_Attempt_1__c, Capture_Uuid_Attempt_2__c, Capture_Uuid_Attempt_3__c, Capture_Status__c,
            Delta_Void_Response__c, Delta_Void_Uuid__c, Delta_Void_Status__c
            FROM Order 
            WHERE Id IN :orderIds];
        
        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(null, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('Magasin was not found [Order ID: ' + orders[5].Id + ', Magasin ID: null]', resultOrders[5].Capture_Response_Attempt_1__c, 'Bad capture response - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_1__c, 'Bad capture uuid - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_2__c, 'Bad capture response - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_2__c, 'Bad capture uuid - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_3__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_3__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Not Captured yet', resultOrders[5].Capture_Status__c, 'Bad void status of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Response__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Uuid__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Delta Not Voided yet', resultOrders[5].Delta_Void_Status__c, 'Bad void status of processed order');
    }
    
    @IsTest
    private static void testBatch_facturesNotFound() {
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c  testMagasin = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'Test Magasin')
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
            .create ()
            .getRecord(); 
        
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
            .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            .create ()
            .getRecord();
        
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.Magasin_actif__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
            .put(Order.AccountId, testAccount.Id)
            .count(10).create().getRecords();
        
        Set<Id> orderIds = Pluck.ids(orders);
        
        Test.startTest();
        Id batchId = Database.executeBatch(new MP_CaptureCalloutBatch(orderIds));
        Test.stopTest();
        
        List<Order> resultOrders = [
            SELECT 
            Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c,
            Capture_Response_Attempt_1__c, Capture_Response_Attempt_2__c, Capture_Response_Attempt_3__c, Capture_Uuid_Attempt_1__c, Capture_Uuid_Attempt_2__c, Capture_Uuid_Attempt_3__c, Capture_Status__c,
            Delta_Void_Response__c, Delta_Void_Uuid__c, Delta_Void_Status__c
            FROM Order 
            WHERE Id IN :orderIds];
        
        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('Invalid count of related Facture records.\nExpected: 1, Actual: 0\nFactures: null', resultOrders[5].Capture_Response_Attempt_1__c, 'Bad capture response - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_1__c, 'Bad capture uuid - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_2__c, 'Bad capture response - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_2__c, 'Bad capture uuid - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_3__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_3__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Not Captured yet', resultOrders[5].Capture_Status__c, 'Bad void status of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Response__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Uuid__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Delta Not Voided yet', resultOrders[5].Delta_Void_Status__c, 'Bad void status of processed order');
    }
    
    @IsTest
    private static void testBatch_captured_deltaVoided() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200));
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
            .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
            .create().getRecord();
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasin.Id)
            .put(Account.Magasin_actif_en_cours__c, magasin.Id)
            .create ()
            .getRecord();
        
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.Magasin_actif__c, magasin.Id)
            .put(Order.AccountId, testAccount.Id)	
            .count(10).create().getRecords();
        
        Set<Id> orderIds = Pluck.ids(orders);
        
        List<Facture__c> factures = (List<Facture__c>)
            new SObjectBuilder(Facture__c.SObjectType)
            .put(Facture__c.Commande__c, new SObjectFieldProviders.ListProvider(new List<Id>(orderIds)))
            .put(Facture__c.Montant_TTC_de_la_facture__c, -1)
            .put(Facture__c.Magasin__c, magasin.Id) 
            .put(Facture__c.Code_carte_client__c, testAccount.Id)
            .count(10).create().getRecords();
        
        Test.startTest();
        Id batchId = Database.executeBatch(new MP_CaptureCalloutBatch(orderIds));
        Test.stopTest();
        
        List<Order> resultOrders = [
            SELECT 
            Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c,
            Capture_Response_Attempt_1__c, Capture_Response_Attempt_2__c, Capture_Response_Attempt_3__c, Capture_Uuid_Attempt_1__c, Capture_Uuid_Attempt_2__c, Capture_Uuid_Attempt_3__c, Capture_Status__c,
            Delta_Void_Response__c, Delta_Void_Uuid__c, Delta_Void_Status__c
            FROM Order 
            WHERE Id IN :orderIds];
        
        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('{"success": true, "body": "Order captured", "uuid": "123"}', resultOrders[5].Capture_Response_Attempt_1__c, 'Bad capture response - attempt 1 of processed order');
        System.assertEquals('123', resultOrders[5].Capture_Uuid_Attempt_1__c, 'Bad capture uuid - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_2__c, 'Bad capture response - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_2__c, 'Bad capture uuid - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_3__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_3__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Captured - Success', resultOrders[5].Capture_Status__c, 'Bad void status of processed order');
        System.assertEquals('{"success": true, "body": "Order captured", "uuid": "123"}', resultOrders[5].Delta_Void_Response__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals('123', resultOrders[5].Delta_Void_Uuid__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Delta Void - Success', resultOrders[5].Delta_Void_Status__c, 'Bad void status of processed order');
    }
    
    @IsTest
    private static void testBatch_captured_deltaNotVoided() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200));
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
            .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
            .create().getRecord();
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasin.Id)
            .put(Account.Magasin_actif_en_cours__c, magasin.Id)
            .create ()
            .getRecord();
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.Magasin_actif__c, magasin.Id)
            .put(Order.AccountId, testAccount.Id)	
            .count(10).create().getRecords();
        
        Set<Id> orderIds = Pluck.ids(orders);
        
        List<Facture__c> factures = (List<Facture__c>)
            new SObjectBuilder(Facture__c.SObjectType)
            .put(Facture__c.Commande__c, new SObjectFieldProviders.ListProvider(new List<Id>(orderIds)))
            .put(Facture__c.Magasin__c, magasin.Id)
            .put(Facture__c.Montant_TTC_de_la_facture__c, 1000)
            .put(Facture__c.Code_carte_client__c, testAccount.Id)
            .count(10).create().getRecords();
        
        Test.startTest();
        Id batchId = Database.executeBatch(new MP_CaptureCalloutBatch(orderIds));
        Test.stopTest();
        
        List<Order> resultOrders = [
            SELECT 
            Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c,
            Capture_Response_Attempt_1__c, Capture_Response_Attempt_2__c, Capture_Response_Attempt_3__c, Capture_Uuid_Attempt_1__c, Capture_Uuid_Attempt_2__c, Capture_Uuid_Attempt_3__c, Capture_Status__c,
            Delta_Void_Response__c, Delta_Void_Uuid__c, Delta_Void_Status__c
            FROM Order 
            WHERE Id IN :orderIds];
        
        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('{"success": true, "body": "Order captured", "uuid": "123"}', resultOrders[5].Capture_Response_Attempt_1__c, 'Bad capture response - attempt 1 of processed order');
        System.assertEquals('123', resultOrders[5].Capture_Uuid_Attempt_1__c, 'Bad capture uuid - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_2__c, 'Bad capture response - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_2__c, 'Bad capture uuid - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_3__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_3__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Captured - Success', resultOrders[5].Capture_Status__c, 'Bad void status of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Response__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Uuid__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Delta Not Voided yet', resultOrders[5].Delta_Void_Status__c, 'Bad void status of processed order');
    }
    
    @IsTest
    private static void testBatch_notCaptured() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(201));
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
            .create().getRecord();
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasin.Id)
            .put(Account.Magasin_actif_en_cours__c, magasin.Id)
            .create ()
            .getRecord();
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.Magasin_actif__c, magasin.Id)
            .put(Order.AccountId, testAccount.Id)	
            .count(10).create().getRecords();
        
        Set<Id> orderIds = Pluck.ids(orders);
        
        List<Facture__c> factures = (List<Facture__c>)
            new SObjectBuilder(Facture__c.SObjectType)
            .put(Facture__c.Commande__c, new SObjectFieldProviders.ListProvider(new List<Id>(orderIds)))
            .put(Facture__c.Magasin__c, magasin.Id)
            .put(Facture__c.Code_carte_client__c, testAccount.Id)
            .count(10).create().getRecords();
        
        Test.startTest();
        Id batchId = Database.executeBatch(new MP_CaptureCalloutBatch(orderIds));
        Test.stopTest();
        
        List<Order> resultOrders = [
            SELECT 
            Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c,
            Capture_Response_Attempt_1__c, Capture_Response_Attempt_2__c, Capture_Response_Attempt_3__c, Capture_Uuid_Attempt_1__c, Capture_Uuid_Attempt_2__c, Capture_Uuid_Attempt_3__c, Capture_Status__c,
            Delta_Void_Response__c, Delta_Void_Uuid__c, Delta_Void_Status__c
            FROM Order 
            WHERE Id IN :orderIds];
        
        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('{"success": false, "body": "Capture failed", "uuid": null}', resultOrders[5].Capture_Response_Attempt_1__c, 'Bad capture response - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_1__c, 'Bad capture uuid - attempt 1 of processed order');
        System.assertEquals('{"success": false, "body": "Capture failed", "uuid": null}', resultOrders[5].Capture_Response_Attempt_2__c, 'Bad capture response - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_2__c, 'Bad capture uuid - attempt 2 of processed order');
        System.assertEquals('{"success": false, "body": "Capture failed", "uuid": null}', resultOrders[5].Capture_Response_Attempt_3__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_3__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Captured - Error', resultOrders[5].Capture_Status__c, 'Bad void status of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Response__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Uuid__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Delta Not Voided yet', resultOrders[5].Delta_Void_Status__c, 'Bad void status of processed order');
    }
    
    @IsTest
    private static void testBatch_captureException() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(400));
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
            .create().getRecord();
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasin.Id)
            .put(Account.Magasin_actif_en_cours__c, magasin.Id)
            .create ()
            .getRecord();
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.Magasin_actif__c, magasin.Id)
            .put(Order.AccountId, testAccount.Id)	
            .count(10).create().getRecords();
        
        Set<Id> orderIds = Pluck.ids(orders);
        
        List<Facture__c> factures = (List<Facture__c>)
            new SObjectBuilder(Facture__c.SObjectType)
            .put(Facture__c.Commande__c, new SObjectFieldProviders.ListProvider(new List<Id>(orderIds)))
            .put(Facture__c.Magasin__c, magasin.Id)
            .put(Facture__c.Code_carte_client__c, testAccount.Id)
            .count(10).create().getRecords();
        
        Test.startTest();
        Id batchId = Database.executeBatch(new MP_CaptureCalloutBatch(orderIds));
        Test.stopTest();
        
        List<Order> resultOrders = [
            SELECT 
            Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c,
            Capture_Response_Attempt_1__c, Capture_Response_Attempt_2__c, Capture_Response_Attempt_3__c, Capture_Uuid_Attempt_1__c, Capture_Uuid_Attempt_2__c, Capture_Uuid_Attempt_3__c, Capture_Status__c,
            Delta_Void_Response__c, Delta_Void_Uuid__c, Delta_Void_Status__c
            FROM Order 
            WHERE Id IN :orderIds];
        
        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('Exception during capture', resultOrders[5].Capture_Response_Attempt_1__c, 'Bad capture response - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_1__c, 'Bad capture uuid - attempt 1 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_2__c, 'Bad capture response - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_2__c, 'Bad capture uuid - attempt 2 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Response_Attempt_3__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Capture_Uuid_Attempt_3__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Not Captured yet', resultOrders[5].Capture_Status__c, 'Bad void status of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Response__c, 'Bad capture response - attempt 3 of processed order');
        System.assertEquals(null, resultOrders[5].Delta_Void_Uuid__c, 'Bad capture uuid - attempt 3 of processed order');
        System.assertEquals('Delta Not Voided yet', resultOrders[5].Delta_Void_Status__c, 'Bad void status of processed order');
    }
    
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        
        public HttpCalloutMockImpl(Integer statusCode) {
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            switch on this.statusCode {
                when 200 {
                    this.body = '{"success": true, "body": "Order captured", "uuid": "123"}';
                } when 201 {
                    this.body = '{"success": false, "body": "Capture failed", "uuid": null}';
                } when else {
                    throw Utilities.newAuraHandledException('Exception during capture');
                }
            }
            
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}