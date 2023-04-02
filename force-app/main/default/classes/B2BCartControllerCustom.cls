/**
* @description Demonstrates how to make Apex calls to ConnectApi.CommerceCart class
* to perform Cart Operations for B2B Commerce on Lightning.
*
* @see B2BUtils
*/
public with sharing class B2BCartControllerCustom {
    public class UserAndPromocashLogo{
        @AuraEnabled
        public User userRecord;
        @AuraEnabled
        public String imageURL;
    }
    @AuraEnabled
    public static UserAndPromocashLogo getUserDetails(String userId){
        UserAndPromocashLogo details = new UserAndPromocashLogo();
        List<User> userList = new List<User>();
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.UserDetailsCache');
        if (!sessionPart.contains('UserDetails')) { //The method is called from the cart, that's why we don't check if the session partition is availible for the current user
            userList = [SELECT Id,ContactId,Contact.AccountId,Name,Username,ProfileName__c FROM User WHERE Id =:userId LIMIT 1];
            if(userList!= null && !userList.isEmpty()){
                details.userRecord = userList[0];
            }
            List<ContentVersion> cVersionList = new List<ContentVersion>();
            cVersionList = [SELECT Id,ContentBodyId,Title FROM ContentVersion WHERE Title='Promocash_Logo' LIMIT 1];
            if(cVersionList!= null && !cVersionList.isEmpty()){
                String baseDomain = Url.getOrgDomainUrl().toExternalForm();
                baseDomain = baseDomain.substringBefore('.') + '--c.documentforce.com';
                String url = baseDomain+'/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+cVersionList[0].Id;
                url = url + '&operationContext=CHATTER&contentId='+cVersionList[0].ContentBodyId;
                details.imageURL = url;
            }
            sessionPart.put('UserDetails', details); 
        }
        return (UserAndPromocashLogo)sessionPart.get('UserDetails');
    }
    
    @AuraEnabled(cacheable=true)
    public static User getUserInfo(String userId){
        List<User> userList = new List<User>();
        userList = [SELECT Id,Name,Username,ProfileName__c FROM User WHERE Id =:userId LIMIT 1];
        if(userList!= null && !userList.isEmpty()){
            return userList[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static void deleteOrder(String accId){
        List<Order>  orderList = [Select Id FROM Order WHERE AccountId =:accId AND Status = 'Draft order' Order By CreatedDate DESC LIMIT 1];
        if(orderList!= null && !orderList.isEmpty()){
            Database.delete(orderList[0],false);
        }   
    }
    
    
    /**
* @description Demonstrates how to call ConnectApi.CommerceCart.getCartItems
* @param  communityId The Id of the community from which the call originated
* @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
* @param activeCartOrId ID of the cart, active, or current.
* @param pageParam Specifies the page token to be used to view a page of information.
* @param sortParam Sort order for items in a cart.
* @return CartItemCollection A collection of cart items
*/
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String pageParam,
        String sortParam
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        // Get the ConnectApi.CartItemSortOrder enum value from string.
        // For the list of possible values, see:
        // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
        ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtilsCustom.resolveSortParam(
            sortParam
        );
        
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CartItemCollection res = Test.isRunningTest()? null: ConnectApi.CommerceCart.getCartItems(webstoreId, effectiveAccountId, activeCartOrId, pageParam, resolvedSortParam);
        return res;
    }
    
    /**
* @description Demonstrates how to call ConnectApi.CommerceCart.updateCartItem
* @param  communityId The Id of the community from which the call originated
* @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
* @param activeCartOrId ID of the cart, active, or current.
* @param cartItemId ID of the cart item to be updated.
* @return CartItem The updated cart item
*/
    @AuraEnabled
    public static ConnectApi.CartItem updateCartItem(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String cartItemId,
        ConnectApi.CartItemInput cartItem
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        System.debug('EDEC updateCartItem - cartItemId: '+cartItemId+'   cartItem+ '+cartItem + '   activeCartOrId'+activeCartOrId + '  effectiveAccountId: '+effectiveAccountId);
        
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CartItem res = Test.isRunningTest()? null: ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, activeCartOrId, cartItemId, cartItem);
        B2BCartControllerCustom.addMontantVignetteAlcool(cartItemId);
        B2BGetInfoCustom.calculatePromoAndTaxes(communityId, effectiveAccountId);
        return res;
    }
    
    /**
* @description Demonstrates how to call ConnectApi.CommerceCart.deleteCartItem
* @param  communityId The Id of the community from which the call originated
* @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
* @param activeCartOrId ID of the cart, active, or current.
* @param cartItemId ID of the cart item to be deleted.
*/
    @AuraEnabled
    public static void deleteCartItem(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String cartItemId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        if(!Test.isRunningTest()) ConnectApi.CommerceCart.deleteCartItem(webstoreId, effectiveAccountId, activeCartOrId, cartItemId);
        B2BGetInfoCustom.calculatePromoAndTaxes(communityId, effectiveAccountId);
    }
    
    
    /**
* @description Demonstrates how to call ConnectApi.CommerceCart.getCartSummary
* @param  communityId The Id of the community from which the call originated
* @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
* @param activeCartOrId ID of the cart, active, or current.
*/
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CartSummary res = Test.isRunningTest()? null: ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeCartOrId);
        return res;
    }
    
    /**
* @description Demonstrates how to call ConnectApi.CommerceCart.createCart
* @param  communityId The Id of the community from which the call originated
* @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
*/
    @AuraEnabled
    public static ConnectApi.CartSummary createCart(
        String communityId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
        cartInput.effectiveAccountId = effectiveAccountId;
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CartSummary res = Test.isRunningTest() ? null : ConnectApi.CommerceCart.createCart(webstoreId, cartInput);
        return res;
    }
    
    /**
* @description Demonstrates how to call ConnectApi.CommerceCart.deleteCart
* @param  communityId The Id of the community from which the call originated
* @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
* @param activeCartOrId ID of the cart, active, or current.
*/
    @AuraEnabled
    public static void deleteCart(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        if(!Test.isRunningTest()) ConnectApi.CommerceCart.deleteCart(webstoreId, effectiveAccountId, activeCartOrId);
    }
    
    
    
    //*************** EDEC */
    
    
    /**
*  Get the cart summary
* Since we need to break dow inStock and outOfStock, this will have to restore the cartItems
* and we're relying on the method getCartItemsPromo to do the work
*
*
*/
    @AuraEnabled
    public static PROMOCartItemCollection getCartSummaryPromo(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        //String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        PROMOCartItemCollection res = Test.isRunningTest() ? null : getCartItemsPromo(communityId,effectiveAccountId,activeCartOrId,null,'CreatedDateDesc');
        return res;
    }
    
    
    
    /**
*
* EDEC - Promocash
* This is the method that returns a list of cart items for the cart page
* We first make a call to the ConnectApi.CommerceCart.getCartItems
* and we add Promocash specifics:
* - Indicate stock level on each line and splitting lines when partially available
* 
*
*/
    @AuraEnabled
    public static PROMOCartItemCollection getCartItemsPromo(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String pageParam,
        String sortParam
    ) {
        
        System.debug('EDEC getCartItemsPromo - START');
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        List<String> cartIds = new List<String>();
        cartIds.add(activeCartOrId);
        //B2BPromotionsControllerCustom.calculateCartItemPromotions(activeCartOrId,effectiveAccountId);
        //B2BCartTaxesCustom.calculateTaxes(cartIds);
        ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtilsCustom.resolveSortParam(
            sortParam
        );
        
        // for more info: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        
        ConnectApi.CartItemCollection cartItemColl;
        
        if(Test.isRunningTest()) {
            
            cartItemColl = new ConnectApi.CartItemCollection();
            CartItem item = [SELECT Id, cartId, Product2Id FROM CartItem WHERE CartId = :activeCartOrId LIMIT 1];
            
            ConnectApi.CartSummary summary = new ConnectApi.CartSummary();
            summary.AccountId = effectiveAccountId;
            summary.CartId = item.CartId;
            summary.Name = 'Test Sumary';
            summary.webstoreId = webStoreId;
            cartItemColl.CartSummary = summary;
            ConnectApi.CartItemResult itmRes = new ConnectApi.CartItemResult();
            ConnectApi.AbstractCartItem crtItem = new ConnectApi.CartItem();
            crtItem.cartItemId = item.Id;
            crtItem.cartId = activeCartOrId;
            crtItem.type = ConnectApi.CartItemType.Product;
            crtItem.productId = item.Product2Id;
            crtItem.Quantity = '2';
            
            itmRes.cartItem = crtItem;
            cartItemColl.cartItems = new List<ConnectApi.CartItemResult>();
            cartItemColl.cartItems.add(itmRes);
        }

        List<String> productFields = new List<String>{
                String.valueOf(Product2.Code_IFLS__c),
                String.valueOf(Product2.Picto_front__c),
                String.valueOf(Product2.Libelle_rayon__c),
                String.valueOf(Product2.Libell_Final_TA__c)
        };
        
        ConnectApi.CartItemCollection cartItemCollection    =  Test.isRunningTest()
                                                            ? cartItemColl
                                                            : ConnectApi.CommerceCart.getCartItems(
                                                                    webstoreId,
                                                                    effectiveAccountId,
                                                                    activeCartOrId,
                                                                    String.join(productFields, ','),
                                                                    pageParam,
                                                                    100,
                                                                    resolvedSortParam
                                                              );
        System.debug('EDEC getCartItemsPromo - END');
        return new PROMOCartItemCollection(cartItemCollection);
        
        
    }
    
    
    public class PROMOCartItemCollection{
        
        @AuraEnabled
        public ConnectApi.CartItemCollection cartItemCollection { get; set; }
        
        @AuraEnabled
        public List<PROMOCartItemResult> promoCartItems { get; set; }
        
        @AuraEnabled
        public String cartDescription { get; set; }
        
        
        /*
* The subtotal of available items
*/
        @AuraEnabled
        public Decimal productAmountInStock { get; set; } 
        
        /*
* The split quantity of the line - this is used for  split lines to indicate the inStock or outOtStock quantity
*/
        @AuraEnabled
        public Decimal productAmountOutOfStock { get; set; }
        
        
        public PROMOCartItemCollection(ConnectApi.CartItemCollection collection){
            system.debug('==========> ' + collection);
            this.cartItemCollection = collection;
            cartDescription = 'This is the custom cart content';
            
            promoCartItems = new List<PROMOCartItemResult>();
            // list to store all product ids of the cart
            List<String> cartItemIdList = new List<String>();
            // list to store all cart item ids of the cart
            List<String> productIdList = new List<String>();
            // map where key:productId and value:stock
            Map<String,Decimal> productStockMap = new Map<String,Decimal>();
            
            productAmountInStock = 0;
            productAmountOutOfStock = 0;
            
            // first iteration is to gather all product ids so that we can fetch the available stock
            for (ConnectApi.CartItemResult itemResult : collection.cartItems) {                
                System.debug('EDEC - PROMOCartItemCollection loop');
                if(itemResult.cartItem!=null && itemResult.cartItem.type.name() == 'Product')
                    productIdList.add(itemResult.cartItem.productId);
                
            }
            productStockMap = B2BGetInfoCustom.checkStockAndEnCoursForProducts(productIdList,this.cartItemCollection.cartSummary.accountId);
            
            for (ConnectApi.CartItemResult itemResult : collection.cartItems) {
                
                
                if(itemResult.cartItem!=null && itemResult.cartItem.type.name() == 'Product'){
                    // get the stock for this product
                    Decimal stock = (productStockMap.get(itemResult.cartItem.productId)!=null)?productStockMap.get(itemResult.cartItem.productId):0;
                    Decimal quantity = Decimal.valueOf(itemResult.cartItem.quantity);
                    System.debug('EDEC - PROMOCartItemCollection second loop stock: '+stock+'   quantity: '+quantity);
                    
                    if(quantity <= stock){
                        //  whole quantity is available
                        this.promoCartItems.add(new PROMOCartItemResult(itemResult,true));
                        productAmountInStock += this.promoCartItems.get(this.promoCartItems.size()-1).totalPrice;
                    }
                    else if(stock <= 0){
                        // no stock; just flag the whole line as out of stock
                        this.promoCartItems.add(new PROMOCartItemResult(itemResult,false));
                        productAmountOutOfStock += this.promoCartItems.get(this.promoCartItems.size()-1).totalPrice;
                    }
                    else{
                        // the asked quantity is bigger than stock, we need to split the line
                        // first we create the line with instock quantity
                        this.promoCartItems.add(new PROMOCartItemResult(itemResult,true,true,stock));
                        productAmountInStock += this.promoCartItems.get(this.promoCartItems.size()-1).totalPrice;
                        
                        // then the out of stock line
                        this.promoCartItems.add(new PROMOCartItemResult(itemResult,false,true,quantity - stock));
                        productAmountOutOfStock += this.promoCartItems.get(this.promoCartItems.size()-1).totalPrice;
                    }                    
                    
                    
                }
                
            }          
            
            
        }
        
        
    }
    
    /**
* PROMO: custom wrapper around CartItemResult
* https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_connectapi_output_cart_item.htm
* 
* We need this for any additional custom properties, and to store values of updated properties
*
*/
    public class PROMOCartItemResult{
        
        @AuraEnabled
        public ConnectApi.CartItemResult cartItemResult { get; set; }
        
        /*
* Indicate if the cart item is inStock
*/
        @AuraEnabled
        public boolean inStock { get; set; }
        
        /*
* Indicate if the cart item was split
*/
        @AuraEnabled
        public boolean split { get; set; }
        
        /*
* The quantity of the line
*/
        @AuraEnabled
        public Decimal quantity { get; set; } 
        
        /*
* The split quantity of the line - this is used for  split lines to indicate the inStock or outOtStock quantity
*/
        @AuraEnabled
        public Decimal splitQuantity { get; set; }
        
        /*
* The max quantity that a user can select for the line - this is used for  split lines
*/
        @AuraEnabled
        public Decimal maxQuantity { get; set; }             
        
        /*
* The available quantity of the line - this is used for  split lines to indicate the inStock quantity
*/
        @AuraEnabled
        public Decimal availableQuantity { get; set; } 
        
        /*
* The total  price of the line
*/
        @AuraEnabled
        public Decimal totalPrice { get; set; }  
        
        /*
* The total List price of the line
*/
        @AuraEnabled
        public Decimal totalListPrice { get; set; }  
        
        
        public PROMOCartItemResult(ConnectApi.CartItemResult itemResult,boolean inStockStatus){
            this(itemResult,inStockStatus,false);
        }
        
        public PROMOCartItemResult(ConnectApi.CartItemResult itemResult,boolean inStockStatus,boolean splitLine){
            
            this(itemResult,inStockStatus,splitLine,Decimal.valueOf(itemResult.cartItem.quantity));
        }
        
        /**
* Constructor used for split lines
* This is likely to need an update when implementing promotions. based on what fields the promotion adjustments will be stored in.
* for now, we only look at two total price: totalPrice without any adjustment and total list price
*        
*
*/
        public PROMOCartItemResult(ConnectApi.CartItemResult itemResult,boolean inStockStatus,boolean splitLine,Decimal quantity){
            System.debug('EDEC - PROMOCartItemResult itemResult: '+itemResult+'   inStockStatus: '+inStockStatus+ '  splitLine: '+splitLine+'  quantity: '+quantity);
            
            this.cartItemResult = itemResult;
            this.inStock = inStockStatus;
            this.split = splitLine;
            this.quantity = Decimal.valueOf(itemResult.cartItem.quantity);
            this.splitQuantity = quantity;
            this.availableQuantity = (this.inStock)?this.splitQuantity:(this.quantity-this.splitQuantity);
                this.maxQuantity = (this.split && this.inStock)?this.availableQuantity:100000;
            
            // we cannot update the cartItemResult properties directly. We need to copy them as fields of our custom class
            Decimal salesPrice = Test.isRunningTest()? 400 : Decimal.valueOf(((ConnectApi.CartItem)cartItemResult.cartItem).salesPrice);
            Decimal totalPrice = Test.isRunningTest()? 400 : Decimal.valueOf(((ConnectApi.CartItem)cartItemResult.cartItem).totalPrice);
            System.debug('EDEC - PROMOCartItemResult salesPrice: '+salesPrice+'   this.splitQuantity: '+this.splitQuantity);
            
            // this.totalPrice = salesPrice * this.splitQuantity;
            this.totalPrice = (totalPrice / this.quantity) * this.splitQuantity;
            Decimal listPrice = Test.isRunningTest()? 400: Decimal.valueOf(((ConnectApi.CartItem)cartItemResult.cartItem).listPrice);
            this.totalListPrice = listPrice * this.splitQuantity;
        } 
        
    }
    
    
    /**
* Temporary method that returns a stock of 10 for all lines
*
*
*/
    public static Map<String,Decimal> populateDummyStockMap(List<String> productList){
        Map<String,Decimal> productStockMap = new Map<String,Decimal>();
        
        for (String productId : productList) {
            productStockMap.put(productId,Decimal.valueOf(10));
        }
        
        return productStockMap;
    }
    
    /**
* This method is called from the add to wishlist modal, to add all products from the cart to a new wishlist
*
*/
    @AuraEnabled
    public static ConnectApi.Wishlist createsAndAddToList(
        String communityId,
        String cartId,
        String wishlistName,
        String effectiveAccountId,
        String realUserId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        // Store the product in a WishlistItemInput to pass to the Wishlist
        List<ConnectApi.WishlistItemInput> wlItemInput = new List<ConnectApi.WishlistItemInput>();
        List<CartItem> cartItemList = [SELECT Product2Id FROM CartItem WHERE CartId = :cartId AND Type = 'Product'];
        
        
        for (CartItem cartItem : cartItemList) {
            ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
            wishlistItemInput.productId = cartItem.Product2Id;
            wlItemInput.add(wishlistItemInput);
        }
        
        //Create a wishlistInput to be created
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wishlistName;
        
        wishlistInput.products = wlItemInput ; 
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
        ConnectApi.Wishlist returnedValues = Test.isRunningTest() ? null : ConnectApi.CommerceWishlist.createWishlist(webstoreId,effectiveAccountId,wishlistInput);
        Wishlist wishlist;
        if(Test.isRunningTest()) wishList = [SELECT Id, LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c FROM Wishlist WHERE AccountId = :effectiveAccountId];
        else
            wishlist = Queries.getWishList(returnedValues.summary.id);
        
        Utilities.updateWishList(wishlist, realUserId, true);
        
        ConnectApi.Wishlist res = Test.isRunningTest() ? null : ConnectApi.CommerceWishlist.getWishlist(webstoreId, effectiveAccountId, returnedValues.summary.id, null, null);
        return res;
    }
    
    @AuraEnabled
    public static ConnectApi.Wishlist createsAndAddProductToList(
        String communityId,
        String productId,
        String wishlistName,
        String effectiveAccountId,
        String realUserId,
        Integer quantity
    ) {
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wishlistName;
        
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        ConnectApi.Wishlist returnedValues = Test.isRunningTest() ? null : ConnectApi.CommerceWishlist.createWishlist(webstoreId,effectiveAccountId,wishlistInput);
        
        List<ConnectApi.WishlistItemInput> wishlistItemInputs = new List<ConnectApi.WishlistItemInput>();
        
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;
        String wishlistId;
        if(Test.isRunningTest()) {wishlistId = [Select Id FROM WishList WHERE AccountId = :effectiveAccountId].Id;}
        else
            wishlistId = returnedValues.summary.id;
        
        wishlistItemInputs.add(wishlistItemInput);
        
        if(!Test.isRunningTest()) {ConnectApi.CommerceWishlist.addItemToWishlist(webstoreId,wishlistId,wishlistItemInput);}
        
        Wishlist wishlist = getWishlistAndWhishListItem(wishlistId, productId);
        //Add quantity in the field quantite__c for the favorite wishlist quantity for each product
        WishlistItem WishlistItem = wishlist.WishlistItems[0];
        WishlistItem.quantite__c = quantity;
        update WishlistItem;
        Utilities.updateWishList(wishlist, realUserId, true);
        ConnectApi.Wishlist res = Test.isRunningTest() ? null : ConnectApi.CommerceWishlist.getWishlist(webstoreId, effectiveAccountId, wishlistId, null, null);
        return res;
    }
    
    @AuraEnabled
    public static ConnectApi.Wishlist addProductToList(
        String communityId,
        String productId,
        String wishlistId,
        String effectiveAccountId,
        Integer quantity,
        String realUserId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        List<ConnectApi.WishlistItemInput> wlItemInput = new List<ConnectApi.WishlistItemInput>();        
        
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;
        if(!Test.isRunningTest()) {ConnectApi.CommerceWishlist.addItemToWishlist(webstoreId,wishlistId,wishlistItemInput);}
        
        Wishlist wishlist = getWishlistAndWhishListItem(wishlistId, productId);
        //Add quantity in the field quantite__c for the favorite wishlist quantity for each product
        WishlistItem wishlistItem = wishlist.WishlistItems[0];
        wishlistItem.Quantite__c = quantity;
        update WishlistItem;
        Utilities.updateWishList(wishlist, realUserId, false);
        
        ConnectApi.Wishlist res = Test.isRunningTest() ? null : ConnectApi.CommerceWishlist.getWishlist(webstoreId, effectiveAccountId, wishlistId, null, null);
        return res;
    }
    
    
    
    /**
* This method is called from the add to wishlist modal, to add all products from the cart to a new wishlist
*
*/
    @AuraEnabled
    public static ConnectApi.Wishlist addCartToList(
        String communityId,
        String cartId,
        String wishlistId,
        String effectiveAccountId,
        String realUserId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        // Store the product in a WishlistItemInput to pass to the Wishlist
        List<ConnectApi.WishlistItemInput> wlItemInput = new List<ConnectApi.WishlistItemInput>();
        List<CartItem> cartItemList = [SELECT Product2Id FROM CartItem WHERE CartId = :cartId AND Type = 'Product'];
        
        
        for (CartItem cartItem : cartItemList) {
            ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
            wishlistItemInput.productId = cartItem.Product2Id;
            ConnectApi.CommerceWishlist.addItemToWishlist(webstoreId,wishlistId,wishlistItemInput);            
        }
        
        Wishlist wishlist = Queries.getWishList(wishlistId);
        Utilities.updateWishList(wishlist, realUserId, false);
        ConnectApi.Wishlist res = Test.isRunningTest() ? null : ConnectApi.CommerceWishlist.getWishlist(webstoreId, effectiveAccountId, wishlistId, null, null);
        
        /*return ConnectApi.CommerceWishlist.getWishlist(
webstoreId,
effectiveAccountId,
wishlistId,
null,
null
);*/
        return res;
    }
    
    
    /**
* This method is called from the add to wishlist modal, to get the list of existing wishlists
*
*/
    
    @AuraEnabled(cacheable=false)
    public static List<Wishlist> getListWhislist(String accountId)
    {
        System.debug('EDEC - getListWhislist accountId: '+accountId);
        
        return [ SELECT Id,Name,AccountId FROM Wishlist WHERE AccountId=:accountId];
    }
    
    @AuraEnabled
    public static CartItem updateCartItemQuantities(String cartItemId, Boolean split, Decimal maxQuantity, Decimal quantity, Decimal splitQuantity)
    {
        CartItem ci = new CartItem();
        ci = [SELECT Id, Name, Product2Id, Quantity,UnitAdjustedPrice, Product2.Code_IFLS__c,
              Product2.Libelle_rayon__c,
              LastQuantity__c, LastOutOfStockQuantity__c From CartItem Where Id =: cartItemId];
        System.debug('ci before update'+ ci);
        ci.LastQuantity__c = quantity;
        if(split){
            ci.LastOutOfStockQuantity__c = quantity - maxQuantity;
        }else{
            ci.LastOutOfStockQuantity__c = 0;
        }
        update ci;
        System.debug('ci after update'+ ci);
        /* CartItem cid = [SELECT Id, Name, Product2Id, Quantity,UnitAdjustedPrice, Product2.Code_IFLS__c,
Product2.Libelle_rayon__c,
LastQuantity__c, LastOutOfStockQuantity__c From CartItem Where Id =: cartItemId];*/
        
        return ci;
    }
    
    /**
* Cancels the cart async operation
* @param cartId - cart id of the cart who's async operation will be canceled
*/
    @AuraEnabled
    public static void executeCancelCartAsyncAction(String cartId) {
        System.debug('EDEC - executeCancelCartAsyncAction cartId: '+cartId);
        
        // query the cartCheckoutSession for this cart that are not archived - there should be only one
        List<CartCheckoutSession> checkoutSessionList = [SELECT id,IsArchived FROM CartCheckoutSession WHERE WebCartId = :cartId and IsArchived=false];
        if(!checkoutSessionList.isEmpty()){
            for (CartCheckoutSession checkoutSession : checkoutSessionList) {
                System.debug('EDEC - executeCancelCartAsyncAction updating checkoutSession id: '+checkoutSession.Id);
                checkoutSession.IsArchived=true;
            }
            update checkoutSessionList; 
        }
        
        
        // reset the cart to active
        WebCart cart = [SELECT id,Status FROM WebCart WHERE Id = :cartId];
        if(cart.Status != 'Active'){
            cart.Status='Active';
            update cart; 
        }
    }    
    
    @AuraEnabled
    public static  List<Map<String,Object>> getCartItemExtraInfos(List<Map<String,Object>> cartItemsExtract, String effectiveAccountId) {
        system.debug('cartItemsExtract');
        system.debug(cartItemsExtract);
        List<Map<String,Object>> returnedList = new List<Map<String,Object>>();
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        Set<Id> cartItemIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for(Map<String,Object> cartItem : cartItemsExtract){
            productIds.add((Id)cartItem.get('productId'));
            cartItemIds.add((Id)cartItem.get('cartItemId'));
        }        
        
        Account account = Queries.getEffectiveAccount(effectiveAccountId);
        
        system.debug('=====account======'+account);
        system.debug('=====productIds======'+productIds);
        
        Map<String, Promotion__c> promotionMap = new Map<String, Promotion__c>([SELECT Id, Phrase_offre__c, Type_d_offre__c, Type_de_promotion__c, Mecanique_Promotion_TECH__c,
                                                                                Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c, Libelle_periode_de_promotion__c,Produit__r.Libelle_du_conditionnement_vente__c,
                                                                                Quantite_minimum_de_commande__c, Quantite_offerte__c, Quantite_payee__c,
                                                                                Prix_sous_mecanique__c, Remise_en_e__c, Remise_en_p__c, Prix_de_vente_promotion__c, Produit__c 
                                                                                FROM Promotion__c 
                                                                                WHERE Magasin__c =:account.Magasin_actif_en_cours__c AND Produit__c in:productIds AND Date_de_debut_de_promotion__c <= TODAY AND Date_de_fin_de_promotion__c >= TODAY]);
        
        
        Map<String, Offre_produit_Magasin__c> opmMap = new Map<String, Offre_produit_Magasin__c>([SELECT Id, Statut__c, Produit__c, Prix_de_vente_magasin__c, Prix_de_vente_magasin_au_conditionnement__c,
                                                                                                  Code_departement__c, Ref_tarifaire_magasin__c, Rang_tarifaire__c, Prix_T2_au_conditionnement_de_vente__c,
                                                                                                  Prix_T3_au_conditionnement_de_vente__c, vignette_alcool__c, (SELECT Prix_de_vente_au_conditionnement__c FROM Prix_specifiques__r where
                                                                                                                                           Reference_client__c =: account.Id )
                                                                                                  FROM Offre_produit_Magasin__c 
                                                                                                  WHERE Magasin__c =:account.Magasin_actif_en_cours__c 
                                                                                                  AND Produit__c in:productIds]);
        
        Map<String, Product_Image_URL__c> urlsMap = new Map<String, Product_Image_URL__c>([SELECT Id, Name, AlternativeText__c, Image_ExternalId__c, ProductId__c, Product_Image_URL__c, Product_URL_Vignette__c, Titre__c, Ordre_Affichage__c FROM Product_Image_URL__c WHERE ProductId__c in:productIds ORDER BY Ordre_Affichage__c ]);
        system.debug('=====urlsMaps======'+urlsMap);
        returnedList.add(promotionMap);
        returnedList.add(getCartTaxesByCartItemId(cartItemIds));
        returnedList.add(opmMap);
        returnedList.add(urlsMap);
        return returnedList;
    }
    
    private static Map<String, CartTax> getCartTaxesByCartItemId(Set<Id> cartItemIds) {
        List<CartTax> cartTaxes = Queries.getCartTaxes(cartItemIds);
        Map<String, CartTax> cartTaxesByCartItemId = new Map<String, CartTax>();
        for (CartTax cartTax : cartTaxes) {
            cartTaxesByCartItemId.put(cartTax.CartItemId + ',' + cartTax.Name , cartTax);
        }
        
        return cartTaxesByCartItemId;
    }
    
    
    
    @AuraEnabled
    public static  List<Map<String,Object>> updateSplitQuantities(List<Map<String,Object>> cartItemsInfo) {
        system.debug('cartItemsInfo');
        system.debug(cartItemsInfo);
        
        /*
Map<String,String> Map2 = new Map<String,String>();
Map<Map<String,Boolean>,Map<String,String>> topMap = new Map<Map<String,Boolean>,Map<String,String>>();
topMap.put(Map1,Map2);
*/
        List<Map<String,Object>> changeList = new List<Map<String,Object>>();
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        
        Set<Id> cartItemIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for(Map<String,Object> cartItem : cartItemsInfo){
            cartItemIds.add((Id)cartItem.get('cartItemId'));
        }
        system.debug('cartItemIds');
        system.debug(cartItemIds);
        
        Map<Id, CartItem> cartItemMap = new Map<Id, CartItem>([SELECT Id, Name, Product2Id, Quantity,UnitAdjustedPrice, Product2.Code_IFLS__c,SalesPrice,
                                                               Product2.Libelle_rayon__c,
                                                               LastQuantity__c, LastOutOfStockQuantity__c From CartItem Where Id in : cartItemIds]);
        
        //cartItems = [SELECT Id, Name, Quantity, LastQuantity__c, LastOutOfStockQuantity__c From CartItem Where Id in : cartItemIds];where
        system.debug('cartItemMap');
        system.debug(cartItemMap);
        system.debug('cartItemsInfo');
        system.debug(cartItemsInfo);
        
        for(Map<String,Object> cartItem : cartItemsInfo){
            CartItem cItem =  (CartItem)cartItemMap.get((Id)cartItem.get('cartItemId'));
            Decimal availableQuantity = cartItem.get('availablequantity')!= null? (Decimal)cartItem.get('availablequantity'):0;
            Decimal quantity = cartItem.get('quantity') != null?(Decimal)cartItem.get('quantity'):0;
            Boolean isSplit = cartItem.get('isSplit') != null ? (Boolean)cartItem.get('isSplit') : false;
            Decimal splitQuantity = 0;
            String productImageUrl = '';
            productImageUrl = (String)cartItem.get('productImageUrl');
            String productImageAlternativeText = '';
            productImageAlternativeText = (String)cartItem.get('productImageAlternativeText');
            if(isSplit){
                splitQuantity =  quantity - availableQuantity;
            }
            system.debug('cItem');
            system.debug(cItem);
            if(cItem.LastQuantity__c == quantity && cItem.LastOutOfStockQuantity__c == splitQuantity){
                system.debug('do nothing');
            }
            else if(cItem.LastQuantity__c == 0){
                system.debug('do nothing item just got added');
            }
            else if(cItem.LastOutOfStockQuantity__c != splitQuantity || cItem.LastQuantity__c != quantity  || (cItem.LastOutOfStockQuantity__c == 0 && splitQuantity != 0)){
                Boolean hasDifferenceOOQ = (splitQuantity - cItem.LastOutOfStockQuantity__c) != 0;
                Boolean hasDifferenceQ = (Quantity - cItem.LastQuantity__c) != 0;
                system.debug('means notification');
                system.debug('out of stock qty changed');
                Map<String,Object> changes = new Map<String,Object>();
                changes.put('cartItemId', cItem.Id);
                changes.put('productId', cItem.Product2Id);
                changes.put('OutOfStockQuantity', splitQuantity);
                changes.put('LastOutOfStockQuantity', cItem.LastOutOfStockQuantity__c);
                changes.put('LastQuantity', cItem.LastQuantity__c);
                changes.put('Quantity', quantity);
                changes.put('differenceOOQ', splitQuantity - cItem.LastOutOfStockQuantity__c);
                changes.put('differenceQ', Quantity - cItem.LastQuantity__c);
                changes.put('hasDifferenceOOQ', hasDifferenceOOQ);
                changes.put('hasDifferenceQ', hasDifferenceQ);
                changes.put('unitAdjustedPrice', cItem.unitAdjustedPrice);
                changes.put('salesPrice', cItem.SalesPrice);
                changes.put('libelleRayon', cItem.Product2.Libelle_rayon__c);
                changes.put('IFLS', cItem.Product2.Code_IFLS__c);
                changes.put('name', cItem.Name);
                changes.put('url', productImageUrl);
                changes.put('altText', productImageAlternativeText);
                
                changeList.add(changes);
                cItem.LastOutOfStockQuantity__c = splitQuantity;
                cItem.LastQuantity__c = quantity;
                cartItemsToUpdate.add(cItem);
            }
        }
        update cartItemsToUpdate;
        return changeList;
    }
   
    @AuraEnabled
    public static void updateQuantity(
        String communityId,
        String effectiveAccountId,
        String activeCartOrId,
        String cartItemId,
        Integer quantity
    ) {
        
        String webstoreId = '';
        // Lookup the webstore ID associated with the community
        if(communityId.length() < 18){
            Id communityResolved = communityId;
            webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        }else{
            webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        }
        CartItem item = [Select Id, Quantity from CartItem Where Id=: cartItemId];
        if(item.Quantity-quantity<=0){
            if(!Test.isRunningTest()) ConnectApi.CommerceCart.deleteCartItem(webstoreId,effectiveAccountId, activeCartOrId,cartItemId);
            return ;
        }
        String qty =String.valueOf(item.Quantity-quantity);
        
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.quantity = qty;
        if(!Test.isRunningTest()) ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, activeCartOrId, cartItemId,cartInput);
        
        
        
    }
    
    /*public static void addMontantVignetteAlccol(String cartId, String productId) 

{
List<CartItem> cartItemsToUpdate = new List<CartItem>();
List<CartItem> cartItemsExtract = new List<CartItem>([SELECT Id, Product2Id, Product2.Vignette_alcool__c, TotalPrice,Vignette_Alccol_Added__c,
Quantity, UnitAdjustedPrice From CartItem where CartId =: cartId AND Product2Id =: productId]);
for(CartItem cartItem : cartItemsExtract){
if(cartItem.Product2.Vignette_alcool__c != null && cartItem.Product2.Vignette_alcool__c >0 && cartItem.Vignette_Alccol_Added__c == false ){
cartItem.UnitAdjustedPrice = cartItem.UnitAdjustedPrice + cartItem.Product2.Vignette_alcool__c;
cartItem.TotalPrice = cartItem.UnitAdjustedPrice*cartItem.Quantity;
cartItemsToUpdate.add(cartItem);
cartItem.Vignette_Alccol_Added__c = true;
}
} 
if(cartItemsToUpdate !=null && !cartItemsToUpdate.isEmpty())    
update cartItemsToUpdate;
}
*/
    @AuraEnabled
    public static void addMontantVignetteAlcool(String itemId) 
        
    {     
        CartItem cartItemToUpdate = [SELECT Id,Product2.Vignette_alcool__c, Quantity, UnitAdjustedPrice From CartItem where Id =: itemId];
        
        if(cartItemToUpdate != null){
            if(cartItemToUpdate.Product2.Vignette_alcool__c != null && cartItemToUpdate.Product2.Vignette_alcool__c >0 ){
                cartItemToUpdate.UnitAdjustedPrice = cartItemToUpdate.UnitAdjustedPrice + cartItemToUpdate.Product2.Vignette_alcool__c;
                cartItemToUpdate.TotalPrice = cartItemToUpdate.UnitAdjustedPrice*cartItemToUpdate.Quantity;        
                update cartItemToUpdate;
            }                 
        } 
        
    }
    
    @AuraEnabled
    public static boolean hasVignetteAlcool(String cId)
    {    
        boolean hasVa = false;
        List<CartItem> cartItems = [SELECT Id, CartId, Product2.Vignette_alcool__c FROM CartItem where CartId =: cId];
        
        for (CartItem c : cartItems)
        {
            if(c.Product2.Vignette_alcool__c != null && c.Product2.Vignette_alcool__c >0 ){
                hasVa = true; 
            }
            
        } 
        return hasVa;
    }
    
    private static Wishlist getWishlistAndWhishListItem(Id wishlistId, Id productId){
        return [SELECT Id,(SELECT Id, quantite__c, Product2Id FROM WishlistItems WHERE Product2Id =:productId)
                , LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c from Wishlist where Id =: wishlistId];
        
    }
    
    
    
    
}