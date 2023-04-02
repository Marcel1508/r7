public without sharing class PromotionsMecaniquesBatch implements Database.Batchable<sObject> {
    
    public static Boolean systemDebug = Utilities.displaySystemDebug();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,Mecanique_Promotion__c ,Date_de_fin_de_promotion__c,Date_de_debut_de_promotion__c, Code_Produit__c, Code_Anabel__c from Promotion__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Promotion__c> promoList) {
        Set<String> produit =new Set<String>();
        Set<String> codeAnabel =new Set<String>();
        List<Promotion__c> promotionsToUpdate = new List<Promotion__c>();
        List<Mecanique_Promotion__c> mecaniquePoromotionsList = new List<Mecanique_Promotion__c>();
        Map<String,List<Promotion__c>> promotionsByproductIdAndLabelCode = new Map<String,List<Promotion__c>>();
        Map<String,List<Mecanique_Promotion__c>> mecaniquesPromotionsByproductIdAndLabelCode = new Map<String,List<Mecanique_Promotion__c>>();
        List<Promotion__c> promotions;
        List<Mecanique_Promotion__c> mecaniquesPromotions;
        String productIdCodeAnabel;
        
        for(Promotion__c promo : promoList) {    
            if(promo.Code_Produit__c!=null && !String.isBlank(promo.Code_Produit__c) && promo.Code_Anabel__c!=null && !String.isBlank(promo.Code_Anabel__c)){
                produit.add(promo.Code_Produit__c);
                codeAnabel.add(promo.Code_Anabel__c);
                productIdCodeAnabel = promo.Code_Produit__c+promo.Code_Anabel__c;
                if(promotionsByproductIdAndLabelCode.get(productIdCodeAnabel) == null){
                    List<Promotion__c> lp = new List<Promotion__c>();
                    lp.add(promo);
                    promotionsByproductIdAndLabelCode.put(productIdCodeAnabel,lp);
                }else{ 
                    List<Promotion__c> lp = promotionsByproductIdAndLabelCode.get(productIdCodeAnabel);
                    lp.add(promo); 
                    promotionsByproductIdAndLabelCode.put(productIdCodeAnabel,lp);
                }                  
                
            }                
        }
        if(produit != null && !produit.isEmpty() && codeAnabel != null && !codeAnabel.isEmpty()){
            mecaniquePoromotionsList = [SELECT Id, Code_Produit__c, Code_Anabel__c, Date_d_utilisation_debut__c, 
                                        Date_d_utilisation_fin__c FROM Mecanique_Promotion__c where
                                        Code_Produit__c in : produit AND 
                                        Code_Anabel__c in :codeAnabel ];            
        }
        if(mecaniquePoromotionsList != null && !mecaniquePoromotionsList.isEmpty()){
            for(Mecanique_Promotion__c mecaniquePromo : mecaniquePoromotionsList){
                if(mecaniquePromo.Code_Produit__c!=null && !String.isBlank(mecaniquePromo.Code_Produit__c) && mecaniquePromo.Code_Anabel__c!=null && !String.isBlank(mecaniquePromo.Code_Anabel__c)){
                    productIdCodeAnabel = mecaniquePromo.Code_Produit__c+mecaniquePromo.Code_Anabel__c;
                    if(mecaniquesPromotionsByproductIdAndLabelCode.get(productIdCodeAnabel) == null){
                        List<Mecanique_Promotion__c> lmp = new List<Mecanique_Promotion__c>();
                        lmp.add(mecaniquePromo);
                        mecaniquesPromotionsByproductIdAndLabelCode.put(productIdCodeAnabel,lmp);
                    }else{
                        List<Mecanique_Promotion__c> lmp = mecaniquesPromotionsByproductIdAndLabelCode.get(productIdCodeAnabel);
                        lmp.add(mecaniquePromo); 
                        mecaniquesPromotionsByproductIdAndLabelCode.put(productIdCodeAnabel,lmp);
                    }
                } 
            }      
        }
        if (systemDebug) {
            System.debug('mecaniquesPromotionsByproductIdAndLabelCode : '+ mecaniquesPromotionsByproductIdAndLabelCode);
            System.debug('promotionsByproductIdAndLabelCode : '+ promotionsByproductIdAndLabelCode); 
        }
        
        if (!promotionsByproductIdAndLabelCode.IsEmpty() && !mecaniquesPromotionsByproductIdAndLabelCode.IsEmpty()) {
            for (String productAndLabelCode : promotionsByproductIdAndLabelCode.keySet()){
                promotions=promotionsByproductIdAndLabelCode.get(productAndLabelCode);
                mecaniquesPromotions=mecaniquesPromotionsByproductIdAndLabelCode.get(productAndLabelCode);
                if (promotions!= null && mecaniquesPromotions !=null && !promotions.isEmpty() && !mecaniquesPromotions.isEmpty()) {
                    for (Promotion__c p :promotions ) {
                        if(p.Mecanique_Promotion__c == null){
                            for (Mecanique_Promotion__c mp :mecaniquesPromotions) {
                                if (mp.Date_d_utilisation_fin__c != null && mp.Date_d_utilisation_debut__c != null ) {
                                    if (p.Date_de_fin_de_promotion__c >= mp.Date_d_utilisation_fin__c  && p.Date_de_debut_de_promotion__c <= mp.Date_d_utilisation_debut__c)
                                    {   p.Mecanique_Promotion__c = mp.Id;
                                     promotionsToUpdate.add(p);
                                    }
                                }	
                            }
                        } else
                        {
                            for (Mecanique_Promotion__c mp :mecaniquesPromotions) {
                                if (mp.Date_d_utilisation_fin__c != null && mp.Date_d_utilisation_debut__c != null ) {
                                    if (p.Date_de_fin_de_promotion__c < mp.Date_d_utilisation_fin__c  || p.Date_de_debut_de_promotion__c > mp.Date_d_utilisation_debut__c)
                                    {   p.Mecanique_Promotion__c = null;
                                     promotionsToUpdate.add(p);
                                    }
                                }	
                            }
                        }
                    }
                    
                }
            }
        }
        
        if (!promotionsToUpdate.isEmpty()) {
            try {
                update promotionsToUpdate;   
            } catch(Exception e) {
                if (systemDebug) { System.debug(e); }
            }
        }
        
    }    
    
    public void finish(Database.BatchableContext bc) {
        if (systemDebug) { System.debug('PromotionsMecaniquesBatch Completed'); }
    }
    
}