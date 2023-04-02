@isTest
public class DeactivatePBEForSpecPriceBatch_Test {
    private static Magasin__c createMagasin(String extension, String rang) {
        return  new Magasin__c(
            Responsable__c= UserInfo.getUserId(),
            Name= 'TEST Magasin',
            Extension_de_gamme__c= extension,
            Rang_tarifaire__c= rang,
            Pourcentage_additionel_carte__c= 3,
            Minimum_Commande_Drive__c= 10,
            Minimum_Commande_Livraison__c= 5,
            Minimum_Commande_Drive_Deporte__c= 15,
            API_Key__c= 'Test Magasin 1');
            
    }
    private static Account createAccount(Id magasinId) {
        return  new Account(
            Magasin_de_rattachement__c= magasinId,
            Magasin_actif_en_cours__c= magasinId,
            Etablissement_geographique__c= magasinId,
            Name= 'TEST Account',
            OwnerId= UserInfo.getUserId());
           
    }
    private static Product2 createProduct() {
        return  new Product2(
            Name= 'TEST Product');
            
    }
    
    private static Pricebook2 createPriceBook() {
        return new Pricebook2 (
            Name= 'Standard PMC TEST Magasin',
            isActive= True);
    }
    private static Offre_Produit_Magasin__c createOPM(Id magasinId, Id productId, String produitActif) {
        return new Offre_Produit_Magasin__c(
            Name= 'TEST OPM',
            Magasin__c= magasinId,
            Produit__c= productId,
            Produit_actif__c= produitActif);
           
    }

    private static Prix_specifiques__c createPSP(Id magasinId, Id opm, Id produit, Id acc, Date endDate) {
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
    private static void testUpdatePSP(){   
		//Produit non actif sur update
        //=>    Désactive le produit avec statut 5
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        ProductTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        insert testMagasin;
        Account testAccount = createAccount(testMagasin.Id);
        insert testAccount;
        Product2 testProduct = createProduct();
        insert testProduct;
        Product2 testProduct2 = createProduct();
        insert testProduct2;
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
        insert standardPrice;
        insert standardPrice2;
        Pricebook2 testPricebook = createPriceBook();
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O');
        Offre_Produit_Magasin__c testOPM2 = createOPM(testMagasin.Id, testProduct2.Id,'O');
        insert testOPM;
        insert testOPM2;

        Prix_specifiques__c testPSP = createPSP(testMagasin.Id, testOPM.Id, testProduct.Id, testAccount.Id, Date.Today());
        Prix_specifiques__c testPSP2 = createPSP(testMagasin.Id, testOPM2.Id, testProduct2.Id, testAccount.Id, Date.newInstance(2023, 02, 15));
        insert testPSP;
        insert testPSP2;
        
        Test.startTest(); 
        List <Prix_specifiques__c> resultPSP = [SELECT Id, isActive__c,Offre_Produit_Magasin__c FROM Prix_specifiques__c ];
        System.assertEquals(2, resultPSP.size(), 'should exist 2 specific price');
        System.debug([SELECT Offre_Produit_Magasin__c FROM Prix_specifiques__c WHERE Date_de_fin_d_application__c < Today and isActive__c = true]);
        DeactivatePBEForSpecificPriceBatch dpb = new DeactivatePBEForSpecificPriceBatch();
        Database.executeBatch(dpb);
        Test.stopTest();
               
        List <Prix_specifiques__c> resultTestPSP = [SELECT Id, isActive__c FROM Prix_specifiques__c WHERE isActive__c = true];
        System.assertEquals(1, resultTestPSP.size(), 'should have one active remaining specific price');
        
    }
}