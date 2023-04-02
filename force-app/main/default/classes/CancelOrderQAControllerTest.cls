/**
* @author       jan.straka@bluewolf
* @date         2021-05-03
* @description  Tests for CancelOrderQA controller
**/

@IsTest
private class CancelOrderQAControllerTest {

    private static Order createOrder(Id pricebookId) {
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('TestMagasin');
        Insert magasinRec;
        
         Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert testAccount;
        
        Order testOrder = TestDataFactory.createOrderRecord(testAccount.Id);
        testOrder.Creneau_client__c = null;
        Insert testOrder;
        return testOrder;
    }

    private static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Id productId) {
        OrderItem ordItem = TestDataFactory.createGenericOrderItem(orderId,pricebookEntryId,productId);
        Insert ordItem;
        return ordItem;
    }

    private static PricebookEntry createPricebookEntry() {
        return (PricebookEntry) new SObjectBuilder(PricebookEntry.SObjectType)
            .create().getRecord();
    }

    @IsTest
    private static void testCheckStatusDraftOrder() {
        OrderTriggerHandler.bypassTrigger = true;
        PricebookEntry testPricebookEntry = createPricebookEntry();
        Order testOrder = createOrder(testPricebookEntry.Pricebook2Id);
        Exception caughtException;

        Test.startTest();
        try {
            CancelOrderQAController.checkStatus(testOrder.Id);
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();

        System.assertEquals(null, caughtException, 'No exception should be caught');
    }

    @IsTest
    private static void testCheckStatusEnAttenteDePreparation() {
        OrderTriggerHandler.bypassTrigger = true;
        PricebookEntry testPricebookEntry = createPricebookEntry();
        Order testOrder = createOrder(testPricebookEntry.Pricebook2Id);
        createOrderItem(testOrder.Id, testPricebookEntry.Id, testPricebookEntry.Product2Id);
        testOrder.Status = '1';
        update testOrder;
        Exception caughtException;

        Test.startTest();
        try {
            CancelOrderQAController.checkStatus(testOrder.Id);
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();

        System.assertEquals(null, caughtException, 'No exception should be caught');
    }

    @IsTest
    private static void testCheckStatusEnCoursDePreparation() {
        OrderTriggerHandler.bypassTrigger = true;
        PricebookEntry testPricebookEntry = createPricebookEntry();
        Order testOrder = createOrder(testPricebookEntry.Pricebook2Id);
        createOrderItem(testOrder.Id, testPricebookEntry.Id, testPricebookEntry.Product2Id);
        testOrder.Status = '2';
        Exception caughtException;
        Test.startTest();
        try {
            update testOrder;
            CancelOrderQAController.checkStatus(testOrder.Id);
        } catch(Exception e) {
            caughtException = e;
            System.assert(e.getMessage().contains('Vous ne pouvez modifier manuellement le statut de la commande.'));
        } 
        Test.stopTest();
    }

      
    
    @IsTest
    private static void testCheckStatusTerminee() {
        OrderTriggerHandler.bypassTrigger = true;
        PricebookEntry testPricebookEntry = createPricebookEntry();
        Order testOrder = createOrder(testPricebookEntry.Pricebook2Id);
        createOrderItem(testOrder.Id, testPricebookEntry.Id, testPricebookEntry.Product2Id);
        Test.startTest();
        Exception caughtException;
        try {
            testOrder.Status = '3';
            update testOrder;
            CancelOrderQAController.checkStatus(testOrder.Id);
        } catch(Exception e) {
            caughtException = e;
            System.assert(e.getMessage().contains('Vous ne pouvez modifier manuellement le statut de la commande.'));
        } 
        Test.stopTest();
        System.assertNotEquals(null, caughtException, 'An exception should be caught');
        
     }

    @IsTest
    private static void testCheckStatusAnnulee() {
        OrderTriggerHandler.bypassTrigger = true;
        PricebookEntry testPricebookEntry = createPricebookEntry();
        Order testOrder = createOrder(testPricebookEntry.Pricebook2Id);
        createOrderItem(testOrder.Id, testPricebookEntry.Id, testPricebookEntry.Product2Id);
        testOrder.Status = '4';
        update testOrder;
        Exception caughtException;

        Test.startTest();
        try {
            CancelOrderQAController.checkStatus(testOrder.Id);
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'An exception should be caught');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of exception');
        System.assertEquals(CancelOrderQAController.EXCEPTION_MESSAGE, caughtException.getMessage(), 'Bad message of exception');
    }

    @IsTest
    private static void testCancelOrder() {
        OrderTriggerHandler.bypassTrigger = true;
        PricebookEntry testPricebookEntry = createPricebookEntry();
        Order testOrder = createOrder(testPricebookEntry.Pricebook2Id);
        createOrderItem(testOrder.Id, testPricebookEntry.Id, testPricebookEntry.Product2Id);
        testOrder.Status = '1';
        update testOrder;

        Test.startTest();
        CancelOrderQAController.cancelOrder(testOrder.Id);
        Test.stopTest();

        Order resultOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals('4', resultOrder.Status, 'Bad status of cancelled order');
    }
}