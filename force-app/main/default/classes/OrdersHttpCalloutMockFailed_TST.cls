/**
 * @CreatedBy       : Suliman A.
 * @Date            : 28/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : class that implements the HttpCalloutMock interface to intercept the callout. If an HTTP callout is invoked in test context, 
 * 						the callout is not made. Instead, you receive the mock response that you specify in the respond method.  
 */

@isTest
public class OrdersHttpCalloutMockFailed_TST implements HttpCalloutMock{

    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"orders_request" : {    "Num_client__c" : "01557",    "Code_etablissement__c" : "2001",    "Mode_de_retrait__c" : " ",    "OrderNumber" : "00002160",    "Commande_en_stock__c" : " ",    "Commande_payee__c" : " ",    "Montant_Commande_TTC__c" : " ",    "Status" : "Draft order",    "Origine_de_la_commande__c" : "E-commerce",    "OrderedDate" : " ",    "Related OrderItems" : [ {      "Code_Base_Produit__c" : " ",      "Quantity" : 11.00,      "UnitPrice" : 20.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 12.00,      "UnitPrice" : 30.00    }, {      "Code_Base_Produit__c" : " ",      "Quantity" : 13.00,      "UnitPrice" : 40.00    } ],    "Creneau Salesforce" : {      "Date__c" : "2021-04-27",      "Heure_de_debut__c" : "08:00:00.000Z",      "Heure_de_fin__c" : "12:30:00.000Z"    }  }}');
        response.setStatusCode(404);
        return response; 
        
    }
}