/**
* @author : Maud Vasseur - IBM Lille
* @date : 12/2020
* @description : Trigger sur l'objet Prix_specifiques__c
**/

trigger PrixSpecifiqueTrigger on Prix_specifiques__c (before Insert, before Update, after Insert, after Update) {
    PrixSpecifiqueTriggerHandler handler = new PrixSpecifiqueTriggerHandler(Trigger.new, Trigger.oldMap);
    /*if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.beforeUpdate();
        }
        if (Trigger.isInsert) {
            handler.beforeInsert();
        }
    }*/
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.afterUpdate();
        }
        if (Trigger.isInsert) {
            handler.afterInsert();
        }
    }
}