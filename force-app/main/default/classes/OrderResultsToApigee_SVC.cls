/**
 * @CreatedBy       : Suliman A.
 * @Date            : 22/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : On after create or after update, send order information to ApiGee class.  
 */

public without sharing class OrderResultsToApigee_SVC {
    //check the status of order, if it was Draft and changed to 1, in this case it will be considered as Order creation and I will send it as POST to Apigee
    public static void checkOrderStatus(Map<Id, Order> ordersMap, Map<Id, Order> oldOrdersMap){
        List<Order> ordersToCreate = new List<Order>();
        List<Order> ordersToUpdate = new List<Order>();
        for (Order newRecord : ordersMap.values()) {
            if(oldOrdersMap.get(newRecord.Id) != null){
                Order oldOrderRecord = oldOrdersMap.get(newRecord.Id);
                if(ifOrderHasChanged(newRecord, oldOrderRecord)) {
                    if(oldOrderRecord.Status == 'Draft order' && newRecord.Status == '1'){
                        ordersToCreate.add(newRecord);
                    } else {
                        ordersToUpdate.add(newRecord);
                    }
                }
            }
            
        }
        if (!ordersToCreate.isEmpty()){
            sendRelatedAccount(ordersToCreate);
            getOrders('AInsert', ordersToCreate);
        }
        if (!ordersToUpdate.isEmpty()){
            getOrders('AUpdate', ordersToUpdate);
        }
    }
    
    private static Boolean ifOrderHasChanged(Order newOrder, Order oldOrder) {
        if(newOrder.Num_client__c != oldOrder.Num_client__c || newOrder.Code_etablissement__c != oldOrder.Code_etablissement__c || newOrder.Mode_de_retrait__c != oldOrder.Mode_de_retrait__c
          || newOrder.OrderNumber != oldOrder.OrderNumber || newOrder.commande_extension_de_gamme__c != oldOrder.commande_extension_de_gamme__c || newOrder.Commande_payee__c != oldOrder.Commande_payee__c
          || newOrder.Montant_Commande_TTC__c != oldOrder.Montant_Commande_TTC__c || newOrder.Status != oldOrder.Status || newOrder.Origine_de_la_commande__c != oldOrder.Origine_de_la_commande__c || newOrder.OrderedDate != oldOrder.OrderedDate)
            return true;
        return false;
    }
    //Send related account to ApiGee
    public static void sendRelatedAccount(List<Order> orders){
        
        //Get account ids
        Set<Id> accIds = new Set<ID>();
        for(Order ord : orders){
            if( (new List<String>{'1','2','4'}).contains(ord.Status) ){
            	accIds.add(ord.AccountId);
            }
        }
        
        List<Account> accountsList = [SELECT Statut_Fiche_client__c, Numero_Client__c, Code_etablissement__c, Forme_juridique__c, Name, Numero_Siret__c, Enseigne_commerciale__c,
                                      Code_APE__c, Specialisation__c, Theme__c, Libell_code_APE__c, Email__c, Piece_identite__c, Categorie__c, Attestation_registre_du_commerce__c,
                                      Origine__c, Telephone_Siret__c, K_bis__c, RIB__c, Chaine_bloquee__c, Code_Externe_Chaine_Text__c, NPAI_livraison__c, NPAI_facturation__c, Code_Chaine__c,
                                      Libelle_Chaine_nationale__c, ifAccountSentToAkeneo__c FROM Account WHERE Id =: accIds];
        
        AccountResultsToApigee_SVC.getAccounts('AInsert', accountsList);
            }

    //public static void getOrders(String PostOrPut, Map<Id, Order> ordersMap){
    public static void getOrders(String PostOrPut, List<Order> ordersList){
        //Get URL and APIKey from ApiGee_Setting__mdt object
        ApiGee_Setting__mdt apiGeeSetting = [SELECT MasterLabel, ApiGee_ClientId__c, ApiGee_ClientSecret__c, ApiGee_URL__c FROM ApiGee_Setting__mdt WHERE MasterLabel = 'ApiGee_Order_Identifier' AND Bypass_INT12__c = false LIMIT 1];
        String apiGeeURL;
        String apiGeeId;
        String apiGeeKey;
        if(apiGeeSetting != null){
            apiGeeId = apiGeeSetting.ApiGee_ClientId__c;
            apiGeeKey = apiGeeSetting.ApiGee_ClientSecret__c;
            apiGeeURL = apiGeeSetting.ApiGee_URL__c;
        }
        
        Set<Id> shipAddressId = new Set<Id>();
        //Get only paid order
        Map<Id, Order> paidOrdersMap = new Map<Id, Order>();
        //for(Order order : ordersMap.values()){
        for(Order order : ordersList){
            if( (new List<String>{'1','2','4'}).contains(order.Status) ){
                paidOrdersMap.put(order.Id, order);
                shipAddressId.add(order.Shipping_Address__c);
            }
        }
        
        //Retrieve related OrderItems
        List<OrderItem> orderItemsList = [SELECT Id, OrderId, Code_Base_Produit__c, Quantity, UnitPrice, quantityToAquilon__c FROM OrderItem WHERE OrderId =: paidOrdersMap.keySet()];
        
        //Map OrderID with related orderItems
        Map<Id, List<OrderItem>> orderItemsMap = new Map<Id, List<OrderItem>>();
        for(OrderItem orderItem : orderItemsList){
            if (orderItemsMap.containsKey(orderItem.OrderId)){
                List<OrderITem> ordItemList = orderItemsMap.get(orderItem.OrderId);
                ordItemList.add(orderItem);
                orderItemsMap.put(orderItem.OrderId, ordItemList);
            } else {
                orderItemsMap.put(orderItem.OrderId, new List<OrderItem>{orderItem});
            }
                
        }
                
        //Retrieve Shipping Address fields from ContactPointAddress object
        List<ContactPointAddress> shippingAddress = [SELECT Id, ParentId, Nom_de_voie__c, Numero_de_voie__c, Type_de_voie__c, PostalCode, City, Country, Complement_d_adresse__c FROM ContactPointAddress WHERE id =: shipAddressId];
        //Retrieve Shipping Address
        Map<Id, ContactPointAddress> shippingAddressMap = new Map<Id, ContactPointAddress>();
        if(!shippingAddress.isEmpty()){
            for(ContactPointAddress cpa : shippingAddress){
                shippingAddressMap.put(cpa.Id, cpa);
            }
        }
        
        //Retrieve related Créneaux Salesforce
        List<Creneau_Client__c> creClients = [SELECT Id, Commande__c, Creneau_Salesforce__r.Date__c, Creneau_Salesforce__r.Heure_de_debut__c, Creneau_Salesforce__r.Heure_de_fin__c FROM Creneau_Client__c WHERE Commande__c =: paidOrdersMap.keySet()];
        //Map Order and related creneaux client and creneaux SF
        Map<Id, Creneau_Client__c> creneauxClientSFMap = new Map<Id, Creneau_Client__c>();
        //Retrieve Shipping Address
        if(!creClients.isEmpty()){
            for(Creneau_Client__c creclient : creClients){
                creneauxClientSFMap.put(creclient.Commande__c, creclient);
            }
        }
                
        Integer loopCount = 0;
        for(Order ord : paidOrdersMap.values()){
                        
            //Get Related OrderItems
            List<OrderItem> orderItems = orderItemsMap.get(ord.Id);
                        
            //Check the value of shipping and billing address
            ContactPointAddress shippingaddr = shippingAddressMap.get(ord.Shipping_Address__c);
            
            //Get related créneau SF
            Creneau_Client__c creneauClientSF = creneauxClientSFMap.get(ord.Id);
            
            //Create a JSONGenerator object.
            //Pass true to the constructor for pretty print formatting.
            JSONGenerator gen = JSON.createGenerator(true);
            // Write data to the JSON string.
            gen.writeStartObject();
            
            gen.writeFieldName('orders_request');
            gen.writeStartObject();
            Utilities.writeStringField(gen, 'Num_client__c', ord.Num_client__c, false, null);
            Utilities.writeStringField(gen, 'Code_etablissement__c', ord.Code_etablissement__c, false, null);
            Utilities.writeStringField(gen, 'Mode_de_retrait__c', ord.Mode_de_retrait__c, false, null);
            Utilities.writeStringField(gen, 'OrderNumber', ord.OrderNumber, false, null);
            Utilities.writeStringField(gen, 'commande_extension_de_gamme__c', ord.commande_extension_de_gamme__c, false, null);
            Utilities.writeStringField(gen, 'Commande_payee__c', ord.Commande_payee__c, false, null);
            Decimal Montant_Commande_TTC = 0;
            if(ord.Montant_Commande_TTC__c != null){ Montant_Commande_TTC = ord.Montant_Commande_TTC__c.setScale(2);}
            if(ord.Montant_Commande_TTC__c == null){gen.writeStringField('Montant_Commande_TTC__c', '');} else {gen.writeNumberField('Montant_Commande_TTC__c', Montant_Commande_TTC);}
            Utilities.writeStringField(gen, 'Status', ord.Status, false, null);
            Utilities.writeStringField(gen, 'Origine_de_la_commande__c', ord.Origine_de_la_commande__c, false, null);
            if(ord.OrderedDate == null){gen.writeStringField('OrderedDate', '');} else {gen.writeDatetimeField('OrderedDate', ord.OrderedDate);}
            //if(ord.Numero_de_commande__c == null){gen.writeStringField('Numero_de_commande__c', '');} else {gen.writeStringField('Numero_de_commande__c', ord.Numero_de_commande__c);}
            
            gen.writeFieldName('Related OrderItems');
                gen.writeStartArray();
                    if(orderItems != null){
                        for (OrderItem ordItem : orderItems) {
                            gen.writeStartObject();
                             Utilities.writeStringField(gen, 'Code_Base_Produit__c', ordItem.Code_Base_Produit__c, true, ordItem);
                            if(ordItem == null || ordItem.quantityToAquilon__c == null){gen.writeStringField('Quantity', '');} else {gen.writeNumberField('Quantity', ordItem.quantityToAquilon__c);}
                            if(ordItem == null || ordItem.UnitPrice == null){gen.writeStringField('UnitPrice', '');} else {gen.writeNumberField('UnitPrice', ordItem.UnitPrice);}
                            gen.writeEndObject();
                        }
                    }
                    
                gen.writeEndArray();
            
            if(creneauClientSF == null || creneauClientSF.Creneau_Salesforce__r.Date__c == null){gen.writeStringField('Date__c', '');} else {gen.writeDateField('Date__c', creneauClientSF.Creneau_Salesforce__r.Date__c);}
            if(creneauClientSF == null || creneauClientSF.Creneau_Salesforce__r.Heure_de_debut__c == null){gen.writeStringField('Heure_de_debut__c', '');} else {gen.writeTimeField('Heure_de_debut__c', creneauClientSF.Creneau_Salesforce__r.Heure_de_debut__c);}
            if(creneauClientSF == null || creneauClientSF.Creneau_Salesforce__r.Heure_de_fin__c == null){gen.writeStringField('Heure_de_fin__c', '');} else {gen.writeTimeField('Heure_de_fin__c', creneauClientSF.Creneau_Salesforce__r.Heure_de_fin__c);}
            
            
            gen.writeFieldName('shipping_address');
            gen.writeStartObject();
                if(shippingaddr == null || shippingaddr.Nom_de_voie__c == null){gen.writeStringField('Nom_de_voie__c', '');} else {gen.writeStringField('Nom_de_voie__c', shippingaddr.Nom_de_voie__c);}
            	if(shippingaddr == null || shippingaddr.Numero_de_voie__c == null){gen.writeStringField('Numero_de_voie__c', '');} else {gen.writeStringField('Numero_de_voie__c', shippingaddr.Numero_de_voie__c);}
            	if(shippingaddr == null || shippingaddr.Type_de_voie__c == null){gen.writeStringField('Type_de_voie__c', '');} else {gen.writeStringField('Type_de_voie__c', shippingaddr.Type_de_voie__c);}
            	if(shippingaddr == null || shippingaddr.PostalCode == null){gen.writeStringField('PostalCode', '');} else {gen.writeStringField('PostalCode', shippingaddr.PostalCode);}
            	if(shippingaddr == null || shippingaddr.City == null){gen.writeStringField('City', '');} else {gen.writeStringField('City', shippingaddr.City);}
            gen.writeEndObject();
            
            gen.writeEndObject();
            
            gen.writeEndObject();
            
            // Get the JSON string.
            String orderDetails = gen.getAsString();
            
            
            String orderNum;
            //Check if it is Update or Insert to add the client number to URL
            if(PostOrPut == 'AUpdate'){
                orderNum = ord.OrderNumber;
                                            } else if(PostOrPut == 'AInsert'){
                orderNum = '';
                            }
            
            OrdersToApigeeCallout_SVC.orderPostOrPutCallout(orderNum, orderDetails, ord.Id, apiGeeURL, apiGeeId, apiGeeKey);
            loopCount++;
        }
            }
}