/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          22-03-2021           ajay.tiwari3@ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
public without sharing class MecaniquePromotionService {
    
    /**
    * @description  Update the promotion Record with Mecanique Promotions
    * @author Ajay.Kumar Tiwari | 03-22-2021 
    * @param mecaniquePromotions 
    **/
    public void updatePromotions(Map<Id,Mecanique_Promotion__c> mecaniquePromotions){
        List<Promotion__c> updatePromotions=new List<Promotion__c>();
        List<Promotion__c> promotionsList=new List<Promotion__c>();
        Set<Id> produit =new Set<Id>();
        Set<String> codeAnabel =new Set<String>();
        
        for(Mecanique_Promotion__c mecaniquePromo : mecaniquePromotions.values()){
            
            if(mecaniquePromo.Produit__c!=null && !String.isBlank(mecaniquePromo.Produit__c))
                produit.add(mecaniquePromo.Produit__c);
            
            if(mecaniquePromo.Code_Anabel__c!=null && !String.isBlank(mecaniquePromo.Code_Anabel__c))
                codeAnabel.add(mecaniquePromo.Code_Anabel__c);
        }
        
        promotionsList = [Select Id,Mecanique_Promotion__c ,Date_de_fin_de_promotion__c,
                    Date_de_debut_de_promotion__c,  Produit__c, Code_Anabel__c
                    from Promotion__c
                    where
                    Produit__c in : produit AND 
                    Code_Anabel__c in :codeAnabel ];
        
        if(!promotionsList.isEmpty()){
            for(Mecanique_Promotion__c mecaniquePromo : mecaniquePromotions.values()){
                
                for(Promotion__c promo : promotionsList){
                    if(mecaniquePromo.Produit__c== promo.Produit__c && 
                       mecaniquePromo.Code_Anabel__c== promo.Code_Anabel__c &&
                       mecaniquePromo.Date_d_utilisation_fin__c<= promo.Date_de_fin_de_promotion__c &&
                       mecaniquePromo.Date_d_utilisation_debut__c>= promo.Date_de_debut_de_promotion__c){
                       promo.Mecanique_Promotion__c=mecaniquePromo.Id;
                       updatePromotions.add(promo);
                       }
                }  
            }
            if(!updatePromotions.isEmpty()){
                update updatePromotions;
            }
        }
        
    }
}