public without sharing class B2bCommerceApiService {
    
    public class ResWrapper {
        List<ConnectApi.CartItemResult> cartItems;
		ConnectApi.CartSummary cartSummary;
    }
    
    @AuraEnabled
    public static ResWrapper getCartItems(Id cartId) {
        system.debug('cartId ; ' + cartId);
        ResWrapper res = new ResWrapper();
        
        List<ConnectApi.CartItemResult> cartItemsResults = new List<ConnectApi.CartItemResult>();
        WebCart cart = getCart(cartId);
        Map<Id, Boolean> cartItemsErrorMap = getCartItemErrorsMap(cart);
        
        for(CartItem ci: cart.cartitems) {
            ConnectApi.CartItemResult cir = new ConnectApi.CartItemResult();
            ConnectApi.CartItem aCartItem = new ConnectApi.CartItem();
            cir.cartItem = aCartItem;
            cir.status = 'success';
            cir.message = null;
            //Construct main fields
            aCartItem.cartId = ci.CartId;
            aCartItem.cartItemId = ci.Id;
            aCartItem.listPrice = ci.listPrice + '';
            aCartItem.name = ci.name;
            aCartItem.cartItemId = ci.Id;
            aCartItem.productId = ci.Product2Id;
            aCartItem.quantity = ci.quantity + '';
            aCartItem.salesPrice = ci.salesPrice + '';
            aCartItem.totalAdjustmentAmount = ci.totalAdjustmentAmount + '';
            aCartItem.totalAmount = ci.totalAmount + '';
            aCartItem.totalListPrice = ci.totalListPrice + '';
            aCartItem.totalPrice = ci.totalPrice + '';
            aCartItem.totalTax = ci.totalTaxAmount + '';
            aCartItem.type = (ci.type.equals('Product'))? ConnectApi.CartItemType.Product: ConnectApi.CartItemType.DeliveryCharge;
            aCartItem.unitAdjustedPrice = ci.unitAdjustedPrice + '';
            aCartItem.unitAdjustmentAmount = ci.unitAdjustmentAmount + '';
            //construct CartMessagesSummary
            ConnectApi.CartMessagesSummary cms = new ConnectApi.CartMessagesSummary();
            aCartItem.messagesSummary = cms;
            cms.relatedEntityId = ci.Id;
            Boolean hasError = cartItemsErrorMap.get(ci.Id);
            if(hasError) {
                cms.hasErrors = true;
                ConnectApi.CartMessage cartMessage = new ConnectApi.CartMessage();
                cartMessage.message = 'Ce produit n\'est pas disponible';
                cartMessage.relatedEntityId = ci.Id;
                cartMessage.severity = ConnectApi.CartMessageSeverity.Error;
                cartMessage.visible = true;
                cms.limitedMessages = new List<ConnectApi.CartMessage>{cartMessage};
            } //The case of no error not implemented yet
            aCartItem.messagesSummary = cms;
            
            ConnectApi.CartItemProduct cip = new ConnectApi.CartItemProduct();
            Map<String, String> productFieldsMap = new Map<String, String>();
            productFieldsMap.put('Code_IFLS__c', ci.Product2.Code_IFLS__c);
            productFieldsMap.put('Libelle_commercial__c', ci.Product2.Libelle_commercial__c);
            productFieldsMap.put('Libelle_fournisseur__c', ci.Product2.Libelle_fournisseur__c);
            productFieldsMap.put('Libell_Final_TA__c', ci.Product2.Libell_Final_TA__c);
            productFieldsMap.put('Libelle_rayon__c', ci.Product2.Libelle_rayon__c);
            productFieldsMap.put('Picto_front__c', ci.Product2.Picto_front__c);
            cip.fields = productFieldsMap;
            cip.name = ci.name;
            cip.productId = ci.Product2Id;
            cip.sku = ci.Sku;
            aCartItem.productDetails = cip;
            //thumbnailImage *****
            cartItemsResults.add(cir);
        }
        res.cartItems = cartItemsResults;
        //Construct CartSummary
        ConnectApi.CartSummary cartSummary = new ConnectApi.CartSummary();
        cartSummary.accountId = cart.AccountId;
        cartSummary.cartId = cart.Id;
        cartSummary.currencyIsoCode = cart.currencyIsoCode;
        cartSummary.grandTotalAmount = cart.grandTotalAmount + '';
        cartSummary.name = cart.name;
        cartSummary.ownerId = cart.ownerId;
        cartSummary.purchaseOrderNumber = cart.PoNumber;
        //Set cart status
        ConnectApi.CartStatus cStatus = ConnectApi.CartStatus.Active;
        if(cart.Status == 'Checkout') cStatus = ConnectApi.CartStatus.Checkout;
        if(cart.Status == 'Closed') cStatus = ConnectApi.CartStatus.Closed;
        if(cart.Status == 'PendingDelete') cStatus = ConnectApi.CartStatus.PendingDelete;
        if(cart.Status == 'Processing') cStatus = ConnectApi.CartStatus.Processing;
        cartSummary.status = cStatus;
        cartSummary.totalChargeAmount = cart.totalChargeAmount + '';
        cartSummary.totalListPrice = cart.TotalListAmount + '';
        cartSummary.totalProductAmount = cart.totalProductAmount + '';
        cartSummary.totalProductCount = cart.totalProductCount + '';
        cartSummary.totalTaxAmount = cart.totalTaxAmount + '';
        cartSummary.type = ConnectApi.CartType.Cart;
        cartSummary.uniqueProductCount = cart.uniqueProductCount;
        cartSummary.webstoreId = cart.webstoreId;
        
        res.cartSummary = cartSummary;
        return res;
    }
    
    private static Map<Id, Boolean> getCartItemErrorsMap(WebCart cart) {
        Map<Id, Boolean> res = new Map<Id, Boolean>();
        Set<Id> productsIds = new Set<Id>();
        //Step 1: check product status error
        for(CartItem ci: cart.cartitems) {
            if(!ci.Product2.isActive) {
                res.put(ci.Id, true); //Product has an error
            } else {
                res.put(ci.Id, false);
                productsIds.add(ci.Product2Id);
            }
        }
        
        //Step 2: check Commerce entitilment policy error
        Account a = [select id, Magasin_actif_en_cours__r.name from Account Where id = :cart.AccountId];
        String magasinName = 'Assortiment PMC ' + a.Magasin_actif_en_cours__r.name;
        List<CommerceEntitlementPolicy> cepRes = [select id, (select id, ProductId from CommerceEntitlementProducts where ProductId in :productsIds) from CommerceEntitlementPolicy where name = :magasinName];
        List<Id> cepList = new List<Id>();
        if(cepRes != null && cepRes.size() > 0) {
            for(CommerceEntitlementProduct cep: cepRes.get(0).CommerceEntitlementProducts) {
                cepList.add(cep.ProductId);
            }
        }
        for(CartItem ci: cart.cartitems) {
            if(!cepList.contains(ci.Product2Id)) {//Product isn't in the magasin policy
                res.put(ci.Id, true); //Product has an error
            }
        }
        
        //Step 3: check pricing error
        List<BuyerGroupMember> accountBuyerGroupsMember = [SELECT ID, BuyerGroupId FROM BuyerGroupMember where BuyerId = :a.Id];
        List<Id> buyerGroupIDs = new List<Id>();
        if(accountBuyerGroupsMember != null && accountBuyerGroupsMember.size() > 0) {
            for(BuyerGroupMember bgm: accountBuyerGroupsMember) {
                buyerGroupIDs.add(bgm.BuyerGroupId);
            }
        }
        List<PricebookEntry> productPriceBookEntry = [SELECT id, Pricebook2Id, Product2Id FROM PricebookEntry where Product2Id in :productsIds];
        List<Id> priceBookIDs = new List<Id>();
        Map<Id, List<Id>> listPricebookByProductID = new Map<Id, List<Id>>();
        
        if(productPriceBookEntry != null && productPriceBookEntry.size() > 0) {
            for(PricebookEntry pbe: productPriceBookEntry) {
                priceBookIDs.add(pbe.Pricebook2Id);
                if(listPricebookByProductID.get(pbe.Product2Id) != null) {
                    listPricebookByProductID.get(pbe.Product2Id).add(pbe.Pricebook2Id);
                } else {
                    listPricebookByProductID.put(pbe.Product2Id, new List<Id>{pbe.Pricebook2Id});
                }
            }
        }
        
        Map<Id, Id> buyerGroupPbByPriceBook = new Map<Id, Id>();
        List<BuyerGroupPricebook> buyerGroupPricebook = [SELECT ID, Pricebook2Id FROM BuyerGroupPricebook where BuyerGroupId in :buyerGroupIDs AND Pricebook2Id in :priceBookIDs];
        
        if(buyerGroupPricebook != null && buyerGroupPricebook.size() > 0) {
            for(BuyerGroupPricebook bgpb: buyerGroupPricebook) {
                buyerGroupPbByPriceBook.put(bgpb.Pricebook2Id, bgpb.Id);
            }
        }
        
        for(CartItem ci: cart.cartitems) {
            Boolean entryFound = false;
            if(listPricebookByProductID.get(ci.Product2Id) == null) {//Product doesn't contain no entry in any pricebook
                res.put(ci.Id, true); //Product has an error
            } else {//We need to check if the buyer account has access of at least one product pricebook
                List<Id> productPricebooksList = listPricebookByProductID.get(ci.Product2Id);
                for(Id pb: productPricebooksList) {
                    if(buyerGroupPbByPriceBook.get(pb) != null) {
                        entryFound = true;
                    }
                }
            }
            if(!entryFound)
                res.put(ci.Id, true); //Product has an error                
        }
        
        return res;
    }
    
    public static WebCart getCart(Id cartId) {
        return [
                SELECT          AccountId, CurrencyIsoCode, GrandTotalAmount, Name, OwnerId, PoNumber, Status, TotalChargeAmount, TotalListAmount, TotalProductAmount, TotalProductCount,
                                TotalTaxAmount, Type, UniqueProductCount, WebStoreId,
                                (
                                        SELECT  Id, Product2Id, Product2.IsActive, Product2.Code_IFLS__c, Product2.Libelle_commercial__c, Product2.Libelle_fournisseur__c,
                                                Product2.Libell_Final_TA__c, Product2.Libelle_rayon__c, Product2.Picto_front__c, ListPrice, CartId, Quantity, SalesPrice, TotalAdjustmentAmount, TotalAmount, TotalListPrice, TotalPrice, Type, UnitAdjustedPrice,
                                                UnitAdjustmentAmount, TotalTaxAmount, Sku
                                        FROM CartItems
                                )
                FROM WebCart
                WHERE Id=:cartId
        ];
    }
}