/**
* @author       jan.straka@bluewolf
* @date         2021-07-02
* @description  Test class for MP_Callout class
**/

@IsTest
public class MP_CalloutTest {
    
    @IsTest
    private static void testPreauthorize() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(400, 'preauthorize'));
        try {
            Test.startTest();
            MP_Callout.preauthorize(null, null, null, new Magasin__c(API_Key__c = 'API'));
            system.assert(true, 'Test Ok');
            Test.stopTest();
        } catch(Exception e) {
                        system.assert(false, 'Shouldn\'t throw eception');
        }
    }
    
    @IsTest
    private static void testTransactionStatusByUuid() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(400, 'preauthorize'));
        try {
            Test.startTest();
            MP_Callout.TransactionStatusByUuid('', new Magasin__c(API_Key__c = 'API'));
            system.assert(true, 'Test Ok');
            Test.stopTest();
        } catch(Exception e) {
                        system.assert(false, 'Shouldn\'t throw eception');
        }
    }
    
    @IsTest
    private static void testVoid() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(400, 'preauthorize'));
        try {
            Test.startTest();
            MP_Callout.void(null, new Magasin__c(API_Key__c = 'API'));
            system.assert(true, 'Test Ok');
            Test.stopTest();
        } catch(Exception e) {
                        system.assert(false, 'Shouldn\'t throw eception');
        }
    }
    
    @IsTest
    private static void testCapture() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(400, 'preauthorize'));
        try {
            Test.startTest();
            MP_Callout.capture(null, new Magasin__c(API_Key__c = 'API'), null, null);
            system.assert(true, 'Test Ok');
            Test.stopTest();
        } catch(Exception e) {
                        system.assert(false, 'Shouldn\'t throw eception');
        }
    }
    
    private static Order getOrder() {
        return new Order();
    }
    
    private static Magasin__c getMagasin() {
        return new Magasin__c(Pourcentage_additionel_carte__c = 10);
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        private String callType;
        
        public HttpCalloutMockImpl(Integer statusCode, String callType) {
            this.statusCode = statusCode;
            this.body = body;
            this.callType = callType;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            switch on this.callType {
                when 'preauthorize' {
                    this.body = '{"success": true}';
                }
                when else {
                                    }
            }
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}