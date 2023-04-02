/**
* @author       jan.straka@bluewolf
* @date         2021-02-03
* @description  Class for utility methods
**/
public without sharing class Utilities {
    @TestVisible static List<Country_Codes_Setting__mdt> countryCodesMdt;
    /**
* @author       jan.straka@bluewolf
* @date         2021-02-03
* @description  method to set bupasses of validation rules, processes/flows, workflows
*               note: used values need to be defined as picklist values in their respective fields on User object
**/
    public static void setBypassesToCurrentUser(
        List<String> flowNames, 
        List<String> triggerNames, 
        List<String> workflowNames, 
        List<String> validationRuleNames) {
            User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            currentUser.Bypass_PB__c = flowNames == null ? null : String.join(flowNames, ';');
            currentUser.Bypass_Trigger__c = triggerNames == null ? null : String.join(triggerNames, ';');
            currentUser.Bypass_VR__c = validationRuleNames == null ? null : String.join(validationRuleNames, ';');
            currentUser.Bypass_WF__c = workflowNames == null ? null : String.join(workflowNames, ';');
            update currentUser;
        }
    
    /*** format Phone Number to international format ******* @author: youssef.jamil1@ibm ***/
    public static String formatPhone(String phoneNumber, String countryCode){
        
        // create an instance from PhoneNumberUtil (appexchange libphone)
        noltic_libphone.PhoneNumberUtil phoneUtil = noltic_libphone.PhoneNumberUtil.getInstance();
        String formattedNumber = '';
        try{
            noltic_libphone.PhoneNumber frenchNumberProto = phoneUtil.parse(phoneNumber, countryCode);
            formattedNumber = phoneUtil.format(frenchNumberProto, noltic_libphone.PhoneNumberUtil.PhoneNumberFormat.E164); //with + sign
            formattedNumber = formattedNumber.removeStart('+'); // remove + sign
        }catch(Exception e){
        }
        return formattedNumber;
    }
    
    /*** Format Contact Phone Number ******* @author: youssef.jamil1@ibm ***/
    public static void formatContactPhone(List<Contact> contactList){
        Set<Id> accIds = new Set<Id>();
        
        for(Contact ctc : contactList){
            accIds.add(ctc.AccountId);
        }
        
        Map<Id, Account> accountIdMap = new Map<Id, Account>([select id, ShippingCountry from Account where Id in :accIds]);
        Map<String, Country_Codes_Setting__mdt> countryCodeMap = new Map<String, Country_Codes_Setting__mdt>();
        countryCodesMdt = (countryCodesMdt == null) ? [select Id, DeveloperName, Contry_Code__c from Country_Codes_Setting__mdt] : countryCodesMdt;
        for( Country_Codes_Setting__mdt elm : countryCodesMdt ){
            countryCodeMap.put(elm.DeveloperName, elm );
        }
        
        for(contact ctc : contactList){
            for (String key : countryCodeMap.keyset()) {
                if(key == accountIdMap.get(ctc.AccountId).ShippingCountry){
                    ctc.formattedPhone__c =  formatPhone(ctc.Telephone_portable__c, countryCodeMap.get(key).Contry_Code__c);
                    ctc.Phone2__c =  formatPhone(ctc.Telephone_portable__c, countryCodeMap.get(key).Contry_Code__c);
                    
                }
            }
        }
    }
    /**
* @author       jan.straka@bluewolf
* @date         2020-02-03
* @description  method to build AuraHandledException for Aura & LWC controllers to throw
**/
    public static AuraHandledException newAuraHandledException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
    
    /**
* @author       Marcel SANI
* @date         2022-02-01
* @description  method to manage the display or not of the system.debug
**/
    @AuraEnabled(cacheable = true)
    public static Boolean displaySystemDebug() {
        DebugHandler__c  debugHandler = DebugHandler__c.getOrgDefaults();
        return  debugHandler.displaySystemDebug__c;
    }
    
    public static Map<String, Set<Id>> KeyBuilding(List<sObject> records ){
        
        Map<String, Set<Id>> IdsMap = new Map<String, Set<Id>>();
        IdsMap.put('accountIds',new Set<Id>());
        IdsMap.put('magasinsIds',new Set<Id>());
        Set<Id> accountsIds = new Set<Id>();
        Set<Id> magasinsIds = new Set<Id>();
        Schema.SObjectType sObjectType = records.getSObjectType();
        if(records[0] instanceOf Frais__c)
        {
            Frais__c frais = new Frais__c();
            for(sObject record: records)
            {
                frais = (Frais__c)record;
                accountsIds.add(frais.Account__c);
                magasinsIds.add(frais.Magasin_Associe__c);
            }
            
        } else if(records[0] instanceOf Fidelite__c)
        {
            Fidelite__c fidelite = new Fidelite__c();
            for(sObject record: records)
            {
                fidelite = (Fidelite__c)record;
                accountsIds.add(fidelite.Compte__c);
                magasinsIds.add(fidelite.Magasin__c);
            }
            
        } else if(records[0] instanceOf Information_financiere__c)
        {
            Information_financiere__c informationFinanciere = new Information_financiere__c();
            for(sObject record: records)
            {
                informationFinanciere = (Information_financiere__c)record;
                accountsIds.add(informationFinanciere.Account__c);
                magasinsIds.add(informationFinanciere.Magasin__c);
            }           
        }
        IdsMap.put('accountIds',accountsIds);
        IdsMap.put('magasinsIds',magasinsIds);
        return IdsMap;
    }
    
    public static void updateWishList( Wishlist wishlist, String realUserId, Boolean UpdateCreatedByIdTeleSales)
    {
        String uId = realUserId;
        if(realUserId == 'Regular Session' || String.isBlank(realUserId)) {
            uId = UserInfo.getUserId();
        }
        wishlist.LastModifiedByIdTelesales__c = uId;
        if(UpdateCreatedByIdTeleSales)
        {
            wishlist.CreatedByIdTeleSales__c = uId;
        }
        update wishlist;
    }
    
    public static void checkStockAndEnCours(Offre_Produit_Magasin__c opm, Decimal niveauDeStock, Decimal stockAndEnCours, Decimal enCoursDeCommande){   
        stockAndEnCours = CalculatestockAndEnCours(opm,niveauDeStock,enCoursDeCommande);
    }
    
    public static Decimal checkStockAndEnCoursBulk(Offre_Produit_Magasin__c opm){
        Decimal NivDeStock;
        Decimal EncourCmd;
        return CalculatestockAndEnCours(opm,NivDeStock,EncourCmd);
    }
    
    private static Decimal CalculatestockAndEnCours(Offre_Produit_Magasin__c opm, Decimal niveauDeStock, Decimal enCoursDeCommande){
        if(opm.Niveau_de_stock__c == null){
            niveauDeStock = 0;
        } else {
            niveauDeStock = opm.Niveau_de_stock__c;
        }
        
        if(opm.En_cours_de_commande__c == null){
            enCoursDeCommande = 0;
        } else {
            enCoursDeCommande = opm.En_cours_de_commande__c;
        }
        return niveauDeStock + enCoursDeCommande;    
    }
    
    public static void writeStringField(JSONGenerator gen, String fieldName, String fieldValue, Boolean parentObjectExists, sObject objectName){
        
        if(!parentObjectExists)
        {
            if(fieldValue == null){gen.writeStringField(fieldName, '');} else {gen.writeStringField(fieldName,fieldValue );}
        } else
        {
            if(objectName == null || fieldValue == null){gen.writeStringField(fieldName, '');} else {gen.writeStringField(fieldName,fieldValue);}
            
        }
        
    }
    
    public static Product2 findProductByCodeProduit(List<Product2> productList, String PromoCodeProduit) {
        for(Product2 prod: productList) {
            if (prod.Code_Base__c == PromoCodeProduit) {
                return prod;
            }
        }
        return null;
    }
    
    public static List<Product2> activateOrDeactivatePromo(List<Product2> scope, List<Promotion__c> listPromotion, Boolean activatePromo) {
        List<Product2> listProductToUpdate = new List<Product2>();
        Map<String,Product2> productsMap = new Map<String,Product2>();
        for(Product2 product: scope)
        {
            productsMap.put(product.Code_Base__c,product); 
        }
        if(activatePromo == true)
        {
            for(Promotion__c promo : listPromotion){
                Product2 product = productsMap.get(promo.Code_Produit__c);
                if (product != null) {
                    product.En_Promotion__c = true;
                    product.Promotion_en_cours__c = promo.En_tete_Promotion__c;
                    listProductToUpdate.add(product);
                }
            }
        }else
        {
            for(Promotion__c promo : listPromotion){
                Product2 product = productsMap.get(promo.Code_Produit__c);
                if (product != null) {
                    product.En_Promotion__c = false;
                    product.Promotion_en_cours__c = null;
                    listProductToUpdate.add(product);
                }
            }            
        }
        if(!listProductToUpdate.isEmpty()) 
        {
            return listProductToUpdate;
        }else
        {
            return null;
        }
        
    }
}