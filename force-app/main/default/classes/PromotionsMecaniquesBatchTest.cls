@isTest
public class PromotionsMecaniquesBatchTest {
    @isTest
    private static void testPromotionsMecaniquesBatchAssociation(){
        
        Magasin__c magasin =  TestDataFactory.createMagasin();
        List<String> productsIds = TestDataFactory.createProducts();
        Date dateDebutPromo=Date.newInstance(2019, 12, 9);
        Date dateFinPromo=Date.newInstance(2026, 12, 9);
        Date dateDebutUtilisation=Date.newInstance(2020, 12, 9);
        Date dateFinUtilisation=Date.newInstance(2025, 12, 9);
        List<Promotion__c> promotions = TestDataFactory.createPromotions(magasin.Id,productsIds, dateDebutPromo,dateFinPromo );
        List<Mecanique_Promotion__c> mecaniquesPromotions = TestDataFactory.createMecaniquesPromotions(magasin.Id, productsIds,dateDebutUtilisation,dateFinUtilisation);
        
        Test.startTest();
        PromotionsMecaniquesBatch pmb = new PromotionsMecaniquesBatch();
        Id batchId = Database.executeBatch(pmb,200);
        Test.stopTest();
        
        List<Promotion__c> updatedPromotions = [SELECT Id,Mecanique_Promotion__c FROM Promotion__c WHERE Mecanique_Promotion__c != null AND Mecanique_Promotion__c != '' ];
        System.assertEquals(200, updatedPromotions.size(),'200 records should be retreived');
    }
    
     @isTest
    private static void testPromotionsMecaniquesBatchNonAssociation(){
        
        Magasin__c magasin =  TestDataFactory.createMagasin();
        List<String> productsIds = TestDataFactory.createProducts();
        Date dateDebutPromo=Date.newInstance(2019, 12, 9);
        Date dateFinPromo=Date.newInstance(2026, 12, 9);
        Date dateDebutUtilisation=Date.newInstance(2019, 12, 8);
        Date dateFinUtilisation=Date.newInstance(2025, 12, 9);
        List<Promotion__c> promotions = TestDataFactory.createPromotions(magasin.Id,productsIds, dateDebutPromo,dateFinPromo );
        List<Mecanique_Promotion__c> mecaniquesPromotions = TestDataFactory.createMecaniquesPromotions(magasin.Id, productsIds,dateDebutUtilisation,dateFinUtilisation);
        List<Promotion__c> promotionsToUpdate = new List<Promotion__c>();
        for(Integer i=0; i<promotions.size(); i++){
                for(Integer j=0; j<mecaniquesPromotions.size(); j++)
                {
                    if(i==j)
                    {
                        promotions[i].Mecanique_Promotion__c = mecaniquesPromotions[j].Id;  
                    }
                         
                }
                promotionsToUpdate.add(promotions[i]);

			}
                   
        update promotionsToUpdate;
        Test.startTest();
        PromotionsMecaniquesBatch pmb = new PromotionsMecaniquesBatch();
        Id batchId = Database.executeBatch(pmb,200);
        Test.stopTest();
        
        List<Promotion__c> updatedPromotions = [SELECT Id,Mecanique_Promotion__c FROM Promotion__c WHERE Mecanique_Promotion__c = null ];
        System.assertEquals(200, updatedPromotions.size(),'200 records should be retreived');
    }
}