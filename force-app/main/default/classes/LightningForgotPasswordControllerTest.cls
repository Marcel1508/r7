/**
* @author       unknown
* @modifier     jan.straka@bluewolf
* @date         2021-07-19
* @description  Verifies that ForgotPasswordController handles invalid usernames appropriately
*/
@IsTest(SeeAllData = true)
private class LightningForgotPasswordControllerTest {

    
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
    }

    /* Verifies that null checkEmailRef url throws proper exception. */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a@carrefour.com', null), 'Argument 1 cannot be null');
    }

    /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void setExperienceIdTest() {
        LightningForgotPasswordController.setExperienceId('12345');
    }

}