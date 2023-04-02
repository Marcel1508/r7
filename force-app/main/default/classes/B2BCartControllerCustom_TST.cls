@isTest
public class B2BCartControllerCustom_TST {
    
    private static Frais__c createFrais(Id accountId, Id magasinId, String zoneTerritoriale) {
        return (Frais__c) new SObjectBuilder(Frais__c.SObjectType)
            .put(Frais__c.Account__c, accountId)
            .put(Frais__c.Magasin_Associe__c, magasinId)
            .put(Frais__c.Zone_territoriale__c, zoneTerritoriale)
            .create().getRecord();
    }

    private static Taxes__c createTaxes(String codeTVA, String zoneTerritoriale, Decimal tauxDeTVA) {
        return (Taxes__c) new SObjectBuilder(Taxes__c.SObjectType)
            .put(Taxes__c.Code_TVA__c, codeTVA)
            .put(Taxes__c.Zone_Territoriale__c, zoneTerritoriale)
            .put(Taxes__c.Taux_de_TVA__c, tauxDeTVA)
            .create().getRecord();
    }

    private static CartTax createCartTax(Id cartItemId) {
        return (CartTax) new SObjectBuilder(CartTax.SObjectType)
            .put(CartTax.CartItemId, cartItemId)
            .create().getRecord();
    }
    
    @isTest
    static void testCartController() {
        Profile p = [Select Id,Name from profile Where Name ='Customer Community Plus User'];
       Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;
        
         Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Client',magasinRec); 
        testAccount.RecordTypeId = clientRecordTypeId;
        testAccount.Numero_Siret__c = '66204244900014';
        Insert testAccount;
        
        Contact testContact = TestDataFactory.createContactRecord(testAccount.Id);
        Insert testContact;
   		Order testOrder = TestDataFactory.createOrderRecord(testAccount.Id);
        Insert testOrder;
        Frais__c frais = createFrais(testAccount.Id, magasinRec.Id, '5');
        testAccount.Frais_autorisations__c = frais.Id;
        update testAccount;
            
        Taxes__c taxes = createTaxes('3', '5', 15);
        
        BuyerAccount buyerAccount = TestDataFactory.createBuyerAccount(testAccount.id);
        Insert buyerAccount;
		Product2 prod = TestDataFactory.createGenericProduct();
        Insert prod;
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinRec.id)
            .put(Offre_Produit_Magasin__c.Produit__c, prod.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Statut__c, '2')
            .count(1).create().getRecords();
        
         WebStore store = TestDataFactory.createWebStoreRecord();
        Insert store;
        WebCart webCart = TestDataFactory.createWebCartRecord(testAccount.Id);
		Insert webCart;
        CartDeliveryGroup cartDelivery = new CartDeliveryGroup(Name ='Delivery Test', CartId = webCart.Id);
        insert cartDelivery;
        
        CartItem cartItem = new CartItem(CartId = webCart.Id, Product2Id = prod.Id, CartDeliveryGroupId = cartDelivery.Id, Name = 'Test CartItem', Quantity = 2, SalesPrice = 200, TotalPrice =400, ListPrice =400);    
        insert cartItem;
       
        //Create a Wishlist
        Wishlist wishList = TestDataFactory.createwishListRecord(store.Id,testAccount.Id);
         Insert wishList;
        WishlistItem witem = new WishlistItem(
            Name = 'Test',
            WishlistId = wishList.Id,
            Product2Id = prod.Id,
            Quantite__c = 2
        );
        insert witem;       
        
        Network network = [SELECT Id, Name FROM Network WHERE Name = 'Promocash' LIMIT 1][0];
        User currentUser = [Select Id, Bypass_Trigger__c FROM user WHERE Id=:userInfo.getUserId()];
        NetworkMember membership = [SELECT NetworkID, MemberID FROM NetworkMember WHERE memberID = :currentUser.id][0];
               
        B2BUtilsCustom.communityIdToWebStoreIdCache.put(network.Id, store.Id);
        
        
        Test.startTest();
            WebStore getStore = [SELECT Id FROM WebStore][0];
            AccountTriggerHandler.bypassTrigger = true;
            B2BCartControllerCustom.getCartItems(network.id, testAccount.Id, webCart.Id, '', '');
            ConnectApi.CartItemInput cartItemInp = new ConnectApi.CartItemInput();
            B2BCartControllerCustom.updateCartItem(network.Id, testAccount.Id, webCart.Id, cartItem.Id, cartItemInp);
            
            B2BCartControllerCustom.updateCartItemQuantities(cartItem.Id,false,2.0,1.0,1.0);
            Map<String,Object> itemExtract = new Map<String,Object>();
            itemExtract.put(cartItem.Id,cartItem);
            itemExtract.put(prod.Id,prod);
            List<Map<String,Object>> lstCartItemExtract = new List<Map<String,Object>>();
            lstCartItemExtract.add(itemExtract);
            B2BCartControllerCustom.getCartItemExtraInfos(lstCartItemExtract,testAccount.Id);
            try{
                B2BCartControllerCustom.updateSplitQuantities(lstCartItemExtract);
            }
            catch(Exception e){
                            }
            
            B2BCartControllerCustom.updateQuantity(network.Id,testAccount.Id,webCart.Id,cartItem.Id,2);
            String networkId = network.Id;
            networkId = networkId.substring(0, 15);
            B2BCartControllerCustom.updateQuantity(networkId,testAccount.Id,webCart.Id,cartItem.Id,1);
            
            B2BCartControllerCustom.deleteCartItem(network.Id, testAccount.Id, webCart.Id, cartItem.Id);
            B2BCartControllerCustom.getCartSummary(network.Id, testAccount.Id, webCart.Id);
            B2BCartControllerCustom.createCart(network.Id, testAccount.Id);
            
            B2BCartControllerCustom.executeCancelCartAsyncAction(webCart.Id);
            
            B2BCartControllerCustom.deleteCart(network.Id, testAccount.Id, webCart.Id);
            B2BCartControllerCustom.getCartSummaryPromo(network.Id, testAccount.Id, webCart.Id);
            B2BCartControllerCustom.getCartItemsPromo(network.Id, testAccount.Id, webCart.Id, null, 'CreatedDateASC');
            B2BCartControllerCustom.populateDummyStockMap(new List<String>{prod.Id});
            B2BCartControllerCustom.createsAndAddToList(network.Id, webCart.Id, wishList.Name , testAccount.Id, '');
            B2BCartControllerCustom.createsAndAddProductToList(network.Id, prod.Id, wishList.Name , testAccount.Id, '', 2);
            B2BCartControllerCustom.addProductToList(network.Id, prod.Id, wishList.Id , testAccount.Id, 2, '');
            B2BCartControllerCustom.addCartToList(network.Id, webCart.Id,wishList.Id,testAccount.Id, '');
            B2BCartControllerCustom.getListWhislist(testAccount.Id);
            B2BCartControllerCustom.getUserDetails(UserInfo.getUserId());
            B2BCartControllerCustom.getUserInfo(UserInfo.getUserId());
            B2BCartControllerCustom.deleteOrder(testAccount.Id);
            
        Test.stopTest();
    }
    
   
}