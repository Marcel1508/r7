public without sharing class B2BSetInfoCustom {
    @AuraEnabled()
    public static String setFavWishlistId(
        String effectiveAccountId,
        String wishlistId
    ) {
        Account a = [SELECT Id, FavWishlist__c from Account where Id =: effectiveAccountId];
        a.FavWishlist__c = wishlistId;
        update a;
        return a.FavWishlist__c;
    }

}