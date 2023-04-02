@IsTest
private class MagasinTrigger_TST {
    
    @IsTest
    private static void testUpdateMagasin(){   
        
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'non')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
			.create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .count(1).create().getRecords();
        
        Test.startTest(); 
        	testMagasin.Extension_de_gamme__c = 'oui';
        	update testMagasin;
        	System.assertEquals('oui', testMagasin.Extension_de_gamme__c);
        Test.stopTest();
        
    }
}