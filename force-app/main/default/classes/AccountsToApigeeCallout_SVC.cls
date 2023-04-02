/**
 * @CreatedBy       : Suliman A.
 * @Date            : 08/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : Rest API PUT call to APIGEE in order to send the Account records when created or updated.  
 */

public without sharing class AccountsToApigeeCallout_SVC {

    @future(callout=true)
    public static void accountPostOrPutCallout(String clientNum, String jsonContent, String recordID, String apiGeeBaseURL, String apiGeeClientId, String apiGeeClientKey) {
        
        if(clientNum != null){
            //Identify PUT or POST
            String postOrPut;
            String apiGeeURL;
            //Make HTTP request to ApiGee
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            if(clientNum == ''){
                //apiGeeURL = apiGeeBaseURL;
                request.setEndpoint('callout:Apigee'+'/retail/v1/digital/accounts');
                postOrPut = 'POST';
            } else if(clientNum.length()>0){
               //apiGeeURL = apiGeeBaseURL+'/'+clientNum;
                request.setEndpoint('callout:Apigee'+'/retail/v1/digital/accounts/'+clientNum);
                postOrPut = 'PUT';
            }
            
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-apigee-client-id', '{!$Credential.UserName}');
            request.setHeader('x-apigee-client-secret', '{!$Credential.Password}');
            request.setMethod(postOrPut);
            request.setBody(jsonContent);
            //request.setBody('{"name":"Test2 Account From SF"}');
           // try{
                HttpResponse response = http.send(request);
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    updateAccountsWithErrorDetails(recordID, response, postOrPut);
                } else {
                    updateAccountsWithErrorDetails(recordID, response, postOrPut);
                }
                
 /*           }
            catch(CalloutException ex){
                  
            }
*/
            
        }
        
    }
    
    public static void updateAccountsWithErrorDetails(String accountId, System.HttpResponse response, String postOrPut){
        
        List<Account> accountsToUpdate = new List<Account>();
        Account accountToUpdate = [SELECT Aquilon_synchronisation_details__c, Aquilon_Synchronisation_Statut__c, ifAccountSentToAkeneo__c FROM Account WHERE Id =: accountId LIMIT 1];
        
        if (response.getStatusCode() != 200) {
            accountToUpdate.Aquilon_Synchronisation_Statut__c = Constants.AQUILON_SYNCHRONISATION_STATUS2;
            accountToUpdate.Aquilon_synchronisation_details__c = DateTime.now() + ' : '+'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus();
            accountsToUpdate.add(accountToUpdate);
        } else {
            if(postOrPut == 'POST') { // The first time account is created in Akeneo, we update ifAccountSentToAkeneo__c = true
                accountToUpdate.ifAccountSentToAkeneo__c = true;
            }
            accountToUpdate.Aquilon_Synchronisation_Statut__c = Constants.AQUILON_SYNCHRONISATION_STATUS3;
            accountToUpdate.Aquilon_synchronisation_details__c = DateTime.now() + ' : '+'The status code returned was seccessful: ' + 
                response.getStatusCode() + ' ' + response.getStatus();
            accountsToUpdate.add(accountToUpdate);
        }
        
        //update accountsToUpdate;
        Database.SaveResult [] updateResult = Database.update(accountsToUpdate, false);
        // Iterate through each returned result to retrieve errors
        for (Database.SaveResult mList : updateResult) {
            if (mList.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
               }
            else {
                // Operation failed, so get all errors               
                for(Database.Error err : mList.getErrors())
                {
                }
                    
            }
        }
    }
}