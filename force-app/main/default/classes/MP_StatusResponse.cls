/**
* @author       jan.straka@bluewolf
* @date         2021-03-17
* @description  MarketPay Status response wrapper
**/
public with sharing class MP_StatusResponse {
    public String body;
    public List<Error> errors;
    @AuraEnabled public String transactionStatus;
    @AuraEnabled public Boolean success;
    public String result;
    public String uuid;
    public String merchantTransactionId;
    public String purchaseId;
    public String transactionType;
    public String paymentMethod;
    public String amount;
    public String xcurrency;
    public String merchantMetaData;
    public String description;
    public Customer customer;
    public ReturnData returnData;
    
    //for 8001 error
    @AuraEnabled public String errorMessage;
    @AuraEnabled public String errorCode;

    public class Error {
        @AuraEnabled public String message;
        @AuraEnabled public String code;
        public String adapterMessage;
        public String adapterCode;
    }

    public class Customer {
        public String identification;
        public String firstName;
        public String lastName;
        public String gender;
        public String billingAddress1;
        public String billingAddress2;
        public String billingCity;
        public String billingPostcode;
        public String billingState;
        public String billingCountry;
        public String billingPhone;
        public String company;
        public String email;
        public String emailVerified; //todo: according to MP documentation it should be Boolean
        public String ipAddress;
    }

    public class ReturnData {
        public String xType; //todo: parse to "_TYPE"
        public String type;
        public String cardHolder;
        public Integer expiryMonth;
        public Integer expiryYear;
        public String firstSixDigits;
        public String lastFourDigits;
        public String fingerprint;
        public String threeDSecure;
        public String binBand;
        public String binBank;
        public String binType;
        public String binLevel;
        public String binCountry;
    }

    public static MP_StatusResponse parse(String json) {
        MP_StatusResponse res = (MP_StatusResponse) System.JSON.deserialize(json, MP_StatusResponse.class);
        res.body = json;
        return res;
    }
}