trigger FideliteTrigger on Fidelite__c (before insert) {
    FideliteTriggerHandler handler = new FideliteTriggerHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsertMethod();
        } 
    }
}