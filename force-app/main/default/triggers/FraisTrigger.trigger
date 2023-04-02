trigger FraisTrigger on Frais__c (before insert, before update) {
    FraisTriggerHandler handler = new FraisTriggerHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsertMethod();
        } 
        if (Trigger.isUpdate) {
            handler.beforeUpdateMethod();
        } 
    }
}