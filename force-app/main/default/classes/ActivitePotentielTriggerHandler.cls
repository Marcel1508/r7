public without sharing class ActivitePotentielTriggerHandler {
    private final List<Activite_potentiel__c> newRecords;
    private final Map<Id, Activite_potentiel__c> oldRecords;
    private final Map<Id, Activite_potentiel__c> newRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    
    public ActivitePotentielTriggerHandler(List<Activite_potentiel__c> newRecords, Map<Id, Activite_potentiel__c> oldRecords, Map<Id, Activite_potentiel__c> newRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
    }
    
    
    public void beforeInsertMethod() {
        Set<Id> accountsIds = new Set<Id>();
        Set<Id> magasinsIds = new Set<Id>();
        
        for(Activite_potentiel__c activite: newRecords) {
            accountsIds.add(activite.Account__c);
            magasinsIds.add(activite.Magasin_actif__c );
        }
        
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT ID, Name, Numero_Client__c FROM ACCOUNT WHERE ID=:accountsIds]);
        Map<Id, Magasin__c> magasinsMap = new Map<Id, Magasin__c>([SELECT ID, Name, Responsable__c, Code_etablissement__c FROM Magasin__c WHERE ID=:magasinsIds]);
        
        if(!accountsMap.isEmpty() && !magasinsMap.isEmpty()) {
            for(Activite_potentiel__c activite: newRecords) {
                Account a = accountsMap.get(activite.Account__c);
                Magasin__c m = magasinsMap.get(activite.Magasin_actif__c);
                if(a != null && m != null && !String.isBlank(a.Numero_Client__c) && !String.isBlank(m.Code_etablissement__c)) {
                    activite.AP_External_ID__c = a.Numero_Client__c + '_' + m.Code_etablissement__c;
                }
            }
        }
    }
}