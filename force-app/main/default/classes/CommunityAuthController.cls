public without sharing class CommunityAuthController {
    @AuraEnabled
    public static string doLogin(String username, String password){
        try {
            String startUrl = '';
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            
            if(pageRef != null) return pageRef.getUrl();
            
            throw new CalloutException();
            
        } catch (Exception e) {
                        throw new AuraHandledException(e.getMessage());
        }
    }
}