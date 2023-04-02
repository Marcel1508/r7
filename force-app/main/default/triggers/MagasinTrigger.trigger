/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Trigger sur l'objet Magasin
**/
    
trigger MagasinTrigger on Magasin__c (before insert, before update, after update) {
    MagasinTriggerHandler handler = new MagasinTriggerHandler(Trigger.new, Trigger.oldMap);
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.afterUpdate();
        }
    }
}