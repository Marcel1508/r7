/**
* @author       unknown
* @modifier     jan.straka@bluewolf
* @date         2021-07-19
* @description  An apex page controller that exposes the site login functionality
 */
@IsTest 
private class SiteLoginControllerTest {
    @IsTest(SeeAllData=true) 
    private static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@carrefour.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}