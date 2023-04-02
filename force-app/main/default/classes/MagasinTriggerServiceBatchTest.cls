@isTest
public class MagasinTriggerServiceBatchTest {
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
    private static Product2 createProduct(String assor, Boolean ext) {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c , assor)
            .put(Product2.Extension_de_gamme__c, ext)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
    }
    
    private static Pricebook2 createPriceBook() {
        return (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
    }
    private static Offre_Produit_Magasin__c createOPM(Id magasinId, Id productId, String produitActif, String prodAvec) {
        return (Offre_Produit_Magasin__c) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinId)
            .put(Offre_Produit_Magasin__c.Produit__c, productId)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, produitActif)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, prodAvec)
            .create().getRecord();
    }
    
    @IsTest
    private static void testUpdateOPM(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct('1', false);
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
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O','1');
        
        Test.startTest(); 
        MagasinTriggerServiceBatch mtb = new MagasinTriggerServiceBatch(new List<Magasin__c>{testMagasin});
        Id batchId = Database.executeBatch(mtb);
        Test.stopTest();
    }
    
    @IsTest
    private static void testOPM2(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct('0', false);
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
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O','2');
        
        Test.startTest(); 
        MagasinTriggerServiceBatch mtb = new MagasinTriggerServiceBatch(new List<Magasin__c>{testMagasin});
        Id batchId = Database.executeBatch(mtb);
        Test.stopTest();
    }
    
    @IsTest
    private static void testOPM2Uknown(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct('0', true);
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
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O','0');
        
        Test.startTest(); 
        MagasinTriggerServiceBatch mtb = new MagasinTriggerServiceBatch(new List<Magasin__c>{testMagasin});
        Id batchId = Database.executeBatch(mtb);
        Test.stopTest();
    }
    
    @IsTest
    private static void test2(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct('X', false);
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
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'N','null');
        testOPM.Niveau_de_stock__c = 0;
        testOPM.En_cours_de_commande__c = 0;
        update testOPM;
        Test.startTest(); 
        MagasinTriggerServiceBatch mtb = new MagasinTriggerServiceBatch(new List<Magasin__c>{testMagasin});
        mtb.prixVenteActif = true;
        Id batchId = Database.executeBatch(mtb);
        Test.stopTest();
    }
    
    @IsTest
    private static void checkExistingPrices(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        testMagasin.Rang_tarifaire__c = 'T2';
        update testMagasin;
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct('X', false);
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
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'N','0');
        testOPM.Prix_de_vente_magasin__c = 0;
        update testOPM;

        testOPM = [SELECT ID, Prix_de_vente_magasin__c, Rang_tarifaire__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        Test.startTest(); 
        MagasinTriggerServiceBatch mtb = new MagasinTriggerServiceBatch(new List<Magasin__c>{testMagasin});
        mtb.checkExistingPrices(testOPM);
        
        testMagasin.Rang_tarifaire__c = 'T3';
        update testMagasin;
        testOPM = [SELECT ID, Prix_de_vente_magasin__c, Rang_tarifaire__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        mtb.checkExistingPrices(testOPM);
        //Test3
        testOPM.Prix_de_vente_magasin__c = 12;
        update testOPM;
        testOPM = [SELECT ID, Prix_de_vente_magasin__c, Rang_tarifaire__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        mtb.checkExistingPrices(testOPM);
        
        Test.stopTest();
    }
    
    @IsTest
    private static void checkExistInAquilon(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        testMagasin.Rang_tarifaire__c = 'T2';
        update testMagasin;
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct('X', false);
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
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'N','1');

        testOPM = [SELECT ID, Actif_Aquilon__c, Prix_de_vente_magasin__c, magasin__c, Rang_tarifaire__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        Test.startTest(); 
        MagasinTriggerServiceBatch mtb = new MagasinTriggerServiceBatch(new List<Magasin__c>{testMagasin});
        mtb.checkExistInAquilon(testOPM);
        testOPM.Actif_Aquilon__c = true;
        update testOPM;
        testOPM = [SELECT ID, Actif_Aquilon__c, Rupture_entrepot1__c, Niveau_de_stock__c, En_cours_de_commande__c, Prix_de_vente_magasin__c, magasin__c, Rang_tarifaire__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        mtb.checkExistInAquilon(testOPM);
        testOPM.Rupture_entrepot1__c = true;
        update testOPM;
        testOPM = [SELECT ID, Actif_Aquilon__c, Rupture_entrepot1__c, Niveau_de_stock__c, En_cours_de_commande__c, Prix_de_vente_magasin__c, magasin__c, Rang_tarifaire__c, Magasin__r.Extension_de_gamme__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        //Test checkExistInAquilonIfExtension
        mtb.checkExistInAquilonIfExtension(testOPM);
        mtb.StockAndEnCours = 6;
        mtb.checkExistInAquilonIfExtension(testOPM);
        mtb.StockAndEnCours = 0;
        mtb.checkExistInAquilonIfExtension(testOPM);
        //Actif acuqilon = false
        testOPM.Actif_Aquilon__c = false;
        update testOPM;
        testOPM = [SELECT ID, Actif_Aquilon__c, Rupture_entrepot1__c, Niveau_de_stock__c, En_cours_de_commande__c, Prix_de_vente_magasin__c, magasin__c, Rang_tarifaire__c, Magasin__r.Extension_de_gamme__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        mtb.checkExistInAquilonIfExtension(testOPM);
        
        testMagasin.Extension_de_gamme__c='non';
        update testMagasin;
        testOPM = [SELECT ID, Actif_Aquilon__c, Rupture_entrepot1__c, Niveau_de_stock__c, En_cours_de_commande__c, Prix_de_vente_magasin__c, magasin__c, Rang_tarifaire__c, Magasin__r.Extension_de_gamme__c, Produit__r.Prix_de_vente_tarif_T2__c, Produit__r.Prix_de_vente_tarif_T3__c FROM Offre_Produit_Magasin__c limit 1];
        mtb.checkExistInAquilonIfExtension(testOPM);
        
        Test.stopTest();
    }
}