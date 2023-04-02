/**
* @CreatedBy       : Suliman A.
* @Date            : 10/08/2021
* @Company         : IBM, Bluewolf
* @Description     : A Batch to update Etat field on Account by calculate the value of Date_derniere_facture__c field on Activite_potentiel__c object.  
*/

public without sharing class UpdateEtatFieldOnAccount_BATCH implements Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    //Prepare the data
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select id, (select Id, Account__r.Id, Account__r.Statut_Client_sur_le_magasin__c, Date_derniere_facture__c from Activit_s_potentiel__r where Date_derniere_facture__c != null order by Date_derniere_facture__c desc limit 1) from account';
        return Database.getQueryLocator(query);
    }
    //Compare Date_derniere_facture__c value to set Statut_Client_sur_le_magasin__c 's value on Account
    public void execute(Database.BatchableContext bc, List<Account> scope){
        List<Activite_potentiel__c> activities = new List<Activite_potentiel__c>();
        for(Account a: scope) {
            if(!a.Activit_s_potentiel__r.isEmpty())
                activities.add(a.Activit_s_potentiel__r.get(0));
        }
        Map<Id, Activite_potentiel__c> newScope = new Map<Id, Activite_potentiel__c>();
        //Retrieve the most recent value in Date_derniere_facture__c field on Activite_potentiel__c object related to an Account 
        for (Activite_potentiel__c activityPotentiel : activities) {
            newScope.put(activityPotentiel.Account__c, activityPotentiel);
        }
        
        //Retrieve batch parameters
        UpdateEtatFieldOnAccountBatch__mdt batchParameters = [SELECT Label, Actif_Achetant_Limit__c, Actif_NonAchetant_Limit_1__c, Actif_NonAchetant_Limit_2__c, Inactif_Limit__c FROM UpdateEtatFieldOnAccountBatch__mdt LIMIT 1];
        Integer actifAchetantLimit = batchParameters.Actif_Achetant_Limit__c.intValue();
        Integer actifNonAchetantLimit1 = batchParameters.Actif_NonAchetant_Limit_1__c.intValue();
        Integer actifNonAchetantLimit2 = batchParameters.Actif_NonAchetant_Limit_2__c.intValue();
        Integer inactifLimit = batchParameters.Inactif_Limit__c.intValue();
        
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        //Loop over data
        for (Activite_potentiel__c activityPotentiel : newScope.values()) {
            //If activityPotentiel is IN LAST 30 DAYS, Set the Statut_Client_sur_le_magasin__c on Account to 'Actif_Achetant'
            if(activityPotentiel.Date_derniere_facture__c >= Date.today().addDays(-actifAchetantLimit) && activityPotentiel.Date_derniere_facture__c <= Date.today()){
                if(activityPotentiel.Account__r.Statut_Client_sur_le_magasin__c != Constants.ACTIF_ACHETANT){
                    activityPotentiel.Account__r.Statut_Client_sur_le_magasin__c = Constants.ACTIF_ACHETANT;
                    accountsToUpdate.put(activityPotentiel.Account__c, activityPotentiel.Account__r);
                    // Increment the instance member counter
                    recordsProcessed = recordsProcessed + 1;
                }
            }
            //If activityPotentiel is BEFORE LAST 30 DAYS AND AFTER THE LAST 90 DAYS, Set the Statut_Client_sur_le_magasin__c on Account to 'Actif_Non_Achetant'
            else if(activityPotentiel.Date_derniere_facture__c >= Date.today().addDays(-actifNonAchetantLimit2) && activityPotentiel.Date_derniere_facture__c < Date.today().addDays(-actifNonAchetantLimit1)){
                if(activityPotentiel.Account__r.Statut_Client_sur_le_magasin__c != 'Actif_Non_Achetant'){
                    activityPotentiel.Account__r.Statut_Client_sur_le_magasin__c = 'Actif_Non_Achetant';
                    accountsToUpdate.put(activityPotentiel.Account__c, activityPotentiel.Account__r);
                    // Increment the instance member counter
                    recordsProcessed = recordsProcessed + 1;
                }
            }
            //If activityPotentiel is BEFORE LAST 90 DAYS, Set the Statut_Client_sur_le_magasin__c on Account to 'Inactif'
            else if(activityPotentiel.Date_derniere_facture__c < Date.today().addDays(-inactifLimit)){
                if(activityPotentiel.Account__r.Statut_Client_sur_le_magasin__c != 'Inactif'){
                    activityPotentiel.Account__r.Statut_Client_sur_le_magasin__c = 'Inactif';
                    accountsToUpdate.put(activityPotentiel.Account__c, activityPotentiel.Account__r);
                    // Increment the instance member counter
                    recordsProcessed = recordsProcessed + 1;
                }
            }
        }
        
        //update accountsToUpdate.values();
        Database.SaveResult[] results = Database.update(accountsToUpdate.values(), false);
        // Iterate through each returned result
        List<Error_Log__c> errorsToUpdate = new List<Error_Log__c>();
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    errorsToUpdate.add(new Error_Log__c(
                        Name = 'UpdateEtatFieldOnAccount '+bc.getJobId(),
                        Batch_Name__c = 'UpdateEtatFieldOnAccount_BATCH',
                        ID_Job__c = bc.getJobId(),
                        Job_Name__c = 'UpdateEtatFieldOnAccount',
                        Execution_Time__c = Date.today(),
                        Error__c = err.getMessage()
                    ));
                }
            }
        }
        Database.SaveResult[] errors = Database.insert(errorsToUpdate, false);
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed, ExtendedStatus, CreatedDate,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        if(job.NumberOfErrors >= 1){
            insert new Error_Log__c(
                Name = 'UpdateEtatFieldOnAccount '+job.Id,
                Batch_Name__c = 'UpdateEtatFieldOnAccount_BATCH',
                ID_Job__c = job.Id,
                Job_Name__c = 'UpdateEtatFieldOnAccount',
                Execution_Time__c = job.CreatedDate,
                Error__c = job.ExtendedStatus
            );
        }
        
    }
    
}