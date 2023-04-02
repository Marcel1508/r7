public class Queries {
    
    public static Account getEffectiveAccount(String effectiveAccountId)
    {
        Account account = [SELECT Id, Magasin_de_rattachement__c, Etablissement_geographique__c, Magasin_actif_en_cours__c FROM Account WHERE Id =:effectiveAccountId];
        return account;
    }
    
    public static Offre_Produit_Magasin__c getOPM(String magasinActifEnCoursId, String productId)
    {
        List<Offre_Produit_Magasin__c> res = [SELECT Id , Name, CurrencyIsoCode, Prix_de_vente_magasin__c, Statut__c
                                        FROM Offre_Produit_Magasin__c 
                                        WHERE Magasin__c =: magasinActifEnCoursId AND Produit__c =:productId];
        if(res != null && res.size() > 0)
            return res.get(0);
        return null;
    }
    
    public static AccountMagasinWrapper getAccountsAndMagasinsMaps(Set<Id> accountsIds, Set<Id> magasinsIds)
    {
        AccountMagasinWrapper acMagWrapper = new AccountMagasinWrapper();
        acMagWrapper.accounts = new Map<Id, Account>([SELECT ID, Name, Numero_Client__c,ShippingPostalCode,ShippingCity FROM ACCOUNT WHERE ID=:accountsIds]);
        acMagWrapper.magasins = new Map<Id, Magasin__c>([SELECT ID, Name, Responsable__c, Code_etablissement__c FROM Magasin__c WHERE ID=:magasinsIds]);
        return acMagWrapper;
    }
    
    public class AccountMagasinWrapper {
        public Map<Id,Account> accounts {get;set;}
        public Map<Id,Magasin__c> magasins {get;set;}
        public AccountMagasinWrapper(){
            this.accounts = new Map<Id,Account>();
            this.magasins = new Map<Id,Magasin__c>();
        }  
    }
    
    public static Wishlist getWishList(Id wishlistId)
    {
        Wishlist wishlist = [SELECT Id, CreatedById, LastModifiedById,LastModifiedByIdTelesales__c, CreatedByIdTeleSales__c, CreatedByNameTeleSales__c, LastModifiedByNameTelesales__c from Wishlist where Id =: wishlistId];
        return wishlist;
    }
    
    public static Wishlist getWishListAndItems(Id wishlistId)
    {
        Wishlist wishlist = [SELECT Id, OwnerId, Name, AccountId, WebStoreId, CurrencyISOCode, CreatedByIdTeleSales__c, LastModifiedByIdTeleSales__c, (Select Id, Name, Product2Id, WishlistId from WishlistItems) from Wishlist where Id =: wishlistId];
        return wishlist;
    }
    
     public static List<CartTax> getCartTaxes(Set<Id> cartItemIds)
    {
        List<CartTax> cartTaxes = [
            SELECT Id, Name, CartId, CartItemId, Amount, TaxRate, TaxType, TaxCalculationDate 
            FROM CartTax 
            WHERE CartItemId IN :cartItemIds];
        return cartTaxes;
    }
    
    public static String resolveCommunityIdToWebstoreIdPromocash(String communityId) {
        return Test.isRunningTest() ? [SELECT Id FROM WebStore WHERE Name = 'TestWebStore'].Id  : [SELECT WebStoreId, NetworkId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
    }
    
    public static Map<String,Id> getCodeEstablishmentVsGroupId(Set<String> codeEstablishmentIds, Map<Id,String> magaIdVsCodeEtalishment){
         Map<String,Id> codeEstablishmentVsGroupId = new Map<String,Id>();
         for(Group g : [select id, developername, name from group where developername like : codeEstablishmentIds and name like '%/ Magasin']){
                String groupName=g.developername;
                //String str='Magasin_AGDE_BIRASO__2000';
                Integer i = groupName.lastIndexOf('_');
                if(i!=-1){
                    String establishmentCode = groupName.substring(i+1, groupName.length());//2000 unique code
                    codeEstablishmentVsGroupId.put(establishmentCode,g.Id);
                }
            }     
        
        return codeEstablishmentVsGroupId;   
    }
    
    public static Map<Id,Id> getGroupIdVsAccId(Set<Id> allAccIds, Map<String,Id> codeEstablishmentVsGroupId){
        Map<Id, Id> groupIdVsAccId = new Map<Id,Id>();
    
        List<Id> gId = codeEstablishmentVsGroupId.values();// added by ajay-us844
        for(AccountShare accS : [Select Id,AccountId,UserOrGroupId FROM Accountshare WHERE AccountId IN :allAccIds AND UserOrGroupId IN :gId]){
            groupIdVsAccId.put(accS.UserOrGroupId,accS.AccountId);
        }
        return groupIdVsAccId;
    }
        
}