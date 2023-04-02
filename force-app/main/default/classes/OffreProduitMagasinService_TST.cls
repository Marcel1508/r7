/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Classe de test de la classe OffreProduitMagasinTriggerService
**/

@IsTest
public class OffreProduitMagasinService_TST {
    
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
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
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
    
    private static Pricebook2 createPriceBook2() {
        return new Pricebook2 (
            Name= 'TEST Account TEST Magasin',
            isActive= True);
    }
    
    private static Account createAccount2(Id magasinId) {
        return  new Account(
            Magasin_de_rattachement__c= magasinId,
            Magasin_actif_en_cours__c= magasinId,
            Etablissement_geographique__c= magasinId,
            Name= 'TEST Account',
            OwnerId= UserInfo.getUserId());
           
    }
    private static Prix_specifiques__c createPSP(Id magasinId, Id OPM, Id produit, Id acc, Date endDate) {
        return new Prix_specifiques__c(
           
            Libelle_etablissement__c= magasinId,
            Offre_Produit_Magasin__c= OPM,
            Produit__c= produit,
            Reference_client__c= acc,
            Date_de_debut_d_application__c= Date.newInstance(2023, 02, 01),
            Date_de_fin_d_application__c= endDate,
            Prix_de_vente_client__c= 9000);
            
    }

    @IsTest
    private static void testPriceBook() {
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct();
        Pricebook2 pb = createPriceBook();
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O');
        testOPM.Prix_de_vente_magasin__c = 2;
        new OffreProduitMagasinService().createPriceBook(new List<Offre_Produit_Magasin__c>{testOPM});
        
        testProduct.Prix_de_vente_tarif_T2__c = 3;
        testOPM.Prix_de_vente_magasin__c = null;
        update testProduct;
        testOPM = [SELECT Ref_tarifaire_magasin__c, Prix_de_vente_magasin__c, Magasin__c, Produit__c, Prix_de_vente_magasin_au_conditionnement__c, Rang_tarifaire__c, Prix_T2_au_conditionnement_de_vente__c
                   , Prix_T3_au_conditionnement_de_vente__c FROM Offre_Produit_Magasin__c limit 1];
        new OffreProduitMagasinService().createPriceBook(new List<Offre_Produit_Magasin__c>{testOPM});
        
		testMagasin.Rang_tarifaire__c = 'T3';
        update testMagasin;
        testProduct.Prix_de_vente_tarif_T3__c = 3;
        update testProduct;
        testOPM = [SELECT Ref_tarifaire_magasin__c, Prix_de_vente_magasin__c, Magasin__c, Produit__c, Prix_de_vente_magasin_au_conditionnement__c, Rang_tarifaire__c, Prix_T2_au_conditionnement_de_vente__c
                   , Prix_T3_au_conditionnement_de_vente__c FROM Offre_Produit_Magasin__c limit 1];
        new OffreProduitMagasinService().createPriceBook(new List<Offre_Produit_Magasin__c>{testOPM});

        system.assertEquals(0, [SELECT ID FROM PricebookEntry].size());
    }
    
    @IsTest
    private static void testUpdateOPM(){   
		//Produit non actif sur update
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
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
        
        Test.startTest(); 
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM.Produit_actif__c = 'N';
        testOPM.Quantite_minimum_de_commande__c = 10;
        update testOPM;
                
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c, Produit_actif__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.assertEquals('N', resultTestOPM.get(0).Produit_actif__c);
        //System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortOnePrixDeVenteNoActifAquilon(){
        //Produit Assortiment 1, prix de vente T2 OK, NO Actif aquilon
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '1')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, 7)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, 5)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortOnePrixDeVenteActifAquilonAvecStock(){   
        //Produit Assortiment 1, prix de vente T2 OK, Actif aquilon, avec stock
        //=>    Active le produit avec statut 3
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '1')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, 7)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, 5)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteT3(){   

        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = T3, département 2, Actif Aquilon, avec stock, Rupture Entrepot = false      
        //=>    Active le produit avec statut 3
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T3')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, 6)
            .put(Product2.Prix_de_vente_tarif_T3__c, 5)
            .put(Product2.Code_departement__c, '2')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartDeux(){   

        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 2       
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
        @IsTest
    private static void testProductAssortZeroNoExtDeGammePrixDeVenteDepartDeuxStock(){   

        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 2       
        //=>    Active le produit avec statut 3
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, false)
            .put(Product2.Prix_de_vente_tarif_T2__c, 5)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroNoExtDeGammePrixDeVenteNullDepartDeux(){   

        //Produit Assortiment 0 avec Produit Extension de Gamme = false, prix de vente = null, département 2       
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, false)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, '0')
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreAquilonStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, avec stock,rupture entrepot = false
        //=>    Active le produit avec statut 3
        ProductTriggerHandler.bypassTrigger = true;
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, '0')
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon = false, 
        //avec stock, rupture entrepot = false
        //=>    Active le produit avec statut 1
        ProductTriggerHandler.bypassTrigger = true;
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, '0')
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('1', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
        @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonNoStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon = false, 
        //avec stock, rupture entrepot = false
        //=>    Désactive le produit avec statut 4
        ProductTriggerHandler.bypassTrigger = true;
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoStockRuptureEntrepotExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = oui
        //=>    Active le produit avec statut 2
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, '0')
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('2', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoStockRuptureEntrepotNoExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = non
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'non')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, '0')
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonNoStockRuptureEntrepotExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), No Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = oui
        //=>    Active le produit avec statut 2
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonNoStockRuptureEntrepotNoExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), No Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = non
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'non')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreAquilonNoStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, sans stock, rupture entrepot = false
        //=>    Désactive le produit avec statut 4
           
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreStockRuptureEntrepot(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, avec stock, rupture entrepot = true
        //=>    Active le produit avec statut 1
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 3)
            .put(Magasin__c.Minimum_Commande_Drive__c, 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 15)
            .put(Magasin__c.API_Key__c, 'Test Magasin 1')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
			.create().getRecord();
        
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
        
        Pricebook2 testPricebook =  (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard PMC TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .put(Offre_Produit_Magasin__c.Produit_avec_assortiment_text__c, '0')
            .count(1).create().getRecords();
        
        Test.startTest();
        OffreProduitMagasinTriggerHandler.firstRun = true;
        testOPM[0].Quantite_minimum_de_commande__c = 10;
        Update testOPM;
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
                System.assertEquals('1', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
	}

    @IsTest
    private static void testUpdatePSP(){   
		//Produit non actif sur update
        //=>    Désactive le produit avec statut 5
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount2(testMagasin.Id);
        insert testAccount;
        Product2 testProduct = createProduct();
        Product2 testProduct2 = createProduct();
        Pricebook2 testPricebook = createPriceBook();
        Pricebook2 testPricebook2 = createPriceBook2();
        insert testPricebook2;
        //Instantiate the Pricebook2 record with StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        //Insert a price book entry for the standard price book.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = testProduct.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = testProduct2.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        PricebookEntry spePrice = new PricebookEntry(
            Pricebook2Id = testPricebook2.Id, 
            Product2Id = testProduct.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        PricebookEntry spePrice2 = new PricebookEntry(
            Pricebook2Id = testPricebook2.Id, 
            Product2Id = testProduct2.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        insert standardPrice;
        insert standardPrice2;
        insert spePrice;
        insert spePrice2;
        
        Offre_Produit_Magasin__c testOPM = new Offre_Produit_Magasin__c(
            Name= 'TEST OPM',
            Magasin__c= testMagasin.Id,
            Produit__c= testProduct.Id,
            Produit_actif__c= 'O',
            Conditionnement_de_vente_bloque__c =FALSE,
            Statut__c = '1',
            Quantite_minimum_de_commande__c = 1);
        
        Offre_Produit_Magasin__c testOPM2 = new Offre_Produit_Magasin__c(
            Name= 'TEST OPM2',
            Magasin__c= testMagasin.Id,
            Produit__c= testProduct2.Id,
            Produit_actif__c= 'O',
            Conditionnement_de_vente_bloque__c =FALSE,
            Statut__c = '1',
            Quantite_minimum_de_commande__c = 1);   
        insert testOPM;
        insert testOPM2;

        Prix_specifiques__c testPSP = createPSP(testMagasin.Id, testOPM.Id, testProduct.Id, testAccount.Id, Date.Today());
        Prix_specifiques__c testPSP2 = createPSP(testMagasin.Id, testOPM2.Id, testProduct2.Id, testAccount.Id, Date.newInstance(2023, 02, 15));
        insert testPSP;
        insert testPSP2;
        List<Offre_Produit_Magasin__c> OPMList= [SELECT Id, Niveau_de_stock__c,CurrencyIsoCode, Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c, 
                   produit__r.id, Prix_de_vente_magasin__c, En_cours_de_commande__c, Produit_en_extension_de_gamme__c, Statut__c, Prix_kilo__c, Prix_L__c, Prix_unite__c, 
                   Libelle_du_conditionnement_de_vente__c, Magasin__c,Prix_de_vente_magasin_au_conditionnement__c 
                   FROM Offre_Produit_Magasin__c];
        Test.startTest(); 
        List <Prix_specifiques__c> resultPSP = [SELECT Id, isActive__c,Offre_Produit_Magasin__c FROM Prix_specifiques__c ];
        System.assertEquals(2, resultPSP.size(), 'should exist 2 specific price');
        System.debug([SELECT Offre_Produit_Magasin__c FROM Prix_specifiques__c WHERE Date_de_fin_d_application__c < Today and isActive__c = true]);
        OffreProduitMagasinService opmService = new OffreProduitMagasinService();
        opmService.updatePriceBooksOPMWithSpe(OPMList);
        Test.stopTest();
            
        List<PricebookEntry> prix =[SELECT UnitPrice FROM PricebookEntry WHERE UnitPrice = 9000 ];
        System.assertEquals(1, prix.size() , 'one pricebook Entry should have a price equal to 9000');
        
    }
       
}