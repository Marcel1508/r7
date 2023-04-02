/**
* @author       jan.straka@bluewolf
* @date         2021-01-29
* @description  TriggerHandler for AccountTrigger
**/
public without sharing class AccountTriggerHandler {
    private final List<Account> newRecords;
    private final List<Account> oldRecords;
    private final Map<Id, Account> newRecordsMap;
    private final Map<Id, Account> oldRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    private static AccountService service = new AccountService();

    private final String User_Name = UserInfo.getName(); //FDI 19/07/2021 : Get Current user

    public AccountTriggerHandler(List<Account> newRecords, List<Account> oldRecords, Map<Id, Account> newRecordsMap, Map<Id, Account> oldRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
        this.oldRecordsMap = oldRecordsMap;
    }

    public void beforeInsert() {
        if (bypassTrigger) { return; }
        List<Account> accountsToCheck = service.filterAccountsForCheckSiret(newRecords);
        if (!accountsToCheck.isEmpty()) {
            service.checkSiret(accountsToCheck);    
        }
       //Check if Code_Chaine__c is filled => Account becomes Grand Compte
        service.checkGrandCompte(newRecords);
      

         // Assign 'owner' and 'Assigne_a__c' in Accounts if Magasin_actif_en_cours__c value update first time
         if(User_Name == 'Data Integration' || User_Name.containsIgnoreCase('Guest')){
         List<Account> accountsForOwnerAssign = service.isMagasinActifEnCoursChange(newRecords);
         if (!accountsForOwnerAssign.isEmpty()) {
            service.assignOwnerId(accountsForOwnerAssign);   
         }
        }
        
         // added by ajay ,to update the numero client on basis of status
        service.updateNumeroClient(newRecords);  
        
        //S.A 17/08/2021: If user select "Personnel Promocash" as Catégorie Client, the Code APE "XXXXX" will be selected automatically 
        if(User_Name != 'Data Integration'){
            service.setCodeAPEAutomatically(newRecords);

            //added by Ajay
            if(service.checkContactMagasin(newRecords)){   
                service.assignOwnerAndMagasin(newRecords);
            }  
            
        }
    }

    public void beforeUpdate() {
        if (bypassTrigger) { return; }
        List<Account> accountsToCheck = service.filterAccountsForCheckSiret(newRecords, oldRecordsMap);
        if (!accountsToCheck.isEmpty()) {
            service.checkSiret(accountsToCheck);    
        }
        // Update when Account becomes "Prospect"
        List<Account> accountsProspect = service.filterAccountsProspect(newRecords, oldRecordsMap);
        if (!accountsProspect.isEmpty()) {
            // added by ajay ,to update the numero client on basis of status
            service.updateNumeroClient(accountsProspect);   
        }
        // update when Statut Fiche Client value change,assign record type
        List<Account> accountsToCheckStatutFicheClient = service.filterToCheckStatutFicheClient(newRecords, oldRecordsMap);
        if (!accountsToCheckStatutFicheClient.isEmpty()) {
            service.assignRecordType(accountsToCheckStatutFicheClient);   
        }
        // store assignment
        List<Account> accountsForStoreAssign = service.filterAccountsStoreAssignment(newRecords, oldRecordsMap);
        if (!accountsForStoreAssign.isEmpty()) {
            service.assignStore(accountsForStoreAssign);   
        }
        // Assign 'owner' and 'Assigne_a__c' in Accounts if Magasin_actif_en_cours__c value change
     /*   List<Account> accountsForOwnerAssign = service.isMagasinActifEnCoursChange(newRecords, oldRecordsMap);
        if (!accountsForOwnerAssign.isEmpty()) {
           
            service.assignOwnerId(accountsForOwnerAssign);      
        }*/
        //Check if Code_Chaine__c is filled => Account becomes Grand Compte
        service.checkGrandCompte(newRecords);
        
        //S.A 17/08/2021: If user select "Personnel Promocash" as Catégorie Client, the Code APE "XXXXX" will be selected automatically 
        if(User_Name != 'Data Integration'){
            service.setCodeAPEAutomatically(newRecords);
            // addedby ajay 
            service.checkContactMagasin(newRecords);
        }
        
    }
    
    public void afterInsert() {
        if (bypassTrigger) { return; }
        if (firstRun) {
            // service.createFrais(newRecords);
            firstRun = false;
        }
        if (!System.isFuture() && !System.isBatch() && User_Name != 'Data Integration') {
            AccountResultsToApigee_SVC.getAccounts('AInsert', newRecords);
        }
    }

    public void afterUpdate() {
        if (bypassTrigger) { return; }
        if (firstRun) {
            // service.upsertFrais(newRecordsMap);
            List<Account> accountsUpdateFrais = service.filterAccountsStoreAssignment(newRecords, oldRecordsMap);
            service.updateRelatedFrais(accountsUpdateFrais);
            service.updateExternalIds(newRecords, newRecordsMap, oldRecordsMap);
            if (!System.isFuture() && !System.isBatch() && User_Name != 'Data Integration') {
                
                AccountResultsToApigee_SVC.getAccounts('AUpdate', newRecords);
    
            }
        firstRun = false;
        }
        
    }

}