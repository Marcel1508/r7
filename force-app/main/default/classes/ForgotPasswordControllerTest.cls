/**
* @author       unknown
* @modifier     jan.straka@bluewolf
* @date         2021-07-19
* @description  An apex page controller that exposes the site forgot password functionality
 */
@IsTest 
private class ForgotPasswordControllerTest {
	
	@IsTest(SeeAllData=true) 
	private static void testForgotPasswordController() {
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@carrefour.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}