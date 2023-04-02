/**
*
* This class contains the methods to handle the enhanced "log in to community as user" functionality for Promocash
* This is used for the Telesales scenario
*
* 1st December 2020 - Initial version - Edouard Declercq
*
*/

public without sharing class TelesalesUtils {
    
    /**
    * This method is called by the IsLoggedInAs banner and on other pages to validate whether we're in a "logged in as" scenario
    * 
    * It retrieves "logged in" as operation, in order to find which telesales user is logged in as.
    * It filters these operation to return only the one with current user
    *
     */
    @AuraEnabled(cacheable=true)
    public static List<SetupAuditTrail> getLoggedAsDetails() {

                String userName = UserInfo.getName();

        // fix 11 May 2021: added CreatedBy.Name
        List<SetupAuditTrail> sat = [
            SELECT CreatedById,CreatedBy.Name,Display,DelegateUser
            FROM SetupAuditTrail
            WHERE Action = 'suNetworkAdminLogin'
            ORDER BY CreatedDate desc
            LIMIT 30
        ];

        // Display cannot be filtered in query call. so we do this here
        List<SetupAuditTrail> filteredSat = new List<SetupAuditTrail>();
        for(SetupAuditTrail auditTrail:sat){
            if(!String.isBlank(auditTrail.Display) && auditTrail.Display.contains(userName)){
                filteredSat.add(auditTrail);
                break;
             }     
        }   

        // we're still returning a list (could return a single record but front end code expect a list)
        
        return filteredSat;

    }

    /**
    * This method is called in the product pages (PDP and PLP) to display additional fields for the Telesales
    * It only returns Stock info for now, but might be expanded to additional fields in future
    *
     */
    /* @AuraEnabled(cacheable=true)
    public static Map < String, Object > getTelesalesProductFields(String productId, String effectiveAccountId){
                // get real stock of the product; we use an existing method for this
        fieldMap.put('Stock',B2BGetInfoCustom.checkStockAndEnCours(productId,effectiveAccountId));

        // future usage - add additional fields
        //fieldMap.put('Margin','23%');

        return fieldMap;

    }*/
}