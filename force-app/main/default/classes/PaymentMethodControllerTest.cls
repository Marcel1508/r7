/**
* @author       jan.straka@bluewolf
* @date         2021-01-08
* @description  Test class for PaymentMethodController apex class
**/
@IsTest
private class PaymentMethodControllerTest {

    private static ContactPointAddress createContactPointAddress(Id accountId, String addressType) {
        ContactPointAddress cpa = (ContactPointAddress)
            new SObjectBuilder(ContactPointAddress.sObjectType)
            .put(ContactPointAddress.ParentId, accountId)
            .put(ContactPointAddress.AddressType, addressType)
            .put(ContactPointAddress.IsDefault, true)
            .create().getRecord();
        system.debug('ContactPointAddress :'+cpa);
        return cpa;
    }

    private static Webcart createCart(Id accountId) {
        WebCart cart = TestDataFactory.createGenericWebCartRecord(accountId);
        Insert cart;
        return cart;
    }

    private static Magasin__c createMagasin() {
       Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('TestMagasin');
       Insert magasinRec;
        return magasinRec;
    }


    private static Frais__c createFrais(Id accountId, Id magasinId, String echeance) {
        Frais__c frais = (Frais__c)
            new SObjectBuilder(Frais__c.sObjectType)
                .put(Frais__c.Magasin_Associe__c, magasinId)
                .put(Frais__c.Account__c, accountId)
                .put(Frais__c.echeance__c, echeance)
                .create().getRecord();
        return frais;
    }

    private static Account createAccount(Magasin__c magasinId) {
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinId); 
        Insert testAccount;
        return testAccount;
    }
    @IsTest
    private static void testGetBillingAddressesSuccess() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = TestDataFactory.createAccountwithOutMagasin();
        Insert account;
        WebCart cart = createCart(account.Id);
        
        List<ContactPointAddress> addresses = new List<ContactPointAddress>{
            createContactPointAddress(account.Id, 'Shipping'),
            createContactPointAddress(account.Id, 'Billing'),
            createContactPointAddress(account.Id, 'Billing'),
            createContactPointAddress(account.Id, 'Billing'),
            createContactPointAddress(account.Id, 'Shipping')
        };
        
        Test.startTest();
        List<PaymentMethodController.BillingAddressWrapper> results = PaymentMethodController.getBillingAddresses(cart.Id);
        System.debug('$$$$$ results' +results);
        Test.stopTest();

        System.assertEquals(4, results.size(), 'Bad count of billingAddresses');
        System.assertEquals(addresses[1].Id, results[1].value, 'Bad Id of first contact point address');
        System.assertEquals(addresses[2].Id, results[2].value, 'Bad Id of second contact point address');
        System.assertEquals(addresses[3].Id, results[3].value, 'Bad Id of third contact point address');
    }

    @IsTest
    private static void testGetBillingAddressesNoAddress() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = TestDataFactory.createAccountwithOutMagasin();
        Insert account;
        WebCart cart = createCart(account.Id);

        Exception caughtException;
        
        Test.startTest();
        try {
            PaymentMethodController.getBillingAddresses(cart.Id);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of exception');
        System.assertEquals(PaymentMethodController.ERROR_BILLING_ADDRESSES_NOT_FOUND, caughtException.getMessage(), 'Bad message of exception');
    }


    @IsTest
    private static void testGetPaymentMethodsAll() {
        AccountTriggerHandler.bypassTrigger = true;

        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, '01');
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);

        PaymentMethodController.cartSummary = new ConnectApi.CartSummary();
        PaymentMethodController.cartSummary.webStoreId = cart.WebStoreId;
        PaymentMethodController.cartSummary.accountId = cart.AccountId;
    
        Test.startTest();
        List<PaymentMethodController.PaymentMethodWrapper> results = PaymentMethodController.getPaymentMethods(cart.Id);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Bad count of delivery methods');
        Set<String> resultMethodNames = new Set<String>();
        for (PaymentMethodController.PaymentMethodWrapper result : results) {
            resultMethodNames.add(result.label);
        }
        System.assert(resultMethodNames.contains('Paiement par carte'), 'Paiement par carte is not present');
        System.assert(resultMethodNames.contains('Paiement différé'), 'Paiement différé is not present');
    }

    @IsTest
    private static void testGetPaymentMethodsBankCardOnly() {
        AccountTriggerHandler.bypassTrigger = true;

        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin);
        Frais__c frais = createFrais(account.Id, magasin.Id, null);
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);

        PaymentMethodController.cartSummary = new ConnectApi.CartSummary();
        PaymentMethodController.cartSummary.webStoreId = cart.WebStoreId;
        PaymentMethodController.cartSummary.accountId = cart.AccountId;
    
        Test.startTest();
        List<PaymentMethodController.PaymentMethodWrapper> results = PaymentMethodController.getPaymentMethods(cart.Id);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Bad count of delivery methods');
        System.assertEquals('Paiement par carte', results[0].label, 'Bad label of payment method');
    }

    @IsTest
    private static void testGetPaymentMethodsNoFrais() {
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin);
        WebCart cart = createCart(account.Id);

        PaymentMethodController.cartSummary = new ConnectApi.CartSummary();
        PaymentMethodController.cartSummary.webStoreId = cart.WebStoreId;
        PaymentMethodController.cartSummary.accountId = cart.AccountId;
    
        Exception caughtException;
        
        Test.startTest();
        try {
            PaymentMethodController.getPaymentMethods(cart.Id);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals(PaymentMethodController.ERROR_ACCOUNT_FEES_NOT_FOUND, caughtException.getMessage(), 'Bad message of exception');
        System.assertEquals('System.AuraHandledException', caughtException.getTypeName(), 'Bad type of exception');
    }
}