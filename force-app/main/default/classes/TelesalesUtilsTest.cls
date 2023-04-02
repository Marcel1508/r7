/**
*
* Test class for TelesalesUtils
*
*/
@IsTest
public with sharing class TelesalesUtilsTest {
    @IsTest
    static void testMyClass() {
		Test.startTest();
		Object obj = TelesalesUtils.getLoggedAsDetails();
        //Object obj2 = TelesalesUtils.getTelesalesProductFields('','');
		Test.stopTest();
    }
}