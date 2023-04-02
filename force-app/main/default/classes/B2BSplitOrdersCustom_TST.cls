/**
 * @CreatedBy       : Suliman A.
 * @Date            : 06/07/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A test class for B2BSplitOrdersCustom class.  
 */

@isTest
public class B2BSplitOrdersCustom_TST {

    private static final String DRIVE = 'Drive';
    private static final String DRIVE_DEPORTE = 'Drive déporté';
    private static final String LIVRAISON = 'Livraison';
    private static final List<String> METHOD_NAMES = new List<String>{DRIVE, DRIVE_DEPORTE, LIVRAISON};
    private static final List<String> METHOD_MINIMUMS = new List<String>{'Minimum_Commande_Drive__c', 'Minimum_Commande_Drive__c', 'Minimum_Commande_Livraison__c'};
    private static final List<String> METHOD_FEES = new List<String>{'Frais_de_Drive__c', 'Frais_drive_deporte__c', 'Frais_de_livraison__c'};
        
    /*IF ( Frais_de_livraison_par_zone__c > 0 ,"Frais par zone de chalandise",
        IF ( !ISNULL(Taux_de_majoration_livraison__c), "Frais fixes",
     		IF ( !ISNULL( Taux_majoration_CA_tranche_1__c ), 
    			ELSE"Frais par tranche de CA",*/
    
    private static Magasin__c createMagasin(Decimal tauxMajorationLivraison, Decimal tauxMajorationTrancheCA ) {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Pourcentage_additionel_carte__c , 12)
            .put(Magasin__c.Minimum_Commande_Drive__c , 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c , 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c , 15)
            .put(Magasin__c.Forfait_majoration_livraison__c , 10)
            .put(Magasin__c.Taux_de_majoration_livraison__c , tauxMajorationLivraison)
            .put(Magasin__c.Taux_majoration_CA_tranche_1__c , tauxMajorationTrancheCA)
            .put(Magasin__c.Montant_FEF__c , 5)
            .put(Magasin__c.API_Key__c , '12Test')
            .create().getRecord();
    }
    
    private static Account createAccount(Id magasinId) {
        return (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.Magasin_actif_en_cours__c, magasinId)
            .put(Account.Magasin_actif_en_cours__c, magasinId)
            .put(Account.ShippingPostalCode, '16000')
            .put(Account.ShippingCity, 'Angouleme')
            .create().getRecord();
    }
    
    private static Frais_par_Zone_de_Chalandise__c createFraisParZoneDeChalandise(Id magasinId) {
        return (Frais_par_Zone_de_Chalandise__c) new SObjectBuilder(Frais_par_Zone_de_Chalandise__c.SObjectType)
            .put(Frais_par_Zone_de_Chalandise__c.Magasin__c, magasinId)
            .put(Frais_par_Zone_de_Chalandise__c.Forfait_de_majoration__c, 20)
            .put(Frais_par_Zone_de_Chalandise__c.Taux_majoration__c, 10)
            .put(Frais_par_Zone_de_Chalandise__c.Code_zone_de_chalandise__c, '1')
            .create().getRecord();
    }
    
    private static Zone_de_Chalandise__c createZoneDeChalandise (Id magasinId, String shippingPostalCode, String shippingCity) {
        return (Zone_de_Chalandise__c) new SObjectBuilder(Zone_de_Chalandise__c.SObjectType)
            .put(Zone_de_Chalandise__c.Magasin__c, magasinId)
            .put(Zone_de_Chalandise__c.Code_Chalandise__c, '1')
            .put(Zone_de_Chalandise__c.Code_postal_text__c, shippingPostalCode)
            .put(Zone_de_Chalandise__c.Libelle_ville__c, shippingCity)
            .create().getRecord();
    }

    private static WebCart createCart(Id accountId) {
        return (WebCart) new SObjectBuilder(WebCart.SObjectType)
            .put(WebCart.AccountId, accountId)
            .create().getRecord();
    }
    
    private static Product2 createProduct() {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .create().getRecord();
    }

    private static CartDeliveryGroup createCartDeliveryGroup(Id cartId) {
        return (CartDeliveryGroup) new SObjectBuilder(CartDeliveryGroup.SObjectType)
            .put(CartDeliveryGroup.CartId, cartId)
            .create().getRecord();
    }
    
    private static En_tete_Promotion__c createEnTetePromotion() {
        return (En_tete_Promotion__c) new SObjectBuilder(En_tete_Promotion__c.SObjectType)
            .put(En_tete_Promotion__c.Name, 'Promo test')
            .put(En_tete_Promotion__c.Type_Envoi__c, 'T')
            .create().getRecord();
    }
    
    private static Promotion__c createPromotion(Id enTetePromoID, Id productId, Id magasinId) {
        return (Promotion__c) new SObjectBuilder(Promotion__c.SObjectType)
            .put(Promotion__c.En_tete_Promotion__c, enTetePromoID)
            .put(Promotion__c.Produit__c, productId)
            .put(Promotion__c.Magasin__c, magasinId)
            .put(Promotion__c.Date_de_debut_de_promotion__c, Date.today().addDays(-2))
            .put(Promotion__c.Date_de_fin_de_promotion__c, Date.today().addDays(+3))
            .create().getRecord();
    }
    

    private static CartItem createCartItem(Id cartId, Id productId, Id cartDeliveryGroupId, Decimal amount, Decimal availableQuantity, Id promoId) {
        return (CartItem) new SObjectBuilder(CartItem.SObjectType)
            .put(CartItem.CartId, cartId)
            .put(CartItem.Product2Id, productId)
            .put(CartItem.TotalLineAmount, amount)
            .put(CartItem.CartDeliveryGroupId, cartDeliveryGroupId)
            .put(CartItem.Available_Quantity__c, availableQuantity)
            .put(CartItem.Quantity, 10)
            .put(CartItem.ListPrice, 10)
            .put(CartItem.AdjustmentAmount, 10)
            .put(CartItem.UnitAdjustedPrice, 10)
            .put(CartItem.Type, 'Product')
            .put(CartItem.Promotion__c, promoId)
            .create().getRecord();
    }

    /*IF ( !ISNULL( Taux_de_majoration_zone__c ) ,"Frais par zone de chalandise",
    IF ( !ISNULL( Taux_de_majoration_livraison__c ), "Frais fixes",
    IF ( !ISNULL( Taux_majoration_CA_tranche_1__c ), "Frais par tranche de CA",
    ELSE "Pas de frais négociés"*/
        
    private static Frais__c createFrais(Id accountId, Id magasinId, String zoneTerritoriale, Decimal tauxMajorationZone, Decimal tauxMajorationLivraison, Decimal tauxMajorationTrancheCA, Decimal forfaitMajorationZone, Decimal forfaitMajorationLivraison ) {
        return (Frais__c) new SObjectBuilder(Frais__c.SObjectType)
            .put(Frais__c.Account__c, accountId)
            .put(Frais__c.Magasin_Associe__c, magasinId)
            .put(Frais__c.Taux_de_majoration_zone__c , tauxMajorationZone)
            .put(Frais__c.Taux_de_majoration_livraison__c , tauxMajorationLivraison)
            .put(Frais__c.Taux_majoration_CA_tranche_1__c , tauxMajorationTrancheCA)
            .put(Frais__c.Zone_territoriale__c, zoneTerritoriale)
            .put(Frais__c.Forfait_majoration_livraison__c, forfaitMajorationLivraison)
            .put(Frais__c.Forfait_majoration_zone__c, forfaitMajorationZone)
            .put(Frais__c.Taux_de_majoration_preparation__c, 10)
            .put(Frais__c.Indicateur_FEF__c,'O')
            .create().getRecord();
    }

    
    private static Taxes__c createTaxes(String codeTVA, String zoneTerritoriale, Decimal tauxDeTVA) {
        return (Taxes__c) new SObjectBuilder(Taxes__c.SObjectType)
            .put(Taxes__c.Code_TVA__c, codeTVA)
            .put(Taxes__c.Zone_Territoriale__c, zoneTerritoriale)
            .put(Taxes__c.Taux_de_TVA__c, tauxDeTVA)
            .create().getRecord();
    }

    private static CartTax createCartTaxTVA(Id cartItemId) {
        return (CartTax) new SObjectBuilder(CartTax.SObjectType)
            .put(CartTax.CartItemId, cartItemId)
            .put(CartTax.Name, 'TVA')
            .create().getRecord();
    }
    
    private static CartTax createCartTaxEcotaxe(Id cartItemId) {
        return (CartTax) new SObjectBuilder(CartTax.SObjectType)
            .put(CartTax.CartItemId, cartItemId)
            .put(CartTax.Name, 'Ecotaxe')
            .create().getRecord();
    }
    
    private static CartTax createCartTaxConsigne(Id cartItemId) {
        return (CartTax) new SObjectBuilder(CartTax.SObjectType)
            .put(CartTax.CartItemId, cartItemId)
            .put(CartTax.Name, 'Consigne')
            .create().getRecord();
    }
    
    private static CartTax createCartTaxVignetteAlcool(Id cartItemId) {
        return (CartTax) new SObjectBuilder(CartTax.SObjectType)
            .put(CartTax.CartItemId, cartItemId)
            .put(CartTax.Name, 'Taxe Vignette Alcool')
            .create().getRecord();
    }
      
    private static Order createOrder(Id accountId) {
        return (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, accountId)
                .create().getRecord();
    }
    
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
                .put(OrderDeliveryMethod.IsActive, true)
                .put(OrderDeliveryMethod.Name, 'Default Delivery Method')
                .build().getRecord());
        insert deliveryMethods;
        return deliveryMethods;
    }
    
    @isTest
    private static void checkoutDeliveryMethodNoTaux(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(10, null);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        Frais_par_Zone_de_Chalandise__c fraisParZoneChalandise = createFraisParZoneDeChalandise(magasin.Id);
        Zone_de_Chalandise__c zonedechalandise = createZoneDeChalandise (magasin.Id,'16000', 'Angouleme'); 
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 30, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', null, null, null,20,20);
        Taxes__c tax = createTaxes('3', '5', 15);
        CartTax cartTaxConsigne =  createCartTaxConsigne(cartItem.Id);
        CartTax cartTaxEcotaxe =  createCartTaxEcotaxe(cartItem.Id);
        CartTax cartTaxTVA =  createCartTaxTVA(cartItem.Id);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
          
        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    } 
    
    @isTest
    private static void checkoutDeliveryMethodFraisFixes(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(10, null);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 30, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', null, null, null,null,20);
        Taxes__c tax = createTaxes('3', '5', 15);
        CartTax cartTaxConsigne =  createCartTaxConsigne(cartItem.Id);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
          
        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    } 
    @isTest
    private static void checkoutDeliveryMethodTrancheCA(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, 5);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 30, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', null, null, 15,20,20);
        Taxes__c tax = createTaxes('3', '5', 15);
        CartTax cartTaxConsigne =  createCartTaxConsigne(cartItem.Id);
        CartTax cartTaxEcotaxe =  createCartTaxEcotaxe(cartItem.Id);
        CartTax cartTaxTVA =  createCartTaxTVA(cartItem.Id);
        CartTax cartTaxVignetteAlccol = createCartTaxVignetteAlcool(cartItem.Id);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
    @isTest
    private static void checkoutDeliveryMethodLivraison(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(10, 5);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 30, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', null, 10, null,20,20);
        Taxes__c tax = createTaxes('3', '5', 15);
        CartTax cartTaxConsigne =  createCartTaxConsigne(cartItem.Id);
        CartTax cartTaxEcotaxe =  createCartTaxEcotaxe(cartItem.Id);
        CartTax cartTaxTVA =  createCartTaxTVA(cartItem.Id);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
   
        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
    @isTest
    private static void checkoutDeliveryMethodZoneDeChalandise(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, 5);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 30, promo.Id);
        CartItem cartItem1 = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 0, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', 0, null, null,0,null);
        Zone_de_Chalandise__c zoneDeChalandise = createZoneDeChalandise (magasin.Id, '16000', 'Angouleme');
        Frais_par_Zone_de_Chalandise__c fraisParZoneDeChalandise = createFraisParZoneDeChalandise(magasin.Id);
        Taxes__c tax = createTaxes('3', '5', 15);
        CartTax cartTaxConsigne =  createCartTaxConsigne(cartItem.Id);
        CartTax cartTaxEcotaxe =  createCartTaxEcotaxe(cartItem.Id);
        CartTax cartTaxTVA =  createCartTaxTVA(cartItem.Id);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
                        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
    @isTest
    private static void checkoutDeliveryMethod(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, null);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 30, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', 5, null, null,20,20);
        Taxes__c tax = createTaxes('3', '5', 15);
        CartTax cartTaxConsigne =  createCartTaxConsigne(cartItem.Id);
        CartTax cartTaxEcotaxe =  createCartTaxEcotaxe(cartItem.Id);
        CartTax cartTaxTVA =  createCartTaxTVA(cartItem.Id);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
    @isTest
    private static void checkoutDeliveryMethodWithoutFrais(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, 5);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        update account;
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
                        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
     @isTest
    private static void checkoutDeliveryMethodWithoutMagasin(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, 5);
        Account account = createAccount(magasin.Id);
        delete magasin;
        WebCart cart = createCart(account.Id);
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
                        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    @isTest
    private static void checkoutDeliveryMethodWithoutAccount(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, 5);
        Account account = createAccount(magasin.Id);
        WebCart cart = createCart(account.Id);
        delete account;
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
                        Test.startTest();
        try {
                        B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
    @isTest
    private static void checkoutDeliveryMethodInAndOutOfTheStock(){
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(null, 5);
        Account account = createAccount(magasin.Id);
        Order order = createOrder(account.Id);
        WebCart cart = createCart(account.Id);
        CartDeliveryGroup cdg = createCartDeliveryGroup(cart.Id);
        Product2 prod = createProduct();
        En_tete_Promotion__c enTetePromo = createEnTetePromotion();
        Promotion__c promo =  createPromotion(enTetePromo.Id, prod.Id, magasin.Id);
        CartItem cartItem = createCartItem(cart.Id, prod.Id, cdg.Id, 200, 7, promo.Id);
        //CartItem cartItem2 = createCartItem(cart.Id, prod.Id, cdg.Id, 250, 0);
        Frais__c frais = createFrais(account.Id, magasin.Id, '0', null, null, 15,null,null);
        account.Frais_autorisations__c = frais.Id;
        update account;
        createDeliveryMethods();
        Exception caughtException;
        //Get Wrapper class
        B2BSplitOrdersCustom.RequestWrapper wrapper= new B2BSplitOrdersCustom.RequestWrapper();
        wrapper.cartId = cart.Id;
        wrapper.realUserId = UserInfo.getUserId();
        Test.startTest();
        try {
            B2BSplitOrdersCustom.splitCartToOrders(new List<B2BSplitOrdersCustom.RequestWrapper>{wrapper});
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
    }
    
    }