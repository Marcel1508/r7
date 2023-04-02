/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Class test of ProductTrigger class 
**/
@IsTest
private class ProductTrigger_TST {
    
    @IsTest
    private static void testUpdateProduct(){   
        
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .create().getRecord();
            
 		Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Extension_de_gamme__c, false)
			.create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .count(1).create().getRecords();
        
        Test.startTest(); 
        	testProduct.Extension_de_gamme__c = true;
        	update testProduct;
        	System.assertEquals(true, testProduct.Extension_de_gamme__c);
        Test.stopTest();
        
    }
}