/**
 * @description       : 
 * @author            : Ajay.Kumar Tiwari
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : Ajay.Kumar Tiwari
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   05-28-2021   Ajay.Kumar Tiwari   Initial Version
**/
public without sharing class ContactPointAddressTriggerHandler {
    private final List<ContactPointAddress> newRecords;
    private final Map<Id, ContactPointAddress> oldRecords;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    private static ContactPointAddressService service = new ContactPointAddressService();
    
    private final String User_Name = UserInfo.getName(); //FDI 19/07/2021 : Get Current user

    public ContactPointAddressTriggerHandler(List<ContactPointAddress> newRecords, Map<Id, ContactPointAddress> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
    }
    
    public void beforeInsertMethod() {
        if (bypassTrigger) { return; }
        

        //sync Numéro de voie,Type de voie,and Nom de voie with street name
        service.updateChannelData(newRecords);

        // sync ville , postal code  and pays
        service.assignCityPostalCode(newRecords);
        // validate contacat point address
        service.validateContactPointAddress(newRecords); 
        
    }
    
    public void beforeUpdate() {
        if (bypassTrigger) { return; }
        
            List<ContactPointAddress> cpaToCheckChannelData = service.checkChannelData(newRecords,oldRecords);
        
            if (!cpaToCheckChannelData.isEmpty()) {
                //added by ajay,sync Numéro de voie,Type de voie,and Nom de voie with street name
                service.updateChannelData(cpaToCheckChannelData);   
            }
            
            // sync ville ,postal code and pays 
            service.assignCityPostalCode(newRecords);
        
            // validate contacat point address
            service.validateContactPointAddress(newRecords);     
        
    }

    public void beforeDelete() {
        if (bypassTrigger) { return; }
        // added by ajya validate contacat point address
      //  service.validateBeforeDeleteContactPointAddress(oldRecords.values());   
        
    }

    public void afterInsertMethod() {
        if (bypassTrigger) { return; }
        if(firstRun){
            firstRun=false;
            set<id> setOfId  = new set<id>();
        
            List<ContactPointAddress> filtredRecords = new List<ContactPointAddress>();
            for(ContactPointAddress addressRecord : newRecords) {
                if(!AddressCheckRecursive.recordIdMap.contains(addressRecord.Id)) { // Check if the record has already been processed
                    AddressCheckRecursive.recordIdMap.add(addressRecord.Id);
                    filtredRecords.add(addressRecord);
                    if(addressRecord.ParentId != null) {
                        setOfId.add(addressRecord.ParentId );
                    }
                }
            }
                            
            //FDI 19/07 : We execute this method if the current user is different than "Data Integration"
            if (User_Name != 'Data Integration')
            {
                /*System.debug('data send from CPA insert------>');
                AccountResultsToApigee_SVC.getAccounts('AInsert', getParentAccounts(setOfId));*/    
                
                            //S.A 02/08/2021 
                //Create Shipping or Billing address by default
                service.createShippingOrBillingAddressByDefault(filtredRecords);
            }
            
            if(!setOfId.isEmpty()) {//todo: you can use setOfId.isEmpty() instead
                countDefaultAddresses(setOfId);
            }
            //added by Ajay,for update account address **start**
            List<ContactPointAddress> isDefaultContactPointAddress = service.checkIsDefaultAddress(filtredRecords);   
            if (!isDefaultContactPointAddress.isEmpty()) {
                
                            service.updateAccountAddress(isDefaultContactPointAddress);    
            }
            //added by Ajay,for update account address **end**
            service.updateExternalId(filtredRecords);  
            
        }
        
    }
    
    public void afterDeleteMethod() {
        if (bypassTrigger) { return; }
        set<id> setOfId = new set<id>();
        for(ContactPointAddress objChildNew : oldRecords.values()) {
            if(objChildNew.ParentId != null) {
                setOfId.add(objChildNew.ParentId);
                            }
        }
        if(!setOfId.isEmpty()) {//todo: you can use setOfId.isEmpty() instead
            countDefaultAddresses(setOfId);
        }
    }
    
    public void afterUpdateMethod()
    {
                if (bypassTrigger) { return; }

                if(firstRun){
                    firstRun=false; 
                    List<ContactPointAddress> filtredRecords = new List<ContactPointAddress>();
                    for(ContactPointAddress addressRecord : newRecords) {
                        if(!AddressCheckRecursive.recordIdMap.contains(addressRecord.Id)) { // Check if the record has already been processed
                            AddressCheckRecursive.recordIdMap.add(addressRecord.Id);
                            filtredRecords.add(addressRecord);
                        }
                    }
                    set<id> setOfId = new set<id>();
                    set<id> parentId = new set<id>();
                            for(ContactPointAddress childObj : filtredRecords)
                    {
                        parentId.add(childObj.ParentId);
                        if((childObj.ParentId != null && oldRecords.get(childObj.id).ParentId != null && childObj.ParentId != oldRecords.get(childObj.id).ParentId )
                           ||( childObj.ParentId != null && childObj.IsDefault != oldRecords.get(childObj.id).IsDefault ) ) //todo: add check for change of childObj.AddressType
                        { 
                                            setOfId.add(childObj.ParentId);
                            setOfId.add(oldRecords.get(childObj.id).ParentId);
                        }
                    }
                    
                    //FDI 19/07 : We execute this method if the current user is different than "Data Integration"
                  /*  if (User_Name != 'Data Integration' && !parentId.isEmpty())
                    {
                        System.debug('data send from CPA--update---->');
                        AccountResultsToApigee_SVC.getAccounts('AInsert', getParentAccounts(parentId));
                    }*/
                            if(!setOfId.isEmpty()) //todo: you can use setOfId.isEmpty() instead
                    {
                        countDefaultAddresses(setOfId);
                    }
                    
                    //added by Ajay,for update account address **start**
                    List<ContactPointAddress> isDefaultContactPointAddress = service.checkIsDefaultAddress(filtredRecords);
                    if (!isDefaultContactPointAddress.isEmpty()) {
                        
                                    service.updateAccountAddress(isDefaultContactPointAddress);    
                    } 
                    //added by Ajay,for update account address **end**
                    
                    service.updateExternalId(filtredRecords);
                    
                }
       
    }
    
    List<Account> getParentAccounts(Set<Id> accIds) {
        return [SELECT Statut_Fiche_client__c, Numero_Client__c, Code_etablissement__c, Forme_juridique__c, Name, Numero_Siret__c, Enseigne_commerciale__c,
                Code_APE__c, Specialisation__c, Theme__c, Libell_code_APE__c, Email__c, Piece_identite__c, Categorie__c, Attestation_registre_du_commerce__c,
                Origine__c, Telephone_Siret__c, K_bis__c, RIB__c, Chaine_bloquee__c, Code_Externe_Chaine_Text__c, NPAI_livraison__c, NPAI_facturation__c, Code_Chaine__c,
                Libelle_Chaine_nationale__c, ifAccountSentToAkeneo__c FROM Account WHERE Id =: accIds];
    }
    
    private static void countDefaultAddresses(set<id> setOfId) {
                try {
            List<Account> accountsToUpdate = new List<Account>();
            List<Account> loadedAccounts = new list<Account>([select id,name, CountDefaultExpeditionAddresses__c, CountDefaultFacturationAddresses__c, (select id,name, IsDefault,AddressType,ParentId from ContactPointAddresses 
                                                                                                                                                        where IsDefault = true and (AddressType = 'Shipping' OR AddressType = 'Billing')) 
                                                              from Account where id IN:setOfId]);
            
            for(Account account: loadedAccounts) {
                Integer shippingAddressCount = 0;
                Integer billingAddressCount = 0;
                for(ContactPointAddress cpa: account.ContactPointAddresses) {
                    if(cpa.addressType == 'Shipping') {
                        shippingAddressCount++;
                    } else if(cpa.addressType == 'Billing') {
                        billingAddressCount++;
                    }
                }
                if(shippingAddressCount != account.CountDefaultExpeditionAddresses__c || billingAddressCount != account.CountDefaultFacturationAddresses__c) {
                    account.CountDefaultExpeditionAddresses__c = shippingAddressCount;
                    account.CountDefaultFacturationAddresses__c = billingAddressCount;
                    accountsToUpdate.add(account);
                }
            }
            
            if(!accountsToUpdate.isEmpty())
                update accountsToUpdate;
        }
        catch(DmlException e) {}  
    }
}