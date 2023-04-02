/**
* @author       jan.straka@bluewolf
* @date         2021-03-17
* @description  MarketPay Void API request body wrapper
**/
public with sharing class MP_VoidRequest {
    public String merchantTransactionId;
    public String referenceUuid;

    @TestVisible
    private static Datetime timeNow = Datetime.now();

    private MP_VoidRequest(Order order) {
        this.merchantTransactionId = timeNow + '_' + order.Id;
        this.referenceUuid = order.Preauthorize_Uuid__c;
    }

    public static String getRequestBodyString(Order order) {
        return JSON.serialize(new MP_VoidRequest(order), false /* suppressApexObjectNulls */);
    }
}