global without sharing class ActivateCustomerUserService {
    
    @AuraEnabled
    public static Boolean isCustomerUserEnabled(String contactId) {
        try {
            List<User> loadedUsers = (contactId != null)? [SELECT Id,Name,Email, Profile.Name FROM User WHERE ContactId = :contactId AND (Profile.Name='Customer Community +' OR Profile.Name='Customer Community Plus User')]:new List<User>();
            if(!loadedUsers.isEmpty())
                return true;
            return false;
        } catch(Exception e) {
             return true;
        }
    }
    
    @AuraEnabled
    public static selfRegService.ServiceResponse changeUsername(String userId, String email) {
        try {
            User u = [SELECT ID FROM USER WHERE ID=:userId limit 1];
            u.Username = email;
            update u;
            return new selfRegService.ServiceResponse(true, '', 'ok');
        } catch(Exception e) {
            return new selfRegService.ServiceResponse(false, '', e.getMessage());
        }
    }
    
    @AuraEnabled
    public static User getCustomerUser(String contactId) {
        List<User> loadedUsers = [SELECT Id,Name,Email, username FROM User WHERE ContactId = :contactId AND (Profile.Name='Customer Community +' OR Profile.Name='Customer Community Plus User')];
        if(loadedUsers.isEmpty())
            return null;
        return loadedUsers.get(0);
    }
    
    @AuraEnabled
    public static selfRegService.ServiceResponse enablePortalUserForContact(Id contactId, String email, String firstName, String lastName) {
       try {
            List<User> loadedUsers = (contactId != null)? [SELECT Id,Name,Email, Profile.Name FROM User WHERE ContactId = :contactId AND (Profile.Name='Customer Community +' OR Profile.Name='Customer Community Plus User')]:new List<User>();
            if(loadedUsers != null && loadedUsers.size() > 0) { // Contact has a portal user
                //return 'user_already_exists';
                return new selfRegService.ServiceResponse(false, '', 'user_already_exists');
            } else { // Contact doesn't have a portal User, need te be created
                Id communityId = getCommunityProfileId();
                if(communityId == null)
                    return new selfRegService.ServiceResponse(false, 'unkown', 'communityId is null');
                
                Contact loadedContact = [SELECT ID, firstname, lastname, accountId FROM CONTACT WHERE ID=:contactId limit 1];
                
                //Id userId = createExternalUser(firstname, lastName, email, null, loadedContact.accountId, contactId, communityId);
                Id userId = createPortalUser(firstname, lastName, email, null, loadedContact.accountId, contactId, communityId);
                
                
                if(userId != null) {
                    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
                    Map<String, Id> psMap = getPermissionMap();
                    for(String k: psMap.keySet()) {
                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = psMap.get(k), AssigneeId = userId);
                        permissionSetList.add(psa);
                    }
                    upsert permissionSetList;
                    return new selfRegService.ServiceResponse(true, '', 'created userId: ' + userId);
                }
                else{
                    applyPermissions(contactId);
                    return new selfRegService.ServiceResponse(true, '', 'returned user is null');
                }
            }
            
        }
        catch(Exception e) {
           return new selfRegService.ServiceResponse(false, 'unknown', e.getMessage() + 'enablePortalUserForContact line: ' + e.getLineNumber() + 'e.getStackTraceString(): ' + e.getStackTraceString() + ' cause: ' + e.getCause());
        }
    }
    
    @testVisible
    private static Id getCommunityProfileId() {
        try {
            return [select id, name from profile where name='Customer Community +' LIMIT 1].Id;   
        } catch(Exception e) { }
        return null;
    }
    
    private static Id createPortalUser(String firstname ,String lastname, String email, String password, String accountId, String contactId, Id profileId) {
       String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
        
        User u2 = new User(contactId=contactId, username=email, firstname=firstName,
                           lastname = lastName, email = email, communityNickname = nickname,
                           alias = string.valueof(firstName.substring(0,1) + lastName.substring(0,1)), profileid = profileId, emailencodingkey='UTF-8',
                           languagelocalekey='fr', localesidkey='fr_FR', timezonesidkey='America/Los_Angeles');
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail= true;
        Database.saveresult sr = Database.insert(u2,dlo);
        return u2.Id;
    }
    
    private static Map<String, Id> getPermissionMap() {
        Map<String, Id> res= new Map<String, Id>();
        List<PermissionSet> mp = [select id, Name from PermissionSet where name='B2B_Commerce_Buyer' or name='Account_Switcher_User'];
        if(mp != null && mp.size() > 0) {
            for(PermissionSet ps: mp) {
                res.put(ps.name, ps.Id);
            }
        }
        return res;
    }
    
    
    @testVisible
     @future
    private static void applyPermissions(String contactId){
        try{
            User newUser = new User();
            newUser = [Select Id, ContactId from User where ContactId =: contactId];
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            Map<String, Id> psMap = getPermissionMap();
            for(String k: psMap.keySet()) {
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = psMap.get(k), AssigneeId = newUser.Id);
                permissionSetList.add(psa);
            }
            upsert permissionSetList;
            
        }
        catch(Exception e) {}
    }
    
}