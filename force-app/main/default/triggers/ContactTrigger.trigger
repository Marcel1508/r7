trigger ContactTrigger on Contact(before insert, before update, after insert, after update) {
   
   // ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.new, Trigger.oldMap);
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //handler.afterInsert();
        } else {
            //handler.afterUpdate();
        }
    }
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            //handler.beforeInsert();
        } else {
            //handler.beforeUpdate();
        }
    }
}