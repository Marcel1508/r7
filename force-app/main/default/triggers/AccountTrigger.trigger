/**
* @author       jan.straka@bluewolf
* @date         2021-01-29
* @description  Trigger on Account object
**/
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert();
        } else if (Trigger.isUpdate) {
            handler.afterUpdate();
        }
    }
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert();
        } else if (Trigger.isUpdate) {
            handler.beforeUpdate();
        }
    }
}