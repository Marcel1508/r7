@istest
public class BonCommandeServiceTest {
    
    @testSetup
    private static void init() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec;
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec); 
        Insert testAccount;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Product2 p = TestDataFactory.createGenericProduct();
        p.Code_rayon__c = '31';
        Insert p;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id = standardPricebook.id, product2id = p.id, unitprice=1.0, isActive=true);
        insert pbe;
        
        
        // createOrder
         Order testOrder = TestDataFactory.createOrder(standardPricebook.id);
        Insert testOrder;
        
        //Create Creneau_Salesforce__c
        Creneau_Salesforce__c creneauSalesforce = TestDataFactory.createSfSlot();
 		creneauSalesforce.Date__c = system.today();
        insert creneauSalesforce;
        
        //Initiate Creneau_client__c
        Creneau_client__c creneauClient = new Creneau_client__c(
            Commande__c = testOrder.Id,
            Creneau_Salesforce__c = creneauSalesforce.Id
        );
        Insert creneauClient; 
        OrderItem oi = TestDataFactory.createGenericOrderItem(testOrder.Id,pbe.Id,p.Id);
        oi.TotalLineAmount = 20; oi.quantity = 2;
        Insert oi;
    }    
    @isTest
    private static void test() {
        OrderTriggerHandler.bypassTrigger = true;
        Order o = [SELECT ID FROM ORDER limit 1];
        
        Product2 prd =[select ID,Code_rayon__c,name from Product2 where name = 'TEST Product'];
        Set<String> rayons = new Set<String>();
        rayons.add(prd.Code_rayon__c);
        Exception caughtException;
         Test.startTest();
        try {
            BonCommandeService.constructJSON(new List<Id>{o.Id},rayons, false);
        } catch(Exception e) {
            caughtException = e;
        } 
        Test.stopTest();
        
    }
}