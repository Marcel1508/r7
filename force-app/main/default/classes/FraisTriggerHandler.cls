public without sharing class FraisTriggerHandler {
    private final List<Frais__c> newRecords;
    private final Map<Id, Frais__c> oldRecords;
    private final Map<Id, Frais__c> newRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    
    public FraisTriggerHandler(List<Frais__c> newRecords, Map<Id, Frais__c> oldRecords, Map<Id, Frais__c> newRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
    }
    
    public void beforeInsertMethod() {
        
        Set<Id> accountsIds = Utilities.KeyBuilding(newRecords).get('accountIds');
        Set<Id> magasinsIds = Utilities.KeyBuilding(newRecords).get('magasinsIds');

        Queries.AccountMagasinWrapper accMagWrapper = Queries.getAccountsAndMagasinsMaps(accountsIds,magasinsIds);  
        
        if(!accMagWrapper.accounts.isEmpty() && !accMagWrapper.magasins.isEmpty()) {
            for(Frais__c frais: newRecords) {
                Account a = accMagWrapper.accounts.get(frais.Account__c);
                Magasin__c m = accMagWrapper.magasins.get(frais.Magasin_Associe__c);
                if(a != null && m != null && !String.isBlank(a.Numero_Client__c) && !String.isBlank(m.Code_etablissement__c)) {
                    frais.Frais_externalID__c = a.Numero_Client__c + '_' + m.Code_etablissement__c;
                }
                
                if(m != null && m.Responsable__c != null) {
                    frais.OwnerId = m.Responsable__c;
                }
            }
            
            FraisService fs = new FraisService();
            fs.updateCodeZoneDeChanlandise(newRecords,accMagWrapper.accounts);
        }
        
        
    }
    
    public void beforeUpdateMethod() {
        FraisService fs = new FraisService();
        if(!newRecords.isEmpty()){  
            Set<Id> accountsIds = new Set<Id>();
            for(Frais__c frais: newRecords) {
                accountsIds.add(frais.Account__c);
            }
            
            Map<Id, Account> accountsMap = new Map<Id,Account>([SELECT ID, ShippingPostalCode,ShippingCity FROM ACCOUNT WHERE ID=:accountsIds]);
            if(accountsMap !=null && !accountsMap.isEmpty()){
            fs.updateCodeZoneDeChanlandise(newRecords,accountsMap);
            }
        }
    }
    
}