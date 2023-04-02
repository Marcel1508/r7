/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Trigger sur l'objet Offre produit Magasin
**/

trigger OffreProduitMagasinTrigger on Offre_Produit_Magasin__c (before insert, before update, after update) {
    OffreProduitMagasinTriggerHandler handler = new OffreProduitMagasinTriggerHandler(Trigger.new, Trigger.oldMap);
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert();
        }
        if (Trigger.isUpdate) {
            handler.beforeUpdate();
        }
    }   
}