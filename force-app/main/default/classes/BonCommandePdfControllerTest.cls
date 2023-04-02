@isTest
public class BonCommandePdfControllerTest {
    @testSetup
    private static void init() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = (Magasin__c)
            new SObjectBuilder(Magasin__c.sObjectType)
                .put(Magasin__c.Pourcentage_additionel_carte__c, 20)
                .create().getRecord();
	 	Account testAccount = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasin.Id)
            .put(Account.Magasin_actif_en_cours__c, magasin.Id)
            .create ()
            .getRecord();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Product2 p = new Product2(name='Test product', Code_rayon__c = '31');
        insert p;
        PricebookEntry pbe = new PricebookEntry(pricebook2id = standardPricebook.id, product2id = p.id, unitprice=1.0, isActive=true);
        insert pbe;
        
           Order testOrder = (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.Preauthorize_Uuid__c, '123')
                .put(Order.CurrencyIsoCode, 'EUR')
            	.put(Order.AccountId, testAccount.id)
                .put(Order.Pricebook2Id, standardPricebook.Id)
                .put(Order.is_BDP_generated__c, true)
                .create().getRecord();
        OrderItem oi = new OrderItem(OrderId = testOrder.Id, Product2Id = p.Id, TotalLineAmount = 20, quantity = 2);
        oi.PricebookEntryId = pbe.Id;
        insert oi;
    }    
    @isTest
    private static void test() {
        OrderTriggerHandler.bypassTrigger = true;
        Order o = [SELECT ID FROM ORDER limit 1];
        initConstant();
        PageReference pageRef = Page.BonCommandePdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('selectedOrders',''+o.Id+',');
        ApexPages.currentPage().getParameters().put('selectedRayons','');
        ApexPages.currentPage().getParameters().put('inclureimage','false');
        BonCommandePdfController.initData();
        BonCommandePdfController.getCommandes();
        BonCommandePdfController.Livraison liv = new BonCommandePdfController.Livraison();
        liv.dateLivraison = null;
        liv.heureDebut = null;
        liv.heureFin = null;
        liv.modeRetrait = null;
    }
    
    private static void initConstant() {
        BonCommandePdfController.RayonsSelectionne rs = new BonCommandePdfController.RayonsSelectionne();
        rs.name = '';
        rs.selected = false;
        BonCommandePdfController.OrderItemWr oi = new BonCommandePdfController.OrderItemWr();
        oi.rayon = '';
        oi.codeRayon = '';
        oi.backgroundColor = '';
        oi.products = new List<BonCommandePdfController.ProductWr>{};
        
        BonCommandePdfController.ProductWr pw = new BonCommandePdfController.ProductWr();
        pw.image = '';
        pw.name = '';
        pw.conditionnement = '';
        pw.ifls = '';
        pw.prixHT = 9;
       	pw.quantity = 4;
        pw.cssClass = '';
    }
}