/**
* @author       jan.straka@bluewolf
* @date         2021-03-10
* @description  Invocable class for transaction status check from MarketPay
**/
public with sharing class B2BMarketPayCheckStatus {
	@testVisible private static MP_StatusResponse testMockResponse;
    
    public class RequestWrapper {
        @InvocableVariable(required=true)
        public Id orderId;
    }
    
    public class ResultWrapper {
        @InvocableVariable(required=false)
        public String errorMessage;
        
        @InvocableVariable(required=false)
        public String errorCode;
    }

    private static final String PREAUTHORIZE = 'PREAUTHORIZE';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR = 'ERROR';
    private static final String UNKNOWN = 'UNKNOWN';

    @InvocableMethod(label='Get Transaction Status' description='Get transaction status of Order record' category='Promocash')
    public static List<ResultWrapper> getTransactionStatus(List<RequestWrapper> request) {
        try {
            ResultWrapper result = new ResultWrapper();
            Id orderId = request[0].orderId;
            if (orderId == null) {
                throw Utilities.newAuraHandledException('In-stock order Id is not defined');
            }

            Order order = [SELECT Id, Preauthorize_Uuid__c, Magasin_actif__c, Magasin_actif__r.API_Key__c FROM Order WHERE Id = :orderId];
            Id magasinId= order.Magasin_actif__c;
            String apiKey = order.Magasin_actif__r.API_Key__c;
            List<Magasin__c> magasins = new List<Magasin__c>{new magasin__c(Id=magasinId,API_Key__c=APIKey)};
            if (magasins.size() != 1) {
                throw Utilities.newAuraHandledException('Magasin was not found [Order ID: ' + order.Id + ', Magasin ID: ' + order.Magasin_actif__c + ']');
            }
			MP_StatusResponse sRes;
            if(!Test.isRunningTest()) {
                sRes = MP_Callout.transactionStatusByUuid(order.Preauthorize_Uuid__c, magasins[0]);
            } else {
                sRes = testMockResponse;
            }
            
            if (sRes.success) {
                if (sRes.transactionType == PREAUTHORIZE) {
                    if (sRes.transactionStatus == SUCCESS) {
                        //everything is ok
                    } else if (sRes.transactionStatus == ERROR) {
                        String errorCode = sRes.errors[0].code;
                        String errorMessage = sRes.errors[0].message;
                        result.errorCode = errorCode == null ? UNKNOWN : errorCode;
                        result.errorMessage = errorMessage == null ? UNKNOWN : errorMessage;
                    } else {
                        result.errorCode = UNKNOWN;
                        result.errorMessage = 'Transaction Status: ' + sRes.transactionStatus;
                    }
                }
            } else {
                result.errorCode = sRes.errorCode == null ? UNKNOWN : sRes.errorCode;
                result.errorMessage = sRes.errorMessage == null ? UNKNOWN : sRes.errorMessage;
            }
            
            return new List<ResultWrapper>{result};
            
        } catch (Exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
}