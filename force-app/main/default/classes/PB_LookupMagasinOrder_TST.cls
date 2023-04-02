/**
* @author       Maud VAsseur - IBM Lille
* @date         02/2021
* @description  Test for PB_LookupMagasinOrder class
**/

@IsTest
private class PB_LookupMagasinOrder_TST {
    
    private static Magasin__c createMagasin(Boolean enabled) {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
                .put(Magasin__c.Responsable__c, UserInfo.getUserId())
                .create().getRecord();
    }
    
    private static Account createAccount(Id magasinId) {
        return (Account) new SObjectBuilder(Account.SObjectType)
                .put(Account.Magasin_de_rattachement__c, magasinId)
                .put(Account.OwnerId, UserInfo.getUserId())
                .create().getRecord();
    }

    private static Order createOrder(Id accountId,Id PriceBook2Id) {
        return (Order) new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, accountId)
                .put(Order.PriceBook2Id, PriceBook2Id)
                .create().getRecord();
    }
    
    private static Product2 createProduct() {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
                .put(Product2.Name, 'TEST Product')
                .put(Product2.isActive,true)
                .create().getRecord();
    }
    
    private static priceBookEntry createpriceBookEntry(Id Pricebook2Id,Id Product2Id) {
        return (PricebookEntry) new SObjectBuilder(PricebookEntry.SObjectType)
                .put(PricebookEntry.Pricebook2Id, Pricebook2Id)
                .put(PricebookEntry.Product2Id, Product2Id)
                .put(PricebookEntry.UnitPrice, 1)
                .put(PricebookEntry.isActive,true)
                .put(PricebookEntry.UseStandardPrice,false)
                .create().getRecord();
    }

    private static Offre_Produit_Magasin__c createOPM(Id magasinId, Id productId) {
        return (Offre_Produit_Magasin__c) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinId)
            .put(Offre_Produit_Magasin__c.Produit__c, productId)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .create().getRecord();
    }
    
    private static OrderItem createOrderItem(Id magasinId, Id orderId, Id productId,Id PricebookEntryId) {
        return (OrderItem) new SObjectBuilder(OrderItem.SObjectType)
            .put(OrderItem.Etablissement_maitre__c, magasinId)
            .put(OrderItem.Product2Id, productId)
            .put(OrderItem.Quantity, 3)
            .put(OrderItem.UnitPrice, 2)
            .put(OrderItem.OrderId, orderId)
            .put(OrderItem.PricebookEntryId, PricebookEntryId)
            .create().getRecord();
    }

    @IsTest
    private static void lookupMagasinOrder(){  
        
        OrderTriggerHandler.bypassTrigger = true;
        Id pricebookId = Test.getStandardPricebookId();
        Magasin__c testMagasin = createMagasin(true);
        Account testAccount = createAccount(testMagasin.Id);
        Product2 testProduct = createProduct();
        priceBookEntry  pEntry = createpriceBookEntry(pricebookId,testProduct.Id);
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id);
        Order testOrder = createOrder(testAccount.Id,pricebookId);
        OrderItem testOrderItem = createOrderItem(testMagasin.Id, testOrder.Id, testProduct.Id,pEntry.Id);
        
        Test.startTest();
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT id, Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        List <OrderItem> resultTestorderItem = [SELECT id, OrderItemNumber, Etablissement_maitre__c, Product2Id, Ref_Produit_Magasin__c FROM OrderItem WHERE Product2Id = :testProduct.id AND Etablissement_maitre__c = :testMagasin.id];
        System.assertEquals(resultTestOPM.get(0).id, resultTestorderItem.get(0).Ref_Produit_Magasin__c);
        Test.stopTest();
        
    }
}