/**
* @author       jan.straka@bluewolf
* @date         2021-07-09
* @description  Test class for Batch apex for MarketPay void API callout
**/
@IsTest 
private class MP_VoidCalloutBatchTest {

    @IsTest 
    private static void testBatch_magasinNotFound() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;

        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert testAccount;
        
        List<Order> orders = TestDataFactory.createOrderList(testAccount.Id); 
        Insert orders; 

        Set<Id> orderIds = Pluck.ids(orders);

        Test.startTest();
            Id batchId = Database.executeBatch(new MP_VoidCalloutBatch(orderIds));
        Test.stopTest();

        List<Order> resultOrders = [
            SELECT Id, Magasin_actif__c, Void_Response__c, Void_Uuid__c, Void_Status__c 
            FROM Order 
            WHERE Id IN :orderIds];

        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(null, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('Magasin was not found [Order ID: ' + orders[5].Id + ', Magasin ID: null]', resultOrders[5].Void_Response__c, 'Bad void response of processed order');
        System.assertEquals(null, resultOrders[5].Void_Uuid__c, 'Bad void uuid of processed order');
        System.assertEquals('Not Cancelled yet', resultOrders[5].Void_Status__c, 'Bad void status of processed order');
    }

    @IsTest 
    private static void testBatch_cancelled() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200));
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;

        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert testAccount;
        
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
                .put(Order.Magasin_actif__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
                .put(Order.AccountId, testAccount.Id)
            	.count(10).create().getRecords();

        Set<Id> orderIds = Pluck.ids(orders);

        Test.startTest();
            Id batchId = Database.executeBatch(new MP_VoidCalloutBatch(orderIds));
        Test.stopTest();

        List<Order> resultOrders = [
            SELECT Id, Magasin_actif__c, Void_Response__c, Void_Uuid__c, Void_Status__c 
            FROM Order 
            WHERE Id IN :orderIds];

        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('{"success": true, "body": "Order cancelled", "uuid": "123"}', resultOrders[5].Void_Response__c, 'Bad void response of processed order');
        System.assertEquals('123', resultOrders[5].Void_Uuid__c, 'Bad void uuid of processed order');
        System.assertEquals('Cancelled - Success', resultOrders[5].Void_Status__c, 'Bad void status of processed order');
    }

    @IsTest 
    private static void testBatch_notCancelled() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(201));
        OrderTriggerHandler.bypassTrigger = true;
        
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;

        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert testAccount;
        
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
                .put(Order.Magasin_actif__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
                 .put(Order.AccountId, testAccount.Id)
            	.count(10).create().getRecords();

        Set<Id> orderIds = Pluck.ids(orders);

        Test.startTest();
            Id batchId = Database.executeBatch(new MP_VoidCalloutBatch(orderIds));
        Test.stopTest();

        List<Order> resultOrders = [
            SELECT Id, Magasin_actif__c, Void_Response__c, Void_Uuid__c, Void_Status__c 
            FROM Order 
            WHERE Id IN :orderIds];

        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('{"success": false, "body": "Cancellation failed", "uuid": null}', resultOrders[5].Void_Response__c, 'Bad void response of processed order');
        System.assertEquals(null, resultOrders[5].Void_Uuid__c, 'Bad void uuid of processed order');
        System.assertEquals('Cancelled - Error', resultOrders[5].Void_Status__c, 'Bad void status of processed order');
    }

    @IsTest 
    private static void testBatch_exception() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(500));
        OrderTriggerHandler.bypassTrigger = true;
         Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;

        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert testAccount;
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
                .put(Order.Magasin_actif__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
                .put(Order.AccountId, testAccount.Id)
            	.count(10).create().getRecords();

        Set<Id> orderIds = Pluck.ids(orders);

        Test.startTest();
            Id batchId = Database.executeBatch(new MP_VoidCalloutBatch(orderIds));
        Test.stopTest();

        List<Order> resultOrders = [
            SELECT Id, Magasin_actif__c, Void_Response__c, Void_Uuid__c, Void_Status__c 
            FROM Order 
            WHERE Id IN :orderIds];

        System.assertEquals(10, resultOrders.size(), 'Bad count of processed orders');
        System.assertEquals(orders[5].Magasin_actif__c, resultOrders[5].Magasin_actif__c, 'Bad magasin of processed order');
        System.assertEquals('Exception during cancellation', resultOrders[5].Void_Response__c, 'Bad void response of processed order');
        System.assertEquals(null, resultOrders[5].Void_Uuid__c, 'Bad void uuid of processed order');
        System.assertEquals('Not Cancelled yet', resultOrders[5].Void_Status__c, 'Bad void status of processed order');
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
                    this.body = '{"success": true, "body": "Order cancelled", "uuid": "123"}';
                } when 201 {
                    this.body = '{"success": false, "body": "Cancellation failed", "uuid": null}';
                } when else {
                    throw Utilities.newAuraHandledException('Exception during cancellation');
                }
            }
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }

}