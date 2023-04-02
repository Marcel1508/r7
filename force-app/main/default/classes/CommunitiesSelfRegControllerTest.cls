/**
* @author       unknown
* @modifier     jan.straka@bluewolf
* @date         2021-07-19
* @description  An apex page controller that supports self registration of users in communities that allow self registration
 */
@IsTest 
private class CommunitiesSelfRegControllerTest {
    @IsTest(SeeAllData=true) 
    private static void testCommunitiesSelfRegController() {
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@carrefour.com';
        controller.communityNickname = 'test';
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    }    
}