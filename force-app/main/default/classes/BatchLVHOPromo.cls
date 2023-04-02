public without sharing class BatchLVHOPromo implements Database.Batchable<sObject> {
    
    public static Boolean systemDebug = Utilities.displaySystemDebug();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Prix_de_vente_promotion__c, Type_de_promotion__c, Type_d_offre__c FROM Promotion__c where Prix_de_vente_promotion__c !=0 AND LastModifiedDate!= TODAY';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Promotion__c> promoList) {
       List<Promotion__c> promotionsToUpdate = new List<Promotion__c>();
       for(Promotion__c p: promoList)
        {
            if(p.Type_de_promotion__c == 'LVHO' && p.Type_d_offre__c=='P')
            {
                promotionsToUpdate.add(p);
            }
                
        }
        if (!promotionsToUpdate.isEmpty()) {
            try {
                update promotionsToUpdate;   
            } catch(Exception e) {
                if (systemDebug) { System.debug(e); }
            }
        }
        
    }    
    
    public void finish(Database.BatchableContext bc) {
        if (systemDebug) { System.debug('Completed'); }
    }
    
}