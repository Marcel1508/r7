/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Class test of PrixSpecifiqueService class
**/

@IsTest
public class PrixSpecifiqueService_TST {
    private static Magasin__c createMagasin(String extension, String rang) {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Name, 'magasinName')
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
            .put(Account.Name, 'accountName')
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
            .put(Pricebook2.Name, 'accountName magasinName')
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
        MagasinTriggerHandler.bypassTrigger = true;
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        ProductTriggerHandler.bypassTrigger = true;
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
        insert new WebStore(name='Promocash');
        
    }
    
    @IsTest
    private static void testUpdate(){
        Account testAccount = [SELECT ID, isBuyer FROM ACCOUNT limit 1];
        BuyerAccount bacc = TestDataFactory.createBuyerAccount(testAccount.id);
        insert bacc;
        Magasin__c mag = [SELECT ID FROM Magasin__c limit 1];
        BuyerGroup bg = new BuyerGroup();
        bg.name = 'accountName magasinName'; 
        insert bg;
        try {
            Prix_specifiques__c ps = new Prix_specifiques__c(Reference_client__c = testAccount.Id, Libelle_etablissement__c = mag.Id);
            insert ps;
            ps.Prix_de_vente_client__c  = 20;
            update ps;
        } catch(Exception e) {}
    }
    
    @IsTest
    private static void testInsert(){
        Account testAccount = [SELECT ID FROM ACCOUNT limit 1];
        Magasin__c mag = [SELECT ID FROM Magasin__c limit 1];
         BuyerAccount bacc = TestDataFactory.createBuyerAccount(testAccount.id);
        insert bacc;
        delete [SELECT ID FROM BuyerGroup];
        try {
            Prix_specifiques__c ps = new Prix_specifiques__c(Reference_client__c = testAccount.Id, Libelle_etablissement__c = mag.Id);
            insert ps;
        } catch(Exception e) {}
    }

    @IsTest
    private static void testUpdateValidityDate(){
        Account testAccount = [SELECT ID, isBuyer FROM ACCOUNT limit 1];
        BuyerAccount bacc = TestDataFactory.createBuyerAccount(testAccount.id);
        insert bacc;
        Magasin__c mag = [SELECT ID FROM Magasin__c limit 1];
        BuyerGroup bg = new BuyerGroup();
        bg.name = 'accountName magasinName'; 
        insert bg;
        try {
            Prix_specifiques__c ps = new Prix_specifiques__c(Reference_client__c = testAccount.Id, Libelle_etablissement__c = mag.Id, Date_de_debut_d_application__c= Date.newInstance(2023, 02, 01),
            Date_de_fin_d_application__c= Date.Today());
            Prix_specifiques__c ps2 = new Prix_specifiques__c(Reference_client__c = testAccount.Id, Libelle_etablissement__c = mag.Id, Date_de_debut_d_application__c= Date.newInstance(2023, 02, 01),
            Date_de_fin_d_application__c= Date.newInstance(2023, 02, 15));
            insert ps;
            insert ps2;
            ps.Date_de_fin_d_application__c= Date.newInstance(2023, 02, 15);
            ps2.Date_de_fin_d_application__c= Date.Today();
            update ps;
            update ps2;
        } catch(Exception e) {}
    }
}