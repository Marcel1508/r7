/**
 * @CreatedBy       : Suliman A.
 * @Date            : 29/03/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A test class for OpenHours_Magasin_SVC AND OpenHours_Magasin_SCH classes, it uses 'GetBusinessesOpenHours' Static resource file.  
 */

@isTest
private class OpenHours_Magasin_SVC_TST {
	@isTest
    static  void testGetCallout() {
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetBusinessesOpenHours');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
            // Call method to test
            OpenHours_Magasin_SVC.getOpenHours();
        	OpenHours_Magasin_SCH job = new OpenHours_Magasin_SCH();
            String sch = '0 0 5,11,14,17 * * ?';
            system.schedule('Partoo API Job Test', sch, job);
            
        	Magasin__c magasin = new Magasin__c (
                Code_etablissement__c = '10101', 
                Minimum_Commande_Drive_Deporte__c = 10,
                Minimum_Commande_Drive__c = 12, 
                Minimum_Commande_Livraison__c = 8,
                API_Key__c = 'Test Magasin OH'
            );
        	insert magasin;
        
            System.assertEquals('10101',magasin.Code_etablissement__c,
              'The Magasin is updated successfully.');
                    Test.stopTest();
    }
    
}