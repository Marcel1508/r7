/**
* @author       unknown
* @modifier     jan.straka@bluewolf
* @date         2021-07-19
* @description  Class containing tests for SiteRegisterController
 */
@IsTest 
private class SiteRegisterControllerTest {
    @IsTest(SeeAllData=true) 
    static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@carrefour.com';
        controller.email = 'test@carrefour.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    }
}