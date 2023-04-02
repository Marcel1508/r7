/**
* @author       ajay.tiwari3@ibm
* @date         2021-03-22
* @description  TriggerHandler for MecaniquePromotionTrigger
**/
trigger MecaniquePromotionTrigger on Mecanique_Promotion__c (after insert) {
    MecaniquePromotionTriggerHandler handler= new MecaniquePromotionTriggerHandler(Trigger.newMap,Trigger.oldMap);
    if(Trigger.isAfter && Trigger.isInsert) {
        //handler.afterInsertMethod();
    }

}