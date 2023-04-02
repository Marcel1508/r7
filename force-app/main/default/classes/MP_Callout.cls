/**
* @author       jan.straka@bluewolf
* @date         2020-03-11
* @description  Apex class for MarketPay callouts
**/
public with sharing class MP_Callout {

    private static MarketPay_Setting__mdt mpSetting {
        get {
            if (mpSetting == null) {
                mpSetting = [
                    SELECT 
                        urlBase__c, username__c, password__c, 
                        communityUrl__c, preauthorizeCallbackUrl__c, staticResourceSuccessName__c, staticResourceErrorName__c 
                    FROM MarketPay_Setting__mdt];
            }
            return mpSetting;
        }
        set;
    }

    public static MP_PreauthorizeResponse preauthorize(Order order, Contact contact, User currentUser, Magasin__c magasin) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketPay' + '/transaction/' + magasin.API_Key__c + '/preauthorize');
        req.setMethod('POST');
        String body = (Test.isRunningTest())? '': MP_PreauthorizeRequest.getRequestBodyString(order, contact, currentUser, magasin, mpSetting);
        req.setBody(body);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(mpSetting.username__c + ':' + mpSetting.password__c)));
    
        Http http = new Http();
        HTTPResponse res = http.send(req);

        return MP_PreauthorizeResponse.parse(res.getBody());
    }

    public static MP_StatusResponse transactionStatusByUuid(String uuid, Magasin__c magasin) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketPay' + '/status/' + magasin.API_Key__c + '/getByUuid/' + uuid);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
      // req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(mpSetting.username__c + ':' + mpSetting.password__c)));
    
        Http http = new Http();
        HTTPResponse res = http.send(req);

        return MP_StatusResponse.parse(res.getBody());
    }

    public static MP_VoidResponse void(Order order, Magasin__c magasin) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketPay' + '/transaction/' + magasin.API_Key__c + '/void');
        req.setMethod('POST');
        String body = (Test.isRunningTest())? '': MP_VoidRequest.getRequestBodyString(order);
        req.setBody(body);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
      //  req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(mpSetting.username__c + ':' + mpSetting.password__c)));
    
        Http http = new Http();
        HTTPResponse res = http.send(req);

        return MP_VoidResponse.parse(res.getBody());
    }

    public static MP_CaptureResponse capture(Order order, Magasin__c magasin, Facture__c facture, Integer attempt) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketPay' + '/transaction/' + magasin.API_Key__c + '/capture');
        req.setMethod('POST');
        String body = (Test.isRunningTest())? '': MP_CaptureRequest.getRequestBodyString(order, facture, attempt);
        req.setBody(body);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(mpSetting.username__c + ':' + mpSetting.password__c)));
    
        Http http = new Http();
        HTTPResponse res = http.send(req);

        return MP_CaptureResponse.parse(res.getBody());
    }

    public class MP_CalloutException extends Exception {}
}