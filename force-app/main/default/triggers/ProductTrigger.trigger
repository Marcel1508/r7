/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Trigger sur l'objet Product
**/

trigger ProductTrigger on Product2 (
        before insert,
        after insert,
        before update,
        after update,
        before delete
) {
    new ProductTriggerHandler(Trigger.new, Trigger.oldMap).run();
}