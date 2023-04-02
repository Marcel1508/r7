public class FideliteTriggerHandler {
    private final List<Fidelite__c> newRecords;
    private final Map<Id, Fidelite__c> oldRecords;
    private final Map<Id, Fidelite__c> newRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    
    public FideliteTriggerHandler(List<Fidelite__c> newRecords, Map<Id, Fidelite__c> oldRecords, Map<Id, Fidelite__c> newRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
    }
     
    public void beforeInsertMethod() {
        Set<Id> accountsIds = Utilities.KeyBuilding(newRecords).get('accountIds');
        Set<Id> magasinsIds = Utilities.KeyBuilding(newRecords).get('magasinsIds');        
        Queries.AccountMagasinWrapper accMagWrapper = Queries.getAccountsAndMagasinsMaps(accountsIds,magasinsIds);
        
        if(!accMagWrapper.accounts.isEmpty() && !accMagWrapper.magasins.isEmpty()) {
            for(Fidelite__c fidelite: newRecords) {
                Account a = accMagWrapper.accounts.get(fidelite.Compte__c);
                Magasin__c m = accMagWrapper.magasins.get(fidelite.Magasin__c);
                if(a != null && m != null && !String.isBlank(a.Numero_Client__c) && !String.isBlank(m.Code_etablissement__c)) {
                    fidelite.Fid_ExternalID__c = a.Numero_Client__c + '_' + m.Code_etablissement__c;
                }
            }
        }
    }
}