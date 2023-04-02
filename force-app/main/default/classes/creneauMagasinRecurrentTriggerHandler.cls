public without sharing class creneauMagasinRecurrentTriggerHandler {
    //CreneauMagasinRecurrentService creneauMagasinRecurrentService = new CreneauMagasinRecurrentService();
    
    public static void afterUpdate(List<Creneau_Magasin_Recurrent__c> newRecords, Map<Id, Creneau_Magasin_Recurrent__c> oldRecords) {
        Set<Id> cmrIds = new Set<Id>();
        Map<Id, Creneau_Magasin_Recurrent__c> newCreneauxById = new Map<Id, Creneau_Magasin_Recurrent__c>();
        List<Creneau_Salesforce__c> creneauSalesforceToUpdate = new List<Creneau_Salesforce__c>();
        
        for(Creneau_Magasin_Recurrent__c cmr: newRecords) {
            cmrIds.add(cmr.Id);
            newCreneauxById.put(cmr.Id, cmr);
        }
        List<Creneau_Salesforce__c> creneauxSalesforceList = getCreneauSalesforce(cmrIds);
        if(creneauxSalesforceList != null) {
            for(Creneau_Salesforce__c creneauSalesforce: creneauxSalesforceList) {
                boolean valueChanged = false;
                if(newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Heure_de_debut__c != oldRecords.get(creneauSalesforce.Creneau_Recurrent__c).Heure_de_debut__c) {
                    creneauSalesforce.Heure_de_debut__c = newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Heure_de_debut__c;
                    valueChanged = true;
                }
                if(newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Heure_de_fin__c != oldRecords.get(creneauSalesforce.Creneau_Recurrent__c).Heure_de_fin__c) {
                    creneauSalesforce.Heure_de_fin__c = newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Heure_de_fin__c;
                    valueChanged = true;
                }
                if(newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Capacite__c != oldRecords.get(creneauSalesforce.Creneau_Recurrent__c).Capacite__c) {
                    creneauSalesforce.Capacite__c = newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Capacite__c;
                    valueChanged = true;
                }
                if(newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Temps_de_preparation__c != oldRecords.get(creneauSalesforce.Creneau_Recurrent__c).Temps_de_preparation__c) {
                    creneauSalesforce.Temps_de_preparation__c = newCreneauxById.get(creneauSalesforce.Creneau_Recurrent__c).Temps_de_preparation__c;
                    valueChanged = true;
                }
                if(valueChanged) {
                    creneauSalesforceToUpdate.add(creneauSalesforce);
                }
            }
            if(!creneauSalesforceToUpdate.isEmpty()) {
                update creneauSalesforceToUpdate;
            }
        }
    }
    
    private static List<Creneau_Salesforce__c> getCreneauSalesforce(Set<Id> creneauMagasinIds) {
        List<Creneau_Salesforce__c> res = [SELECT ID, Creneau_Recurrent__c FROM Creneau_Salesforce__c where Creneau_Recurrent__c  in :creneauMagasinIds];
        if(res != null && res.size() > 0)
            return res;
        return null;
    }
}