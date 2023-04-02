@IsTest public class ScheduleB2BSearchIndex_TST {
    @IsTest
    static void testBatch(){
        Webstore wbestore = new Webstore(Name ='Promocash');
        insert wbestore;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BSearchIndexMockPositive());
        new ScheduleB2BSearchIndex().execute(null);
        Test.stopTest();
    }
    
    private class B2BSearchIndexMockPositive implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":"success","Label":"testLabel","indexes":[{"indexStatus":"InProgress"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}