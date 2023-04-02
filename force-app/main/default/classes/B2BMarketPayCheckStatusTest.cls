@isTest
public class B2BMarketPayCheckStatusTest {
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR = 'ERROR';
    private static final String UNKNOWN = 'UNKNOWN';
    
    private static Order createOrder(Magasin__c mag) {
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',mag); 
        Insert testAccount;
        Order testOrder = TestDataFactory.createOrderRecord(testAccount.Id);
        testOrder.Creneau_client__c = null;
        testOrder.Magasin_actif__c = mag.id;
        Insert testOrder;
        return testOrder;
    }
    
    private static Magasin__c createMagasin(Boolean populated) {
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
                .put(Magasin__c.Minimum_Commande_Drive__c, populated ? 20.00 : null)
                .put(Magasin__c.Minimum_Commande_Livraison__c, populated ? 40.00 : null)
                .put(Magasin__c.CurrencyIsoCode, 'EUR')
                .put(Magasin__c.Responsable__c, UserInfo.getUserId())
                .create().getRecord();
        return magasin;
    }
    
    @isTest
    private static void testGetTransactionStatusOk() {
        String json = '';
        Magasin__c mag = createMagasin(true);
        Order order = createOrder(mag);
        
        MP_StatusResponse mockResponse = new MP_StatusResponse();
        mockResponse.success = true;
        mockResponse.transactionType = 'PREAUTHORIZE';
        mockResponse.transactionStatus = SUCCESS;

        B2BMarketPayCheckStatus.testMockResponse = mockResponse;
        B2BMarketPayCheckStatus.RequestWrapper req = new B2BMarketPayCheckStatus.RequestWrapper();
        req.orderId = order.Id;

        B2BMarketPayCheckStatus.getTransactionStatus(new List<B2BMarketPayCheckStatus.RequestWrapper>{req});
    }
    
    @isTest
    private static void testGetTransactionStatusError() {
        String json = '';
        Magasin__c mag = createMagasin(true);
        Order order = createOrder(mag);
        
        MP_StatusResponse.Error errorWr = new MP_StatusResponse.Error();
        
        MP_StatusResponse mockResponse = new MP_StatusResponse();
        mockResponse.success = true;
        mockResponse.transactionStatus = ERROR;
        mockResponse.transactionType = 'PREAUTHORIZE';
        mockResponse.errors = new List<MP_StatusResponse.Error>{errorWr};

        B2BMarketPayCheckStatus.testMockResponse = mockResponse;
        B2BMarketPayCheckStatus.RequestWrapper req = new B2BMarketPayCheckStatus.RequestWrapper();
        req.orderId = order.Id;

        B2BMarketPayCheckStatus.getTransactionStatus(new List<B2BMarketPayCheckStatus.RequestWrapper>{req});
    }
    
    @isTest
    private static void testGetTransactionStatusUknown() {
        String json = '';
        Magasin__c mag = createMagasin(true);
        Order order = createOrder(mag);
        
        MP_StatusResponse.Error errorWr = new MP_StatusResponse.Error();
        
        MP_StatusResponse mockResponse = new MP_StatusResponse();
        mockResponse.success = true;
        mockResponse.transactionStatus = UNKNOWN;
        mockResponse.transactionType = 'PREAUTHORIZE';
        mockResponse.errors = new List<MP_StatusResponse.Error>{errorWr};

        B2BMarketPayCheckStatus.testMockResponse = mockResponse;
        B2BMarketPayCheckStatus.RequestWrapper req = new B2BMarketPayCheckStatus.RequestWrapper();
        req.orderId = order.Id;

        B2BMarketPayCheckStatus.getTransactionStatus(new List<B2BMarketPayCheckStatus.RequestWrapper>{req});
    }
    
    @isTest
    private static void testGetTransactionStatusErrorInt() {
        String json = '';
        Magasin__c mag = createMagasin(true);
        Order order = createOrder(mag);
        
        MP_StatusResponse.Error errorWr = new MP_StatusResponse.Error();
        
        MP_StatusResponse mockResponse = new MP_StatusResponse();
        mockResponse.success = false;
        mockResponse.transactionStatus = UNKNOWN;
        mockResponse.transactionType = 'PREAUTHORIZE';
        mockResponse.errors = new List<MP_StatusResponse.Error>{errorWr};

        B2BMarketPayCheckStatus.testMockResponse = mockResponse;
        B2BMarketPayCheckStatus.RequestWrapper req = new B2BMarketPayCheckStatus.RequestWrapper();
        req.orderId = order.Id;

        B2BMarketPayCheckStatus.getTransactionStatus(new List<B2BMarketPayCheckStatus.RequestWrapper>{req});
    }
}