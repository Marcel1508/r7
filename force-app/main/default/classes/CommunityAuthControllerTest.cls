@isTest
public class CommunityAuthControllerTest {
    
    @isTest
    private static void testLogin() {
        Test.startTest();
        try
        {
            String errorRelease =  CommunityAuthController.doLogin('', '');
        }
        catch(exception e)
        {
        }     
        Test.stopTest();
        
    }
}