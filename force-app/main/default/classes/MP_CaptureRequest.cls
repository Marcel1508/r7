/**
* @author       jan.straka@bluewolf
* @date         2021-03-17
* @description  MarketPay Capture API request body wrapper
**/
public with sharing class MP_CaptureRequest {
    public String merchantTransactionId;
    public String referenceUuid;
    public String amount;
    public String xcurrency;
    public String merchantMetaData;
    public String description;

    @TestVisible
    private static Datetime timeNow = Datetime.now();

    private MP_CaptureRequest(Order order, Facture__c facture, Integer attempt) {
        this.merchantTransactionId = timeNow + '_' + order.Id + '_' + attempt;
        this.referenceUuid = order.Preauthorize_Uuid__c;
        this.amount = String.valueOf(facture.Montant_TTC_de_la_facture__c); 
        this.xcurrency = order.CurrencyIsoCode;
        this.merchantMetaData = ' ';
        this.description = order.OrderNumber;
    }

    public static String getRequestBodyString(Order order, Facture__c facture, Integer attempt) {
        String requestBodyString = JSON.serialize(new MP_CaptureRequest(order, facture, attempt), false /* suppressApexObjectNulls */);
        requestBodyString = requestBodyString.replace('xcurrency', 'currency');
        return requestBodyString;
    }
}