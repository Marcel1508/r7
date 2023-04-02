public without sharing class GenerateSlotsBatch implements Database.Batchable<sObject> {
    Date todayDate;
    
    public GenerateSlotsBatch(Date todayDate) {
        this.todayDate = todayDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(GenerateSlots_Service.getQuery(this.todayDate));
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        GenerateSlots_Service.generateCreneaux((List<Creneau_Magasin_Recurrent__c>)scope, todayDate);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}