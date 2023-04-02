@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
 
    /*
     * Added by Suliman
     * */
    @IsTest
    static void testLoginWithInvalidCredentials() {
        System.assertEquals(null, LightningLoginFormController.login('testUser', 'fakepwd', null));
    }    
    
    @isTest
    static void testSetExpId() {
        String result = LightningLoginFormController.setExperienceId('asd24');
        System.assertNotEquals(null, result);
    }
    @isTest
    static void getForgotPasswordUrlTest() {
       LightningLoginFormController.getForgotPasswordUrl();
    }

    
   
    
    /*
     * End Added by Suliman
     * */
}