/**
* @author : Maud Vasseur - IBM Lille
* @date : 04/2021
* @description : Batch on Product to populate the lookup field Promotion en cours
* @TestClass : PromotionActivationBatch_TST
**/
public without sharing class PromotionActivationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT id, Name, Code_base__c, En_Promotion__c, Promotion_en_cours__c
                                         FROM Product2
                                         WHERE Promotion_en_cours__c = null AND Code_base__c != null
                                        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> scope) {
        
        List<Promotion__c> listPromotion = [SELECT id, Code_Produit__c, En_tete_Promotion__c, 
                                            Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c
                                            FROM Promotion__c 
                                            WHERE Date_de_debut_de_promotion__c <= Today
                                            AND Date_de_fin_de_promotion__c >= Today
                                            AND Type_d_envoi__c = 'T'
                                            AND Code_Produit__c != null
                                           ];
        List<Product2> listProductToUpdate = Utilities.activateOrDeactivatePromo(scope,listPromotion, true);
        if(listProductToUpdate != null && !listProductToUpdate.isEmpty())
        {
            UPDATE listProductToUpdate;
        }
        
    }
    
    public void finish(Database.BatchableContext info){     
    }
      
}