/* .Test class for AuraResponse
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          27-04-2021           Ajay.Tiwari3 @ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
@isTest(SeeAllData=false)
public class AuraResponseTest {
	
    @isTest
    public static void testAuraResponse(){
        List<Object> lstWrapper = new List<Object>();
        AuraResponse auraRes = new AuraResponse(true, 'test', 'test');
    	
        auraRes.returnResponse();
        System.assert(auraRes.isSuccess == true);
    }
}