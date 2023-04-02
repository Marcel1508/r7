public without sharing class CreneauMagasinRecurrentService {
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findMagasinRecords(String magasinName) {  
       // string searchText = '\'%' + String.escapeSingleQuotes(magasinName) + '%\'';  
        //string query = 'SELECT Id, Name FROM Magasin__c WHERE Name LIKE '+searchText+' LIMIT 6';
       // return Database.query(String.escapeSingleQuotes(query)); 
 
        return Database.query('SELECT Id, Name FROM Magasin__c WHERE Name LIKE \'%' + String.escapeSingleQuotes(magasinName) + '%\' LIMIT 6');  
    }
    
    @AuraEnabled(cacheable=true)  
    public static String getMagasinServices(String magasinId) {
        try {
                List<Magasin__c> res = [SELECT ID, Services_disponibles__c FROM Magasin__c where Id = :magasinId];
                if (res != null && res.size() >0) { 
                    return res.get(0).Services_disponibles__c; 
                }
        } catch(Exception e) {
            System.debug('className : CreneauMagasinRecurrentService'+ e.getMessage()); 
        }
        return null;
    }
}