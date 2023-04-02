/**
 * @description       : 
 * @author            : Ajay.Kumar Tiwari
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Ajay.Kumar Tiwari
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   05-28-2021   Ajay.Kumar Tiwari   Initial Version
**/
trigger ContactPointAddressTrigger on ContactPointAddress (before insert, after insert, before update,after update, before delete,after delete, after undelete)  
{
    ContactPointAddressTriggerHandler handler = new ContactPointAddressTriggerHandler(Trigger.new, Trigger.oldMap);
    
    if(trigger.isInsert && trigger.isBefore) {
        handler.beforeInsertMethod();
    }
    if(trigger.isInsert && trigger.isAfter) {
        handler.afterInsertMethod();
    }
    if(trigger.isUpdate && trigger.isBefore) {
        handler.beforeUpdate();
    }
    if(trigger.isUpdate && trigger.isAfter) {
        handler.afterUpdateMethod();
    }
    if(trigger.isDelete && trigger.isBefore) {
        handler.beforeDelete();
    }
    if(trigger.isDelete  && trigger.isAfter) {
        handler.afterDeleteMethod();
    }
    
}