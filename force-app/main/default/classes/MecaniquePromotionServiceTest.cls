/* .
--------------------------------------------------------------------------------------
Version#     Date                        Author                    Description
--------------------------------------------------------------------------------------
1.0          23-03-2021                  preethi.u@ibm.com         Initial Version
--------------------------------------------------------------------------------------
*/ 

@isTest
private class MecaniquePromotionServiceTest {

    @testSetup static void setup() {
        Product2 prdRec = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'Test Product') 
            .put(Product2.Code_TVA__c, '3') 
            .create ()
            .getRecord(); 
         Magasin__c  magasinRec = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .create ()
            .getRecord(); 
        new SObjectBuilder(Promotion__c.SObjectType)
            .put(Promotion__c.Produit__c,prdRec.Id)
            .put(Promotion__c.Magasin__c,magasinRec.Id)
            .put(Promotion__c.Date_de_debut_de_promotion__c,System.today())
            .put(Promotion__c.Date_de_fin_de_promotion__c,System.today() +5)
            .create();
        new SObjectBuilder(Mecanique_Promotion__c.SObjectType)
            .put(Mecanique_Promotion__c.Produit__c,prdRec.Id)
            .put(Mecanique_Promotion__c.Magasin__c,magasinRec.Id)
            .put(Mecanique_Promotion__c.Date_d_utilisation_debut__c,System.today())
            .put(Mecanique_Promotion__c.Date_d_utilisation_fin__c,System.today() +5)
            .create();
    }
   
    private static Promotion__c queryPromotionRec() {
         return [SELECT Id,Code_Anabel__c,Produit__c,Date_de_fin_de_promotion__c,Date_de_debut_de_promotion__c,Mecanique_Promotion__c FROM Promotion__c where Produit__r.Name ='Test Product' LIMIT 1];
    }
     private static Mecanique_Promotion__c queryMecaniqueRec() {
         return [SELECT Id,Code_Anabel__c,Produit__c,Date_d_utilisation_debut__c,Date_d_utilisation_fin__c FROM Mecanique_Promotion__c where Produit__r.Name ='Test Product' LIMIT 1];
    }
    
    @IsTest
    static void testPromotionRecMecanique(){
        Promotion__c promotionRec = queryPromotionRec();
        Mecanique_Promotion__c mecaniquePromotionRec = queryMecaniqueRec();
        System.assertEquals(promotionRec.Mecanique_Promotion__c, mecaniquePromotionRec.Id);
    }
}