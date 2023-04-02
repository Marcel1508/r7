public without sharing class B2BShareWishList {
   // @AuraEnabled
   /* public static String shareWishlistsWithAccounts(String wishlistId, List<String> accountIds, String realuserId,String communityId,String effectiveAccountId){
        Wishlist wishlistToCopy = new Wishlist();
        List<Wishlist> wishlistsToInsert = new List<Wishlist>();
        List<WishlistItem> wishlistItemsToInsert = new List<WishlistItem>();
        Map<Id, Id> accountUserMap = new Map<Id, Id>();
        wishlistToCopy = [SELECT Id, OwnerId, Name, AccountId, WebStoreId, CurrencyISOCode, CreatedByIdTeleSales__c, LastModifiedByIdTeleSales__c, (Select Id, Name, Product2Id, WishlistId,Quantite__c from WishlistItems) from Wishlist where Id =: wishlistId];
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
            wishlistToInsert.CreatedByIdTeleSales__c = realuserId;
            wishlistToInsert.LastModifiedByIdTeleSales__c = realuserId;
            wishlistsToInsert.add(wishlistToInsert);
        }
        insert wishlistsToInsert;
        
        for(Wishlist wishlist : wishlistsToInsert){
            for(WishlistItem wItem : wishlistToCopy.WishlistItems){
                WishlistItem wishlistItemToInsert = new WishlistItem();
                wishlistItemToInsert.WishlistId = wishlist.Id;
                wishlistItemToInsert.Product2Id = wItem.Product2Id;
                wishlistItemToInsert.Quantite__c = wItem.Quantite__c;
                wishlistItemToInsert.Name = wItem.Name;
              //  ConnectApi.ProductPrice price = getProductPrice(communityId, wItem.Product2Id, wishlist.AccountId);
               wishlistItemsToInsert.add(wishlistItemToInsert);
            }
        }
        insert wishlistItemsToInsert;
        return 'success';
    }  
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(String communityId, String productId, String effectiveAccountId){
        
        // Lookup the webstore ID associated with the community
        String webstoreId = resolveCommunityIdToWebstoreIdPromocash(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
        return (Test.isRunningTest())? null: ConnectApi.CommerceStorePricing.getProductPrice(webstoreId, productId, effectiveAccountId);
    }

       
    private static String resolveCommunityIdToWebstoreIdPromocash(String communityId) {
       return (Test.isRunningTest())? '': [SELECT WebStoreId, NetworkId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
    }
*/

}