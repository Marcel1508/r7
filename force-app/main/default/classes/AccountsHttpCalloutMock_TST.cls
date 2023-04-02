/**
 * @CreatedBy       : Suliman A.
 * @Date            : 13/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : class that implements the HttpCalloutMock interface to intercept the callout. If an HTTP callout is invoked in test context, 
 * 						the callout is not made. Instead, you receive the mock response that you specify in the respond method.  
 */

@isTest
public class AccountsHttpCalloutMock_TST implements HttpCalloutMock {
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"detailed_account" : {"attributes" : {"N_client__c" : "01557","Code_etablissement__c" : "1313","Forme_juridique__c" : "01","Name" : "Test ApiGee","Numero_Siret__c" : "1111","BillingStreet" : "12 Rue Test","BillingPostalCode" : "1012","BillingCity" : "Paris","Specialisation__c" : "1A","Theme__c" : "25;37","Libell_code_APE__c" : "-","Email__c" : "test@test.co","Piece_identite__c" : false,"Categorie__c" : "1","Attestation_registre_du_commerce__c" : false,"BillingCountry" : "France","NPAI_facturation__c" : true,"ShippingStreet" : "12 Rue test","ShippingPostalCode" : "1012","ShippingCity" : "Paris","ShippingCountry" : "France","NPAI_livraison__c" : true,"K_bis__c" : true,"RIB__c" : true,"Chaine_bloquee__c" : false}}');
        response.setStatusCode(200);
        return response; 
    }

}