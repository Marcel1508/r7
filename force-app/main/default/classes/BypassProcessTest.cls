/**
* @author       jan.straka@bluewolf
* @date         2020-11-25
* @description  Service for bypassing process builders
**/
@IsTest
private class BypassProcessTest {
    
    @IsTest
    private static void testDoNothing() {
        Exception caughtException;
        
        Test.startTest();
        try {
            BypassProcess.doNothing();
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertEquals(null, caughtException, 'No exception was thrown');
    }
	
}