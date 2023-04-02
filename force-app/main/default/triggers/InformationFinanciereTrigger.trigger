trigger InformationFinanciereTrigger on Information_financiere__c (before insert) {
    InformationFinanciereTriggerHandler handler = new InformationFinanciereTriggerHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsertMethod();
        }
    }
}