/**
* @author       jan.straka@bluewolf
* @date         2021-03-17
* @description  MarketPay Void API response wrapper
**/
public with sharing class MP_VoidResponse {

    public String body;

    public Boolean success;
    public String uuid;
    public String purchaseId;
    public String returnType;
    public String redirectType;
    public String redirectUrl;
    public String htmlContent;
    public String paymentDescriptor;
    public String paymentMethod;

    public String errorMessage;
    public Integer errorCode;
    public List<Error> errors;

    public class Error {
        public String errorMessage;
        public Integer errorCode;
    }


    public static MP_VoidResponse parse(String json) {
        MP_VoidResponse res = (MP_VoidResponse) System.JSON.deserialize(json, MP_VoidResponse.class);
        res.body = json;
        return res;
    }
}