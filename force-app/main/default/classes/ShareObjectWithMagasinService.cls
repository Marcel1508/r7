public class ShareObjectWithMagasinService {
    
    public void shareObjectWithMagasin(List<sObject> scope){
        Database.SaveResult[] srList;
        Map<String,Id> codeEstablishmentVsGroupId = new Map<String,Id>();
        Map<Id,String> magaIdVsCodeEtalishment = new Map<Id,String>();
        Set<String> codeEstablishmentIds = new Set<String>();
        Map<Id,Set<Id>> magaIdVsAccounts = new Map<Id,Set<Id>>();
        List<AccountShare> lstAccShare = new List<AccountShare>();
        Set<Id> allAccIds = new Set<Id>();
        Activite_potentiel__c act;
        Fidelite__c fd;
        Frais__c fr;
        Information_financiere__c infoFin;
        
        if(scope[0] instanceOf Activite_potentiel__c){   
            for(sObject obj : scope){
                act = (Activite_potentiel__c)obj;    
                magaIdVsCodeEtalishment.put(act.Magasin_actif__c,act.Magasin_actif__r.Code_etablissement__c);
                codeEstablishmentIds.add('%'+act.Magasin_actif__r.Code_etablissement__c);
                allAccIds.add(act.Account__c);
            }
        }else if(scope[0] instanceOf Fidelite__c){            
            for(sObject obj : scope){
                fd = (Fidelite__c)obj; 
                magaIdVsCodeEtalishment.put(fd.Magasin__c,fd.Magasin__r.Code_etablissement__c);
                codeEstablishmentIds.add('%'+fd.Magasin__r.Code_etablissement__c);
                allAccIds.add(fd.Compte__c);
            }   
            
        }else if(scope[0] instanceOf Frais__c){
            
            for(sObject obj : scope){
                fr = (Frais__c)obj; 
                magaIdVsCodeEtalishment.put(fr.Magasin_Associe__c,fr.Magasin_Associe__r.Code_etablissement__c);
            	codeEstablishmentIds.add('%'+fr.Magasin_Associe__r.Code_etablissement__c);
            	allAccIds.add(fr.Account__c);
            }   
            
        }else if(scope[0] instanceOf Information_financiere__c){
                        
            for(sObject obj : scope){
                 infoFin = (Information_financiere__c)obj; 
                 magaIdVsCodeEtalishment.put(infoFin.Magasin__c,infoFin.Magasin__r.Code_etablissement__c);
                 codeEstablishmentIds.add('%'+infoFin.Magasin__r.Code_etablissement__c);
                 allAccIds.add(infoFin.Account__c);
            }   
            
        }
        
         if(magaIdVsCodeEtalishment != null && !magaIdVsCodeEtalishment.isEmpty() && !codeEstablishmentIds.isEmpty()){
            
            for(Group g : [select id, developername, name from group where developername like : codeEstablishmentIds and name like '%/ Magasin']){
                String groupName=g.developername;
                Integer i = groupName.lastIndexOf('_');
                if(i!=-1){
                    String establishmentCode = groupName.substring(i+1, groupName.length());
                    codeEstablishmentVsGroupId.put(establishmentCode,g.Id);
                }
            }
        }
        
        Map<Id, Id> groupIdVsAccId = new Map<Id,Id>();
        List<Id> gId = codeEstablishmentVsGroupId.values();
        for(AccountShare accS : [Select Id,AccountId,UserOrGroupId FROM Accountshare WHERE AccountId IN :allAccIds AND UserOrGroupId IN :gId]){
            groupIdVsAccId.put(accS.UserOrGroupId,accS.AccountId);
        }
        
        Map<String, AccountShare> accountShareVsKey = new Map<String, AccountShare>();
        String idAccount;
        String codeEtablissement;
        if(scope[0] instanceOf Activite_potentiel__c){
             for(sObject obj : scope){
                 act= (Activite_potentiel__c)obj;
                 idAccount = act.Account__c;
                 codeEtablissement = act.Magasin_actif__r.Code_etablissement__c;
                
            }  
        } else if(scope[0] instanceOf Fidelite__c){
            for(sObject obj : scope){
                 act= (Activite_potentiel__c)obj;
                 idAccount = act.Account__c;
                 codeEtablissement = act.Magasin_actif__r.Code_etablissement__c;
            }  
            
        } else if(scope[0] instanceOf Frais__c){
            
        } else if(scope[0] instanceOf Information_financiere__c){
            
        }
           
    }
    
    private AccountShare addAccountShareObject(String accountId, String codeEtablissement, Map<String,Id> codeEstablishmentVsGroupId, Map<String, AccountShare> accountShareVsKey){
        AccountShare acctShare;
        Id grpId = codeEstablishmentVsGroupId.get(codeEtablissement);
         if(grpId != null ) {
                String key = accountId + '' + grpId;
                if(!accountShareVsKey.containsKey(key)) {
                    acctShare = new AccountShare(AccountId = accountId, UserOrGroupId = grpId, AccountAccessLevel = 'edit', OpportunityAccessLevel = 'edit', RowCause = 'Manual');    
                }
            }
        return acctShare;
        
    }
    
}