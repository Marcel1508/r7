public without sharing class ContactTriggerHandler {
    private final List<Contact> newRecords;
    private final Map<Id, Contact> oldRecords;
    private final Map<Id, Contact> newRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    
    private final String User_Name = UserInfo.getName(); //FDI 19/07/2021 : Get Current user
    
    public ContactTriggerHandler(List<Contact> newRecords, Map<Id, Contact> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
    }
    
    public void afterInsert() {
        if (bypassTrigger) { return; }
        Map<Id, Account> accountsMap = getAccountMap();
        sendAccount(accountsMap);
        checkContactPrincipalAfterInsert(accountsMap);
    }
    public void afterUpdate() {
        if (bypassTrigger) { return; }
        Map<Id, Account> accountsMap = getAccountMap();
        sendAccount(accountsMap);
        checkContactPrincipaleAfterUpdate(accountsMap);
    }
    
    public void beforeInsert() {
        if (bypassTrigger) { return; }
        if(firstRun) {
            checkContactPrincipaleBeforeInsert();
            firstRun = false;
        }
        formatContactPhoneBeforeInsert();

    }
    public void beforeUpdate() {
        if (bypassTrigger) { return; }
        if(firstRun) {
            checkContactPrincipaleBeforUpdate();
            firstRun = false;
        }
        formatContactPhoneBeforeUpdate();
    }
    private void formatContactPhoneBeforeUpdate() {
        List<Contact> contactsWithPhone = new List<Contact>();
        for(Contact ctc : this.newRecords) {
            if(ctc.Telephone_portable__c != this.oldRecords.get(ctc.Id).Telephone_portable__c && String.isNotBlank(ctc.Telephone_portable__c)) {
                contactsWithPhone.add(ctc);
            }
        }
        Utilities.formatContactPhone(contactsWithPhone);
    }
    private void formatContactPhoneBeforeInsert() {
        List<Contact> contactsWithPhone = new List<Contact>();
        for(Contact ctc : this.newRecords) {
            if(String.isNotBlank(ctc.Telephone_portable__c)) {
                contactsWithPhone.add(ctc);
            }
        }
        Utilities.formatContactPhone(contactsWithPhone);
    }
    private void checkContactPrincipalAfterInsert(Map<Id,Account> accountsList) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c: this.newRecords) {
            Account a = accountsList.get(c.accountId);
            List<Contact> accountContacts = a.Contacts;
            List<Contact> tempAccountList = new List<Contact>();
            
            if(c.Contact_principal__c) { //New created contact is principal, we need to uncheck other contacts
                for(Contact ac: accountContacts) {
                    if(ac.Id != c.Id && ac.Contact_principal__c) {
                        Contact loadedCon = ac;
                        loadedCon.Contact_principal__c = false;
                        contactsToUpdate.add(loadedCon);
                    }
                }
            }
        }
        if(!contactsToUpdate.isEmpty())
            update contactsToUpdate;
    }
    
    private void checkContactPrincipaleBeforeInsert() {
        //List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id, Account> accountsList = getAccountMap();
        
        for(Contact c: this.newRecords) {
            Account a = accountsList.get(c.accountId);
            if(a != null) {
                List<Contact> accountContacts = a.Contacts;
                if(accountContacts.isEmpty()) { // Account doesn't have any contact, we need to make sure the first created contact is principal
                    c.Contact_principal__c = true;
                } 
            }
        }
        //if(!contactsToUpdate.isEmpty())
            //update contactsToUpdate;
    }
    
    private void checkContactPrincipaleBeforUpdate() {
        String errorMessage = Label.errorMessage;
        Map<Id, Account> accountsList = getAccountMap();
        
        for(Contact c: this.newRecords) {
            if(c.Contact_principal__c != this.oldRecords.get(c.Id).Contact_principal__c && !c.Contact_principal__c) { //Checkbox value has changed
                Account a = accountsList.get(c.accountId);
                List<Contact> accountContacts = a.Contacts;
                
                if(!accountContacts.isEmpty()) {
                    List<Contact> otherContactsPrincipal = new List<Contact>();
                    for(Contact ac: accountContacts) {
                        if(ac.Id != c.Id && ac.Contact_principal__c) // We need to exclude the current contact from the list
                            otherContactsPrincipal.add(ac);
                    }
                                        if(otherContactsPrincipal.isEmpty())
                        c.addError(errorMessage);
                }
            }
        }
    }
    
    public void checkContactPrincipaleAfterUpdate(Map<Id,Account> accountsList) {
                
        List<Contact> contactsToUpdate = new List<Contact>();
        String errorMessage = 'Vous ne pouvez pas décocher la case "Contact Princpal"';
        for(Contact c: this.newRecords) {
            if(c.Contact_principal__c != this.oldRecords.get(c.Id).Contact_principal__c && c.Contact_principal__c) { //Checkbox value has changed
                Account a = accountsList.get(c.accountId);
                if(a != null) {
                    List<Contact> accountContacts = a.Contacts;
                    List<Contact> otherContactsPrincipal = new List<Contact>();
                    
                                        
                    if(!accountContacts.isEmpty()) {
                        if(c.Contact_principal__c) {
                            for(Contact ac: accountContacts) {
                                if(ac.Id != c.Id) // We need to exclude the current contact from the list
                                    otherContactsPrincipal.add(ac);
                            }
                            for(Contact oc: otherContactsPrincipal) {
                                oc.Contact_principal__c = false;
                                contactsToUpdate.add(oc);
                            }
                        }
                    }
                }
            }
        }
        if(!contactsToUpdate.isEmpty())
            update contactsToUpdate;
    }
    
    private void sendAccount(Map<Id,Account> accountMap) {
        List<Account> accountsList = new List<Account>();
        
        for(Contact c: this.newRecords) {
            if(c.Roles__c != null && c.Roles__c.contains('Propriétaire')) {
                accountsList.add(accountMap.get(c.accountId));
            }
        }
                                               
        //FDI 19/07 : We execute this method if the current user is different than "Data Integration"
        if (User_Name != 'Data Integration')
        {        
        	AccountResultsToApigee_SVC.getAccounts('AInsert', accountsList);
        }
    }
    
    private Map<Id,Account> getAccountMap(){
       
         List<Id> accIds = new List<Id>();
        
        for(Contact c: this.newRecords) {
           accIds.add(c.accountId);
            
        }
        Map<Id,Account> accountsMap = new Map<Id,Account>([SELECT Id, Statut_Fiche_client__c, Numero_Client__c, Code_etablissement__c, Forme_juridique__c, Name, Numero_Siret__c, Enseigne_commerciale__c,
                                      Code_APE__c, Specialisation__c, Theme__c, Libell_code_APE__c, Email__c, Piece_identite__c, Categorie__c, Attestation_registre_du_commerce__c,
                                      Origine__c, Telephone_Siret__c, K_bis__c, RIB__c, Chaine_bloquee__c, Code_Externe_Chaine_Text__c, NPAI_livraison__c, NPAI_facturation__c, Code_Chaine__c,
                                      Libelle_Chaine_nationale__c, ifAccountSentToAkeneo__c,(SELECT ID, name, Contact_principal__c FROM Contacts) FROM Account WHERE Id =: accIds]);
        
        return accountsMap;
    }
    
   
}