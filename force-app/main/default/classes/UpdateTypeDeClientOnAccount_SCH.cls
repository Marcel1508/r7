/**
 * @CreatedBy       : Suliman A.
 * @Date            : 23/08/2021
 * @Company         : IBM, Bluewolf
 * @Description     : This Schedulable class calls UpdateTypeDeClientOnAccount_BATCH class to update Type_de_client__c field on Account 
 * 				      by calculate the value of Montant_total_HT__c field on Facture__c object.
 */

public without sharing class UpdateTypeDeClientOnAccount_SCH implements Schedulable {

    public void execute(SchedulableContext ctx) {
        UpdateTypeDeClientOnAccount_BATCH myBatchObject = new UpdateTypeDeClientOnAccount_BATCH();
		Database.executeBatch(myBatchObject, 2000);
        
    }
}