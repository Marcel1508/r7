/**
 * @CreatedBy       : Suliman A.
 * @Date            : 12/08/2021
 * @Company         : IBM, Bluewolf
 * @Description     : This Schedulable class calls UpdateEtatFieldOnAccount_BATCH class to schedule the update of Etat(Statut_Client_sur_le_magasin__c) field on Account 
 *                    by calculating the value of Date_derniere_facture__c field on Activite_potentiel__c
 */

public without sharing class UpdateEtatFieldOnAccount_SCH implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        UpdateEtatFieldOnAccount_BATCH myBatchObject = new UpdateEtatFieldOnAccount_BATCH();
		Database.executeBatch(myBatchObject, 2000);
        
    }

}