public class Einvoice_ServiceManager {
    
    private static Blob pdfBlob;
    public static String factureName {get; set;} 
    @TestVisible public static Datetime factureDate {get; set;}  
    @TestVisible public static String factureDateFormatted {get; set;} 
    @TestVisible public static String facturePDF {get; set;} 
    public static String numFacture {get; set;} 
    public static Boolean systemDebug = Utilities.displaySystemDebug();
 
    public Einvoice_ServiceManager(ApexPages.StandardController controller) {
        getInfoFacture((Id)controller.getId());
    }
    
    public static void getInfoFacture(String factureId) {

        if (factureId != null) {
            List<Facture__c> factures = [SELECT Id, Name, invoiceCheck__c, TECH_FluxOneInFac11__c, Date_de_facture__c, ExternalId_Facture__c, Numero_externe_facture_de_vente__c FROM Facture__c WHERE Id=:factureId LIMIT 1];
            
            String invoiceCheck = factures[0].invoiceCheck__c;
            Boolean fluxOneInFac11Recu = factures[0].TECH_FluxOneInFac11__c;
            String invoiceID = factures[0].ExternalId_Facture__c;
            factureName = factures[0].Name;
            numFacture = factures[0].Numero_externe_facture_de_vente__c;

            if (factures[0].Date_de_facture__c != null) {
                 factureDate = factures[0].Date_de_facture__c + UserInfo.getTimeZone().getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
                 factureDateFormatted = factureDate.formatGMT('dd-MM-yyyy\' \'HH:mm');
            }

            if (invoiceCheck != null && invoiceID != null && fluxOneInFac11Recu == true) {
                  if (!Test.isRunningTest()) { calloutApiEinvoice(invoiceCheck, invoiceID); }
            } 
        }
    }
    
    public static void calloutApiEinvoice(String invoiceCheck, String invoiceID) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        if(invoiceCheck != null && invoiceID != null ) { 
            request.setHeader('Content-Type', 'application/pdf');
            request.setHeader('RequestOrigin', 'PROMOCASH');
            request.setHeader('check', invoiceCheck);
            request.setHeader('x-apigee-client-id', '{!$Credential.UserName}');
            request.setHeader('x-apigee-client-secret', '{!$Credential.Password}');
            request.setMethod('GET');
            request.setEndpoint('callout:Apigee'+'/retail/v2/invoices_generator/invoices/'+invoiceID);
    
            response = http.send(request);
            //result web service = OK
           if (response.getStatusCode() == 200) { 
                pdfBlob = response.getBodyAsBlob(); 
                if (!Test.isRunningTest()) { 
                    facturePDF = EncodingUtil.base64Encode(pdfBlob); }
                else{
                    facturePDF ='';
                }
            }else {
                facturePDF = 'Code Error : '+response.getStatusCode() ;
            }
        }  
    }
}