/**
 * @CreatedBy       : Suliman A.
 * @Date            : 26/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : Rest API PUT call to APIGEE in order to send the Order records when created or updated.  
 */

global class OrdersToApigeeCallout_SVC {

    @future(callout=true)
    public static void orderPostOrPutCallout(String orderNum, String JSONContent, String recordID, String apiGeeBaseURL, String apiGeeId, String apiGeeKey) {
        
        if(orderNum != null){
            //Identify PUT or POST
            String PostOrPut;
            String apiGeeURL;
           //Make HTTP request to ApiGee
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            if(orderNum == ''){
               // apiGeeURL = apiGeeBaseURL;
               request.setEndpoint('callout:Apigee'+'/retail/v1/digital/orders');
                PostOrPut = 'POST'; 
            } else if(orderNum.length()>0){
               // apiGeeURL = apiGeeBaseURL+'/'+orderNum;
                request.setEndpoint('callout:Apigee'+'/retail/v1/digital/orders/'+orderNum);
                PostOrPut = 'PUT';
            }
            system.debug('===> '  + Request.getEndpoint());
          //  request.setEndpoint(apiGeeURL);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-apigee-client-id', '{!$Credential.UserName}');
            request.setHeader('x-apigee-client-secret', '{!$Credential.Password}');
            request.setMethod(PostOrPut);
            request.setBody(JSONContent);
            //request.setBody('{"name":"Test2 Account From SF"}');
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                //Call method to set Order Synchronisation/Errors fields
                updateOrdersWithErrorDetails(recordID, response);
            } else {
                //Call method to set Order Synchronisation/Errors fields
                updateOrdersWithErrorDetails(recordID, response);
            }
        }
    }
    
    public static void updateOrdersWithErrorDetails(String OrderId, System.HttpResponse response){
        
        List<Order> ordersToUpdate = new List<Order>();
        Order orderToUpdate = new Order(Id=OrderId);
        if (response.getStatusCode() != 200) {
            orderToUpdate.Aquilon_Synchronisation_Statut__c = '2';
            orderToUpdate.Aquilon_synchronisation_details__c = DateTime.now().format('dd-MM-yyyy HH:mm:ss a', 'CET') + ' : '+'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus();
            ordersToUpdate.add(orderToUpdate);
        } else {
            orderToUpdate.Aquilon_Synchronisation_Statut__c = '3';
            orderToUpdate.Aquilon_synchronisation_details__c = DateTime.now().format('dd-MM-yyyy HH:mm:ss a', 'CET') + ' : '+'The status code returned was seccessful: ' + 
                response.getStatusCode() + ' ' + response.getStatus();
            ordersToUpdate.add(orderToUpdate);
        }
        
        Database.SaveResult [] updateResult = Database.update(ordersToUpdate, false);
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