/*------------------------------------
Author : Youssef JAMIL
Test Class : SelectionPromotionControllerTest
------------------------------------*/

public without sharing class SelectionPromotionController {
    
    @TestVisible static List<RayonsPriority_Setting__mdt> rayonPromoMdt;
    @TestVisible static Template_Promotion_Setting__mdt tplPromoMdt;

	@AuraEnabled
    public static Campaign getCampaign(string recordId){
        Campaign cmp;
        try{
             cmp = [select id, Name, Magasin__c, Type, Status, PromoState__c, EmailSubject__c, Validation_Campaign__c,Promotion_Header__c, Template__c, NumberOfContacts, StartDate, EndDate from Campaign where Id =: recordId];    	
        }
        catch (Exception ex) {
            System.Debug('$$$$ Exception'+ex.getMessage());
        }
        return cmp;
     }
    
    @AuraEnabled
    public static Map<Id, CampaignMember> getCampaignMembers(string cmpId){
        Map<Id, CampaignMember> members;
       // List<Id> cmpMemberIds = new List<Id>();
        try{
       		 members = new Map<Id, CampaignMember>([Select id, ContactId from CampaignMember where CampaignId in (select id from campaign where id = :cmpId)]);
        }
        catch (Exception ex) {
            System.Debug('$$$$ Exception'+ex.getMessage());
        }
        /*
        finally{
            cmpMemberIds = new List<Id>((new Map<Id,CampaignMember>(cmpMember)).keySet());

        }*/
        return members;
     }
   
    @AuraEnabled
    public static Map<String, String> getShelvesByPriority(){
        Map<String, String> shelvesPriorityMap = new Map<String, String> ();
		// get all the shelves with their order of priority
        List<RayonsPriority_Setting__mdt> shelvesAll = (rayonPromoMdt != null) ? rayonPromoMdt : [select Id, DeveloperName, Label, Priority__c from RayonsPriority_Setting__mdt order by Priority__c ASC];
        //put them in a Map (key=>Priority, value=>Label)
        for(RayonsPriority_Setting__mdt shelf : shelvesAll){
            shelvesPriorityMap.put(String.valueOf(shelf.Priority__c), shelf.Label);
        }
        return shelvesPriorityMap;
    } 
     
    @AuraEnabled
    public static Map <string, Map<string, Map<String, List<String>>>> getProductsByShelf(Id promoHeaderId, String magasinId){
        //get the shelves with their priority
        Map<String, String> shelvesPriorityMap = getShelvesByPriority();
		//put all the shelves into a List
        List<String> shelvesList = new List<String>();
        for(String key : shelvesPriorityMap.keySet()){
            shelvesList.add(shelvesPriorityMap.get(key));
        }
       // List<ProductCategoryProduct> prodCtgJct = [select ProductCategory.Name, Product.Name, ProductId,  Product.Code_rayon__c, ProductCategory.Code_categorie__c, Product.Code_IFLS__c, Product.Marque__c,  ProductCategory.Type_de_categorie__c from ProductCategoryProduct where ProductCategory.Type_de_categorie__c = 'RAYONS' and Product.Code_rayon__c != null and ProductCategory.Name IN :shelvesList];
        
        Set<String> codeRayonSet = new Set<String>();
        List<promotion__c> promoLineList;
        
        Magasin__c mag = [SELECT Id, Name FROM Magasin__c WHERE Id =:magasinId LIMIT 1];
        String magasinName = mag.Name;
     
        if (magasinName == 'Promocash') { //If magasin='Promocash' display promotion of LYON GERLAND
            promoLineList = [SELECT Id, Produit__r.Name, Produit__r.Code_rayon__c, Produit__r.Libelle_rayon__c, Produit__r.Code_IFLS__c, Produit__r.Marque__c, Name, Magasin__c, Magasin__r.Name, En_tete_Promotion__c , Type_de_promotion__c, Code_Produit__c, Libelle_promotion__c  FROM promotion__c WHERE Produit__r.Code_rayon__c != null and En_tete_Promotion__c = :promoHeaderId and Magasin__r.Name =: System.Label.MAGASIN_SELECTION_PROMO_AU_NATIONAL];  
        } else {      
            promoLineList = [SELECT Id, Produit__r.Name, Produit__r.Code_rayon__c, Produit__r.Libelle_rayon__c, Produit__r.Code_IFLS__c, Produit__r.Marque__c, Name, Magasin__c, Magasin__r.Name, En_tete_Promotion__c , Type_de_promotion__c, Code_Produit__c, Libelle_promotion__c  FROM promotion__c WHERE Produit__r.Code_rayon__c != null and En_tete_Promotion__c = :promoHeaderId and Magasin__c = :magasinId]; 
        }
   
        for (promotion__c promoLine : promoLineList) {
            codeRayonSet.add(promoLine.Produit__r.Code_rayon__c);
        }
      
        List<ProductCategory> prdCtgList = [SELECT Id, Name, Code_categorie__c, Type_de_categorie__c, ParentCategory.Code_categorie__c
                                            FROM ProductCategory 
                                            WHERE Code_categorie__c IN :codeRayonSet and Type_de_categorie__c = 'RAYONS'];
       
       	List<promotion__c> newPromoLineList = new List<promotion__c>();

        for(promotion__c promoLine : promoLineList){
            for(ProductCategory prdC : prdCtgList){
                if(promoLine.Produit__r.Code_rayon__c == prdC.Code_categorie__c){     //&& Integer.valueOf(promoLine.Code_rayon__c) == Integer.valueOf(prdC.ParentCategory.Code_categorie__c)
                    //if(prdC.Type_de_categorie__c == 'RAYONS'){
                        newPromoLineList.add(promoLine);
                    //}
                }
            }
        }

        Map <string, Map<string, Map<String, List<String>>>> shelfProductMap = new Map <string, Map<string, Map<String, List<String>>>>();

        for (String priority : shelvesPriorityMap.keySet()){
            shelfProductMap.put(priority, new Map<string, Map<String, List<String>>>{shelvesPriorityMap.get(priority) => new Map<String, List<String>>()});
        }
        
        for (promotion__c promoLine : newPromoLineList){
             for (String priority : shelfProductMap.keySet()){
                for (String categ : shelfProductMap.get(priority).keySet()){
                    if (promoLine.Produit__r.Libelle_rayon__c.toUpperCase() == categ.toUpperCase()){
                        Map<String, List<String>> existproducts = shelfProductMap.get(priority).get(categ);
                        existproducts.put(promoLine.Id, new List<String>{promoLine.Produit__r.Name, String.isBlank(promoLine.Produit__r.Code_rayon__c) ? '' : promoLine.Produit__r.Code_rayon__c, String.isBlank(promoLine.Produit__r.Marque__c) ? '' : promoLine.Produit__r.Marque__c, String.isBlank(promoLine.Produit__r.Code_IFLS__c) ? '' : promoLine.Produit__r.Code_IFLS__c});
                    }
                }
            }
        }
        // remove categories that don't have products
        shelfProductMap = removeCtgNoProductsFromMap(shelfProductMap);
        return shelfProductMap;
    } 
   
    private static Map <string, Map<string, Map<String, List<String>>>> removeCtgNoProductsFromMap(Map <string, Map<string, Map<String, List<String>>>> shelfProductMap){
             for(String priority : shelfProductMap.keySet()) {
                 for(String categ : shelfProductMap.get(priority).keySet()) {
                     if(shelfProductMap.get(priority).get(categ) == new Map<string,List<string>>{}) {
                         shelfProductMap.remove(priority);
                     }
                 }
             }   
        return shelfProductMap;
    }
  
    @AuraEnabled
    public static  Template_Promotion_Setting__mdt getPromotionSetByTemplate(String templateName){
        Template_Promotion_Setting__mdt tempPromo;
        
        try{
        	 tempPromo = (tplPromoMdt != null) ? tplPromoMdt : [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Multiple_de__c, Number_of_Promotions__c, Nb_Max_Promo_Shelf__c FROM Template_Promotion_Setting__mdt where Label = :templateName LIMIT 1];
    	}
        catch (Exception ex) {
            System.Debug('$$$$ Exception'+ex.getMessage());
        }
            return tempPromo;
    }
  
    @AuraEnabled
    public static SObject updateFieldSObject(Id recordId, String sObjectName, String qApiName, String value ){

        String apiName = [SELECT EntityDefinition.QualifiedApiName, QualifiedApiName
                            FROM FieldDefinition 
                            WHERE EntityDefinition.QualifiedApiName = :sObjectName AND QualifiedApiName = :qApiName].QualifiedApiName;
        
        String query = 'SELECT '+apiName+' FROM '+sObjectName+' WHERE Id =\''+recordId+'\' limit 1';
        
        // List<SObject> sObjectList = Database.query(String.escapeSingleQuotes(query));
        List<SObject> sObjectList = Database.query(query);
        
        // field type 
        //  String objectName = sObjectName;
        String fieldName = apiName;
        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        string fieldType = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
        
        if(fieldType == 'DATETIME'){
            Datetime dt = DateTime.ValueofGmt(value.replace('T', ' '));                 
            //convert local TZ of the user
            Integer offset = UserInfo.getTimezone().getOffset(dt);
            Datetime local = dt.addSeconds(offset/1000);
            sObjectList[0].put(apiName,local);
        }/*
        else if(fieldType == 'STRING' || fieldType == 'TEXTAREA'){
            sObjectList[0].put(apiName, value);
        }*/
        else if(fieldType == 'REFERENCE'){
            sObjectList[0].put(apiName, Id.valueOf(value));
        }
        else if(fieldType == 'BOOLEAN'){
            sObjectList[0].put(apiName,Boolean.valueOf(value));
        }
        else {
            sObjectList[0].put(apiName, value);
        }
        try {
            update sObjectList;
        } catch (DmlException e) {
            System.Debug('$$$$ DmlException'+e.getMessage());
        }      
    
        return sObjectList[0];
    }
 
    @AuraEnabled
    public static List<CampaignMember> updateCampMbrStatus(Id cmpId, List<Id> idsList, String memberType, String statusValue){
        List<CampaignMember> campaignMembers;
        if(memberType == 'Contact'){
            campaignMembers = [SELECT Id, Status, IsDeleted, CampaignId, LeadId, ContactId 
                              FROM CampaignMember where CampaignId = :cmpId and ContactId IN :idsList]; 
            
            for(CampaignMember cmpMbr : campaignMembers){
                cmpMbr.Status = statusValue;
            }
        }
        else if(memberType == 'Lead'){
            campaignMembers = [select Id, Status, IsDeleted, CampaignId, LeadId, ContactId 
                               from CampaignMember where CampaignId = :cmpId and LeadId IN :idsList]; 
            
            for(CampaignMember cmpMbr : campaignMembers){
                cmpMbr.Status = statusValue;
            }
        }

        try {
            update campaignMembers;
        } catch (DmlException e) {
            System.Debug('$$$$ DmlException'+e.getMessage());
        }   
        return campaignMembers;
    }
    
   @AuraEnabled
    public static CampaignMember addLeadTestToCampaign(Id cmpId, String userId){
        User u = [select id, FirstName, LastName, Email , CompanyName from User where id = :userId];

		Lead leadTest = new Lead(LastName = u.LastName, FirstName = u.FirstName, Company='CompanyTest',  Email = u.Email);
        insert leadTest;
        
        CampaignMember cmpMember = new CampaignMember(LeadId = leadTest.Id, CampaignId = cmpId);
        
        try {
             insert cmpMember;
        } catch (DmlException e) {
            System.Debug('$$$$ DmlException'+e.getMessage());
        }   
        
        return cmpMember;
    }
    
    @AuraEnabled(cacheable=true) 
    public static Campaign_Config__c getCampaignSettings(){
        return Campaign_Config__c.getOrgDefaults();
    }
    
}