/* .
--------------------------------------------------------------------------------------
Version#     Date                   Author                    Description
--------------------------------------------------------------------------------------
1.1          22-02-2022       		Preethi U               Test Class update
--------------------------------------------------------------------------------------
*/ 
@isTest
public class TestDataFactory {
    
    public static Account createAccountRecord(){
        Magasin__c  testMagasin = [select Name from Magasin__c where Name='Test Magasin'];
        Account accRec = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
            .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            .create ()
            .getRecord(); 
        return accRec;
    }
    
    public static Account createProspectAccount(Account acc){
        acc.Name='Aj-AccountData';
        acc.Statut_Fiche_client__c='Prospect';
        return acc;
    }
    
    public static Account createAccountwithOutMagasin(){
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST Account')
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .build().getRecord();
        return testAccount;
    }
    public static BuyerAccount createBuyerAccount(ID accId){
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = accId;
        buyerAccount.Name = 'Test Buyer Account';
        buyerAccount.IsActive = true;
        return buyerAccount;
    }
    
    public static Magasin__c createMagasinRecord(){
        Magasin__c  magasinRec = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'Test Magasin')
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5) 
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.Services_disponibles__c, 'Autres')
            .put(Magasin__c.API_Key__c, 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq') 
            .create ().getRecord();
        return magasinRec;
    }
    public static Account createMagasinWithAcc(){
        Magasin__c  magasinRec = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'Test Magasin')	
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .put(Magasin__c.Pourcentage_additionel_carte__c, 10)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5) 
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.Services_disponibles__c, 'Autres')
            .put(Magasin__c.API_Key__c, 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq') 
            .create ().getRecord();
        
        Account accRec = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'Test Account') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasinRec.id) 
            .put(Account.Magasin_actif_en_cours__c, magasinRec.id)	
            .create ()
            .getRecord(); 
        return accRec;
        
    }
    public static Contact createContactRecord(Id accID){
        Contact testContact = (Contact) new sObjectbuilder(Contact.sObjectType)	
            .put(Contact.FirstName, 'TEST')
            .put(Contact.LastName, 'TestContact')
            .put(Contact.Roles__c, 'Autre')
            .put(Contact.Contact_principal__c, True)
            .put(Contact.Email, 'test@carrefour.com')
            .put(Contact.AccountId, accID)
            .build().getRecord();
        return testContact;
    }
    
    public static User createUserRecord(){
        Profile customerCommunityPlus = [SELECT Id FROM Profile WHERE Name = 'Customer Community +'];
        User customer = (User)
            new SObjectBuilder(User.SObjectType)
            .put(User.ProfileId, customerCommunityPlus.Id)
            .put(User.FirstName, 'The')
            .put(User.LastName, 'Customer')
            .put(User.UserName, 'theCustomer@carrefour.com')
            //   .put(User.ContactId, con.Id)
            .build().getRecord();
        return customer;
    }
    
    public static Order createOrderRecord(ID accountId){
        Id pricebookId = Test.getStandardPricebookId();
        Order testOrder = (Order) new SObjectBuilder(Order.SObjectType)
            .put(Order.Pricebook2Id, pricebookId)
            .put(Order.status, 'Draft order')
            .put(Order.Origine_de_la_commande__c, 'E-commerce')
            .put(Order.EffectiveDate, system.today())
            .put(Order.Montant_Commande_TTC__c,23)
            .put(Order.Commande_payee__c,'O')
            .put(Order.Commande_en_stock__c, 'O')
            .put(Order.Mode_de_retrait__c, '1')
            .put(Order.AccountId, accountId)
            .put(Order.Preauthorize_Uuid__c, '123')
            .put(Order.CurrencyIsoCode, 'EUR')
            .put(Order.Description, 'EUR')
            .put(Order.BillingStreet, 'BillStreet')
            .put(Order.BillingCity, 'BillCity')
            .put(Order.BillingPostalCode, 'BillZipCode')
            .put(Order.BillingCountry, 'France')
            .put(Order.ShippingStreet, 'ShipStreet')
            .put(Order.ShippingCity, 'ShipCity')
            .put(Order.ShippingPostalCode, 'ShipZipCode')
            .put(Order.ShippingCountry, 'France')
            .build().getRecord(); 
        return testOrder;
    }
    
    public static Facture__c createFactureRecord(ID accountId){
        Facture__c testFacture = (Facture__c)
            new SObjectBuilder(Facture__c.SObjectType)
            .put(Facture__c.Magasin__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.SObjectType))
            .put(Facture__c.Montant_TTC_de_la_facture__c, 1000)
            .put(Facture__c.Code_carte_client__c, accountId)
            .build().getRecord();
        return testFacture;
    }
    
    public static list<Order> createOrderList(ID accountId){
        List<Order> orders = (List<Order>)
            new SObjectBuilder(Order.sObjectType)
            .put(Order.AccountId, accountId)
            .put(Order.Magasin_actif__c, null)
            .count(10).build().getRecords();
        return orders;
    }
    
    /* public static List<Facture__c> createFactureList(){

Magasin__c  testMagasin = [select Name from Magasin__c where Name='Test Magasin'];
Account  testAccount = [select Name from Account where Name='Test Account' limit 1];
list<Order> ordList = createOrderList();
Set<Id> orderIds = Pluck.ids(ordList);

List<Facture__c> factures = (List<Facture__c>)
new SObjectBuilder(Facture__c.SObjectType)
.put(Facture__c.Commande__c, new SObjectFieldProviders.ListProvider(new List<Id>(orderIds)))
.put(Facture__c.Magasin__c, testMagasin.Id)
.put(Facture__c.Montant_TTC_de_la_facture__c, 1000)
.put(Facture__c.Code_carte_client__c, testAccount.Id)
.count(10).create().getRecords();
return factures;
} */
    
    public static Codes_Postaux__c createCodePostauxRecord(String name, String codePostal, String pays, String commune){
        Codes_Postaux__c cpo = new Codes_Postaux__c();
        cpo.Name = name;
        cpo.Code_postal__c = codePostal;
        cpo.Pays__c = pays;
        cpo.Commune__c = commune;
        return cpo;
    }
    
    public static ContactPointAddress createContactPointAddressRecord(ContactPointAddress cpa,String AddressType){
        cpa.AddressType=AddressType;
        cpa.City='Kanpur';
        cpa.Name='testContactPoint';
        cpa.Street='K 288 D';
        cpa.IsDefault=true;
        cpa.N_habite_pas_ladresse_indiquee__c=true;
        cpa.Nom_de_voie__c='test';
        cpa.Complement_d_adresse__c='115/288D';
        cpa.Numero_de_voie__c='99';
        cpa.Type_de_voie__c='AV';
        
        return cpa;
    }
    
    public static WebStore createWebStoreRecord(){
        WebStore testWebStore = (WebStore)
            new SObjectBuilder(WebStore.SObjectType)
            .put(WebStore.DefaultLanguage, 'fr')
            .put(WebStore.Name, 'TestWebStore')
            .build().getRecord();
        return testWebStore;
    }
    
    public static WebCart createWebCartRecord(ID accountId){
        WebCart testWebCart = (WebCart)
            new SObjectBuilder(WebCart.SObjectType)
            .put(WebCart.AccountId, accountId)
            .put(WebCart.Name, 'Cart')
            .put(WebCart.Status, 'Active')
            .build().getRecord();
        return testWebCart;
    }
    
    public static wishList createwishListRecord(ID testWebStore, ID accountId){
        Wishlist testWishlist = (Wishlist)
            new SObjectBuilder(Wishlist.SObjectType)
            .put(Wishlist.AccountId, accountId)
            .put(Wishlist.Name, 'wishList Test')
            .put(Wishlist.WebStoreId, testWebStore)
            .build().getRecord();
        return testWishlist;
    }
    
    public static Order createOrder(Id pricebookId) {
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .create().getRecord();
        
        Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST Account')
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
            .create().getRecord();
        
        return (Order) new SObjectBuilder(Order.SObjectType)
            .put(Order.Pricebook2Id, pricebookId)
            .put(Order.status, 'Draft order')
            .put(Order.AccountId, testAccount.Id)	
            .build().getRecord();
    }
    
    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Id productId) {
        return (OrderItem) new SObjectBuilder(OrderItem.SObjectType)
            .put(OrderItem.OrderId, orderId)
            .put(OrderItem.PricebookEntryId, pricebookEntryId)
            .put(OrderItem.Product2Id, productId)
            .create().getRecord();
    }
    
    public static Product2 createProduct() {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .create().getRecord();
    }
    
    /** Return Test Records with out inserting into Salesforce Objects  **/
    
    //Create Generic Account that returns just the account initialized
    //record where the test class would insert the record.
    public static Account createGenericAccountRecord(String accName, String clientType, Magasin__c testMagasin){
        Account accRec = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, accName) 
            .put(Account.Statut_Fiche_client__c, clientType) 
            .put(Account.Magasin_de_rattachement__c, testMagasin.Id)
            .put(Account.Magasin_actif_en_cours__c, testMagasin.Id)
            .build().getRecord();
        return accRec;
    }
    
    public static Code_APE__c createCodeAPE(String codeName){
        Code_APE__c  codeAPE = (Code_APE__c ) new SObjectBuilder(Code_APE__c.SObjectType)
            .put(Code_APE__c.Name, codeName)
            .put(Code_APE__c.APE_code__c, 'P13')
            .put(Code_APE__c.Code_specialisation__c, 'A1')
            .build().getRecord();
        return codeAPE;
    }
    
    
    public static Account createGenericAccwithCodeAPE(ID megID, ID codeID, String clientType){
        Magasin__c  testMagasin = [select Name from Magasin__c where Id=:megID];
        Code_APE__c codeAPE = [Select Id from Code_APE__c where Id=:codeID];
        Account acc = createGenericAccountRecord('testAcc','Prospect',testMagasin);
        acc.Magasin_actif_en_cours__c=testMagasin.Id;
        acc.Magasin_de_rattachement__c=testMagasin.Id;
        acc.code_APE__c = codeAPE.Id;
        return acc;
    }
    
    public static Magasin__c createGenericMagasin(String megName){
        Magasin__c  magasinRec = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, megName)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5) 
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.Services_disponibles__c, 'Autres')
            .put(Magasin__c.API_Key__c, 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq'+megName)
            .build().getRecord();
        return magasinRec;
    }
    
    public static WebCart createGenericWebCartRecord(ID accountId){
        WebCart testWebCart = (WebCart)
            new SObjectBuilder(WebCart.SObjectType)
            .put(WebCart.AccountId, accountId)
            .put(WebCart.Name, 'Cart')
            .put(WebCart.Status, 'Active')
            .build().getRecord();
        return testWebCart;
    }
    
    public static Creneau_Salesforce__c createSfSlot() {
        return (Creneau_Salesforce__c)
            new SObjectBuilder(Creneau_Salesforce__c.sObjectType)
            .put(Creneau_Salesforce__c.Magasin__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.sObjectType))
            .build().getRecord();
    }
    
    public static PricebookEntry createPricebookEntry() {
        return (PricebookEntry) 
            new SObjectBuilder(PricebookEntry.SObjectType)
            .build().getRecord();
    }
    
    public static Order createGenericOrderRecord(ID accountId){
        Id pricebookId = Test.getStandardPricebookId();
        Order testOrder = (Order) new SObjectBuilder(Order.SObjectType)
            .put(Order.Pricebook2Id, pricebookId)
            .put(Order.status, 'Draft order')
            .put(Order.Origine_de_la_commande__c, 'E-commerce')
            .put(Order.EffectiveDate, system.today())
            .put(Order.Montant_Commande_TTC__c,23)
            .put(Order.Commande_payee__c,'O')
            .put(Order.Commande_en_stock__c, 'O')
            .put(Order.Mode_de_retrait__c, '1')
            .put(Order.AccountId, accountId)
            .put(Order.Preauthorize_Uuid__c, '123')
            .put(Order.CurrencyIsoCode, 'EUR')
            .put(Order.Description, 'EUR')
            .put(Order.BillingStreet, 'BillStreet')
            .put(Order.BillingCity, 'BillCity')
            .put(Order.BillingPostalCode, 'BillZipCode')
            .put(Order.BillingCountry, 'France')
            .put(Order.ShippingStreet, 'ShipStreet')
            .put(Order.ShippingCity, 'ShipCity')
            .put(Order.ShippingPostalCode, 'ShipZipCode')
            .put(Order.ShippingCountry, 'France')
            .build().getRecord(); 
        return testOrder;
    }
    
    public static OrderItem createGenericOrderItem(Id orderId, Id pricebookEntryId, Id productId) {
        return (OrderItem) new SObjectBuilder(OrderItem.SObjectType)
            .put(OrderItem.OrderId, orderId)
            .put(OrderItem.PricebookEntryId, pricebookEntryId)
            .put(OrderItem.Product2Id, productId)
            .build().getRecord();
    }
    
    public static Product2 createGenericProduct() {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .build().getRecord();
    }
    
    public static Product_Image_URL__c createProductImageURL(Id productId, String productImageURL, String productURLVignette, String ordreAffichage ) {
        return (Product_Image_URL__c) new SObjectBuilder(Product_Image_URL__c.SObjectType)
            .put(Product_Image_URL__c.ProductId__c, productId)
            .put(Product_Image_URL__c.Product_Image_URL__c, productImageURL)
            .put(Product_Image_URL__c.Product_URL_Vignette__c, productURLVignette)
            .put(Product_Image_URL__c.AlternativeText__c, 'AlternativeText') 
            .create().getRecord();
    }
    
    private static User prepareUser(String roleId, String profId, String firstName, String lastName) {  
        
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
            String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profId
        );    
        if( String.isBlank(roleId) == false ){
            tempUser.UserRoleId = roleId;
        }
        return tempUser;  
    }
    
    
    
    public static User createCommunityUser(String contactId, String profId, String firstName, String lastName) {
        User tempUser = prepareUser('', profId, firstName, lastName);
        tempUser.ContactId = contactId;
        return tempUser;
    }
    
    public static Magasin__c createMagasin() {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c,'123')
            .create().getRecord();
    }
    
    public static Promotion__c createPromotion(String magasinId,String productId, Date debutPromoDate, Date finPromoDate, String mecaniquePromoId  ) {
        return  (Promotion__c) new SObjectBuilder(Promotion__c.SObjectType)
            .put(Promotion__c.Magasin__c, magasinId)
            .put(Promotion__c.Produit__c, productId)
            .put(Promotion__c.Date_de_debut_de_promotion__c, debutPromoDate)
            .put(Promotion__c.Date_de_fin_de_promotion__c, finPromoDate) 
            .put(Promotion__c.Mecanique_Promotion__c, mecaniquePromoId )
            .put(Promotion__c.Prix_sous_mecanique__c, 15 ) 
            .create().getRecord();
 
    }
    
    public static List<Promotion__c> createPromotions(String magasinId,List<String> productsIds, Date debutPromoDate, Date finPromoDate) {
        List<Promotion__c> promotionsToCreate = new List<Promotion__c>();
        Promotion__c promo;
        
        for(Integer i=1;i<=200;i++){ 
            promo =  new Promotion__c(Magasin__c = magasinId, Produit__c = productsIds[i-1], Date_de_debut_de_promotion__c=debutPromoDate,Date_de_fin_de_promotion__c= finPromoDate);
            promotionsToCreate.add(promo);
        }
        insert promotionsToCreate;
        return promotionsToCreate;
    }
    
    public static List<Mecanique_Promotion__c> createMecaniquesPromotions(String magasinId, List<String> productsIds, Date debutUtilisationDate, Date finUtilisationDate ) {
        List<Mecanique_Promotion__c> mecaniquesPromotionsToCreate = new List<Mecanique_Promotion__c>();
        Mecanique_Promotion__c mecaniquePromo;
        
        for(Integer i=1;i<=200;i++){
            mecaniquePromo =  new Mecanique_Promotion__c(Magasin__c = magasinId, Produit__c = productsIds[i-1], Date_d_utilisation_debut__c = debutUtilisationDate,  Date_d_utilisation_fin__c= finUtilisationDate );
            mecaniquesPromotionsToCreate.add(mecaniquePromo);
        }
        insert mecaniquesPromotionsToCreate;
        return mecaniquesPromotionsToCreate;
    }
    
    public static List<String> createProducts() {
        List<Product2> productsToCreate = new List<Product2>();
        List<String> productsIds = new List<String>();
        Product2 product;
        String productName;
        String productCodeBase;
        for(Integer i=1;i<=200;i++){
            productName= 'product test data'+ i;
            productCodeBase = '01'+i;
            product = new Product2(Name=productName,Code_base__c=productCodeBase);
            productsToCreate.add(product);
           
        }
        insert productsToCreate;
        for(Product2 p: [SELECT Id, Code_base__c from Product2 where Name like 'product test data%'])
        {
            productsIds.add(p.Id);
        }
        
        return productsIds;
    }
    
     public static CartItem createCartItem(Id cartId, Id productId, Id cartDeliveryGroupId, Decimal amount) {
        return (CartItem) new SObjectBuilder(CartItem.SObjectType)
            .put(CartItem.CartId, cartId)
            .put(CartItem.Product2Id, productId)
            .put(CartItem.Quantity, 2)
            .put(CartItem.TotalLineAmount, amount)
            .put(CartItem.CartDeliveryGroupId, cartDeliveryGroupId)
            .create().getRecord();
    }
    
    public static WebCart createCart(Id accountId) {
        return (WebCart) new SObjectBuilder(WebCart.SObjectType)
            .put(WebCart.AccountId, accountId)
            .create().getRecord();
    }
    
    public static CartDeliveryGroup createCartDeliveryGroup(Id cartId) {
        return (CartDeliveryGroup) new SObjectBuilder(CartDeliveryGroup.SObjectType)
            .put(CartDeliveryGroup.CartId, cartId)
            .create().getRecord();
    }
    
    public static Mecanique_Promotion__c createMecaniquePromotion(String typeOffre, String TypePromotion) {
        return (Mecanique_Promotion__c) new SObjectBuilder(Mecanique_Promotion__c.SObjectType)
            .put(Mecanique_Promotion__c.Type_d_offre__c, typeOffre)
            .put(Mecanique_Promotion__c.Type_de_promotion__c, TypePromotion)
            .create().getRecord();
    }
    
    
    public static Offre_Produit_Magasin__c createOPM(Id magasinId, Id productId, String produitActif) {
        return (Offre_Produit_Magasin__c) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinId)
            .put(Offre_Produit_Magasin__c.Produit__c, productId)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, produitActif)
            .create().getRecord();
    }
    
    

    
}