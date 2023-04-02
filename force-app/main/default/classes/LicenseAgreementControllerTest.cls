@IsTest
class LicenseAgreementControllerTest {
    @testVisible static List<LicenseAgreement__mdt> licenseAgreement{ 
get{ 
    if(licenseAgreement == NULL){ 
        licenseAgreement = [SELECT Content__c FROM LicenseAgreement__mdt]; 
    } 
    return licenseAgreement; 
     } 
	set; 
  } 
@IsTest
 static void testAgreement(){
    List<LicenseAgreement__mdt> testLicenseAgreement = (List<LicenseAgreement__mdt>)Json.deserialize('[{"Content__c": "test content","DeveloperName" : "CGU_and_CGV"}]', List<LicenseAgreement__mdt>.class);
   
     test.startTest();
       LicenseAgreementControllerTest.licenseAgreement=testLicenseAgreement;
    string content= LicenseAgreementController.getLicenseAgreement();
     test.stopTest();
    }
}