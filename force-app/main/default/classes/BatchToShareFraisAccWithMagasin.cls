/**
* @CreatedBy       : Chandra Sekhar
* @Date            : 09/08/2021
* @Company         : IBM, Bluewolf
* @Description     : Batch Class to give Edit Access to Magasins which are linked to Frais & autorisations on Accounts 
*/
public without sharing class BatchToShareFraisAccWithMagasin implements Database.Batchable <sObject>{
    public Database.QueryLocator start(Database.BatchableContext info){
        String accStatus = 'Lead';
        String soql = 'Select Id,Account__c,Magasin_Associe__c, Magasin_Associe__r.Code_etablissement__c FROM Frais__c WHERE Magasin_Associe__c != null AND Account__c != null AND Account__r.Statut_Fiche_client__c != :accStatus AND Magasin_Associe__r.Code_etablissement__c != null';
        return Database.getQueryLocator(soql);
    }
    public void execute(Database.BatchableContext info, List<Frais__c> scope){
        Database.SaveResult[] srList;
        Map<String,Id> codeEstablishmentVsGroupId = new Map<String,Id>();
        Map<Id,String> magaIdVsCodeEtalishment = new Map<Id,String>();
        Set<String> codeEstablishmentIds = new Set<String>();
        List<AccountShare> lstAccShare = new List<AccountShare>();
        Set<Id> allAccIds = new Set<Id>();
        for(Frais__c fr : scope){
            magaIdVsCodeEtalishment.put(fr.Magasin_Associe__c,fr.Magasin_Associe__r.Code_etablissement__c);
            codeEstablishmentIds.add('%'+fr.Magasin_Associe__r.Code_etablissement__c);
            allAccIds.add(fr.Account__c);
            
        }
        
        if(magaIdVsCodeEtalishment != null && !magaIdVsCodeEtalishment.isEmpty() && !codeEstablishmentIds.isEmpty()){          
            codeEstablishmentVsGroupId = Queries.getCodeEstablishmentVsGroupId(codeEstablishmentIds, magaIdVsCodeEtalishment);
        }
        
        Map<Id, Id> groupIdVsAccId = new Map<Id,Id>();
        groupIdVsAccId = Queries.getGroupIdVsAccId(allAccIds,codeEstablishmentVsGroupId);
       
        Map<String, AccountShare> accountShareVsKey = new Map<String, AccountShare>();
        
        for(Frais__c fr  : scope) {
            String codeEtablissement = fr.Magasin_Associe__r.Code_etablissement__c;
            Id grpId = codeEstablishmentVsGroupId.get(codeEtablissement);
            if(grpId != null  ) {
                String key = fr.Account__c + '' + grpId;
                if(!accountShareVsKey.containsKey(key)) {
                    AccountShare acctShare = new AccountShare(AccountId = fr.Account__c, UserOrGroupId = grpId, AccountAccessLevel = 'edit', OpportunityAccessLevel = 'edit', RowCause = 'Manual');   
                    lstAccShare.add(acctShare);
                    accountShareVsKey.put(key, acctShare);
                }
            }
        }
        
        srList = (lstAccShare != null && !lstAccShare.isEmpty())? Database.insert(lstAccShare, false): new list<Database.SaveResult>();
        
    }
    public void finish(Database.BatchableContext info){ 
        Utilities2.createErrorLogBatch(info.getJobId(),'BatchToShareFraisAccWithMagasin');        
        BatchToShareFideliteAccWithMagasin b = new BatchToShareFideliteAccWithMagasin();
        Database.executeBatch(b, 50);
    }
    
}