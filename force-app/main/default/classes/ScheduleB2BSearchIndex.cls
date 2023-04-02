public without sharing class ScheduleB2BSearchIndex implements Schedulable, Database.AllowsCallouts {
    public void execute(SchedulableContext SC) {
        futureMethodSample();
    }
    
    @future(callout=true)
    public static void futureMethodSample(){
    Object response;                
        HttpRequest httpRequest = new HttpRequest();        
        httpRequest.setHeader(
                'Content-Type',
                'application/json;  charset=utf-8'
        );
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        // webstore id is hardcoded here; you can get it SELECT Id, name from WebStore => update by Maud
        webstore idWebstore = [Select id from Webstore where Name = 'Promocash'];

        //https://developer.salesforce.com/docs/atlas.en-us.chatterapi.meta/chatterapi/connect_resources_commerce_webstore_search_indexes.htm
        httpRequest.setEndpoint(baseUrl+
                '/services/data/v' +
                '51.0' +
                '/commerce/management/webstores/' +
                idWebstore.id +
                '/search/indexes'
        );
        // first we're calling it as a GET to get the list of indexes (a POST would create a new one)
        httpRequest.setMethod('GET');
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequest);
        Integer statusCode = httpResponse.getStatusCode();
        if (statusCode >= 200 && statusCode <= 204) {
            response = JSON.deserializeUntyped(httpResponse.getBody()); // this gives a map<string,object>
            // https://developer.salesforce.com/docs/atlas.en-us.chatterapi.meta/chatterapi/connect_responses_commerce_search_index_collection_output.htm
            
            List<Object> indexes =  (List<Object>)((map<string,object>)response).get('indexes');
            // list of https://developer.salesforce.com/docs/atlas.en-us.chatterapi.meta/chatterapi/connect_responses_commerce_search_index_output.htm

            boolean alreadyBuilding = false;
            // loop through indexes; and see if any is currently being built (InProgress)
            // note that we could ignore and always ask for creation of a new index as the request will suppress any index currently being build
            // but instead we're letting the index being built to complete
            for (Object index : indexes) {
                String indexStatus = (String)((Map<String,Object>)index).get('indexStatus');
                                if(indexStatus == 'InProgress')
                    alreadyBuilding = true;
            }
            // if no index is currently being buit, start the creation of a new one
            if(!alreadyBuilding){
                                // set to PSOT to trigger new index creation
                httpRequest.setMethod('POST');

                httpResponse = http.send(httpRequest);
                Integer statusCode2 = httpResponse.getStatusCode();
                if (statusCode2 >= 200 && statusCode2 <= 204) {
                                    } else {
                                        throw new CalloutException(httpResponse.getBody());
                }
                
            } else {
                            }

        } else {
                        throw new CalloutException(httpResponse.getBody());
        }
    }
}