@isTest
public class B2BSearchControllerCustomTest {
    private static Magasin__c createMagasin(String extension, String rang) {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, extension)
            .put(Magasin__c.Rang_tarifaire__c, rang)
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
    }
    private static Account createAccount(Id magasinId) {
        return (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.Magasin_actif_en_cours__c, magasinId)
            .put(Account.OwnerId, UserInfo.getUserId())
            .create().getRecord();
    }
    private static Product2 createProduct() {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .create().getRecord();
    }
    
    private static Pricebook2 createPriceBook() {
        return (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
    }
    private static Offre_Produit_Magasin__c createOPM(Id magasinId, Id productId, String produitActif) {
        return (Offre_Produit_Magasin__c) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinId)
            .put(Offre_Produit_Magasin__c.Produit__c, productId)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, produitActif)
            .create().getRecord();
    }
    @testSetup
    private static void init() {
        AccountTriggerHandler.bypassTrigger = true;
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct();
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        //Insert a price book entry for the standard price book.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = testProduct.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        insert standardPrice;
        Pricebook2 testPricebook = createPriceBook();
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O');
    }
    
    @IsTest
    private static void testExtraInfo(){
        Product2 testProduct = [SELECT ID FROM Product2 limit 1];
        Account testAccount = [SELECT ID FROM ACCOUNT limit 1];
        
        Test.startTest();
        B2BSearchControllerCustom.getExtraInfoPLP(new List<String>{testProduct.Id}, testAccount.Id);
        B2BSearchControllerCustom.getExtraInfoPLP(new List<String>{testProduct.Id}, '000000000000000');
        Test.stopTest();
    }
    @IsTest
    private static void opmSearch(){
        Product2 testProduct = [SELECT ID FROM Product2 limit 1];
        Account testAccount = [SELECT ID FROM ACCOUNT limit 1];
        
        Test.startTest();
        B2BSearchControllerCustom.opmSearch(testProduct.Id, testAccount.Id);
        Test.stopTest();
    }
    
    @IsTest
    private static void productSearchSuccess(){
        Product2 testProduct = [SELECT ID FROM Product2 limit 1];
        Account testAccount = [SELECT ID FROM ACCOUNT limit 1];
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, '{"example":"test"}'));
        Test.startTest();
        B2BSearchControllerCustom.productSearch(null, '{"name": "prod"}', testAccount.Id);
        B2BSearchControllerCustom.productSearch(null, '{"name": "prod"}', null); //Guest user
        B2BSearchControllerCustom.productSearch(null, '{"name": "prod"}', testAccount.Id);
        B2BSearchControllerCustom.productSearch(null, '{"name": "prod"}', null); //Guest user

        Test.stopTest();
    }
    
    @IsTest
    private static void productSearchError(){
        Product2 testProduct = [SELECT ID FROM Product2 limit 1];
        Account testAccount = [SELECT ID FROM ACCOUNT limit 1];
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(400, '{"example":"test"}'));
        Test.startTest();
        try {
            B2BSearchControllerCustom.productSearch(null, '{"name": "prod"}', testAccount.Id);   
        } catch(Exception e) {}
        Test.stopTest();
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public HttpCalloutMockImpl(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}