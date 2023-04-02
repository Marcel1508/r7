/**
 * @CreatedBy       : Suliman A.
 * @Date            : 14/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A test class for OrdersToApigeeCallout_SVC AND OrderResultsToApigee_SVC classes, it uses 'OrdersHttpCalloutMock_TST' to receive the mock response that we specified.  
 */

@isTest
private class OrdersToApigeeCallout_TST {

    public static Map<Id, Order> createOrder(){
        
        //Create a Magasin
        Magasin__c magasin = new Magasin__c(
        	Name = 'Magasin Test ApiGee',
            API_Key__c = 'MagasinTestApiGee',
            Minimum_Commande_Drive_Deporte__c = 22,
            Minimum_Commande_Livraison__c = 10,
            Minimum_Commande_Drive__c = 8,
            Pourcentage_additionel_carte__c = 5,
            Autoriser_livraison_aux_nouveaux_clients__c = true,
            Responsable__c = UserInfo.getUserId()
        );
        insert magasin;
        
        //Create CodeAPI
        Code_APE__c codeAPE = new Code_APE__c(
        	APE_code__c = 'P13',
            Name = 'Test APE',
            Code_specialisation__c = 'A1'
        );
        Insert codeAPE;
        
        // Create an account
        Account acc = new Account(
            //Code_etablissement__c = '1313',
            Forme_juridique__c = '01',
            Name = 'Test ApiGee',
            //Numero_Siret__c = '1111',
            BillingStreet = '12 Rue Test',
            BillingPostalCode = '1012',
            BillingCity = 'Paris',
            Specialisation__c = '1A',
            Theme__c = '34;25;37',
            Email__c = 'test@test.co',
            //Piece_identite__c = false,
            Categorie__c = '1',
            Attestation_registre_du_commerce__c = false,
            //BillingCountry = 'France',
            BillingCountryCode = 'FR',
            NPAI_facturation__c = true,
            ShippingStreet = '12 Rue test',
            ShippingPostalCode = '1012',
            ShippingCity = 'Paris',
            //ShippingCountry = 'France',
            NPAI_livraison__c = true,
            K_bis__c = true,
            RIB__c = true,
            Chaine_bloquee__c = false,
            Statut_Fiche_client__c = 'Prospect',
            Magasin_actif_en_cours__c = magasin.Id, 
            Enseigne_commerciale__c = 'Sushi 1',
            Code_APE__c = codeAPE.Id
        ); 
        insert acc;
        
        //Create pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create an Order
        Order ord = new Order(
            AccountId = acc.Id,
            //Code_etablissement__c = '1313',
            //Num_client__c = '01',
            Mode_de_retrait__c = '1',
            //OrderNumber = '1111',
            Commande_en_stock__c = 'O',
            Commande_payee__c = 'O',
            Montant_Commande_TTC__c = 23,
            Status = 'Draft order',
            EffectiveDate = system.today(),
            Origine_de_la_commande__c = 'E-commerce',
            Pricebook2Id =  pricebookId
        ); 
        insert ord;
        
        //Create Product
        Product2 prod = new Product2(
            Name = ' Test Product ',
            Description='Test Product Entry 1',
            productCode = 'ABC',
            isActive = true
        );
        insert prod;
        
        //Create PricebookEntry
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 20,
            IsActive = true,
            UseStandardPrice = false
        );
        insert standardPrice ;
        
        //Create Offre_Produit_Magasin__c
        Offre_Produit_Magasin__c refProdMagasin = new Offre_Produit_Magasin__c(
        	Name = 'ApiGee Test',
            Magasin__c = magasin.Id,
            Produit__c = prod.Id,
            Niveau_de_stock__c = 120
        );
        insert refProdMagasin;
        
        //Create OrderItem
        OrderItem ordItem = new ORderItem(
        	UnitPrice = 20,
            Quantity = 2,
            OrderId = ord.Id,
            Product2id  = prod.Id,
            Ref_Produit_Magasin__c = refProdMagasin.Id,
            PricebookEntryId = standardPrice.Id
        );
        insert ordItem;
        
        Map<Id, Order> orderMap = new Map<Id, Order>();
        orderMap.put(ord.Id, ord);
        return orderMap;
    }
    
    @isTest
    static void testPostCallout() {
        AccountTriggerHandler.bypassTrigger = true;
        Map<Id, Order> orderMap = createOrder();
        String orderId;
        for(String orderKey : orderMap.keySet()){
            orderId = orderKey;
            break;
        }
        
        //Update Orders
        for(Order ords : orderMap.values()){
            ords.Status = '1';
        }
        update orderMap.values();
        Map<Id, Order> NewOrderMap = new Map<Id, Order>(orderMap);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new OrdersHttpCalloutMock_TST()); 
        // This causes a fake response to be sent
        String expectedValue = '{"orders_request" : {    "Num_client__c" : "01557",    "Code_etablissement__c" : "2001",    "Mode_de_retrait__c" : " ",    "OrderNumber" : "00002160",    "Commande_en_stock__c" : " ",    "Commande_payee__c" : " ",    "Montant_Commande_TTC__c" : " ",    "Status" : "Draft order",    "Origine_de_la_commande__c" : "E-commerce",    "OrderedDate" : " ",    "Related OrderItems" : [ {      "Code_Base_Produit__c" : " ",      "Quantity" : 11.00,      "UnitPrice" : 20.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 12.00,      "UnitPrice" : 30.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 13.00,      "UnitPrice" : 40.00    } ],    "Creneau Salesforce" : {      "Date__c" : "2021-04-27",      "Heure_de_debut__c" : "08:00:00.000Z",      "Heure_de_fin__c" : "12:30:00.000Z"    }  }}';
        // from the class that implements HttpCalloutMock.
        String apiGeeBaseURL = 'urlTest';
        String apiGeeId = 'clientIdTest';
        String apiGeeKey = 'clientSecretTest';
        Test.startTest();
        	//OrderResultsToApigee_SVC.getOrders('AInsert', orderMap);
        	OrderResultsToApigee_SVC.checkOrderStatus(NewOrderMap, orderMap);
            OrdersToApigeeCallout_SVC.OrderPostOrPutCallout('', expectedValue, orderId, apiGeeBaseURL, apiGeeId, apiGeeKey);
        Test.stopTest();
    }
    
    @isTest
    static void testPutCallout() {
        AccountTriggerHandler.bypassTrigger = true;
        Map<Id, Order> orderMap = createOrder();
        String orderId;
        for(String orderKey : orderMap.keySet()){
            orderId = orderKey;
            break;
        }
        
        //Update Orders
        for(Order ords : orderMap.values()){
            ords.Status = '1';
        }
        update orderMap.values();
        Map<Id, Order> NewOrderMap = new Map<Id, Order>(orderMap);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new OrdersHttpCalloutMock_TST()); 
        // This causes a fake response to be sent
        String expectedValue = '{"orders_request" : {    "Num_client__c" : "01557",    "Code_etablissement__c" : "2001",    "Mode_de_retrait__c" : " ",    "OrderNumber" : "00002160",    "Commande_en_stock__c" : " ",    "Commande_payee__c" : " ",    "Montant_Commande_TTC__c" : " ",    "Status" : "Draft order",    "Origine_de_la_commande__c" : "E-commerce",    "OrderedDate" : " ",    "Related OrderItems" : [ {      "Code_Base_Produit__c" : " ",      "Quantity" : 11.00,      "UnitPrice" : 20.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 12.00,      "UnitPrice" : 30.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 13.00,      "UnitPrice" : 40.00    } ],    "Creneau Salesforce" : {      "Date__c" : "2021-04-27",      "Heure_de_debut__c" : "08:00:00.000Z",      "Heure_de_fin__c" : "12:30:00.000Z"    }  }}';
        // from the class that implements HttpCalloutMock.
        String apiGeeBaseURL = 'urlTest';
        String apiGeeId = 'clientIdTest';
        String apiGeeKey = 'clientSecretTest';
        Test.startTest();
        	//OrderResultsToApigee_SVC.getOrders('AInsert', orderMap);
        	OrderResultsToApigee_SVC.checkOrderStatus(NewOrderMap, orderMap);
            OrdersToApigeeCallout_SVC.OrderPostOrPutCallout('01557', expectedValue, orderId, apiGeeBaseURL, apiGeeId, apiGeeKey);
        Test.stopTest();
    }
    
    @isTest
    static void testFailedCallout() {
        AccountTriggerHandler.bypassTrigger = true;
        Map<Id, Order> orderMap = createOrder();
        String orderId;
        for(String orderKey : orderMap.keySet()){
            orderId = orderKey;
            break;
        }
        
        //Update Orders
        for(Order ords : orderMap.values()){
            ords.Status = '1';
        }
        update orderMap.values();
        Map<Id, Order> NewOrderMap = new Map<Id, Order>(orderMap);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new OrdersHttpCalloutMockFailed_TST()); 
        // This causes a fake response to be sent
        String expectedValue = '{"orders_request" : {    "Num_client__c" : "01557",    "Code_etablissement__c" : "2001",    "Mode_de_retrait__c" : " ",    "OrderNumber" : "00002160",    "Commande_en_stock__c" : " ",    "Commande_payee__c" : " ",    "Montant_Commande_TTC__c" : " ",    "Status" : "Draft order",    "Origine_de_la_commande__c" : "E-commerce",    "OrderedDate" : " ",    "Related OrderItems" : [ {      "Code_Base_Produit__c" : " ",      "Quantity" : 11.00,      "UnitPrice" : 20.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 12.00,      "UnitPrice" : 30.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 13.00,      "UnitPrice" : 40.00    } ],    "Creneau Salesforce" : {      "Date__c" : "2021-04-27",      "Heure_de_debut__c" : "08:00:00.000Z",      "Heure_de_fin__c" : "12:30:00.000Z"    }  }}';
        // from the class that implements HttpCalloutMock.
        String apiGeeBaseURL = 'urlTest';
        String apiGeeId = 'clientIdTest';
        String apiGeeKey = 'clientSecretTest';
        Test.startTest();
        	//OrderResultsToApigee_SVC.getOrders('AInsert', orderMap);
        	OrderResultsToApigee_SVC.checkOrderStatus(NewOrderMap, orderMap);
            OrdersToApigeeCallout_SVC.OrderPostOrPutCallout('', expectedValue, orderId, apiGeeBaseURL, apiGeeId, apiGeeKey);
        Test.stopTest();
    }
}