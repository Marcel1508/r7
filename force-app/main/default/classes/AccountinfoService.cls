public without sharing class AccountinfoService {
    
    @AuraEnabled
    public static Account getAccountInfo(String objectId, String objectType) {
        String accountId;
        if(objectType.equalsIgnoreCase(Constants.ACCOUNT))
            accountId = objectId;
        if(objectType.equalsIgnoreCase(Constants.CONTACT))
            accountId = getContactAccountId(objectId);
        if(objectType.equalsIgnoreCase(Constants.CONTACT_POINT_ADDRESS))
            accountId = getAddressAccountId(objectId);
        
        List<Account> res = (accountId == null)? new List<Account>(): [SELECT ID, (SELECT ID FROM CONTACTS), (SELECT ID, AddressType FROM ContactPointAddresses) FROM ACCOUNT WHERE ID=:accountId];
        if(!res.isEmpty())
            return res.get(0);
        return null;
    }
    
    private static String getContactAccountId(String contactId) {
        List<Contact> res = [SELECT ID, AccountId FROM CONTACT where id=:contactId];
        if(!res.isEmpty())
            return res.get(0).AccountId;
        return null;
    }
    
    private static String getAddressAccountId(String contactPointAddressId) {
        List<ContactPointAddress> res = [SELECT ID, ParentId FROM ContactPointAddress where id=:ContactPointAddressId];
        if(!res.isEmpty())
            return res.get(0).ParentId;
        return null;
    }
}