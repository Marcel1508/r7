/**
 * @description       : 
 * @author            : Ajay.Kumar Tiwari
 * @group             : 
 * @last modified on  : 07-02-2021
 * @last modified by  : Ajay.Kumar Tiwari
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   07-02-2021   Ajay.Kumar Tiwari   Initial Version
**/
@isTest public class PromotionActivationBatch_TST {
    
    private static Product2 createProduct(String codeBase) {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
                .put(Product2.Name, 'TEST Product')
            	.put(Product2.Code_Base__c, codeBase)
            	.put(Product2.En_Promotion__c, false)
            	.put(Product2.Promotion_en_cours__c, null)
                .create().getRecord();
    }
    
    @IsTest
    private static void testActivationBatch() {
        En_tete_Promotion__c enTetePromo = new En_tete_Promotion__c(Name = 'Promo test', 
                                              Type_Envoi__c = 'T');
        insert enTetePromo;
        Product2 testProduct = createProduct('AZERTY1');
         //Create a Magasin
         Magasin__c Magasin = new Magasin__c(
        	Name = 'Test Magasin',
        	Code_etablissement__c = '123',
            Pourcentage_additionel_carte__c = 12,
            Minimum_Commande_Drive__c = 10, 
            Minimum_Commande_Livraison__c = 5, 
            Minimum_Commande_Drive_Deporte__c = 15, 
            API_Key__c = '12Test'
        ); 
        insert Magasin;
        
    	Promotion__c promo = new Promotion__c(En_tete_Promotion__c = enTetePromo.id, 
                                              Produit__c = testProduct.id, 
                                              Magasin__c = Magasin.id, 
                                              Date_de_debut_de_promotion__c = Date.today().addDays(-2),
                                              Date_de_fin_de_promotion__c = Date.today().addDays(+3));
        insert promo;
        List<Promotion__c> listPromo = [SELECT id, name, En_tete_Promotion__c, Produit__c, Type_d_envoi__c,
                                        Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c, Code_Produit__c 
                                        FROM Promotion__c 
                                        WHERE id =:promo.id];       
        Test.startTest();
        PromotionActivationBatch testBatch = new PromotionActivationBatch();
        Id batchId = Database.executeBatch(testBatch);
        Test.stopTest();
        
        List<Product2> resultProduct = [SELECT id, name, Promotion_en_cours__c, En_Promotion__c FROM Product2 WHERE name ='TEST Product'];

        System.assertEquals(resultProduct.get(0).En_Promotion__c, true);
        System.assertEquals(resultProduct.get(0).Promotion_en_cours__c, promo.En_tete_Promotion__c);                                   
    }
    
    @IsTest
    private static void testDeactivationBatchNoCode() {
        En_tete_Promotion__c enTetePromo = new En_tete_Promotion__c(Name = 'Promo test', 
                                              Type_Envoi__c = 'T');
        insert enTetePromo;
        Product2 testProduct = createProduct('AZERTY1');
        Product2 testProduct2 = createProduct('AZERTY2');
         //Create a Magasin
         Magasin__c Magasin = new Magasin__c(
        	Name = 'Test Magasin',
        	Code_etablissement__c = '123',
            Pourcentage_additionel_carte__c = 12,
            Minimum_Commande_Drive__c = 10, 
            Minimum_Commande_Livraison__c = 5, 
            Minimum_Commande_Drive_Deporte__c = 15, 
            API_Key__c = '12Test'
        ); 
        insert Magasin;
        
    	Promotion__c promo = new Promotion__c(En_tete_Promotion__c = enTetePromo.id, 
                                              Produit__c = testProduct2.id, 
                                              Magasin__c = Magasin.id,
                                              Date_de_debut_de_promotion__c = Date.today().addDays(-2),
                                              Date_de_fin_de_promotion__c = Date.today().addDays(+3));  
        insert promo;
        testProduct2.Promotion_en_cours__c = promo.En_tete_Promotion__c;
        update testProduct2;
        
        Test.startTest(); 
        PromotionActivationBatch testBatch = new PromotionActivationBatch();
        Id batchId = Database.executeBatch(testBatch);
        Test.stopTest();
        
        List<Product2> resultProduct = [SELECT id, name, Promotion_en_cours__c, En_Promotion__c FROM Product2 WHERE name ='TEST Product'];

        System.assertEquals(resultProduct.get(0).En_Promotion__c, false);
        System.assertEquals(resultProduct.get(0).Promotion_en_cours__c, null);                                           
    }

}