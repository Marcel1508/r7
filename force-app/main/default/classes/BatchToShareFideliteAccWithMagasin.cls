/**
* @CreatedBy       : Chandra Sekhar
* @Date            : 09/08/2021
* @Company         : IBM, Bluewolf
* @Description     : Batch Class to give Edit Access to Magasins which are linked to Fidélité on Accounts 
*/
public without sharing class BatchToShareFideliteAccWithMagasin implements Database.Batchable <sObject>{
    public Database.QueryLocator start(Database.BatchableContext info){
        String accStatus = 'Lead';
        String soql = 'Select Id,Compte__c,Magasin__c,Magasin__r.Code_etablissement__c FROM Fidelite__c WHERE Magasin__c != null AND Compte__c != null AND Compte__r.Statut_Fiche_client__c != :accStatus AND Magasin__r.Code_etablissement__c != null';
        return Database.getQueryLocator(soql);
    }
    public void execute(Database.BatchableContext info, List<Fidelite__c> scope){
        Database.SaveResult[] srList;
        Map<String,Id> codeEstablishmentVsGroupId = new Map<String,Id>();
        Map<Id,String> magaIdVsCodeEtalishment = new Map<Id,String>();
        Set<String> codeEstablishmentIds = new Set<String>();
        List<AccountShare> lstAccShare = new List<AccountShare>();
        Set<Id> allAccIds = new Set<Id>();
        for(Fidelite__c fd : scope){
            magaIdVsCodeEtalishment.put(fd.Magasin__c,fd.Magasin__r.Code_etablissement__c);
            codeEstablishmentIds.add('%'+fd.Magasin__r.Code_etablissement__c);
            allAccIds.add(fd.Compte__c);
        }
        
        if(magaIdVsCodeEtalishment != null && !magaIdVsCodeEtalishment.isEmpty() && !codeEstablishmentIds.isEmpty()){
            
            codeEstablishmentVsGroupId = Queries.getCodeEstablishmentVsGroupId(codeEstablishmentIds, magaIdVsCodeEtalishment);
        }
        
        Map<Id, Id> groupIdVsAccId = new Map<Id,Id>();
        groupIdVsAccId = Queries.getGroupIdVsAccId(allAccIds,codeEstablishmentVsGroupId);
       
        Map<String, AccountShare> accountShareVsKey = new Map<String, AccountShare>();
        
        for(Fidelite__c fd : scope) {
            String codeEtablissement = fd.Magasin__r.Code_etablissement__c;
            Id grpId = codeEstablishmentVsGroupId.get(codeEtablissement);
            if(grpId != null) {
                String key = fd.Compte__c + '' + grpId;
                if(!accountShareVsKey.containsKey(key)) {
                    AccountShare acctShare = new AccountShare(AccountId = fd.Compte__c, UserOrGroupId = grpId, AccountAccessLevel = 'edit', OpportunityAccessLevel = 'edit', RowCause = 'Manual');   
                    lstAccShare.add(acctShare);
                    accountShareVsKey.put(key, acctShare);
                }
            }
        }
        srList = (lstAccShare != null && !lstAccShare.isEmpty())? Database.insert(lstAccShare, false): new list<Database.SaveResult>();
        
    }
    public void finish(Database.BatchableContext info){ 
        Utilities2.createErrorLogBatch(info.getJobId(),'BatchToShareFideliteAccWithMagasin');
        
    }
    
}