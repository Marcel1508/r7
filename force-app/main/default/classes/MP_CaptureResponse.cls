/**
* @author       jan.straka@bluewolf
* @date         2021-03-17
* @description  MarketPay Capture API response wrapper
**/
public with sharing class MP_CaptureResponse {

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

    public static MP_CaptureResponse parse(String json) {
        MP_CaptureResponse res = (MP_CaptureResponse) System.JSON.deserialize(json, MP_CaptureResponse.class);
        res.body = json;
        return res;
    }
}