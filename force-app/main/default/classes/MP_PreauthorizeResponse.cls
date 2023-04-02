/**
* @author       jan.straka@bluewolf
* @date         2021-03-11
* @description  MarketPay Preauthorize API response wrapper
**/
public without sharing class MP_PreauthorizeResponse {
    public String body;

    @AuraEnabled public Boolean success;
    public String uuid;
    public String purchaseId;
    public String returnType;
    @AuraEnabled public String redirectUrl;
    public String paymentMethod;
    public CustomerProfileData customerProfileData;
    @AuraEnabled public String errorMessage;
    @AuraEnabled public Integer errorCode;

    public without sharing class CustomerProfileData {
        public String profileGuid;
        public String customerIdentification;
    }

    public static MP_PreauthorizeResponse parse(String json) {
        MP_PreauthorizeResponse res = (MP_PreauthorizeResponse) System.JSON.deserialize(json, MP_PreauthorizeResponse.class);
        res.body = json;
        return res;
    }
}