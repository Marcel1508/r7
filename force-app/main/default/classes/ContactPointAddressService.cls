/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          28-05-2021           Ajay.Tiwari3 @ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
public without sharing class ContactPointAddressService {
    
    /**
    * @description filter the contact point adreess with is default address true and parent id not blank
    * @author Ajay.Kumar Tiwari | 05-31-2021 
    * @param newRecords 
    * @return List<ContactPointAddress> 
    **/
    public List<ContactPointAddress> checkIsDefaultAddress(List<ContactPointAddress> newRecords){
                List<ContactPointAddress> filteredContactPointAddress = new List<ContactPointAddress>();
        for (ContactPointAddress cpa : newRecords) {
            if(cpa.IsDefault && cpa.ParentId!=null){
                filteredContactPointAddress.add(cpa);
             }
         }
                        return filteredContactPointAddress;
    }

    
    /**
    * @description filter the contact point adreess with is default address true and parent id not blank and if someone change in the adreess data(like state,street,city)
    * @author Ajay.Kumar Tiwari | 05-31-2021 
    * @param newRecords 
    * @param oldRecordsMap 
    * @return List<ContactPointAddress> 
    **/
     /*public List<ContactPointAddress> checkIsDefaultAddress(List<ContactPointAddress> newRecords,Map<Id, ContactPointAddress> oldRecordsMap){
                 List<ContactPointAddress> filteredContactPointAddress = new List<ContactPointAddress>();
        for (ContactPointAddress cpa : newRecords) {
            //ContactPointAddress oldRecord = oldRecordsMap.get(cpa.Id);
           
           if (cpa.IsDefault && cpa.ParentId!=null ){
                
                filteredContactPointAddress.add(cpa);
            }
         }
                          return filteredContactPointAddress;
         
    } 
*/


  

    /**
    * @description check 
    * @author Ajay.Kumar Tiwari | 05-28-2021 
    * @param newRecords 
    * @return List<ContactPointAddress> 
    **/
   public List<ContactPointAddress> checkChannelData(List<ContactPointAddress> newRecords,Map<Id, ContactPointAddress> oldRecordsMap){
        List<ContactPointAddress> filteredContactPointAddress = new List<ContactPointAddress>();
       
        for (ContactPointAddress cpa : newRecords) {
            ContactPointAddress oldRecord = oldRecordsMap.get(cpa.Id);
           
           if ((cpa.Numero_de_voie__c != oldRecord.Numero_de_voie__c && String.isNotBlank(cpa.Numero_de_voie__c) )
               || (cpa.Type_de_voie__c != oldRecord.Type_de_voie__c && String.isNotBlank(cpa.Type_de_voie__c) )
               || (cpa.Nom_de_voie__c != oldRecord.Nom_de_voie__c && String.isNotBlank(cpa.Nom_de_voie__c) )){
                filteredContactPointAddress.add(cpa);
            }
         }
       
        return filteredContactPointAddress;
    }


   

    /**
    * @description  assign city and postal code with custom ville and postal code
    * @author Ajay.Kumar Tiwari | 06-21-2021 
    * @param contactPointAdresses 
    **/
    public void assignCityPostalCode(List<ContactPointAddress> contactPointAdresses){
        for(ContactPointAddress cpa : contactPointAdresses) {
           //added by ajay,If custom postal code have the value , then put the value in  standard PostalCode.
           if(String.isNotBlank(cpa.Code_postal__c)){
                cpa.PostalCode = cpa.Code_postal__c;
            }
            //added by ajay,If custom Ville commune have the value , then put the value in  standard city field.
            if(String.isNotBlank(cpa.Ville_commune__c)){
                cpa.City = cpa.Ville_commune__c;
            }       
         //added by ajay,If custom pays have the value , then put the value in  standard Country code field.
            if(String.isNotBlank(cpa.Pays__c)){
                cpa.CountryCode  = cpa.Pays__c;
            }
            
        }
    }

    

    /**
    * @description update the channel data and postal code and city 
    * @author Ajay.Kumar Tiwari | 05-28-2021 
    * @param contactPointAdresses 
    **/
    public void updateChannelData(List<ContactPointAddress> contactPointAdresses){
        
        for(ContactPointAddress cpa : contactPointAdresses) {
            
            if( String.isNotBlank(cpa.Numero_de_voie__c) || 
               	String.isNotBlank(cpa.Type_de_voie__c)   || 
               	String.isNotBlank(cpa.Nom_de_voie__c)
              ) {

				//FDI 28/09/2021 : Add to correct problem of lenght of street field                  
                if (cpa.Numero_de_voie__c == Null)
                {
                    cpa.Numero_de_voie__c ='';
                }
                    
                if (cpa.Type_de_voie__c == Null)
                {
                    cpa.Type_de_voie__c ='';
                }

                if (cpa.Nom_de_voie__c == Null)
                {
                    cpa.Nom_de_voie__c ='';
                }
                  
				cpa.Street = cpa.Numero_de_voie__c + ' '+ cpa.Type_de_voie__c + ' ' + cpa.Nom_de_voie__c;
				//FDI 28/09/2021 : End  
                
/* FDI 28/09/2021 : Old Code                
                if(String.isNotBlank(cpa.Numero_de_voie__c))
                    cpa.Street = cpa.Numero_de_voie__c;
                
                if(String.isNotBlank(cpa.Type_de_voie__c))
                    cpa.Street += ' ' + cpa.Type_de_voie__c;
                
                if(String.isNotBlank(cpa.Nom_de_voie__c))
                    cpa.Street += ' ' + cpa.Nom_de_voie__c;
*/                
            }

            //added by ajay,If custom postal code have the value , then put the value in  standard PostalCode.
	        if(String.isNotBlank(cpa.Code_postal__c)){
                cpa.PostalCode = cpa.Code_postal__c;
            }
            //added by ajay,If custom Ville commune have the value , then put the value in  standard city field.
            if(String.isNotBlank(cpa.Ville_commune__c)){
                cpa.City = cpa.Ville_commune__c;
            }  
        }
    }

    /**
    * @description update Account billing and shipping address with contact point address
    * @author Ajay.Kumar Tiwari | 05-31-2021 
    * @param contactPointAdresses 
    **/
    public void updateAccountAddress(List<ContactPointAddress> contactPointAdresses){
                                List<Account> updateAccounts=new List<Account>();
        Map<Id, Account> accountbyId = new Map<Id, Account>();
        
        for(ContactPointAddress cpa : contactPointAdresses) {  
            Account acc = new Account(); 
            acc = accountbyId.get(cpa.ParentId) != null? accountbyId.get(cpa.ParentId): new Account();
            
            if(cpa.AddressType=='Shipping'){
                                acc.Id=cpa.ParentId;
                acc.ShippingStreet=cpa.Street;// street
                acc.ShippingCity=cpa.City;//city
                acc.ShippingPostalCode=cpa.PostalCode;//postalcode
                acc.ShippingCountryCode=cpa.CountryCode;//country
                acc.NPAI_livraison__c=cpa.N_habite_pas_ladresse_indiquee__c;
                
                //updateAccounts.add(acc);
                accountbyId.put(acc.Id, acc);
            }else if(cpa.AddressType=='Billing'){
                acc.Id=cpa.ParentId;
                acc.BillingStreet=cpa.Street;// street
                acc.BillingCity=cpa.City;//city
                acc.BillingPostalCode=cpa.PostalCode;//postalcode
                acc.BillingCountryCode=cpa.CountryCode;//country
                acc.NPAI_facturation__c=cpa.N_habite_pas_ladresse_indiquee__c;
                
                accountbyId.put(acc.Id, acc);
                //updateAccounts.add(acc);
            }
            
        }
		        //if(!updateAccounts.isEmpty()){
        if(!accountbyId.values().isEmpty()){
                                    //update  updateAccounts;
            update accountbyId.values();
        }
    }

    public void validateContactPointAddress(List<ContactPointAddress> contactPointAdresses){
        set<Id> setParentId=new set<Id>();
        user guestUser=new user();
        user dataIntegrationUser=new user();
        guestUser=[Select id,name,Profile.Name  from user where name='Promocash Site Guest User' limit 1];
        dataIntegrationUser=[Select id,name from user where name='Data Integration' limit 1];


        for(ContactPointAddress cpa : contactPointAdresses) {  
            if(cpa.parentId!=null){
                setParentId.add(cpa.parentId);
                }
            
                        
            }
            Map<String,ContactPointAddress> mapAccIdVsContactPointAddress= mapaccountwithAddressType(setParentId);
            
            for(ContactPointAddress cpa : contactPointAdresses){
              //  String createdId= cpa.CreatedById!=null ? cpa.CreatedById :  System.UserInfo.getUserId();
                String createdId=  System.UserInfo.getUserId();
                
                                
                if(cpa.parentId!=null && String.isNotBlank(cpa.AddressType) && !cpa.IsDefault && createdId!=guestUser.Id && createdId!=dataIntegrationUser.Id){
                    String accIdAdressTypeKey = buildCompositeKey(cpa.ParentId, cpa.AddressType);
                    if(!mapAccIdVsContactPointAddress.containsKey(accIdAdressTypeKey) || (mapAccIdVsContactPointAddress.containsKey(accIdAdressTypeKey) && mapAccIdVsContactPointAddress.get(accIdAdressTypeKey).Id==cpa.Id )){
                        cpa.addError('Can not insert/update contact point address.You have to  make is default address true ');  
                    }
                }
            }
    }
    
   /* public void validateBeforeDeleteContactPointAddress(List<ContactPointAddress> contactPointAdresses){
            for(ContactPointAddress cpa : contactPointAdresses){   
                
                if(cpa.IsDefault){
                    cpa.addError('Can not delete contact point address.You have to  make is default address false');       
                }
            }
    }*/


    public  Map<String,ContactPointAddress> mapaccountwithAddressType(set<Id> accountId){
        
        Map<String,ContactPointAddress> mapAccIdVsContactPointAddress=new Map<String,ContactPointAddress>();
        List<ContactPointAddress> contactPointAdresses=new List<ContactPointAddress>();
        contactPointAdresses=[select id,name, IsDefault,AddressType,ParentId 
                                from ContactPointAddress
                                where IsDefault = true
                                and ParentId in : accountId ];

        for(ContactPointAddress cpa : contactPointAdresses){
            if(String.isNotBlank(cpa.AddressType)){
                String accIdAdressTypeKey = buildCompositeKey(cpa.ParentId, cpa.AddressType);
                mapAccIdVsContactPointAddress.put(accIdAdressTypeKey, cpa);
                }
        }
        
                
        return mapAccIdVsContactPointAddress;
    }

    public  string buildCompositeKey(String accountId, String addressType){
        String compositeKey = accountId+addressType;
        return compositeKey;
    }

    public void updateExternalId(List<ContactPointAddress> contactPointAdresses){
        set<id> setOfId  = new set<id>(); 
        List<ContactPointAddress> contactPointAddressToUpdate = new List<ContactPointAddress>();
       
        for(ContactPointAddress objCpa : contactPointAdresses) {
            if(objCpa.ParentId != null) {
                setOfId.add(objCpa.ParentId );
            }
        }

        Integer i=0;
        List<Account> accountsList = [SELECT ID, Numero_Client__c, (SELECT Id, Name, IsDefault, AddressType, ParentId, ExternalID__c FROM ContactPointAddresses) FROM ACCOUNT WHERE ID IN :setOfId];
        for(Account acc: accountsList) {
            for(ContactPointAddress objCpa : acc.ContactPointAddresses) {
                if(String.isNotBlank(acc.Numero_Client__c) && String.isNotBlank(objCpa.AddressType)) { 
                    String isDefaultVal = objCpa.IsDefault? 'true':'false';
                    if(objCpa.IsDefault){
                        objCpa.ExternalID__c = acc.Numero_Client__c+'_'+objCpa.AddressType+'_'+isDefaultVal;
                    } else{
                        objCpa.ExternalID__c = acc.Numero_Client__c+'_'+objCpa.AddressType+'_'+isDefaultVal+'_'+i;
                        i++;
                    }
                    
                } else{
                    objCpa.ExternalID__c='';
                }
                contactPointAddressToUpdate.add(objCpa);     
            }
        }

        if(!contactPointAddressToUpdate.isEmpty()) {
            update contactPointAddressToUpdate;
        }
    }
    
    //S.A 02/08/2021 
    //Create Shipping/Billing address by default when create Shipping/Billing manually by user
    public void createShippingOrBillingAddressByDefault(List<ContactPointAddress> newRecords){
        //Edit By Marouane, Check if the current user is a guest user we exit the method
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Name from Profile where Id = :profileId limit 1].Name;
        if(profileName.containsIgnoreCase('Guest') && !Test.isRunningTest())
            return;
                        //Retrieve ParentId
        Set<String> cpaParentID = new Set<String>();
        List<ContactPointAddress> cpaToCreate = new List<ContactPointAddress>();
  		Map<Id, Integer> cpaCountMap = new Map<Id, Integer>();
        Set<Id> cpaParentIds = Pluck.ids(ContactPointAddress.ParentId, newRecords);
        AggregateResult[] cpaCountByAccounts = [SELECT ParentId, COUNT(Id) cpaCount
                                                FROM ContactPointAddress WHERE ParentId IN: cpaParentIds GROUP BY ParentId];
        for(AggregateResult cpaCountByAccount : cpaCountByAccounts) {
            cpaCountMap.put((ID)cpaCountByAccount.get('ParentId'), (Integer)cpaCountByAccount.get('cpaCount'));
        }
        for(ContactPointAddress cpa : newRecords){
            if(cpaCountMap.get(cpa.ParentId) <= 1){
                 ContactPointAddress cpaToInsert = new ContactPointAddress();
                 if(cpa.AddressType == 'Billing'){
                    cpaToInsert.AddressType = 'Shipping';
                    cpaToInsert.Name = 'Adresse d\'expédition';
                } else if(cpa.AddressType == 'Shipping'){
                    cpaToInsert.AddressType = 'Billing';
                    cpaToInsert.Name = 'Adresse de Facturation';
                }  if(cpa.Nom_de_voie__c != null){
                    cpaToInsert.Nom_de_voie__c = cpa.Nom_de_voie__c;
                }
                
                if(cpa.ParentId != null){
                    cpaToInsert.ParentId = cpa.ParentId;
                }
                cpaToInsert.IsDefault = True;
                if(cpa.Numero_de_voie__c != null){
                    cpaToInsert.Numero_de_voie__c = cpa.Numero_de_voie__c;
                }
                
                if(cpa.Type_de_voie__c != null){
                    cpaToInsert.Type_de_voie__c = cpa.Type_de_voie__c;
                }
                
                if(cpa.Complement_d_adresse__c != null){
                    cpaToInsert.Complement_d_adresse__c = cpa.Complement_d_adresse__c;
                }
                
                if(cpa.Codes_Postaux__c != null){
                    cpaToInsert.Codes_Postaux__c = cpa.Codes_Postaux__c;
                }
                
                if(cpa.ExternalID__c != null){
                  //  cpaToInsert.ExternalID__c = cpa.ExternalID__c;
                }
                
                if(cpa.N_habite_pas_ladresse_indiquee__c != null){
                    cpaToInsert.N_habite_pas_ladresse_indiquee__c = cpa.N_habite_pas_ladresse_indiquee__c;
                }
                
               if(String.isNotBlank(cpa.Code_postal__c)){
                    cpaToInsert.PostalCode = cpa.Code_postal__c;
                }
                
                if(String.isNotBlank(cpa.Ville_commune__c)){
                    cpaToInsert.City = cpa.Ville_commune__c;
                }       
                
                if(String.isNotBlank(cpa.Pays__c)){
                    cpaToInsert.CountryCode  = cpa.Pays__c;
                    cpaToInsert.Pays__c  = cpa.Pays__c;
                }
                
                if(String.isNotBlank(cpa.Numero_de_voie__c) || String.isNotBlank(cpa.Type_de_voie__c) || String.isNotBlank(cpa.Nom_de_voie__c)) {
                    if(String.isNotBlank(cpa.Numero_de_voie__c))
                        cpaToInsert.Street = cpa.Numero_de_voie__c;
                    
                    if(String.isNotBlank(cpa.Type_de_voie__c))
                        cpaToInsert.Street += ' ' + cpa.Type_de_voie__c;
                    
                    if(String.isNotBlank(cpa.Nom_de_voie__c))
                        cpaToInsert.Street += ' ' + cpa.Nom_de_voie__c;
                }
                 cpaToCreate.add(cpaToInsert);
            }
        }
                insert cpaToCreate;
        updateExternalId(cpaToCreate);
        updateAccountAddress(cpaToCreate);
        
    }
}