/**
 * @author       jan.straka@bluewolf
 * @date         2021-01-22
 * @description  Tests for OrderService
 **/
@IsTest
private class OrderService_TST {
    private static final String LIVRAISON = Constants.LIVRAISON;
    private static final String DRIVE = Constants.DRIVE;
    private static final String DRIVE_DEPORTE = Constants.DRIVE_DEPORTE;
    private static final String ALL_METHODS = String.join(new List<String>{ LIVRAISON, DRIVE, DRIVE_DEPORTE }, ';');

    private static Magasin__c createMagasin(Boolean enabled) {
        Magasin__c magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        magasinRec.Autoriser_livraison_aux_nouveaux_clients__c = enabled;
        insert magasinRec;
        return magasinRec;
    }

    private static Account createAccount(Magasin__c magasinId) {
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc', 'Lead', magasinId);
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.FirstOrder__c = null;
        insert testAccount;
        return testAccount;
    }

    private static Order createOrder(Id accountId) {
        Order testOrder = TestDataFactory.createOrderRecord(accountId);
        insert testOrder;
        return testOrder;
    }

    private static Order createOrderBis(Id accountId, Id magasinActif) {
        Order testOrder = TestDataFactory.createOrderRecord(accountId);
        testOrder.Magasin_actif__c = magasinActif;
        insert testOrder;
        return testOrder;
    }

    private static Frais__c createFrais(Id accountId, Id magasinId, String modes) {
        delete [SELECT Id FROM Frais__c];
        return (Frais__c) new SObjectBuilder(Frais__c.SObjectType)
            .put(Frais__c.Account__c, accountId)
            .put(Frais__c.Magasin_Associe__c, magasinId)
            .put(Frais__c.Mode_de_livraison__c, modes)
            .create()
            .getRecord();
    }

    @IsTest
    private static void voidCancelledOrders() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin);
        Order order = createOrder(account.Id);

        new OrderService().voidCancelledOrders(new List<Order>{ order }, new Map<Id, Order>{ order.id => order });
    }

    @IsTest
    private static void captureTerminatedOrders() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin);
        Order order = createOrder(account.Id);

        new OrderService().captureTerminatedOrders(new List<Order>{ order }, new Map<Id, Order>{ order.id => order });
    }

    @IsTest
    private static void fillNumeroDeCommand() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin);
        Order order = createOrderBis(account.Id, magasin.Id);

        List<Order> orders = [
            SELECT
                OrderNumber,
                Code_Etablissement__c,
                Numero_de_commande__c,
                Magasin_actif__r.Code_etablissement__c,
                Magasin_actif__c
            FROM Order
        ];
        new OrderService().fillNumeroDeCommand(orders);
    }

    @IsTest
    private static void testmarkFirstOrder() {
        //todo: @Aymen
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, ALL_METHODS);
        Order order = createOrder(account.Id);

        Test.startTest();
        new OrderService().markFirstOrder(new List<Order>{ order });
        Test.stopTest();

        Account resultAccount = [SELECT Id, FirstOrder__c FROM Account WHERE Id = :account.Id];
        Order resultOrder = [SELECT Id, FirstOrderAccount__c FROM Order WHERE Id = :order.Id];

        System.assertEquals(resultOrder.Id, resultAccount.FirstOrder__c, 'Account has wrong or missing first order');
        System.assertEquals(resultAccount.Id, resultOrder.FirstOrderAccount__c, 'First order has wrong or missing account');

        Order order2 = createOrder(account.Id);
        new OrderService().markFirstOrder(new List<Order>{ order2 });

        resultAccount = [SELECT Id, FirstOrder__c FROM Account WHERE Id = :account.Id];
        resultOrder = [SELECT Id, FirstOrderAccount__c FROM Order WHERE Id = :order2.Id];
        Order resultOrder2 = [SELECT Id, FirstOrderAccount__c FROM Order WHERE Id = :order2.Id];

        System.assertEquals(null, resultAccount.FirstOrder__c, 'Account must have null in firstOrder (Account have two orders)');
        System.assertEquals(null, resultOrder.FirstOrderAccount__c, 'Order is not the first account order');
        System.assertEquals(null, resultOrder2.FirstOrderAccount__c, 'Order is not the first account order');
    }

    @IsTest
    private static void testRemoveAccountDeliveryAuthorizationsNewAccountDeliveryEnabled() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, ALL_METHODS);
        Order order = createOrder(account.Id);

        Test.startTest();
        new OrderService().removeAccountDeliveryAuthorizations(new List<Order>{ order });
        Test.stopTest();

        List<Frais__c> resultFrais = [SELECT Mode_de_livraison__c FROM Frais__c WHERE Id = :frais.Id];
        System.assertEquals(1, resultFrais.size(), 'Bad count of frais');
        System.assert(resultFrais[0].Mode_de_livraison__c.contains(LIVRAISON), 'Livraison method should be available');
    }

    @IsTest
    private static void testRemoveAccountDeliveryAuthorizationsNewAccountDeliveryDisabled() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(false);
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, ALL_METHODS);
        Order order = createOrder(account.Id);

        Test.startTest();
        new OrderService().removeAccountDeliveryAuthorizations(new List<Order>{ order });
        Test.stopTest();

        List<Frais__c> resultFrais = [SELECT Mode_de_livraison__c FROM Frais__c WHERE Id = :frais.Id];
        System.assertEquals(1, resultFrais.size(), 'Bad count of frais');
        //System.assert(resultFrais[0].Mode_de_livraison__c.contains(LIVRAISON), 'Livraison method should not be available');
    }

    @IsTest
    private static void testRemoveAccountDeliveryAuthorizationsOldAccountDeliveryEnabled() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, ALL_METHODS);
        account.FirstOrder__c = createOrder(account.Id).Id;
        update account;
        Order order = createOrder(account.Id);

        Test.startTest();
        new OrderService().removeAccountDeliveryAuthorizations(new List<Order>{ order });
        Test.stopTest();

        List<Frais__c> resultFrais = [SELECT Mode_de_livraison__c FROM Frais__c WHERE Id = :frais.Id];
        System.assertEquals(1, resultFrais.size(), 'Bad count of frais');
        System.assert(resultFrais[0].Mode_de_livraison__c.contains(LIVRAISON), 'Livraison method should be available');
    }

    @IsTest
    private static void testRemoveAccountDeliveryAuthorizationsOldAccountDeliveryDisabled() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(false);
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, ALL_METHODS);
        account.FirstOrder__c = createOrder(account.Id).Id;
        update account;
        Order order = createOrder(account.Id);

        Test.startTest();
        new OrderService().removeAccountDeliveryAuthorizations(new List<Order>{ order });
        Test.stopTest();

        List<Frais__c> resultFrais = [SELECT Mode_de_livraison__c FROM Frais__c WHERE Id = :frais.Id];
        System.assertEquals(1, resultFrais.size(), 'Bad count of frais');
        System.assert(resultFrais[0].Mode_de_livraison__c.contains(LIVRAISON), 'Livraison method should be available');
    }
}