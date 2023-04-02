/**
* @author       jan.straka@bluewolf
* @date         2021-06-28
* @description  Tests for CheckoutOrderSummaryCtrl
**/

@IsTest
private class CheckoutOrderSummaryCtrlTest {
    
    @IsTest
    private static void testGetCheckoutSummaryNoInStockNoOutOfStock() {
        Test.startTest();
        CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(null, null);
        Test.stopTest();

        System.assertEquals(null, result.magasin, 'Bad result magasin value');
        System.assertEquals(null, result.inStockOrder, 'Bad result in stock order value');
        System.assertEquals(null, result.outStockOrder, 'Bad result out of stock order value');
        System.assertEquals(null, result.orderDeliveryGroup, 'Bad result order delivery group value');
        System.assertEquals(null, result.slot, 'Bad result slot value');
        System.assertEquals(null, result.slotDate, 'Bad result slot date value');
        System.assertEquals(null, result.slotTime, 'Bad result slot time value');
    }

    @IsTest
    private static void testGetCheckoutSummaryInStock() {
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            	.put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();

        Creneau_Salesforce__c testSlot = (Creneau_Salesforce__c)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.Date__c, Date.newInstance(2021, 06, 28))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, Time.newInstance(01, 23, 45, 0))
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .create().getRecord();

        Order testInStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();

        OrderDeliveryGroup testODG = (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.SObjectType)
                .put(OrderDeliveryGroup.OrderId, testInStockOrder.Id)
                .put(OrderDeliveryGroup.DeliverToName, 'TEST')
                .create().getRecord();
        
        Test.startTest();
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(testInStockOrder.Id, null);
        Test.stopTest();

        System.assertEquals(testMagasin.Id, result.magasin.Id, 'Bad result magasin Id');
        System.assertEquals(testInStockOrder.Id, result.inStockOrder.Id, 'Bad result in stock order Id');
        System.assertEquals(null, result.outStockOrder, 'Bad result out of stock order value');
        System.assertEquals(testODG.Id, result.orderDeliveryGroup.Id, 'Bad result order delivery group Id');
        System.assertEquals(testSlot.Id, result.slot.Id, 'Bad result slot Id');
        System.assertEquals('28/06/2021', result.slotDate, 'Bad result slot date value');
        System.assertEquals('01:23:45', result.slotTime, 'Bad result slot time value');
    }


    @IsTest
    private static void testGetCheckoutSummaryOutOfStock() {
        
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            	.put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();

        Creneau_Salesforce__c testSlot = (Creneau_Salesforce__c)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.Date__c, Date.newInstance(2021, 06, 28))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, Time.newInstance(01, 23, 45, 0))
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .create().getRecord();
        
        Order testInStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();

        Order testOutOfStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();
        

        OrderDeliveryGroup testODG = (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.SObjectType)
                .put(OrderDeliveryGroup.OrderId, testInStockOrder.Id)
                .put(OrderDeliveryGroup.DeliverToName, 'TEST')
                .create().getRecord();
        

        Test.startTest();
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(null, testOutOfStockOrder.Id);
        Test.stopTest();

        System.assertEquals(null, result.magasin, 'Bad result magasin value');
        System.assertEquals(null, result.inStockOrder, 'Bad result in stock order value');
        System.assertEquals(testOutOfStockOrder.Id, result.outStockOrder.Id, 'Bad result out of stock order Id');
        System.assertEquals(null, result.orderDeliveryGroup, 'Bad result order delivery group value');
        System.assertEquals(null, result.slot, 'Bad result slot value');
        System.assertEquals(null, result.slotDate, 'Bad result slot date value');
        System.assertEquals(null, result.slotTime, 'Bad result slot time value');
    }

    @IsTest
    private static void testGetCheckoutSummaryInStockOutOfStock() {
        
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            	.put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();

        Creneau_Salesforce__c testSlot = (Creneau_Salesforce__c)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.Date__c, Date.newInstance(2021, 06, 28))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, Time.newInstance(01, 23, 45, 0))
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .create().getRecord();
        
        Order testInStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();

        Order testOutOfStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();
        

        OrderDeliveryGroup testODG = (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.SObjectType)
                .put(OrderDeliveryGroup.OrderId, testInStockOrder.Id)
                .put(OrderDeliveryGroup.DeliverToName, 'TEST')
                .create().getRecord();
        
        Test.startTest();
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(testInStockOrder.Id, testOutOfStockOrder.Id);
        Test.stopTest();

        System.assertEquals(testMagasin.Id, result.magasin.Id, 'Bad result magasin Id');
        System.assertEquals(testInStockOrder.Id, result.inStockOrder.Id, 'Bad result in stock order Id');
        System.assertEquals(testOutOfStockOrder.Id, result.outStockOrder.Id, 'Bad result out of stock order Id');
        System.assertEquals(testODG.Id, result.orderDeliveryGroup.Id, 'Bad result order delivery group Id');
        System.assertEquals(testSlot.Id, result.slot.Id, 'Bad result slot Id');
        System.assertEquals('28/06/2021', result.slotDate, 'Bad result slot date value');
        System.assertEquals('01:23:45', result.slotTime, 'Bad result slot time value');
    }

    @IsTest
    private static void testGetCheckoutSummaryInvalidInStock() {
        Exception caughtException;
        
        Test.startTest();
        try {
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary('INVALID', null);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('Invalid id: INVALID', caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.StringException', caughtException.getTypeName(), 'Bad type of caught exception');
    }

    @IsTest
    private static void testGetCheckoutSummaryInvalidOutOfStock() {
        Exception caughtException;
        
        Test.startTest();
        try {
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(null, 'INVALID');
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('Out of Stock Order was not found [ID: INVALID]', caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of caught exception');
    }

    @IsTest
    private static void testGetCheckoutSummaryInStockWithoutODGNoOutOfStock() {
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            	.put(Account.Magasin_de_rattachement__c, testMagasin.Id)
                .create().getRecord();

        Creneau_Salesforce__c testSlot = (Creneau_Salesforce__c)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.Date__c, Date.newInstance(2021, 06, 28))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, Time.newInstance(01, 23, 45, 0))
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .create().getRecord();

        Order testInStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();

        Exception caughtException;
        
        Test.startTest();
        try {
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(testInStockOrder.Id, null);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('Order Delivery Group was not found [Order ID: ' + testInStockOrder.Id + ']', caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of caught exception');
    }

    @IsTest
    private static void testGetCheckoutSummaryInStockWithoutMagasinNoOutOfStock() {
        Magasin__c testMagasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .create().getRecord();

        Account testAccount = (Account)
            new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_actif_en_cours__c,null)
            	.put(Account.Magasin_de_rattachement__c, testMagasin.Id )
                .create().getRecord();

        Creneau_Salesforce__c testSlot = (Creneau_Salesforce__c)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.Date__c, Date.newInstance(2021, 06, 28))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, Time.newInstance(01, 23, 45, 0))
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .create().getRecord();

        Order testInStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .put(Order.Tech_Creneau_Salesforce__c, testSlot.Id)
                .create().getRecord();

        OrderDeliveryGroup testODG = (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.SObjectType)
                .put(OrderDeliveryGroup.OrderId, testInStockOrder.Id)
                .put(OrderDeliveryGroup.DeliverToName, 'TEST')
                .create().getRecord();
        
        Exception caughtException;
        
        Test.startTest();
        try {
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(testInStockOrder.Id, null);
        } catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.assert(e.getMessage().contains('Magasin Actif was not found'));
        }
        Test.stopTest();

    }

    @IsTest
    private static void testGetCheckoutSummaryInStockWithoutSlotNoOutOfStock() {
        Account testAccount = (Account)
        new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_actif_en_cours__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
            .put(Account.Magasin_de_rattachement__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
            .create().getRecord();

        Order testInStockOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, testAccount.Id)
                .create().getRecord();

        OrderDeliveryGroup testODG = (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.SObjectType)
                .put(OrderDeliveryGroup.OrderId, testInStockOrder.Id)
                .put(OrderDeliveryGroup.DeliverToName, 'TEST')
                .create().getRecord();
        
        Exception caughtException;
        
        Test.startTest();
        try {
            CheckoutOrderSummaryCtrl.CheckoutSummaryWrapper result = CheckoutOrderSummaryCtrl.getCheckoutSummary(testInStockOrder.Id, null);
            
        } catch(AuraHandledException e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
        }
        Test.stopTest();

    }

}