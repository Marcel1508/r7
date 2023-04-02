@IsTest
private class OffreProduitMagasinTrigger_TST {
    
    @IsTest
    private static void testCreateOPM(){
        
        //Test.startTest(); 
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Pourcentage_additionel_carte__c , 12)
            .put(Magasin__c.Minimum_Commande_Drive__c , 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c , 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c , 15)
            .put(Magasin__c.API_Key__c , '12Test')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
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
        
        Test.startTest();
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, 15)
            .count(1).create().getRecords();
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testUpdateOPM(){   
        
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Pourcentage_additionel_carte__c , 12)
            .put(Magasin__c.Minimum_Commande_Drive__c , 10)
            .put(Magasin__c.Minimum_Commande_Livraison__c , 5)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c , 15)
            .put(Magasin__c.API_Key__c , '12Test')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
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
            .put(Pricebook2.Name, 'Standard TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
        
        //Boolean firstRun = OffreProduitMagasinTriggerHandler.firstRun;
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .count(1).create().getRecords();
        
        Test.startTest();
        	OffreProduitMagasinTriggerHandler.firstRun = true;
            testOPM.get(0).Produit_actif__c = 'N';
        	update testOPM;
        
        
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.assertEquals('N', testOPM.get(0).Produit_actif__c);
        Test.stopTest();
    }
    
}