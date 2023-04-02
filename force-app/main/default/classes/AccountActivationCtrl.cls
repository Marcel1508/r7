/* 
-------------------------------------------------------------------------
Version#     Date                  Author                 Description
-------------------------------------------------------------------------
1.0          04-02-2021        	   Preethi.u              Initial Version
-------------------------------------------------------------------------
*/ 

global without sharing class AccountActivationCtrl {   
    
    @InvocableMethod(label='Activate the account')
    public static List<AccountActivationResult> checkChidRecords(list<FlowInput> request){
        
        List<ActivationDeCompteCtrl.ActivationDeCompteCtrlWrapper> buyerGroup=new  List<ActivationDeCompteCtrl.ActivationDeCompteCtrlWrapper>();
        List<CommunityUserCtrl.CommunityUser> userCreation  = new  List<CommunityUserCtrl.CommunityUser>();
        
        List<AccountActivationResult> results = new List<AccountActivationResult>();// store the final response
        AccountActivationResult response=new AccountActivationResult();
        response.isSuccess=false;
        results.add(response);
        
        
        try{
            list<Account> accList=request[0].nonActivatedaccountList;// contains only non activated Accounts 
            list<Account> allAccountList=request[0].accountList;// contains all the accounts List
            list<String> activatedAccountsName=new list<String>();// store activated accounts name 
            list<String> nonActivatedAccountsName=new list<String>();// store non activated Accounts name 
            Set<String> accountIds = new Set<String>();// Processed account ids after user creation 
            Set<String> updateAccountIds = new Set<String>();// account ids which update child record successfully (frais,fidilite,active potential)
            Set<String> notUpdatedAccountIds = new Set<String>();// account ids which not update child record successfully (frais,fidilite,active potential)

            for(Account ac: allAccountList ){
                if(ac.IsBuyer ){
                    activatedAccountsName.add(ac.Name);
                }else{
                    nonActivatedAccountsName.add(ac.Name);
                }
            }
            
            Map<String, Account> updateAccountMap = new Map<String, Account>();
            List<Account>  updateAccounts=new List<Account>();
            if(!accList.isEmpty()){
                  // create the user for community
                    userCreation= CommunityUserCtrl.createUser(accList);
                    if(userCreation[0].isSuccess){
                      accountIds=userCreation[0].processedAccountIds;
                        if(!accountIds.isEmpty()){
                            updateAccounts=getAccounts(accountIds);
                            updateAccountMap = processAccountRelatedChilds(updateAccounts);
                            if(!updateAccountMap.isEmpty()){
                                system.debug('Size----->'+updateAccountMap.values().size());
                               Database.SaveResult[] result = Database.update(updateAccountMap.values(),false);
                               for(Integer i=0; i < result.size(); i++) {
                                system.debug('result***----->'+result.get(i));
                                    if(result.get(i).isSuccess()) {
                                        System.debug('Records are updated Successfully');
                                        updateAccountIds.add(result.get(i).Id);
                                    } 
                                    else if(!result.get(i).isSuccess()) {
                                        Database.Error errors =  result.get(i).getErrors().get(0);
                                        System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                                        System.debug('Failure Record Ids While Updating'+updateAccountMap.values().get(i).Id);
                                       // notUpdatedAccountIds.add(result.get(i).Id);
                                    }
                                }
                            }     
                               if(!updateAccountIds.isEmpty()){
                                    // account update successfully
                                    buyerGroup= ActivationDeCompteCtrl.updateNonActivateAccount(updateAccountMap.values());   
                                if(buyerGroup[0].isSuccess){  
                                List<Prix_specifiques__c> prixSpecfiques=new List<Prix_specifiques__c>();
                                prixSpecfiques=[Select Id,Name,Reference_client__c,Libelle_etablissement__c,Produit__c,Prix_de_vente_au_conditionnement__c
                                                from Prix_specifiques__c 
                                                where Reference_client__c in :accountIds];   
                                if(!prixSpecfiques.isEmpty()){
                                    PrixSpecifiqueService cls=new PrixSpecifiqueService();
                                    cls.checkInformationRelatedToPrixSpecifiques(prixSpecfiques);
                                
                                }
                                    response.isSuccess=true;
                                    response.nonActivatedAccounts= listToString(nonActivatedAccountsName);
                                    response.alreadyActivatedAccounts=activatedAccountsName.isEmpty()?'There is no Already Active Accounts': listToString(activatedAccountsName);
                                    response.userCreated=userCreation[0].insertedUser;
                                    response.message='Community user created successfully!!';
                                    response.processedAccounts = userCreation[0].processedAccounts;
                                }else{
                                    response.isSuccess=false;
                                    response.message='Something went wrong in Buyer group Member Creation .Please contact the admin.';
                                }
                               }else{
                                    // issue in updateAccount with child record value
                                    response.isSuccess=false;
                                    response.message='Something went wrong in child record creation .Please contact the admin.';


                                }
                        }
                        
                    }else{
                        response.isSuccess=false;
                        response.userCreated=userCreation[0].insertedUser;
                        response.message='Something went wrong in community user creation .Please contact the admin.';
                    }

            }else{
                response.message='Check the selected Accounts are activated already or Some issue with records chosen!!';
            } 
        }
        catch(Exception ex) {
            System.debug('Exception message :'+ex.getMessage());
            System.debug('Line :'+ex.getLineNumber());
             System.debug('Stack :'+ex.getStackTraceString());
            response.isSuccess=false;
            response.message='Something went wrong in Flow .Please contact the admin.';
        }
        
        return results;
    }
    
    public static string buildCompositeKey(String accId, String magasinActifEnCours){
        String compositeKey = accId+magasinActifEnCours;
        return compositeKey;
    }
    
    
    public static Map<String, Frais__c> fetchFraisMap(Set<String> accSetIds){
        Map<String, Frais__c> fraisMap = new Map<String, Frais__c>();
        List<Frais__c> fraisList = [Select Account__c, Magasin_Associe__c from Frais__c where Account__c IN:accSetIds AND Magasin_Associe__c != NULL];
        for(Frais__c fraRecord : fraisList){
            String fraisCompositeKey = buildCompositeKey(fraRecord.Account__c, fraRecord.Magasin_Associe__c);
            fraisMap.put(fraisCompositeKey, fraRecord);
        } 
        return fraisMap;
    }
    
    public static Map<String, Fidelite__c> fetchFideliteMap(Set<String> accSetIds){
        Map<String, Fidelite__c> fideliteMap = new Map<String, Fidelite__c>();
        List<Fidelite__c> fideliteList = [Select Compte__c, Magasin__c from Fidelite__c where Compte__c IN:accSetIds AND Magasin__c != NULL];
        for(Fidelite__c fideliteRecord : fideliteList){
            String fideliteCompositeKey = buildCompositeKey(fideliteRecord.Compte__c, fideliteRecord.Magasin__c);
            fideliteMap.put(fideliteCompositeKey, fideliteRecord);
        } 
        return fideliteMap;
    }
    
    public static Map<String, Activite_potentiel__c> fetchActivitePotentielMap(Set<String> accSetIds){
        Map<String, Activite_potentiel__c> activitePotenMap = new Map<String, Activite_potentiel__c>();
        List<Activite_potentiel__c> activitePotenList = [Select Account__c, Magasin_actif__c from Activite_potentiel__c where Account__c IN:accSetIds AND Magasin_actif__c != NULL];
        for(Activite_potentiel__c actPotenRecord : activitePotenList){
            String actPotentielCompositeKey = buildCompositeKey(actPotenRecord.Account__c, actPotenRecord.Magasin_actif__c);
            activitePotenMap.put(actPotentielCompositeKey, actPotenRecord);
        } 
        return activitePotenMap;
    }
    
    public static Map<String, Account> processAccountRelatedChilds(List<Account> accList){
        Map<String, Account> accountCompositeMap = new Map<String, Account>();
        Set<String> accountSetIds = new Set<String>();
        for(Account accRecord : accList){
            if (accRecord.Magasin_actif_en_cours__c != null){
                String accountCompositeKey = buildCompositeKey(accRecord.Id, accRecord.Magasin_actif_en_cours__c);
                accountCompositeMap.put(accountCompositeKey, accRecord);
                accountSetIds.add(accRecord.Id);
            }
        }
        Map<String, Account> updateAccountMap = new Map<String, Account>();
        
        // Frais__c records update
        List<Frais__c> insertFraisList = new List<Frais__c>();
        Map<String, Frais__c> fraisMap = fetchFraisMap(accountSetIds); 
        for(String accountKey : accountCompositeMap.keySet()){
            if(fraisMap.containsKey(accountKey)){
                Frais__c fraisRec = fraisMap.get(accountKey);
                Account updateAccRecord = new Account();
                updateAccRecord.Id = fraisRec.Account__c;
                updateAccRecord.Frais_autorisations__c = fraisRec.Id;
                updateAccRecord.Statut_Fiche_client__c = 'Prospect';
                updateAccountMap.put(fraisRec.Account__c, updateAccRecord);
            }else{
                Account accRecord = accountCompositeMap.get(accountKey);
                Frais__c fraisRecord = new Frais__c();
                fraisRecord.Account__c = accRecord.Id;
                fraisRecord.Magasin_Associe__c = accRecord.Magasin_actif_en_cours__c;
                insertFraisList.add(fraisRecord);
            }
        }
        if(!insertFraisList.isEmpty()){
            Insert insertFraisList;
            for(Frais__c fraisRec : insertFraisList){
                                         if(!updateAccountMap.containsKey(fraisRec.Account__c)){
                                             Account updateAccRecord = new Account();
                                             updateAccRecord.id= fraisRec.Account__c;
                                             updateAccRecord.Frais_autorisations__c = fraisRec.Id;
                                             updateAccRecord.Statut_Fiche_client__c = 'Prospect';
                                             updateAccountMap.put(fraisRec.Account__c, updateAccRecord);
                                         }
                                     }
        }
        
        //Fidelite__c records update
        List<Fidelite__c> insertFideliteList = new List<Fidelite__c>();
        Map<String, Fidelite__c> fideliteMap = fetchFideliteMap(accountSetIds); 
        for(String accountKey : accountCompositeMap.keySet()){
            if(fideliteMap.containsKey(accountKey)){
                Fidelite__c fideRec = fideliteMap.get(accountKey);
                Account updateAccRecord = updateAccountMap.get(fideRec.Compte__c);
                updateAccRecord.Fidelite__c = fideRec.Id;
                updateAccRecord.Statut_Fiche_client__c = 'Prospect';
                updateAccountMap.put(fideRec.Compte__c, updateAccRecord);
            }else{
                Account accRecord = accountCompositeMap.get(accountKey);
                Fidelite__c fideliteRecord = new Fidelite__c();
                fideliteRecord.Compte__c = accRecord.Id; 
                fideliteRecord.Magasin__c = accRecord.Magasin_actif_en_cours__c;
                insertFideliteList.add(fideliteRecord); 
            }
        } 
        
        if(!insertFideliteList.isEmpty()){
            Insert insertFideliteList;
            for(Fidelite__c fideRec : insertFideliteList ){
                                          if(updateAccountMap.containsKey(fideRec.Compte__c)){
                                               Account updateAccRecord;
                                               updateAccRecord = updateAccountMap.get(fideRec.Compte__c);
                                               updateAccRecord.Fidelite__c = fideRec.Id;
                                               updateAccRecord.Statut_Fiche_client__c = 'Prospect';
                                               updateAccountMap.put(fideRec.Compte__c, updateAccRecord);
                                           }
                                       }
            
        } 
        
        //Activite_potentiel__c records update
        List<Activite_potentiel__c> insertActPotentielList = new List<Activite_potentiel__c>();
        Map<String, Activite_potentiel__c> activitePotenMap = fetchActivitePotentielMap(accountSetIds); 
        for(String accountKey : accountCompositeMap.keySet()){
            if(activitePotenMap.containsKey(accountKey)){
                Activite_potentiel__c actPotenRec = activitePotenMap.get(accountKey);
                Account updateAccRecord = updateAccountMap.get(actPotenRec.Account__c);
                updateAccRecord.Activite_potentiel__c = actPotenRec.Id;
                updateAccRecord.Statut_Fiche_client__c = 'Prospect';
                updateAccountMap.put(actPotenRec.Account__c, updateAccRecord);
            }else{
                Account accRecord = accountCompositeMap.get(accountKey);
                Activite_potentiel__c actpotenRecord = new Activite_potentiel__c();
                actpotenRecord.Account__c = accRecord.Id; 
                actpotenRecord.Magasin_actif__c = accRecord.Magasin_actif_en_cours__c;
                insertActPotentielList.add(actpotenRecord);
            }
        } 
        
        if(!insertActPotentielList.isEmpty()){
            Insert insertActPotentielList;
            for(Activite_potentiel__c actPotenRec : insertActPotentielList ){
                                                         if(updateAccountMap.containsKey(actPotenRec.Account__c)){
                                                             Account updateAccRecord = updateAccountMap.get(actPotenRec.Account__c);
                                                             updateAccRecord.id= actPotenRec.Account__c;
                                                             updateAccRecord.Activite_potentiel__c = actPotenRec.Id;
                                                             updateAccRecord.Statut_Fiche_client__c = 'Prospect';
                                                             updateAccountMap.put(actPotenRec.Account__c, updateAccRecord);
                                                              }
                                                     }
        }
        return updateAccountMap;
    }
    
    //return the list of Accounts Name to Concatenate Name
    public static String listToString(List<String> aList) {
        String allstring = string.join(aList,',');
        return allstring;
    }

     //Added by ajay to store the accounts
     public static List<Account> getAccounts(set<String> accountIds) {
        
        return [select Id, Name, IsBuyer,Magasin_actif_en_cours__c,Magasin_de_rattachement__c
        from Account where id in: accountIds ];
    }

    public class FlowInput {
        @InvocableVariable(label = 'Account List' required = true)
        public List<Account> accountList;
        
        @InvocableVariable(label = 'Non Activated Account List' required = true)
        public List<Account> nonActivatedaccountList;
        
    }
    
    
    
    public class AccountActivationResult {
        
        @InvocableVariable
        public String nonActivatedAccounts;
        
        @InvocableVariable
        public String alreadyActivatedAccounts;
        
         @InvocableVariable
        public String processedAccounts;
        
        @InvocableVariable
        public String userCreated;
        
        @InvocableVariable
        public Boolean isSuccess;
        
        @InvocableVariable
        public String message;
    
    }

    
}