/**
* @author       jan.straka@bluewolf
* @date         2021-02-12
* @description  Tests for B2BCartTaxesCustom
**/
@IsTest
private class B2BCartTaxesCustomTest {

    private static Magasin__c createMagasin() {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .create().getRecord();
    }
    
    private static Account createAccount(Id magasinId) {
        Code_APE__c codeApe = new Code_APE__c();
        codeApe.Name ='Test123';
        insert codeApe;
        return (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.Enseigne_commerciale__c,'Hill Billy company')
            .put(Account.Forme_juridique__c,'19')
            .put(Account.Categorie__c,'3')
            .put(Account.Code_APE__c,codeApe.Id)
            .create().getRecord();
    }

    private static WebCart createCart(Id accountId) {
        return (WebCart) new SObjectBuilder(WebCart.SObjectType)
            .put(WebCart.AccountId, accountId)
            .create().getRecord();
    }

    private static Product2 createProduct(String codeTVA) {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Code_TVA__c, codeTVA)
            .create().getRecord();
    }

    private static CartDeliveryGroup createCartDeliveryGroup(Id cartId) {
        return (CartDeliveryGroup) new SObjectBuilder(CartDeliveryGroup.SObjectType)
            .put(CartDeliveryGroup.CartId, cartId)
            .create().getRecord();
    }

    private static CartItem createCartItem(Id cartId, Id productId, Id cartDeliveryGroupId, Decimal amount) {
        return (CartItem) new SObjectBuilder(CartItem.SObjectType)
            .put(CartItem.CartId, cartId)
            .put(CartItem.Product2Id, productId)
            .put(CartItem.TotalLineAmount, amount)
            .put(CartItem.CartDeliveryGroupId, cartDeliveryGroupId)
            .create().getRecord();
    }

    private static Frais__c createFrais(Id accountId, Id magasinId, String zoneTerritoriale) {
        return (Frais__c) new SObjectBuilder(Frais__c.SObjectType)
            .put(Frais__c.Account__c, accountId)
            .put(Frais__c.Magasin_Associe__c, magasinId)
            .put(Frais__c.Zone_territoriale__c, zoneTerritoriale)
            .create().getRecord();
    }

    private static Taxes__c createTaxes(String codeTVA, String zoneTerritoriale, Decimal tauxDeTVA) {
        return (Taxes__c) new SObjectBuilder(Taxes__c.SObjectType)
            .put(Taxes__c.Code_TVA__c, codeTVA)
            .put(Taxes__c.Zone_Territoriale__c, zoneTerritoriale)
            .put(Taxes__c.Taux_de_TVA__c, tauxDeTVA)
            .create().getRecord();
    }

    private static CartTax createCartTax(Id cartItemId) {
        return (CartTax) new SObjectBuilder(CartTax.SObjectType)
            .put(CartTax.CartItemId, cartItemId)
            .create().getRecord();
    }

    @IsTest
    private static void testCalculateTaxesNoCartItems() {
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin.Id);
        WebCart cart = createCart(account.Id);
        Exception caughtException;
        
        Test.startTest();
        try {
            B2BCartTaxesCustom.calculateTaxes(new List<String>{cart.Id});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('B2BCartTaxesCustom.B2BCheckoutTaxesException', caughtException.getTypeName(), 'Bad type of exception');
        System.assertEquals('No Cart Items were found (Cart Id: ' + cart.Id + ')', caughtException.getMessage(), 'Bad message of exception');
    }

    @IsTest
    private static void testCalculateTaxesNoFrais() {
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 product = createProduct(null);
        CartItem cartItem = createCartItem(cart.Id, product.Id, cdg.Id, 200);
        Exception caughtException;
        
        Test.startTest();
        try {
            B2BCartTaxesCustom.calculateTaxes(new List<String>{cart.Id});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('B2BCartTaxesCustom.B2BCheckoutTaxesException', caughtException.getTypeName(), 'Bad type of exception');
        System.assertEquals('No Frais__c record was found', caughtException.getMessage(), 'Bad message of exception');
    }

    @IsTest
    private static void testCalculateTaxesNoTaxesSpecification() {
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0');
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 product = createProduct(null);
        CartItem cartItem = createCartItem(cart.Id, product.Id, cdg.Id, 200);
        Exception caughtException;
        
        Test.startTest();
        try {
            B2BCartTaxesCustom.calculateTaxes(new List<String>{cart.Id});
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();

        
        //System.assertEquals('B2BCartTaxesCustom.B2BCheckoutTaxesException', caughtException.getTypeName(), 'Bad type of exception');
        //System.assertEquals('No Taxes__c record found for (Product Id:' + product.Id + ', Frais Id:' + frais.Id + ')', caughtException.getMessage(), 'Bad message of exception');
    }

    @IsTest
    private static void testCalculateTaxesSuccessInsertNew() {
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, '5');
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 product = createProduct('3');
        CartItem cartItem = createCartItem(cart.Id, product.Id, cdg.Id, 200);
        Taxes__c taxes = createTaxes('3', '5', 15);
        
        Test.startTest();
        B2BCartTaxesCustom.calculateTaxes(new List<String>{cart.Id});
        Test.stopTest();

        List<CartTax> results = [SELECT Id, CartId, CartItemId, Name, TaxType, TaxRate, Amount, TaxCalculationDate FROM CartTax];
        //System.assertEquals(1, results.size(), 'Bad count of result Cart Taxes');
        System.assertEquals(cart.Id, results[0].CartId, 'Bad cart Id of result Cart Tax');
        System.assertEquals(cartItem.Id, results[0].CartItemId, 'Bad cart item Id of result Cart Tax');
        System.assertEquals('TVA', results[0].Name, 'Bad name of result Cart Tax');
        System.assertEquals('Actual', results[0].TaxType, 'Bad tax type of result Cart Tax');
        System.assertEquals(taxes.Taux_de_TVA__c, results[0].TaxRate, 'Bad tax rate of result Cart Tax');
        //System.assertEquals(30, results[0].Amount, 'Bad amount of result Cart Tax');
        System.assertEquals(B2BCartTaxesCustom.TODAY_DATE, results[0].TaxCalculationDate, 'Bad calculation date of result Cart Tax');
    }

    @IsTest
    private static void testCalculateTaxesSuccessUpdateExisting() {
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin();
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, '5');
        account.Frais_autorisations__c = frais.Id;
        update account;
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 product = createProduct('3');
        CartItem cartItem = createCartItem(cart.Id, product.Id, cdg.Id, 200);
        Taxes__c taxes = createTaxes('3', '5', 15);
        CartTax cartTax = createCartTax(cartItem.Id);
        
        Test.startTest();
        B2BCartTaxesCustom.calculateTaxes(new List<String>{cart.Id});
        Test.stopTest();

        List<CartTax> results = [SELECT Id, CartId, CartItemId, Name, TaxType, TaxRate, Amount, TaxCalculationDate FROM CartTax];
        //System.assertEquals(1, results.size(), 'Bad count of result Cart Taxes');
        //System.assertEquals(cartTax.Id, results[0].Id, 'Bad Id of result Cart Tax');
        System.assertEquals(cart.Id, results[0].CartId, 'Bad cart Id of result Cart Tax');
        System.assertEquals(cartItem.Id, results[0].CartItemId, 'Bad cart item Id of result Cart Tax');
        //System.assertEquals('Dummy CartTax', results[0].Name, 'Bad name of result Cart Tax');
        System.assertEquals('Actual', results[0].TaxType, 'Bad tax type of result Cart Tax');
        System.assertEquals(taxes.Taux_de_TVA__c, results[0].TaxRate, 'Bad tax rate of result Cart Tax');
        //System.assertEquals(30, results[0].Amount, 'Bad amount of result Cart Tax');
        System.assertEquals(B2BCartTaxesCustom.TODAY_DATE, results[0].TaxCalculationDate, 'Bad calculation date of result Cart Tax');
    }
}