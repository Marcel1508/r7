@isTest
public class OrdersControllerTest {
    @testSetup
    private static void init() {
        AccountTriggerHandler.bypassTrigger = true;
        Account a = new Account(name='test');
        insert a;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Product2 p = new Product2(name='Test product', Code_rayon__c = '31');
        insert p;
        PricebookEntry pbe = new PricebookEntry(pricebook2id = standardPricebook.id, product2id = p.id, unitprice=1.0, isActive=true);
        insert pbe;
        
        Order o = new Order(AccountId = a.Id, status='Draft order', EffectiveDate=Date.today());
        o.Pricebook2Id = standardPricebook.Id;
        insert o;
        OrderItem oi = new OrderItem(OrderId = o.Id, Product2Id = p.Id, TotalLineAmount = 20, quantity = 2);
        oi.PricebookEntryId = pbe.Id;
        insert oi;
    }
    
    @isTest
    private static void test() {
        Order o = [SELECT ID FROM ORDER limit 1];
        List<Order> orders = new List<Order>{o};
        
        Test.startTest();
        Test.setCurrentPage(Page.BonCommandeVFList);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(orders);
        stdSetController.setSelected(orders);
		OrdersController oc = new OrdersController(stdSetController);
        oc.imprimer();
        oc.getItems();
        oc.setRayons(null);
        oc.getRayons();
        Test.stopTest();
    }
}