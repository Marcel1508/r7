trigger ActivitePotentielTrigger on Activite_potentiel__c (before insert) {
    ActivitePotentielTriggerHandler handler = new ActivitePotentielTriggerHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsertMethod();
        } 
    }
}