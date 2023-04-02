public without sharing class CustomLookupController {
    @AuraEnabled()
    public static List<SObject> findRecords(String searchKey, String objectname, String searchField, Integer queryLimit){
        String key = '%' + searchKey + '%';
        Boolean bool = true;
        String query = 'SELECT Id, IsBuyer, '+searchField+' FROM '+objectname +' WHERE '+searchField + ' LIKE :key';
        if(objectname == 'Account'){
         // QUERY += ' AND IsBuyer = true ORDER BY Name DESC LIMIT :queryLimit';
           /*Jira ticket-454,added by Ajay tiwari,to search all the sieret number in accounts.*/ 
           query += '  ORDER BY Name DESC LIMIT :queryLimit';
    
        }else{
            query += ' ORDER BY Name DESC LIMIT :queryLimit';
        }
        System.debug(System.LoggingLevel.DEBUG, query);
        List<SObject> sObjectList = Database.query(query);
        return sObjectList;
    }
    
    //used for custom search bar
    //returns result of custom lwc-defined SOQL query
    @AuraEnabled(cacheable=true)
    public static List<SObject> findRecords2(String searchKey, String objectname, String searchInputField, String searchOutputField,String magaisnActifEnCours){
        String key = '%' + searchKey + '%';
        String query = 'SELECT Id, '+searchInputField+' FROM '+objectname +' WHERE IsBuyer = true  AND Magasin_actif_en_cours__c =: magaisnActifEnCours AND '+searchOutputField +' = :searchKey';
        system.debug(JSON.serializePretty(query));
        system.debug(searchKey);
        System.debug(System.LoggingLevel.DEBUG, query);
        List<SObject> sObjectList = Database.query(query);
        system.debug('sObjectList');
        system.debug(JSON.serializePretty(sObjectList));
        return sObjectList;
    }
    
    public static Map<Id, ConnectApi.Wishlist> createWishlists(List<String> accountIds, String wishlistName, String webstoreId,
                                                           List<ConnectApi.WishlistItemInput> wishlistItemInputs, List<ConnectApi.WishlistInput> wishlistInputs){
        Map<Id, ConnectApi.Wishlist> returnedWishlists = new Map<Id, ConnectApi.Wishlist>();
        for(Id accId : accountIds){
            ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
            wishlistInput.name = wishlistName;
            wishlistInput.products = wishlistItemInputs;
            wishlistInputs.add(wishlistInput);
            try{
               ConnectApi.Wishlist returnedValues = ConnectApi.CommerceWishlist.createWishlist(webstoreId,accId,wishlistInput);
                            //ConnectApi.Wishlist returnedValues = ConnectApi.CommerceWishlist.createWishlist(webstoreId,accountUserMap.get(uId),wishlistInput);
            system.debug('ConnectApi.CommerceWishlist.createWishlist returnedValues for: ' + returnedValues.summary.id);
            system.debug(returnedValues);
            returnedWishlists.put(returnedValues.summary.id,returnedValues);

            }catch(Exception e){
                system.debug(e.getTypeName());
                system.debug(e.getMessage());
                system.debug(e.getCause());
                system.debug(e.getLineNumber());
            }
        }
       return returnedWishlists;
    }
    
    public static ConnectApi.Wishlist createWishlist(String webstoreId, String accId, ConnectApi.WishlistInput wishlistInput){
          return ConnectApi.CommerceWishlist.createWishlist(webstoreId,accId,wishlistInput);
    }
    
    @AuraEnabled(cacheable=true)
    public static String isGerantOrCommercial(String userId) {
        if(String.isBlank(userId)) userId = UserInfo.getUserId();
        Boolean isGerantOrCommercial = false;
        String profileName = '';
        system.debug('profile');
        try{
            profileName = [SELECT Id,Name, ProfileName__c from User where Id =: userId].ProfileName__c;
        }catch(Exception e){
         	return e.getMessage();   
        }
        return profileName;
    }
    
    public static User returnUser(String realUserName){
        User user = new User();
        user = [select Id from user where name =: realUserName LIMIT 1];
        return user;
    }
    
    public static String returnUserId(String realUserName){
        User user = new User();
        user = [select Id from user where name =: realUserName LIMIT 1];
        return user.Id;
    }
    public static Id createCreneau(Creneau_client__c creneauTocreate, Id orderId){
        creneauTocreate.Commande__c = orderId;
		insert creneauTocreate;
        return creneauTocreate.Id;
    }
    public static void updateWishlist(Wishlist wishlist){
		update wishlist;
    }
    
    public static Map<Id,Id> returnUserAccountMap(List<String> accountIds){
        Map<Id, Id> accountUserMap = new Map<Id, Id>();
        for(User u : [SELECT Id, AccountId From User Where AccountId In: accountIds]){
            accountUserMap.put(u.Id, u.AccountId);
        }
        return accountUserMap;
    }

    @AuraEnabled(cacheable=false)
    public static List<String> returnAllTaxes(String cartId){
       List<CartTax> cts =  [
            SELECT Id, CartItemId, CartId, Amount, Name, MontantEcotaxe__c, TaxCalculationDate, TaxType, TaxRate, Description, CartItem.Product2Id, CartItem.Quantity
            FROM CartTax
            WHERE CartId =: cartId];

        Decimal totalTVA = 0;
        Decimal totalEco = 0;
        Decimal totalConsigne = 0;
        Map<Id, CartTax> cartTVA = getFilteredCartTaxesByType(cts, 'TVA');
        Map<Id, CartTax> cartEcotaxe = getFilteredCartTaxesByType(cts, 'Ecotaxe');
        Map<Id, CartTax> cartTaxeEmballage = getFilteredCartTaxesByType(cts, 'Consigne');
        Map<Id, CartTax> cartTaxeVignetteAlcool = getFilteredCartTaxesByType(cts, 'Taxe Vignette Alcool');

        for(CartTax tva : cartTVA.values()){
            totalTVA+=tva.Amount;
        }
        for(CartTax ecoTax : cartEcotaxe.values()){
           // totalEco+=ecoTax.Amount;
            totalEco+=ecoTax.MontantEcotaxe__c;
        }
        for(CartTax consigne : cartTaxeEmballage.values()){
            totalConsigne+=consigne.Amount;
        }
        for(CartTax vignette : cartTaxeVignetteAlcool.values()){
            totalTVA+=vignette.Amount;
        }
           
        List<String> returnedValues = new List<String>();
        if(totalTVA>0){
            returnedValues.add('TVA : ' + totalTVA + '');
        }
        if(totalEco>0){
            returnedValues.add('Ecotaxe : ' + totalEco + '');
        }
        if(totalConsigne>0){
            returnedValues.add('Total Montant Emballage : ' + totalConsigne + '');
        }
        
		return returnedValues;
    }
    

    private static Map<Id, CartTax> getFilteredCartTaxesByType(List<CartTax> cartTaxes, String taxName) {

        Map<Id, CartTax> cartTaxesByCartItemId = new Map<Id, CartTax>();

        for (CartTax cartTax : cartTaxes) {
            if(cartTax.Name == taxName){
            	cartTaxesByCartItemId.put(cartTax.CartItemId, cartTax);
            }
        }
		
        return cartTaxesByCartItemId;
    }


    /**
    * @description call from wishlistsDesktopViewItemsCustom to get all buyer account and under the same magasin store
    * @author Ajay.Kumar Tiwari | 11-24-2021 
    * @param searchKey 
    * @param objectname 
    * @param searchField 
    * @param queryLimit 
    * @param magaisnActifEnCours 
    * @return List<SObject> 
    **/
    @AuraEnabled()
    public static List<SObject> findIsBuyerRecords(String searchKey, String objectname, String searchField, Integer queryLimit,string magaisnActifEnCours){  
        String key = '%' + searchKey + '%';
       // magaisnActifEnCours='a005r000000r4ImAAI';
        String query = 'SELECT Id,  '+searchField+' FROM '+objectname +' WHERE '+searchField + ' LIKE :key';
       if(objectname == 'Account'){
          query += ' AND  IsBuyer = true  AND Magasin_actif_en_cours__c =: magaisnActifEnCours ORDER BY Name DESC LIMIT :queryLimit';
        }else{
            query += ' ORDER BY Name DESC LIMIT :queryLimit';
        }
        System.debug(System.LoggingLevel.DEBUG, query);
        List<SObject> sObjectList = Database.query(query);
        return sObjectList;
    }
    
}