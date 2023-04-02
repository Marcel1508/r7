@RestResource(urlMapping='/api/einvoice/*')
global with sharing class Einvoice_REST { 

    @HttpPost
    global static void webServiceEinvoice() {

        RestResponse resp = RestContext.response;
  
        try {
            
            Einvoice_Request req = Einvoice_Request.parse(RestContext.request.requestBody.toString());

            if (String.isBlank(req.invoiceID)) {  throw new Einvoice_REST_Exception('Veuillez renseigner l\'invoiceID'); }
            if (String.isBlank(req.invoiceCheck)) { throw new Einvoice_REST_Exception('Veuillez renseigner l\'invoiceCheck'); }
            if (String.isBlank(req.invoiceNumber)) { throw new Einvoice_REST_Exception('Veuillez renseigner l\'invoiceNumber'); }
            if (String.isBlank(req.codeMagasin)) { throw new Einvoice_REST_Exception('Veuillez renseigner le code magasin'); }
            if (String.isBlank(req.numeroClient)) { throw new Einvoice_REST_Exception('Veuillez renseigner le numéro client'); }
         

            if (req.invoiceID != null && req.invoiceCheck != null && req.invoiceNumber != null && req.codeMagasin != null &&  req.numeroClient != null ) {
              
                 List<Facture__c> factures = [SELECT Id, TECH_FluxOneInFac11__c  FROM Facture__c WHERE ExternalId_Facture__c =:req.invoiceID LIMIT 1];

                 if (factures.size()>0 && factures[0].TECH_FluxOneInFac11__c == true) { 
                        throw new Einvoice_REST_Exception('Doublon : flux déjà reçu');
                  }else {
                        Facture__c fac = new Facture__c();
                        fac.ExternalId_Facture__c = req.invoiceID ;
                        fac.invoiceCheck__c = req.invoiceCheck;
                        fac.Numero_externe_facture_de_vente__c = req.invoiceNumber;
                        Magasin__c magasinLookup = new Magasin__c(Code_etablissement__c = req.codeMagasin);   
                        fac.Magasin__r = magasinLookup;
                        Account accountLookup = new Account(Numero_Client__c = req.numeroClient);   
                        fac.Code_carte_client__r = accountLookup;
                        fac.TECH_FluxOneInFac11__c = true;

                         try{
                               upsert fac ExternalId_Facture__c;

                               // resp.statusCode = 200;
                                buildResponse[] success = new buildResponse[]{ new buildResponse(true, 'OK')};
                                resp.responseBody = Blob.valueOf(JSON.serialize(success));

                         }catch (Exception e) {

                               //resp.statusCode = 500;
                               buildResponse[] errors = new buildResponse[]{ new buildResponse(false, e.getMessage())};
                               resp.responseBody = Blob.valueOf(JSON.serialize(errors));
                        }
                    }   
            }

        } catch (Exception e) {
          
            //resp.statusCode = 500;
            buildResponse[] errors = new buildResponse[]{ new buildResponse(false, e.getMessage())};
            resp.responseBody = Blob.valueOf(JSON.serialize(errors));
              
        }
     }
    
    public class buildResponse {
        public Boolean success;
        public String message;
        public buildResponse(Boolean success, String message){
            this.success = success;
            this.message = message;
        }
    }
                                                                 
    public class Einvoice_REST_Exception extends Exception {}

}