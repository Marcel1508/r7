public without sharing class InformationFinanciereTriggerHandler {
    private final List<Information_financiere__c> newRecords;
    private final Map<Id, Information_financiere__c> oldRecords;
    private final Map<Id, Information_financiere__c> newRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    
    public InformationFinanciereTriggerHandler(List<Information_financiere__c> newRecords, Map<Id, Information_financiere__c> oldRecords, Map<Id, Information_financiere__c> newRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
    }
    
    
    public void beforeInsertMethod() {
        Set<Id> accountsIds = Utilities.KeyBuilding(newRecords).get('accountIds');
        Set<Id> magasinsIds = Utilities.KeyBuilding(newRecords).get('magasinsIds');
        Queries.AccountMagasinWrapper accMagWrapper = Queries.getAccountsAndMagasinsMaps(accountsIds,magasinsIds);
        if(!accMagWrapper.accounts.isEmpty() && !accMagWrapper.magasins.isEmpty()) {
            for(Information_financiere__c info: newRecords) {
                Account a = accMagWrapper.accounts.get(info.Account__c);
                Magasin__c m = accMagWrapper.magasins.get(info.Magasin__c);
                if(a != null && m != null && !String.isBlank(a.Numero_Client__c) && !String.isBlank(m.Code_etablissement__c)) {
                    info.Info_fi_ExternalID__c  = a.Numero_Client__c + '_' + m.Code_etablissement__c;
                }
                if(m != null && m.Responsable__c != null) {
                    info.OwnerId = m.Responsable__c;
                }
            }
        }
    }
}