trigger creneauMagasinRecurrentTrigger on Creneau_Magasin_Recurrent__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            creneauMagasinRecurrentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}