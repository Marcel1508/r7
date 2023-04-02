public without sharing class BatchZoneDeChalandise implements Database.Batchable<sObject> {
    
    public static Boolean systemDebug = Utilities.displaySystemDebug();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Magasin_Associe__c, Account__c FROM Frais__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Frais__c> fraisList) {
       
        if (!fraisList.isEmpty()) {
            try {
                update fraisList;   
            } catch(Exception e) {
                if (systemDebug) { System.debug(e); }
            }
        }
        
    }    
    
    public void finish(Database.BatchableContext bc) {
        if (systemDebug) { System.debug('Completed'); }
    }
    
}