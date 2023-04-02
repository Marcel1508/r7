/**
* @author       jan.straka@bluewolf
* @date         2021-01-06
* @description  Tests for DeliveryMethodController
**/
@IsTest
private class DeliveryMethodControllerTest {
    private static final String DRIVE = 'Drive';
    private static final String DRIVE_DEPORTE = 'Drive déporté';
    private static final String LIVRAISON = 'Livraison';
    private static final List<String> METHOD_NAMES = new List<String>{DRIVE, DRIVE_DEPORTE, LIVRAISON};
    private static final List<String> METHOD_MINIMUMS = new List<String>{'Minimum_Commande_Drive__c', 'Minimum_Commande_Drive__c', 'Minimum_Commande_Livraison__c'};
    private static final List<String> METHOD_FEES = new List<String>{'Frais_de_Drive__c', 'Frais_drive_deporte__c', 'Frais_de_livraison__c'};

    private static List<OrderDeliveryMethod> createDeliveryMethods() {
        List<OrderDeliveryMethod> deliveryMethods = new List<OrderDeliveryMethod>();
        deliveryMethods.addAll((List<OrderDeliveryMethod>)
            new SObjectBuilder(OrderDeliveryMethod.sObjectType)
                .put(OrderDeliveryMethod.IsActive, true)
                .put(OrderDeliveryMethod.Name, new SObjectFieldProviders.ListProvider(METHOD_NAMES))
                .put(OrderDeliveryMethod.Minimum_Account__c, new SObjectFieldProviders.ListProvider(METHOD_MINIMUMS))
                .put(OrderDeliveryMethod.Minimum_Magasin__c, new SObjectFieldProviders.ListProvider(METHOD_MINIMUMS))
                .count(3).build().getRecords());
        deliveryMethods.add((OrderDeliveryMethod)
            new SObjectBuilder(OrderDeliveryMethod.sObjectType)
                .put(OrderDeliveryMethod.IsActive, false)
                .put(OrderDeliveryMethod.Name, 'Invalid method')
                .build().getRecord());
        insert deliveryMethods;
        return deliveryMethods;
    }

    private static Webcart createCart(Id accountId) {
        WebCart cart = (WebCart)
            new SObjectBuilder(WebCart.sObjectType)
                .put(WebCart.AccountId, accountId)
                .create().getRecord();
        return [SELECT WebStoreId, AccountId FROM WebCart WHERE Id = :cart.Id];
    }

    private static Magasin__c createMagasin(Boolean populated) {
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
                .put(Magasin__c.Minimum_Commande_Drive__c, populated ? 20.00 : null)
                .put(Magasin__c.Minimum_Commande_Livraison__c, populated ? 40.00 : null)
                .put(Magasin__c.CurrencyIsoCode, 'EUR')
                .put(Magasin__c.Responsable__c, UserInfo.getUserId())
                .create().getRecord();
        return magasin;
    }

    private static Frais__c createFrais(Id accountId, Id magasinId, Boolean populated, String methods) {
        delete [SELECT Id FROM Frais__c]; //todo: replace with bypass
        Frais__c frais = (Frais__c)
            new SObjectBuilder(Frais__c.sObjectType)
                .put(Frais__c.Mode_de_livraison__c, methods)
                .put(Frais__c.Minimum_Commande_Drive__c, populated ? 15.00 : null)
                .put(Frais__c.Minimum_Commande_Livraison__c, populated ? 25.00 : null)
                .put(Frais__c.Magasin_Associe__c, magasinId)
                .put(Frais__c.Account__c, accountId)
                .put(Frais__c.CurrencyIsoCode, 'EUR')
                .create().getRecord();
        return frais;
    }

    private static Account createAccount(Id magasinId) {
        return (Account)
            new SObjectBuilder(Account.sObjectType)
            .put(Account.Magasin_actif_en_cours__c, magasinId)
            .put(Account.Numero_Siret__c, '41040946000046')
            .create().getRecord();
    }

    private static Order createOrder() {
        return (Order)
            new SObjectBuilder(Order.SObjectType)
                .create().getRecord();
    }

    private static OrderDeliveryGroup createOrderDeliveryGroup(Id orderId) {
        return (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.sObjectType)
                .put(OrderDeliveryGroup.OrderId, orderId)
                .put(OrderDeliveryGroup.Drive_Fees_Tech__c, 5.99)
                .put(OrderDeliveryGroup.Drive_Deporte_Fees_Tech__c, 9.79)
                .put(OrderDeliveryGroup.Livraison_Fees_Tech__c, 12.19)
                .put(OrderDeliveryGroup.DeliverToName, 'TEST')
                .create().getRecord();
    }
    
    @IsTest 
    private static void testGetDeliveryMethodsAllMethodsFraisMinimumsUsed() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Test.startTest();
        List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Bad count of delivery methods');
        Map<String, DeliveryMethodController.DeliveryMethodWrapper> resultsMap = new Map<String, DeliveryMethodController.DeliveryMethodWrapper>{
            results[0].methodName => results[0],
            results[1].methodName => results[1],
            results[2].methodName => results[2]
        };
        DeliveryMethodController.DeliveryMethodWrapper result = resultsMap.get('Drive');
        System.assertNotEquals(null, result, 'Delivery Method: Drive should be available');
        System.assertEquals(5.99, result.shippingFee, 'Bad shipping fee for Delivery Method: Drive');

        result = resultsMap.get('Drive déporté');
        System.assertNotEquals(null, result, 'Delivery Method: Drive déporté should be available');
        System.assertEquals(9.79, result.shippingFee, 'Bad shipping fee for Delivery Method: Drive déporté');

        result = resultsMap.get('Livraison');
        System.assertNotEquals(null, result, 'Delivery Method: Livraison should be available');
        System.assertEquals(12.19, result.shippingFee, 'Bad shipping fee for Delivery Method: Livraison');
    }
    
    @IsTest 
    private static void testgetDeliveryMethodsForCheckoutFlow() {
         AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, !populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Test.startTest();
        List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethodsForCheckoutFlow(cart.Id, order.Id);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Bad count of delivery methods');
        Map<String, DeliveryMethodController.DeliveryMethodWrapper> resultsMap = new Map<String, DeliveryMethodController.DeliveryMethodWrapper>{
            results[0].methodName => results[0],
            results[1].methodName => results[1],
            results[2].methodName => results[2]
        };
        DeliveryMethodController.DeliveryMethodWrapper result = resultsMap.get('Drive');
        System.assertNotEquals(null, result, 'Delivery Method: Drive should be available');
        System.assertEquals(5.99, result.shippingFee, 'Bad shipping fee for Delivery Method: Drive');

        result = resultsMap.get('Drive déporté');
        System.assertNotEquals(null, result, 'Delivery Method: Drive déporté should be available');
        System.assertEquals(9.79, result.shippingFee, 'Bad shipping fee for Delivery Method: Drive déporté');

        result = resultsMap.get('Livraison');
        System.assertNotEquals(null, result, 'Delivery Method: Livraison should be available');
        System.assertEquals(12.19, result.shippingFee, 'Bad shipping fee for Delivery Method: Livraison');


    }


    @IsTest 
    private static void testGetDeliveryMethodsAllMethodsMagasinMinimumsUsed() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, !populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Test.startTest();
        List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Bad count of delivery methods');
        Map<String, DeliveryMethodController.DeliveryMethodWrapper> resultsMap = new Map<String, DeliveryMethodController.DeliveryMethodWrapper>{
            results[0].methodName => results[0],
            results[1].methodName => results[1],
            results[2].methodName => results[2]
        };
        DeliveryMethodController.DeliveryMethodWrapper result = resultsMap.get('Drive');
        System.assertNotEquals(null, result, 'Delivery Method: Drive should be available');
        System.assertEquals(5.99, result.shippingFee, 'Bad shipping fee for Delivery Method: Drive');

        result = resultsMap.get('Drive déporté');
        System.assertNotEquals(null, result, 'Delivery Method: Drive déporté should be available');
        System.assertEquals(9.79, result.shippingFee, 'Bad shipping fee for Delivery Method: Drive déporté');

        result = resultsMap.get('Livraison');
        System.assertNotEquals(null, result, 'Delivery Method: Livraison should be available');
        System.assertEquals(12.19, result.shippingFee, 'Bad shipping fee for Delivery Method: Livraison');
    }

    @IsTest 
    private static void testGetDeliveryMethodsNoMethodsAllowed() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = null;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Exception caughtException;
        
        Test.startTest();
        try {
            List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
            System.assert(false, 'Should fail here');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals(DeliveryMethodController.ERROR_METHODS_NOT_FOUND, caughtException.getMessage(), 'Bad message of caught exception');
    }

    @IsTest 
    private static void testGetDeliveryMethodsCartTooLow() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '5';
    
        Exception caughtException;
        
        Test.startTest();
        try {
            List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
            //System.assert(false, 'Should fail here');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertEquals(null, caughtException, 'Exception should be caught');
    }

    @IsTest 
    private static void testGetDeliveryMethodsNoMagasin() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(null);
        Frais__c frais = createFrais(account.Id, magasin.Id, populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Exception caughtException;

        Test.startTest();
        try {
            List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
            System.assert(false, 'Should fail here');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        //System.assertEquals('List index out of bounds: 0', caughtException.getMessage(), 'Bad message of caught exception');
    }
    
    

    @IsTest 
    private static void testGetDeliveryMethodsNoFrais() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Exception caughtException;

        Test.startTest();
        try {
            List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
            System.assert(false, 'Should fail here');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals(DeliveryMethodController.ERROR_ACCOUNT_FEES_NOT_FOUND, caughtException.getMessage(), 'Bad message of caught exception');
    }

    @IsTest 
    private static void testGetDeliveryMethodsNoOrderDeliveryGroup() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Exception caughtException;

        Test.startTest();
        try {
            List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
            System.assert(false, 'Should fail here');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('We Should Have Only One Order Delivery Group.', caughtException.getMessage(), 'Bad message of caught exception');
    }

    @IsTest 
    private static void testGetDeliveryMethodsMoreOrderDeliveryGroups() {
        AccountTriggerHandler.bypassTrigger = true;
        Boolean populated = true;
        String allowedMethods = DRIVE + ';' + DRIVE_DEPORTE + ';' + LIVRAISON;

        createDeliveryMethods();
        Magasin__c magasin = createMagasin(populated);
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, populated, allowedMethods);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        Order order = createOrder();
        OrderDeliveryGroup odg1 = createOrderDeliveryGroup(order.Id);
        OrderDeliveryGroup odg2 = createOrderDeliveryGroup(order.Id);

        DeliveryMethodController.cartSummary = new ConnectApi.CartSummary();
        DeliveryMethodController.cartSummary.webStoreId = cart.WebStoreId;
        DeliveryMethodController.cartSummary.accountId = cart.AccountId;
        DeliveryMethodController.cartSummary.totalProductAmount = '100';
    
        Exception caughtException;

        Test.startTest();
        try {
            List<DeliveryMethodController.DeliveryMethodWrapper> results = DeliveryMethodController.getDeliveryMethods(cart.Id, order.Id);
            System.assert(false, 'Should fail here');
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        //System.assertEquals('List index out of bounds: 0', caughtException.getMessage(), 'Bad message of caught exception');
    }
    
    @IsTest
    private static void testRegisterToBeCalledBackPreferencePositive() {
        UserRole ceoRole = [SELECT Id From UserRole Where DeveloperName = 'CEO'];
        User storeAssistant = (User)
            new SObjectBuilder(User.SObjectType)
                .put(User.UserName, 'storeAssistant@carrefour.com')
                .put(User.UserRoleId, ceoRole.Id)
                .create().getRecord();

        Account acc;
        Contact con;
        System.runAs(storeAssistant) {
            Magasin__c magasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .create().getRecord();
            
            acc = (Account)
                new SObjectBuilder(Account.SObjectType)
                    .put(Account.Assigne_a__c, storeAssistant.Id)
                    .put(Account.Magasin_de_rattachement__c, magasin.Id)
                    .put(Account.Numero_Siret__c, '41040946000046')
                    .create().getRecord();

            con = (Contact)
                new SObjectBuilder(Contact.SObjectType)
                    .put(Contact.AccountId, acc.Id)
                    .put(Contact.Roles__c, 'Autre')
                    .create().getRecord();
        }

        Profile customerCommunityPlus = [SELECT Id FROM Profile WHERE Name = 'Customer Community +'];
        User customer = (User)
            new SObjectBuilder(User.SObjectType)
                .put(User.ProfileId, customerCommunityPlus.Id)
                .put(User.FirstName, 'The')
                .put(User.LastName, 'Customer')
                .put(User.UserName, 'theCustomer@carrefour.com')
                .put(User.ContactId, con.Id)
                .create().getRecord();
        
        System.runAs(customer) {
            WebCart cart = createCart(acc.Id);

            Test.startTest();
            String result = DeliveryMethodController.registerToBeCalledBackPreference(cart.Id, true);
            Test.stopTest();

            System.assertEquals(DeliveryMethodController.PREF_UPDATE_SUCCESS, result, 'Bad result message');
            List<WebCart> resultCarts = [SELECT Id, To_Be_Called_Back__c FROM WebCart WHERE Id = :cart.Id];
            System.assertEquals(1, resultCarts.size(), 'Bad count of result carts');
            System.assertEquals(true, resultCarts[0].To_Be_Called_Back__c, 'Bad to be called back preference');
        }
    }

    @IsTest
    private static void testRegisterToBeCalledBackPreferenceNegative() {
        UserRole ceoRole = [SELECT Id From UserRole Where DeveloperName = 'CEO'];
        User storeAssistant = (User)
            new SObjectBuilder(User.SObjectType)
                .put(User.UserName, 'storeAssistant@carrefour.com')
                .put(User.UserRoleId, ceoRole.Id)
                .create().getRecord();

        Account acc;
        Contact con;
        System.runAs(storeAssistant) {
            Magasin__c m = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
                .put(Magasin__c.Responsable__c, UserInfo.getUserId())
                .create().getRecord();
            
            acc = (Account)
                new SObjectBuilder(Account.SObjectType)
                    .put(Account.Assigne_a__c, storeAssistant.Id) 
                    .put(Account.Magasin_de_rattachement__c, m.Id)
                    .put(Account.Numero_Siret__c, '41040946000046')
                    .create().getRecord();

            con = (Contact)
                new SObjectBuilder(Contact.SObjectType)
                    .put(Contact.AccountId, acc.Id)
                    .put(Contact.Roles__c, 'Autre')
                    .create().getRecord();
        }

        Profile customerCommunityPlus = [SELECT Id FROM Profile WHERE Name = 'Customer Community +'];
        User customer = (User)
            new SObjectBuilder(User.SObjectType)
                .put(User.ProfileId, customerCommunityPlus.Id)
                .put(User.FirstName, 'The')
                .put(User.LastName, 'Customer')
                .put(User.UserName, 'theCustomer@carrefour.com')
                .put(User.ContactId, con.Id)
                .create().getRecord();

        System.runAs(customer) {
            WebCart cart = createCart(acc.Id);

            Test.startTest();
            String result = DeliveryMethodController.registerToBeCalledBackPreference(cart.Id, false);
            Test.stopTest();

            System.assertEquals(DeliveryMethodController.PREF_UPDATE_SUCCESS, result, 'Bad result message');
            List<WebCart> resultCarts = [SELECT Id, To_Be_Called_Back__c FROM WebCart WHERE Id = :cart.Id];
            System.assertEquals(1, resultCarts.size(), 'Bad count of result carts');
            System.assertEquals(false, resultCarts[0].To_Be_Called_Back__c, 'Bad to be called back preference');
        }
    }

    @IsTest
    private static void testRegisterToBeCalledBackPreferenceError() {
        Exception caughtException;
        String expectedMessage = 'Update failed. First exception on row 0; first error: MISSING_ARGUMENT, Id not specified in an update call: []';

        Test.startTest();
        try {
            String result = DeliveryMethodController.registerToBeCalledBackPreference(null, null);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of exception');
        System.assertEquals(expectedMessage, caughtException.getMessage(), 'Bad message of exception');
    }
}