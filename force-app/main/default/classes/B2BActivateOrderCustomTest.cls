/**
* @author       jan.straka@bluewolf
* @date         2021-06-23
* @description  Test class for B2BActivateOrderCustom
**/
@IsTest
private class B2BActivateOrderCustomTest {

     @testSetup static void setup() {
      	Magasin__c  createMag=TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert createMag;
        
        Code_APE__c codeAPE = TestDataFactory.createCodeAPE('Test APE');
        Insert codeAPE;
        
        Account acc =new Account();
        acc = TestDataFactory.createGenericAccwithCodeAPE(createMag.Id,codeAPE.Id, 'Prospect');
        acc.Name='TEST ACCOUNT';
        acc.Statut_Fiche_client__c='Prospect';
        acc.Numero_Siret__c='66204244900014';
        acc.Code_Chaine__c='test';
        acc.Enseigne_commerciale__c='text data';
        acc.Forme_juridique__c = '01';
        acc.Categorie__c = '1';
        acc.Origine__c='4';
        Insert acc;
        
        WebCart testCart = TestDataFactory.createGenericWebCartRecord(acc.id);
        Insert testCart;
        
        PricebookEntry testPricebookEntry = TestDataFactory.createPriceBookEntry();
        Insert testPricebookEntry;
        Creneau_Salesforce__c testSfSlot = TestDataFactory.createSfSlot();
        Insert testSfSlot;
        
         Order createOrder= TestDataFactory.createGenericOrderRecord(acc.id);
         createOrder.Creneau_client__c= null;
         createOrder.Tech_Creneau_Salesforce__c = testSfSlot.id;
         Insert createOrder;
        
        Product2 prod = TestDataFactory.createGenericProduct();
        Insert prod;
        
        OrderItem ordItem = TestDataFactory.createGenericOrderItem(createOrder.id, testPricebookEntry.id, prod.id);
        Insert ordItem;
    }
    
    @IsTest
    private static void testActivateOrder() {
        OrderTriggerHandler.bypassTrigger = true;
        MagasinTriggerHandler.bypassTrigger = true;
        AccountTriggerHandler.bypassTrigger = true;
        //Query Magasin__c record which is inserted in SetUp method 
        Magasin__c  testMagasin = [select Name from Magasin__c where name='uniqueMagasinCD'];
        
        //Query Code_APE__c record which is inserted in SetUp method 
        Code_APE__c codeAPE = [Select Id from Code_APE__c where name='Test APE'];
        
        //Query Account record which is inserted in SetUp method 
        Account acc = [Select Id from Account where name='TEST ACCOUNT']; 
                       
       //Query WebCart record which is inserted in SetUp method 
        WebCart testCart = [Select Id from WebCart where name='Cart'];                
        
        //Query PricebookEntry record which is inserted in SetUp method 
        PricebookEntry  testPricebookEntry = [Select id,Pricebook2Id,Product2Id from PricebookEntry limit 1];
        
        //Query Creneau_Salesforce__c record which is inserted in SetUp method 
        Creneau_Salesforce__c testSfSlot = [Select id from Creneau_Salesforce__c limit 1];
        
        //Query testOrder record which is inserted in SetUp method 
        Order testOrder = [Select id from Order limit 1];
        testOrder.Tech_Creneau_Salesforce__c = testSfSlot.id;
        testOrder.AccountId = acc.Id;
        testOrder.Pricebook2Id = testPricebookEntry.Pricebook2Id;
        update testOrder;
        
        //Order testOrder = createOrder(testSfSlot.Id, testPricebookEntry.Pricebook2Id, acc);
        //OrderItem testOrderItem = createOrderItem(testOrder.Id, testPricebookEntry.Id, testPricebookEntry.Product2Id);
        
        //Query testOrder record which is inserted in SetUp method 
        OrderItem testOrderItem = [select id from OrderItem limit 1];
        
        Contact testContact = TestDataFactory.createContactRecord(acc.Id);
        Insert testContact;
        
        Profile customerCommunityPlus = [SELECT Id FROM Profile WHERE Name = 'Customer Community +'];
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
    // User customer = [Select Id, UserRoleId From User Where (Profile.Name='System Administrator' OR Profile.Name='Administrateur système') Limit 1];
        User customer = [SELECT Id, UserRoleId, contactId FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(customer){
            customer.UserRoleId = userRole.Id;
        update customer; 
        }
       
       // User customer = TestUserUtil.createTestUser(userrole.Id, customerCommunityPlus.Id, 'Test FirstName', 'Test LastName');
        
       // User customer = createUser(testContact.Id, customerCommunityPlus.Id);

        B2BActivateOrderCustom.RequestWrapper request = new B2BActivateOrderCustom.RequestWrapper();
        request.cartId = testCart.Id;
        request.inStockOrderId = testOrder.Id;

        System.runAs(customer) {
            Test.startTest();
            B2BActivateOrderCustom.activateOrder(new List<B2BActivateOrderCustom.RequestWrapper>{request});
            Test.stopTest();
        }

        List<Creneau_Client__c> slots = [SELECT Id, Creneau_Salesforce__c, Compte_client__c, Reserve_par__c, Commande__c FROM Creneau_Client__c];
        List<Order> orders = [SELECT Id, Status, Creneau_client__c FROM Order];
        // List<OrderSummary> summaries = [SELECT Id, OriginalOrderId FROM OrderSummary];

        System.assertEquals(1, slots.size(), 'Bad count of created slots');
        System.assertEquals(testOrder.Tech_Creneau_Salesforce__c, slots[0].Creneau_Salesforce__c, 'Bad slot record of created slot');
        System.assertEquals(testOrder.AccountId, slots[0].Compte_client__c, 'Bad account of created slot');
        System.assertEquals(customer.ContactId, slots[0].Reserve_par__c, 'Bad slot record of created slot');
        System.assertEquals(testOrder.Id, slots[0].Commande__c, 'Bad order of created slot');
        
        System.assertEquals(1, orders.size(), 'Bad count of processed orders');
        System.assertEquals('1', orders[0].Status, 'Bad status of processed order');
        System.assertEquals(slots[0].Id, orders[0].Creneau_client__c, 'Bad slot of processed order');

        // System.assertEquals(1, summaries.size(), 'Bad count of created order summaries');
        // System.assertEquals(testOrder.Id, summaries[0].OriginalOrderId, 'Bad order Id of creeated order summary');
    }
}