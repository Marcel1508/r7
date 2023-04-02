public with sharing class B2BGetInfoCustom {
    // Cached API version of this apex class.
    private static Decimal apiVersionApexClass = [SELECT ApiVersion FROM ApexClass  WHERE Name = 'B2BGetInfoCustom'  LIMIT 1].ApiVersion;
    
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
        String communityId,
        String effectiveAccountId
    ) {
        if (effectiveAccountId == Constants.EFFECTIVE_ACCOUNTID || effectiveAccountId == null) { return null; }
        
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId);
        
        //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
        //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"  
        String activeCartOrId = 'current';
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CartSummary res = (Test.isRunningTest())? null: ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeCartOrId);
        return res;
    }
    
    @AuraEnabled
    public static ConnectApi.CartItem addToCartPromocashQuantity(
        String communityId,
        String productId,
        String quantity,
        String effectiveAccountId
    ) {
        
        String webstoreId = '';
        // Lookup the webstore ID associated with the community
        
        if(communityId.length() < 18){
            Id communityResolved = communityId;
            webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        }else{
            webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        }
        
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        ConnectApi.CartItem res = (Test.isRunningTest())? null: ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, 'active', cartInput);
        if(res != null) { B2BCartControllerCustom.addMontantVignetteAlcool(res.cartItemId); } 
        calculatePromoAndTaxes(communityId, effectiveAccountId);
        return res;
        
    }
    
    //Added By Marouane, The method will calculate promotion and taxex
    public static void calculatePromoAndTaxes(String communityId, String effectiveAccountId) {
        try {
            ConnectApi.CartSummary cartSummary = getCartSummary(communityId, effectiveAccountId);
            if(!Test.isRunningTest()) {
                B2BPromotionsControllerCustom.calculateCartItemPromotions(cartSummary.cartId,effectiveAccountId);
                B2BCartTaxesCustom.calculateTaxes(new List<String>{cartSummary.cartId});
            }
        } catch(B2BCartTaxesCustom.B2BCheckoutTaxesException ex) {
        }
    }
    
    @AuraEnabled
    public static ConnectApi.CartItem addToCartPromocashUnique(String productId, String effectiveAccountId, String communityId) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = '1';
        cartInput.type = ConnectApi.CartItemType.PRODUCT;
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        ConnectApi.CartItem res = (Test.isRunningTest())? null: ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, 'active', cartInput);
        calculatePromoAndTaxes(communityId, effectiveAccountId);
        return res;
        
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistToCartResult addWishlistToCartPromocash(
        String wishlistid,
        String effectiveAccountId,
        String communityId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        ConnectApi.WishlistToCartResult res = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.addWishlistToCart(webstoreId, wishlistid, effectiveAccountId);
        calculatePromoAndTaxes(communityId, effectiveAccountId);
        return res;
        
    }
    @AuraEnabled//new method to add wishList to cart 
    public static void addWishlistToCartPromocash1(
        String wishlistid,
        String effectiveAccountId,
        String communityId
    ) {
        String productId;
        String quantite;
        for (WishlistItem wi : [ SELECT Id, Quantite__c, Product2Id FROM WishlistItem WHERE WishlistId = :wishlistid]) {
            productId = String.valueOf(wi.Product2Id);
            quantite = String.valueOf(wi.Quantite__c);
            ConnectApi.CartItem cartItem = addToCartPromocashQuantity(communityId,productId,quantite,effectiveAccountId);
        }
        
    }
    
    
    @AuraEnabled
    public static ConnectApi.WishlistItem addToListsPromocash(
        String productId,
        String wishlistId,
        String effectiveAccountId,
        String communityId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;
        //  ConnectApi.WishlistSummary = getWishlistSummaries(webstoreId, effectiveAccountId, true);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        ConnectApi.WishlistItem res = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.addItemToWishlist(webstoreId, effectiveAccountId, wishlistId, wishlistItemInput);
        return res;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.WishlistsSummary getWishlistSummaries(
        String effectiveaccountid,
        String communityid
    ) {
        //String communityId = getPromocashCommunityId();
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityid);
        //  ConnectApi.WishlistSummary = getWishlistSummaries(webstoreId, effectiveAccountId, true);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        //WINTER21
        //return ConnectApi.CommerceWishlist.getWishlistSummaries(webstoreId,effectiveaccountid,null,true);         
        // EDEC Spring 21: connectapi method signature changed
        
        ConnectApi.WishlistsSummary res = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.getWishlistSummaries(webstoreId,effectiveaccountid,true);
        return res;
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistsSummary getWishlistSummariesRefresh(
        String effectiveaccountid,
        String communityid
    ) {
        //String communityId = getPromocashCommunityId();
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityid);
        //  ConnectApi.WishlistSummary = getWishlistSummaries(webstoreId, effectiveAccountId, true);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        //WINTER21
        //return ConnectApi.CommerceWishlist.getWishlistSummaries(webstoreId,effectiveaccountid,null,true);         
        // EDEC Spring 21: connectapi method signature changed
        ConnectApi.WishlistsSummary res = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.getWishlistSummaries(webstoreId,effectiveaccountid,true);
        return res;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<SetupAuditTrail> getLoggedAsDetails() {
        
        String userName = UserInfo.getName();
        
        List<SetupAuditTrail> sat = [
            SELECT CreatedById,Display,DelegateUser,CreatedByContext,CreatedByIssuer
            FROM SetupAuditTrail
            WHERE Action = 'suNetworkAdminLogin'
            ORDER BY CreatedDate desc
            LIMIT 30
        ];
        
        // Display cannot be filtered in query call. so we do this here
        List<SetupAuditTrail> filteredSat = new List<SetupAuditTrail>();
        for(SetupAuditTrail auditTrail:sat){
            if(!String.isBlank(auditTrail.Display) && auditTrail.Display.contains(userName)){
                filteredSat.add(auditTrail);
                break;
            }     
        }           
        // we're still returning a list (could return a single record but front end code expect a list)
        return filteredSat;
    }
    
    @AuraEnabled
    public static Wishlist createWishlist(
        String listname,
        String effectiveAccountId,
        String communityId,
        String realUserId
    ) {
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = listname;
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        ConnectApi.Wishlist returnedValues = (!Test.isRunningTest())? ConnectApi.CommerceWishlist.createWishlist(webstoreId,effectiveAccountId,wishlistInput): new ConnectApi.Wishlist();
        
        Wishlist wishlist = (!Test.isRunningTest())? [SELECT Id, LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c, CreatedByNameTeleSales__c, LastModifiedByNameTelesales__c from Wishlist where Id =: returnedValues.summary.id]: 
        [SELECT Id, LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c, CreatedByNameTeleSales__c, LastModifiedByNameTelesales__c from Wishlist LIMIT 1];
            //User user = [SELECT Id, FirstName, LastName from User where Id =: wishlist.LastModifiedById];
            //String uId = CustomLookupController.returnUserId(realUserName);
            if(realUserId == 'Regular Session' || String.isBlank(realUserId)) { realUserId = UserInfo.getUserId(); }
        wishlist.CreatedByIdTeleSales__c = realUserId;
        wishlist.LastModifiedByIdTelesales__c = realUserId;
        //CustomLookupController.updateWishlist(wishlist);
        update wishlist;
        return wishlist;
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        
    }
    
    @AuraEnabled
    public static String getWishlistInfosTeleSales(
        String wishlistId
    ) {
        Wishlist wishlist = Queries.getWishList(wishlistId);
        //  User user = [SELECT Id, FirstName, LastName from User where Id =: wishlist.CreatedById];
        
        return wishlist.CreatedByNameTelesales__c +','+wishlist.LastModifiedByNameTelesales__c; 
    }
    @AuraEnabled(cacheable=true)
    public static String getWishlistCreatedByNameTeleSales(
        String wishlistId
    ) {
        Wishlist wishlist = Queries.getWishList(wishlistId);
        //  User user = [SELECT Id, FirstName, LastName from User where Id =: wishlist.CreatedById];
        return wishlist.CreatedByNameTelesales__c; 
    }
    
    @AuraEnabled(cacheable=true)
    public static String getWishlistLastModifiedByNameTeleSales(
        String wishlistId
    ) {
        Wishlist wishlist = Queries.getWishList(wishlistId);
        //    User user = [SELECT Id, FirstName, LastName from User where Id =: wishlist.LastModifiedById];
        
        return wishlist.LastModifiedByNameTelesales__c; 
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRealUserName() {
        String userName = UserInfo.getName();
        return userName;
    }

    @AuraEnabled(cacheable=false)
    public static String getRealUserId() {
        String userId = UserInfo.getUserId();
        return userId;
    }

    @AuraEnabled(cacheable=false)
    public static String getFavWishlistId(
        String effectiveAccountId
    ) {
        String favWishlistId = [SELECT Id, FavWishlist__c from Account where Id =: effectiveAccountId].FavWishlist__c;
        
        if(favWishlistId == ''|| favWishlistId == null){
            return '';
        }
        else{
            return favWishlistId;
        }
    }
    
    @AuraEnabled
    public static void deleteWishlist(
        String wishlistId,
        String communityId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        if(!Test.isRunningTest()) ConnectApi.CommerceWishlist.deleteWishlist(webstoreId,wishlistId);
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistSummary updateWishlist(
        String effectiveAccountId,
        String wishlistId,
        String communityId,
        String newName,
        String realUserName
    ) {
        ConnectApi.WishlistUpdateInput wishlistUpdateInput = new ConnectApi.WishlistUpdateInput();
        wishlistUpdateInput.name = newName;
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        
        ConnectApi.WishlistSummary returnedValues = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.updateWishlist(webstoreId,effectiveAccountId,wishlistId,wishlistUpdateInput);
        if(realUserName != 'Regular Session'){
            Wishlist wishlist = Queries.getWishList(wishlistId);
            //User user = [SELECT Id, FirstName, LastName from User where Id =: wishlist.LastModifiedById];
            String uId = CustomLookupController.returnUserId(realUserName); 
            wishlist.LastModifiedByIdTelesales__c = uId;
            CustomLookupController.updateWishlist(wishlist);
        }
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        return returnedValues;
    }
    @AuraEnabled
    public static void updateWishlistLMB(
        String effectiveAccountId,
        String communityId,
        String realUserName,
        String wishlistId
    ){
        
        Wishlist wishlist = Queries.getWishList(wishlistId);
        String uId = CustomLookupController.returnUserId(realUserName); 
        wishlist.LastModifiedByIdTelesales__c = uId;
        CustomLookupController.updateWishlist(wishlist);
    }
    
    @AuraEnabled
    public static String removeWishlistItem(
        String effectiveAccountId,
        String wishlistId,
        String communityId,
        String wishlistItemId,
        String realUserId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        if(!Test.isRunningTest())
            ConnectApi.CommerceWishlist.removeWishlistItem(webstoreId,effectiveAccountId,wishlistId,wishlistItemId);
        Wishlist wishlist = Queries.getWishList(wishlistId);
        Utilities.updateWishList(wishlist, realUserId, false);
        String lastModifiedBy = getWishlistInfosTeleSales(wishlistId);
        return lastModifiedBy;
    }
    
    @AuraEnabled
    public static ConnectApi.WishlistItemCollection getWishlistItems(
        String effectiveAccountId,
        String wishlistId,
        String communityId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        //  ConnectApi.WishlistSummary = getWishlistSummaries(webstoreId, effectiveAccountId, true);
        
        String fields = 'Id, Name, Code_IFLS__c, Libelle_rayon__c, StockKeepingUnit ';

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        //WINTER21
        //return ConnectApi.CommerceWishlist.getWishlistItems(webstoreId, effectiveAccountId, wishlistId);        
        //EDEC Spring 21: add fields (or null) and 2 null params
        ConnectApi.WishlistItemCollection res = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.getWishlistItems(webstoreId, effectiveAccountId, wishlistId, fields, null,null);
        return res;
    }
    
    @AuraEnabled
    public static Integer getQuantityWishlistItem(
        String effectiveAccountId,
        String wishlistId,
        String wishlistItemId
    ) {
        Integer quantity = 1;
        WishlistItem wishlistItem =[SELECT Id, Quantite__c FROM WishlistItem WHERE id =:wishlistItemId AND WishlistId =: wishlistId];
        if(wishlistItem.Quantite__c != 0 && wishlistItem.Quantite__c != null){
            Decimal temp = wishlistItem.Quantite__c;
            quantity = temp.intvalue();
        }
        return quantity;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getDisplayedProductName(Id productId) {
                return [
                SELECT Libell_Final_TA__c
                FROM Product2
                WHERE Id=:productId
        ]?.Libell_Final_TA__c;
    }


    @AuraEnabled(cacheable=true)
    public static List<Product2> getDisplayedProductData(Id productId) {
        List<Product2> products = new  List<Product2>() ;
        if (productId != null) {
            List<Product2> prds =[SELECT Id, Name, Conseils_d_utilisation__c, Infos_et_avertissements__c, Mentions_legales__c, Degre_alcool__c, Couleur__c, Cuvee__c, Cepages__c, Accords_mets_vins__c ,
            Energie_Kj__c, Energie_Kcal__c, Matieres_grasses__c , dont_acides_gras__c, Glucides__c, dont_sucres__c, Proteines__c, Sel__c,
            Poids_brut__c, Conservation__c, Allergenes__c, Labelrouge__c, ABCERTIFIEAGRIBIOvert__c, AOC__c, Conditionnement__c, Ecotaxe__c, Consigne__c , Origines__c FROM Product2 where Id=:productId LIMIT 1];
            products = prds;
        }
        return products;

    }


    @AuraEnabled(cacheable=true)
    public static String getPromocashCommunityId(){
        String communityId = '';
        ConnectApi.CommunityPage p = (Test.isRunningTest())? new ConnectApi.CommunityPage(): ConnectApi.Communities.getCommunities();
        List<ConnectApi.Community> commList = (Test.isRunningTest())? new List<ConnectApi.Community>(): p.communities;
        for(ConnectApi.Community community : commList){
            if(community.name == 'Promocash') { return community.Id; }
        }
        return communityId;
    }
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct(String communityId, String productId, String effectiveAccountId) {
        // Get partition
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.ProductCache');
        // Add cache value to the partition if session exists
        String key = 'productDetail' + productId;
        if (sessionPart.isAvailable()) {
            if (!sessionPart.contains(key) ) {
                ConnectApi.ProductDetail product = getProduct2(communityId, productId, effectiveAccountId);
                sessionPart.put(key, product);
            }
            //Retrieve cache value from the partition
            return (ConnectApi.ProductDetail)sessionPart.get(key);
        } else {
            ConnectApi.ProductDetail product = getProduct2(communityId, productId, effectiveAccountId);
            return product;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct2(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        List<String> fields = new List<String>();
        fields.add('Code_IFLS__c');
        fields.add('Picto_front__c');
        fields.add('Code_rayon__c');
        fields.add('Libelle_rayon__c');
        fields.add(Product2.Libell_Final_TA__c.getDescribe().getName());
        fields.add('Name');
        fields.add('StockKeepingUnit');
        fields.add('Origines__c');
        fields.add('Vignette_alcool__c');
        fields.add('Conditionnement__c');
        fields.add('Ecotaxe__c');
        fields.add('Consigne__c');
        fields.add('ABCERTIFIEAGRIBIOvert__c');
        fields.add('Indicateur_bio__c');
        fields.add('Labelrouge__c');
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        ConnectApi.ProductDetail res = (Test.isRunningTest())? null: ConnectApi.CommerceCatalog.getProduct(webstoreId, productId, effectiveAccountID, fields, false, null, false, true, false);
        return res;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProductWithCustomFields(
        String communityId,
        String productId,
        String effectiveAccountId,
        List<String> fields
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        ConnectApi.ProductDetail res = (Test.isRunningTest())? null: ConnectApi.CommerceCatalog.getProduct(webstoreId, productId, effectiveAccountID, fields, false, null, false, true, false);
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static Product2 getProductExtraInfo(
        String productId,
        String effectiveAccountId
    ) {
        Product2 product = [SELECT Id, Code_IFLS__c, Picto_front__c, Code_rayon__c, Libelle_rayon__c, Name, Origines__c, Conditionnement__c, Ecotaxe__c, Labelrouge__c, ABCERTIFIEAGRIBIOvert__c from Product2 where Id =: productId];
        return product; 
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Offre_Produit_Magasin__c getOffreProduitMagasin(
        String productId,
        String effectiveAccountId
    ) {
        Account account = new Account();
        Offre_Produit_Magasin__c opm = new  Offre_Produit_Magasin__c();
        account= Queries.getEffectiveAccount(effectiveAccountId);
        List<Offre_Produit_Magasin__c> opmlist = new  List<Offre_Produit_Magasin__c>();
        opmlist = [SELECT Id, Niveau_de_stock__c,CurrencyIsoCode,Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c, 
                   Produit__r.Code_IFLS__c, Produit__r.Picto_front__c,Produit__r.Marque_text__c,
                   En_cours_de_commande__c, Produit_en_extension_de_gamme__c, Statut__c, Prix_kilo__c, Prix_L__c, Libelle_du_conditionnement_de_vente__c,
                   Prix_unite__c, vignette_alcool__c, unit_de_prix__c From Offre_Produit_Magasin__c
                   where Magasin__c =: account.Magasin_actif_en_cours__c and Produit__c =:productId];
        if(opmlist != null && !opmlist.isEmpty()){
            opm = opmlist[0];
        }
        
        return opm; 
    }
    
    @AuraEnabled(cacheable=true)
    public static Prix_specifiques__c getPrixSpecifique(
        String productId,
        String effectiveAccountId,
        String opmId
    ) {
        List<Prix_specifiques__c> res = [select id, Prix_de_vente_client__c, Prix_kilo__c, Prix_L__c, Prix_unite__c from Prix_specifiques__c where
                                         Produit__c = :productId AND Reference_client__c = :effectiveAccountId AND Offre_Produit_Magasin__c=:opmId];
        
        if(res != null && res.size() > 0)
            return res.get(0);
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Prix_specifiques__c getPrixSpecifiqueProduct(
        String productId,
        String effectiveAccountId
    ){
        Account account= Queries.getEffectiveAccount(effectiveAccountId);
        Offre_Produit_Magasin__c opm = Queries.getOPM(account.Magasin_actif_en_cours__c, productId);
        List<Prix_specifiques__c> resPrix = [
            SELECT id, Prix_de_vente_client__c, Prix_kilo__c, Prix_L__c, Prix_unite__c
            FROM Prix_specifiques__c
            WHERE Produit__c = :productId AND Reference_client__c = :effectiveAccountId AND Offre_Produit_Magasin__c = :opm.Id
        ];
        
        if(resPrix != null && resPrix.size() > 0){
            return resPrix.get(0);
        } else return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkProductIsInStock(String productId, String effectiveAccountId) {
        // This could be an external call that returns more information, but for simplicity let's make it a random Boolean.
        return Math.random() > 0.5;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkProductIsPFT(String productId, String effectiveAccountId) {
        Boolean isPFT = false;
        Account account = new Account();
        Offre_Produit_Magasin__c opm = new Offre_Produit_Magasin__c();
        try{
            account = Queries.getEffectiveAccount(effectiveAccountId);
            opm = [SELECT Id, Niveau_de_stock__c, CurrencyIsoCode, Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c,
                   En_cours_de_commande__c, Produit_en_extension_de_gamme__c, Prix_de_vente_magasin__c, Statut__c  From Offre_Produit_Magasin__c 
                   where Magasin__c =: account.Magasin_actif_en_cours__c and Produit__c =:productId];
            
            if(opm.Code_departement__c != null  && (opm.Prix_de_vente_magasin__c  == null || opm.Prix_de_vente_magasin__c  == 0)){
                if(opm.Code_departement__c== '4' && opm.Statut__c == '2' ){
                    isPFT = true;
                }
            }
        }
        catch(Exception e){
            return false;
        }
        return isPFT;
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal checkStockAndEnCours(String productId, String effectiveAccountId){
        Decimal stock = 0;
        Account account = new Account();
        if(effectiveAccountId == Constants.EFFECTIVE_ACCOUNTID || effectiveAccountId == null){
            return 1;
        }
        Offre_Produit_Magasin__c opm = new Offre_Produit_Magasin__c();
        account= Queries.getEffectiveAccount(effectiveAccountId);
        List<Offre_Produit_Magasin__c> listRes = new List<Offre_Produit_Magasin__c>();
        
        listRes = [SELECT Id, Niveau_de_stock__c, CurrencyIsoCode, Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c,
                   En_cours_de_commande__c, Produit_en_extension_de_gamme__c  From Offre_Produit_Magasin__c 
                   where Magasin__c =: account.Magasin_actif_en_cours__c and Produit__c =:productId];
        
        if(listRes.isEmpty())
            return 0;
        opm = listRes.get(0);
        
        if(opm.Niveau_de_stock__c != null && opm.En_cours_de_commande__c != null){
            stock = opm.Niveau_de_stock__c + opm.En_cours_de_commande__c;
        }
        else if(opm.Niveau_de_stock__c != null){
            stock = opm.Niveau_de_stock__c;
        }
        else if(opm.En_cours_de_commande__c != null){
            stock = opm.En_cours_de_commande__c;
        }
        // else if(opm.Niveau_de_stock__c == null && opm.En_cours_de_commande__c == null){
        else{
            stock = 0;
        }
        return stock;
    }
    
    /**
* Check the available qty for a list of product (stock + en cours de commande)
* Returns a map: Key: ProductId, Value: Stock
*
*
*/
    @AuraEnabled(cacheable=true)
    public static Map<String,Decimal> checkStockAndEnCoursForProducts(List<String> productIdList, String effectiveAccountId){
        Map<String,Decimal> productStockMap = new Map<String,Decimal>();
        if (productIdList == null || productIdList.isEmpty())
            return productStockMap;
        
        Account account = new Account();
        
        account= Queries.getEffectiveAccount(effectiveAccountId);
        Offre_Produit_Magasin__c[] opms  = [SELECT Id, Produit__c, Niveau_de_stock__c, CurrencyIsoCode, Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c,
                                            En_cours_de_commande__c, Produit_en_extension_de_gamme__c  From Offre_Produit_Magasin__c 
                                            where Magasin__c =: account.Magasin_actif_en_cours__c and Produit__c IN :productIdList];
        
        for(Offre_Produit_Magasin__c opm : opms){
            Decimal stock = 0;
            if(opm.Niveau_de_stock__c != null && opm.En_cours_de_commande__c != null){
                stock = opm.Niveau_de_stock__c + opm.En_cours_de_commande__c;
            }
            else if(opm.Niveau_de_stock__c != null){
                stock = opm.Niveau_de_stock__c;
            }
            else if(opm.En_cours_de_commande__c != null){
                stock = opm.En_cours_de_commande__c;
            }
            else{
                stock = 0;
            }
            productStockMap.put(opm.Produit__c,stock);
        }
        return productStockMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static String checkDisplayingSimilarProduct(String productId, String effectiveAccountId) {
        
        
        String isDisplayed ='';
        Account account = new Account();
        Offre_Produit_Magasin__c opm = new Offre_Produit_Magasin__c();
        account= Queries.getEffectiveAccount(effectiveAccountId);
        opm= Queries.getOPM(account.Magasin_actif_en_cours__c,productId);
        if(opm.Statut__c == '2') { isDisplayed = opm.Statut__c; }
        return isDisplayed;
    }
    
    @AuraEnabled(cacheable=true)
    public static String checkDisplayingSimilarProductLA(String productId, String effectiveAccountId) {
        String isDisplayed ='';
        Account account = new Account();
        Offre_Produit_Magasin__c opm = new Offre_Produit_Magasin__c();
        account= Queries.getEffectiveAccount(effectiveAccountId);
        opm= Queries.getOPM(account.Magasin_actif_en_cours__c, productId);
        if(opm.Statut__c == '4' || opm.Statut__c == '5'){
            isDisplayed = opm.Statut__c;
        }
        return isDisplayed;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Offre_produit_Magasin__c> getSimilarProduct(String productId, String effectiveAccountId){
        Account account = [
            SELECT Id, Magasin_de_rattachement__c, Etablissement_geographique__c, Magasin_actif_en_cours__c
            FROM Account
            WHERE Id =:effectiveAccountId];
        Offre_produit_Magasin__c currentOPM = [
            SELECT 
            Produit__r.Code_departement__c, 
            Produit__r.Code_rayon__c, 
            Produit__r.Code_sous_famille__c,  
            Produit__r.Code_famille__c, 
            Produit__r.Code_unite_de_besoin__c, 
            Prix_de_vente_magasin__c,
            Ref_tarifaire_magasin__c
            FROM Offre_produit_Magasin__c 
            WHERE Produit__c = :productId AND Magasin__c =: account.Magasin_actif_en_cours__c];
        
        // The proposal for similar products is based on the product proposal with the same codes below as the initial product
        String codeSousFamille = currentOPM.Produit__r.Code_sous_famille__c;
        String codeUniteDeBesoin = currentOPM.Produit__r.Code_unite_de_besoin__c;
        String codeFamille = currentOPM.Produit__r.Code_famille__c;
        String codeRayon = currentOPM.Produit__r.Code_rayon__c;
        
        List<Offre_produit_Magasin__c> similarOPMs = [
            SELECT Id, 
            Niveau_de_stock__c, 
            CurrencyIsoCode, 
            Ref_tarifaire_magasin__c,  
            En_cours_de_commande__c, 
            Prix_de_vente_magasin__c, 
            Produit__r.Name, 
            Statut__c
            FROM Offre_Produit_Magasin__c
            WHERE Produit__r.Code_sous_famille__c = :codeSousFamille
            AND Produit__r.Code_unite_de_besoin__c = :codeUniteDeBesoin
            AND Produit__r.Code_famille__c = :codeFamille
            AND Produit__r.Code_rayon__c = :codeRayon
            AND Magasin__c = :account.Magasin_actif_en_cours__c
            ORDER BY Prix_de_vente_magasin__c ASC
        ];
        
        List<Offre_produit_Magasin__c> result = Utilities2.getTwoSimilarProductsAndPrices(productId,similarOPMs);
        return result;
    }
    
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = Utilities2.getPickListValues(objApiName, fieldName);
        return options;
    }
    
    //used for custom search bar
    //returns result of custom lwc-defined SOQL query
    @AuraEnabled(cacheable=true)
    public static List<SObject> findRecords(String searchKey, String objectname, String searchInputField, String searchOutputField){
        String key = '%' + searchKey + '%';
        String query = 'Select Id, '+searchInputField+' From '+objectname +' Where '+searchOutputField +' = :searchKey';
        List<SObject> sObjectList = Database.query(String.escapeSingleQuotes(query));
        return sObjectList;
    }
    
    //counts accessible accounts in read
    @AuraEnabled(cacheable=true)
    public static String getAccessibleAccountsCount(){  
        try{
            Account acc = database.Query('select Id from account LIMIT 1');
            return String.valueOf(1);
        }catch(Exception e){
            return e.getMessage();
        }    
    }
    
    //under construction: share wishlists using manual sharing, trying to see if connectapi gets the shared wishlists with manually sharing the record, or gets them using
    //other properties, like ownerid for example
    //do not use yet
    
    @testVisible
    private static boolean manualShareRead(Id recordId, Id userOrGroupId){
        // Create new sharing object for the custom object Job.
        WishlistShare wShr  = new WishlistShare();
        // Set the ID of record being shared.
        wShr.ParentId = recordId;
        // Set the ID of user or group being granted access.
        wShr.UserOrGroupId = userOrGroupId;
        // Set the access level.
        wShr.AccessLevel = 'Read';
        // Set rowCause to 'manual' for manual sharing.
        // This line can be omitted as 'manual' is the default value for sharing objects.
        wShr.RowCause = Schema.WishlistShare.RowCause.Manual;
        // Insert the sharing record and capture the save result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        Database.SaveResult sr = Database.insert(wShr,false);
        // Process the save results.
        if(sr.isSuccess()){
            // Indicates success
            return true;
        }
        else {
            // Get first save result error.
            Database.Error err = sr.getErrors()[0];
            // Check if the error is related to trival access level.
            // Access levels equal or more permissive than the object's default 
            // access level are not allowed. 
            // These sharing records are not required and thus an insert exception is acceptable. 
            if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
               err.getMessage().contains('AccessLevel')){
                   // Indicates success.
                   return true;
               }
            else{
                // Indicates failure.
                return false;
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String shareWishlistsWithAccountse(String wishlistId, List<String> accountIds, String realusername, String communityId, String effectiveAccountId){
        Wishlist wishlistToCopy = new Wishlist();
        List<Wishlist> wishlistsInserted = new List<Wishlist>();
        List<Wishlist> wishlistsToUpdate = new List<Wishlist>();
        List<WishlistItem> wishlistItemsToInsert = new List<WishlistItem>();
        Map<Id, Id> accountUserMap = new Map<Id, Id>();
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        User user = [select Id from user where name =: realusername];
        List<ConnectApi.WishlistInput> wishlistInputs = new List<ConnectApi.WishlistInput>();
        List<ConnectApi.WishlistItemInput> wishlistItemInputs = new List<ConnectApi.WishlistItemInput>();
        Map<Id, ConnectApi.Wishlist> returnedWishlists = new Map<Id, ConnectApi.Wishlist>();
        wishlistToCopy = Queries.getWishListAndItems(wishlistId);
        
        for(WishlistItem wItem : wishlistToCopy.WishlistItems){
            ConnectApi.WishlistItemInput wItemInput = new ConnectApi.WishlistItemInput();
            wItemInput.productId = wItem.Product2Id;
            wishlistItemInputs.add(wItemInput);
        }
        
        for(User u : [SELECT Id, AccountId From User Where AccountId In: accountIds]){
            accountUserMap.put(u.Id, u.AccountId);
        }
        
        if(Test.isRunningTest())
            accountUserMap.put(userId, effectiveAccountId);
        
        for(Id uId : accountUserMap.keySet()){
            ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
            wishlistInput.name = wishlistToCopy.Name;
            wishlistInput.products = wishlistItemInputs;
            ConnectApi.Wishlist returnedValues = (Test.isRunningTest())? null: ConnectApi.CommerceWishlist.createWishlist(webstoreId,accountUserMap.get(uId),wishlistInput);
            if(Test.isRunningTest()) {
                returnedWishlists.put(wishlistToCopy.Id, new ConnectApi.Wishlist());
            } else {
                returnedWishlists.put(returnedValues.summary.id,returnedValues);
            }
        }
        
        wishlistsInserted = [SELECT Id, LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c, OwnerId, Name from Wishlist where Id =: returnedWishlists.keySet()];
        
        for(Id uId : accountUserMap.keySet()){
            for(Wishlist wList : wishlistsInserted){
                //wList = wishlistToCopy.clone(false,false,false,false);
                wList.OwnerId = uId;
                wList.CreatedByIdTeleSales__c = user.Id;
                wList.LastModifiedByIdTelesales__c = user.Id;
                wishlistsToUpdate.add(wList);
            }
        }
        
        update wishlistsToUpdate;
        
        /*

Wishlist wishlistToInsert = new Wishlist();
wishlistToInsert = wishlistToCopy.clone(false,false,false,false);
wishlistToInsert.OwnerId = uId;
wishlistToInsert.AccountId = accountUserMap.get(uId);
wishlistsToInsert.add(wishlistToInsert);

Wishlist wishlist = [SELECT Id, LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c from Wishlist where Id =: returnedValues.summary.id];
wishlist.CreatedByIdTeleSales__c = user.Id;
wishlist.LastModifiedByIdTelesales__c = user.Id;
update wishlist;
Wishlist wishlist2 = [SELECT Id, LastModifiedById, CreatedByIdTeleSales__c, LastModifiedByIdTelesales__c,
CreatedByNameTeleSales__c, LastModifiedByNameTelesales__c from Wishlist where Id =: returnedValues.summary.id];
*/
        
        return 'yes';
    }
    @AuraEnabled(cacheable=true)
    public static String shareWishlistsWithAccounts(String wishlistId, List<String> accountIds){
        Wishlist wishlistToCopy = new Wishlist();
        List<Wishlist> wishlistsToInsert = new List<Wishlist>();
        List<WishlistItem> wishlistItemsToInsert = new List<WishlistItem>();
        Map<Id, Id> accountUserMap = new Map<Id, Id>();
        wishlistToCopy = Queries.getWishListAndItems(wishlistId);
        for(User u : [SELECT Id, AccountId From User Where AccountId In: accountIds]){
            accountUserMap.put(u.Id, u.AccountId);
        }
        if(Test.isRunningTest())
            accountUserMap.put(UserInfo.getUserId(), accountIds.get(0));
        
        for(Id userId : accountUserMap.keySet()){
            Wishlist wishlistToInsert = new Wishlist();
            wishlistToInsert = wishlistToCopy.clone(false,false,false,false);
            wishlistToInsert.OwnerId = userId;
            wishlistToInsert.AccountId = accountUserMap.get(userId);
            wishlistsToInsert.add(wishlistToInsert);
        }
        insert wishlistsToInsert;
        
        for(Wishlist wishlist : wishlistsToInsert){
            for(WishlistItem wItem : wishlistToCopy.WishlistItems){
                WishlistItem wishlistItemToInsert = new WishlistItem();
                wishlistItemToInsert.WishlistId = wishlist.Id;
                wishlistItemToInsert.Product2Id = wItem.Product2Id;
                wishlistItemToInsert.Name = wItem.Name;   
                wishlistItemsToInsert.add(wishlistItemToInsert);
            }
        }
        insert wishlistItemsToInsert;
        return 'success';
    }    
    
    @AuraEnabled(cacheable=true)
    public static Map<Id, ConnectApi.Wishlist> shareWishlistsWithAccountsf(String wishlistId, List<String> accountIds, String realuserId, String communityId, String effectiveAccountId){
        String userId = UserInfo.getUserId();
        String userName = UserInfo.getUserName();
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        User user = [select Id, name from user where Id =: realuserId];
        //User user = CustomLookupController.returnUser(realUserName);
        Map<Id, Id> accountUserMap = new Map<Id, Id>();
        
        
        ConnectApi.Wishlist wishlistToShareData = (Test.isRunningTest())? new ConnectApi.Wishlist(): ConnectApi.CommerceWishlist.getWishlist(webstoreId, effectiveAccountId, wishlistId, '', ConnectApi.WishlistItemSortOrder.CreatedDateAsc );
        List<ConnectApi.WishlistInput> wishlistInputs = new List<ConnectApi.WishlistInput>();
        List<ConnectApi.WishlistItemInput> wishlistItemInputs = new List<ConnectApi.WishlistItemInput>();
        Map<Id, ConnectApi.Wishlist> returnedWishlists = new Map<Id, ConnectApi.Wishlist>();
        accountUserMap = CustomLookupController.returnUserAccountMap(accountIds);
        
        List<ConnectApi.WishlistItem> wishListItems = (Test.isRunningTest())? new List<ConnectApi.WishlistItem>{new ConnectApi.WishlistItem()}: wishlistToShareData.page.items;
        for (ConnectApi.WishlistItem wishlistItem  : wishListItems){
            ConnectApi.WishlistItemInput wItemInput = new ConnectApi.WishlistItemInput();
            wItemInput.productId = (Test.isRunningTest())? null: wishlistItem.productSummary.productId;
            wishlistItemInputs.add(wItemInput);
        }
        
        //for(Id uId : accountUserMap.keySet()){
        for(Id accId : accountIds){
            ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
            wishlistInput.name = (Test.isRunningTest())? '': wishlistToShareData.summary.name;
            wishlistInput.products = wishlistItemInputs;
            wishlistInputs.add(wishlistInput);
            //    ConnectApi.Wishlist returnedValues = ConnectApi.CommerceWishlist.createWishlist(webstoreId,accId,wishlistInput);
            ConnectApi.Wishlist returnedValues = (Test.isRunningTest())? new ConnectApi.Wishlist(): CustomLookupController.createWishlist(webstoreId,accId,wishlistInput);
            //ConnectApi.Wishlist returnedValues = ConnectApi.CommerceWishlist.createWishlist(webstoreId,accountUserMap.get(uId),wishlistInput);
            if(!Test.isRunningTest())
                returnedWishlists.put(returnedValues.summary.id,returnedValues);
        }
        
        //return CustomLookupController.createWishlists(accountIds,wishlistToShareData.summary.name,webstoreId,wishlistItemInputs, wishlistInputs);
        return returnedWishlists;
    }    
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(String communityId, String productId, String effectiveAccountId) {
        // Get partition
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.ProductPriceCache');
        // Add cache value to the partition fi session exists
        String key = 'productPrice' + productId;
        if (sessionPart.isAvailable()) {
            if (!sessionPart.contains(key)) {
                ConnectApi.ProductPrice product = getProductPrice2(communityId, productId, effectiveAccountId);
                sessionPart.put(key, product);
            } 
            // Retrieve cache value from the partition
            return (ConnectApi.ProductPrice)sessionPart.get(key);
        } else {
            ConnectApi.ProductPrice product = getProductPrice2(communityId, productId, effectiveAccountId);
            return product;
        }       
    }
    
    //Get the list and buyer price for a product.
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice2(String communityId, String productId, String effectiveAccountId){
        
        // Lookup the webstore ID associated with the community
        String webstoreId = Queries.resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
        return (Test.isRunningTest())? null: ConnectApi.CommerceStorePricing.getProductPrice(webstoreId, productId, effectiveAccountId);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCurrentSessionInfos() {
        Map<String, String> session = (Test.isRunningTest())? null: Auth.SessionManagement.getCurrentSession();
        return session;
    }
    
    /**
* @description to get current account magasin actif encours  value 
* @author Ajay.Kumar Tiwari | 11-25-2021 
* @param wishlistId 
* @return String 
**/
    @AuraEnabled(cacheable=true)
    public static String getCurrentMagasinActif(String effectiveAccountId) {
        return [Select Id,Name,Magasin_actif_en_cours__c  from Account where  Id=:effectiveAccountId limit 1].Magasin_actif_en_cours__c;
    }   

    /**
    * @author       Marcel SANI
    * @date         2022-04-19
    * @description
    **/
    @AuraEnabled
    public static List<Account> getAccountDataInfos(String effectiveAccountId) {
        List<Account> accounts;
        List<Account> accts = [SELECT Id, Name, Numero_Client__c, Contact_principal_la_creation__c, Email__c, Telephone_Siret__c, Website, Adresse_siege_social__c, Code_etablissement__c, Fax, Magasin_de_rattachement__r.Name, Echeance__c, Mode_de_reglement__c, Solde_client__c,
        Activite__c, Code_APE__r.Name, Libell_code_APE__c, Categorie__c, Enseigne_commerciale__c, Numero_Siret__c, Statut_fidelite__c, Fidelite__r.Points_acquis__c, Fidelite__r.Points_arrivant_echeance__c, Fidelite__r.Points_arrivant_echeance_au__c, Fidelite__r.Points_acquis_au__c FROM Account WHERE Id =: effectiveAccountId];
        if (accts.size()>0) {
            accounts = accts;
        }
        return  accounts;
    }
}