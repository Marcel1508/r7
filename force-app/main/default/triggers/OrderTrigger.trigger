/**
* @author       aymen.mtir@ibm
* @date         2020-11-01
* @description  Trigger on Order object
**/
trigger OrderTrigger on Order (after insert, after update, after delete, after undelete) {
    OrderTriggerHandler handler = new OrderTriggerHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsertMethod();
        } else if (Trigger.isUpdate) {
            handler.afterUpdateMethod();
        } else if (Trigger.isDelete) {
            handler.afterDeleteMethod();
        }
    }
}