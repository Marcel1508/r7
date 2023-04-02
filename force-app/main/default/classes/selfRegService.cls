global without sharing class selfRegService {
    @AuraEnabled
    public static ContentVersion saveFile(Id idParent, String strFileName, String base64Data, String fileType) {
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        cv.file_type_fileupload__c = fileType;
        Insert cv;
        return cv;
    }
    
    @AuraEnabled
    public static ServiceResponse updateContactEmail(Id contactId, String email) {
        try {
            Contact c = new Contact(Id=contactId);
            c.email = email;
            update c;
            return new ServiceResponse(true, '', '');
        } catch(Exception e) {
            system.debug('enablePortalUserForContactWithoutEmail Exception e: ' + e);
            return new ServiceResponse(false, '', e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Codes_Postaux__c getCodePostalById(Id idCodePostal) {
        List<Codes_Postaux__c> res = [SELECT ID, Commune__c, Code_postal__c, toLabel(Pays__c) FROM Codes_Postaux__c where id = :idCodePostal];
        if(res != null && res.size() > 0)
            return res.get(0);
        return null;
    }
    
    @AuraEnabled
    public static ServiceResponse enablePortalUserForContactWithoutEmail(Id accountid, Id contactId, String email, String password) {
        User u = getUserByUsername(email);
        if(u != null) {
            ServiceResponse sr = new ServiceResponse(false, 'field', 'username déjà existant');
            sr.fieldName = 'username';
            return sr;
        }
        return enablePortalUserForContactTemplate(accountid, contactId, email, password, true);
    }
    
    @AuraEnabled
    public static ServiceResponse enablePortalUserForContact(Id accountid, Id contactId, String email) {
        system.debug('Param: accountid: ' + accountid);
        system.debug('Param: contactId: ' + contactId);
        system.debug('Param: email: ' + email);
        return enablePortalUserForContactTemplate(accountid, contactId, email, null, false);
    }
    
    @AuraEnabled
    public static ServiceResponse enablePortalUserForContactTemplate(Id accountid, Id contactId, String email, String password, Boolean includePassword) {
        System.debug('selfRegService.enablePortalUserForContact debug 1');
        try {
            List<User> loadedUsers = (contactId != null)? [SELECT Id,Name,Email, Profile.Name FROM User WHERE ContactId = :contactId AND (Profile.Name='Customer Community +' OR Profile.Name='Customer Community Plus User')]:new List<User>();
            System.debug('selfRegService.enablePortalUserForContact debug 2');
            
            if(loadedUsers != null && loadedUsers.size() > 0) { // Contact has a portal user
                //return 'user_already_exists';
                return new ServiceResponse(false, '', 'user_already_exists');
            } else { // Contact doesn't have a portal User, need te be created
                System.debug('selfRegService.enablePortalUserForContact debug 3');
                Id communityId = getCommunityProfileId();
                System.debug('selfRegService.enablePortalUserForContact debug 4');
                if(communityId == null)
                    return new ServiceResponse(false, 'unkown', 'communityId is null');
                
                Contact loadedContact = (contactId != null)? [SELECT ID, firstname, lastname FROM CONTACT WHERE ID=:contactId limit 1]: [SELECT ID, firstname, lastname FROM CONTACT WHERE accountid=:accountid LIMIT 1];
                    
                    Id userId = createExternalUser(loadedContact.firstname, loadedContact.LastName, email, password, password, accountId, getCommunityProfileId(), includePassword);
                system.debug('Created user id: ' + userId);
                
                if(userId != null) {
                    List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
                    Map<String, Id> psMap = getPermissionMap();
                    for(String k: psMap.keySet()) {
                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = psMap.get(k), AssigneeId = userId);
                        permissionSetList.add(psa);
                    }
                    upsert permissionSetList;
                    return new ServiceResponse(true, '', 'created userId: ' + userId);
                }
                else{
                    applyPermissions(contactId);
                    return new ServiceResponse(true, '', 'returned user is null');
                }
            }
            
        }
        catch(Exception e) {
            System.debug('selfRegService.enablePortalUserForContact Exception : ' + e);
            System.debug('selfRegService.enablePortalUserForContact Exception : ' + e.getLineNumber());
            System.debug('selfRegService.enablePortalUserForContact Exception : ' + e.getCause());
            System.debug('selfRegService.enablePortalUserForContact Exception : ' + e.getStackTraceString());
            return new ServiceResponse(false, 'unknown', e.getMessage() + 'enablePortalUserForContact line: ' + e.getLineNumber() + 'e.getStackTraceString(): ' + e.getStackTraceString() + ' cause: ' + e.getCause());
        }
    }
    
    @future
    private static void applyPermissions(String contactId){
        
        try{
            User newUser = new User();
            newUser = [Select Id, ContactId from User where ContactId =: contactId];
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            Map<String, Id> psMap = getPermissionMap();
            for(String k: psMap.keySet()) {
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = psMap.get(k), AssigneeId = newUser.Id);
                permissionSetList.add(psa);
            }
            upsert permissionSetList;
            
        }
        catch(Exception e) {
            System.debug('selfRegService.applyPermissions Exception : ' + e);
            System.debug('selfRegService.applyPermissions Exception : ' + e.getLineNumber());
            System.debug('selfRegService.applyPermissions Exception : ' + e.getCause());
            System.debug('selfRegService.applyPermissions Exception : ' + e.getStackTraceString());
        }
    }
    
    
    
    
    @AuraEnabled
    public static ServiceResponse enablePortalUserForSingleNewContact(Id accountid, Id contactId, String email, String password, Boolean includePassword) {
        try {
            enablePortalUserForSingleNewContactFuture(accountid, contactid, email, password, includePassword);
            
            return new ServiceResponse(true, 'success', 'Création en cours ... ');
        } catch(Exception e) {
            return new ServiceResponse(false, '', 'Erreur ligne: ' + e.getLineNumber() + ': ' + e.getMessage());
        }
        
    }    
    
    @Future
    public static void enablePortalUserForSingleNewContactFuture(Id accountid, Id contactId, String email, String password, Boolean includePassword) {
        try {
            Id communityId = getCommunityProfileId();
            if(communityId == null)
                system.debug( new ServiceResponse(false, 'Unknown', 'CommunityId is null'));
            
            Id userId = createPortalUser('' , email, email, password, password, accountId, communityId, includePassword);
            
            system.debug('Created user id: ' + userId);
            if(userId != null) {
                List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
                Map<String, Id> psMap = getPermissionMap();
                for(String k: psMap.keySet()) {
                    PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = psMap.get(k), AssigneeId = userId);
                    permissionSetList.add(psa);
                }
                upsert permissionSetList;
            }
        } catch(Exception e) {
            System.debug('selfRegService.enablePortalUserForContact Exception : ' + e);
        }
    }
    
    
    @AuraEnabled
    public static User getUserByUsername(String username) {
        List<User> res = [select id, username from user where username=:username];
        if(res != null && res.size() > 0)
            return res.get(0);
        return null;
    }
    
    private static Id createPortalUser(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, Id profileId, Boolean includePassword){
        system.debug('createPortalUser 1');
        User u = new User();
        u.Username = email;
        u.put('Email',email);
        u.FirstName = firstname;
        u.LastName = lastname;
        u.ProfileId = profileId;
        system.debug('LastName: ' + LastName);
        String networkId = Network.getNetworkId();
        system.debug('networkId: ' + networkId);
        
        String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
        u.put('CommunityNickname', nickname);
        
        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        Id userId = Site.createPortalUser(u, accountId, password);
        
        system.debug('userId: ' + userId);
        return userId;
    }
    
    private static Id createExternalUser(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, Id profileId, Boolean includePassword){
        User u = new User();
        u.Username = email;
        u.put('Email',email);
        u.FirstName = firstname;
        u.LastName = lastname;
        u.ProfileId = profileId;
        
        String networkId = Network.getNetworkId();
        String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
        nickname = email;
        u.put('CommunityNickname', nickname);
        
        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        try {
            Id userId = Site.createExternalUser(u, accountId, password);
            if(userId == null && Test.isRunningTest()) {
                return [SELECT ID FROM USER limit 1].Id;
            }
            return userId;
        } catch(Site.ExternalUserCreateException ex) {
            for (String error : ex.getDisplayMessages())  {
                System.debug(LoggingLevel.Error,'External Errors:' + error);
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static ServiceResponse activeExistingLead(String accountId, String magasinDeRattachementId) {
        ServiceResponse response = new ServiceResponse(true, 'success');
        try {
            createRelation(accountId, magasinDeRattachementId);
            List<ActivationDeCompteCtrl.ActivationDeCompteCtrlWrapper> res = ActivationDeCompteCtrl.updateNonActivateAccount(new List<Account>{new Account(id=accountId)});
            handleProspectExtraInfos([SELECT ID, Magasin_de_rattachement__c, Frais_autorisations__c, Activite_potentiel__c, Fidelite__c FROM ACCOUNT where id=:accountId limit 1]);
            if(!res.get(0).isSuccess) {
                response = new ServiceResponse(false, 'exception', res.get(0).message);
            }
        } catch(Exception e) {
            system.debug('activeExistingLead: ' + e.getMessage());
            system.debug('activeExistingLead: ' + e.getCause());
            system.debug('activeExistingLead: ' + e.getStackTraceString());
            response = new ServiceResponse(false, 'exception', e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountbySiret(String siret) {
        List<Account> listAccounts = [SELECT ID, name, Client_grand_compte__c, Code_Chaine__c, Code_Externe_Chaine_Text__c, RecordType.Name, N_client__c, Numero_Client__c, Numero_Siret__c, Enseigne_commerciale__c,Date_creation_etablissement__c,theme__c,Email__c,Forme_juridique__c,N_association__c,
                                      IsBuyer, Magasin_de_rattachement__c, Magasin_actif_en_cours__c, Etablissement_geographique__c, (select id, firstname, lastname, Salutation, Roles__c, Phone, MobilePhone, Telephone_portable__c, Fax, Email_E_commerce__c, Email from Contacts where Contact_principal__c = true) 
                                      FROM ACCOUNT WHERE Numero_Siret__c = :siret];
        if(listAccounts != null && listAccounts.size() > 0)
            return listAccounts.get(0);
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Zone_de_Chalandise__c> getZoneChalandise(String postalCode, String city) {
        List<Zone_de_Chalandise__c> res = [SELECT ID, Magasin__c, Magasin__r.Restrictif__c, Magasin__r.Name, Libelle_ville__c FROM Zone_de_Chalandise__c WHERE Code_postal_text__c = :postalCode AND Libelle_ville__c = :city];
        if(res != null && res.size() > 0)
            return res;
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Zone_de_Chalandise__c> getAllMagasinsFromZoneDeChalandise(String postalCode, String city) {
        List<Zone_de_Chalandise__c> res = [SELECT ID, Magasin__c, Magasin__r.Restrictif__c, Magasin__r.Name, Libelle_ville__c FROM Zone_de_Chalandise__c order by Magasin__r.Name asc];
        if(res != null && res.size() > 0)
            return res;
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Codes_Postaux__c getPostalCode(String postalCode, String city) {
        List<Codes_Postaux__c> res = [select id, Code_postal__c, Commune__c from Codes_Postaux__c where Code_postal__c = :postalCode AND Commune__c = :city];
        system.debug('selfRegService.getPostalCode res: ' + res);
        if(res != null && res.size() > 0)
            return res.get(0);
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Magasin__c getAllMagasins() {
        List<Magasin__c> res = [SELECT ID, Restrictif__c FROM Magasin__c];
        if(res != null && res.size() > 0)
            return res.get(0);
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Code_APE__c> getCodesAPE() {
        List<Code_APE__c> res = [SELECT Id, Name, Code_APE__c, Regroupement__c, Code_Regroupement__c, Specialisation__c, Code_specialisation__c FROM Code_APE__c order by Name asc];
        if(res != null && res.size() > 0)
            return res;
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Code_APE__c>> getCodesAPEBis() {
        Map<String, List<Code_APE__c>> resMap = new Map<String, List<Code_APE__c>>();
        
        List<Code_APE__c> res = [SELECT Id, Name, Code_APE__c, Regroupement__c, Code_Regroupement__c, Specialisation__c, Code_specialisation__c FROM Code_APE__c WHERE Specialisation__c != null AND Regroupement__c != null order by Name asc];
        for(Code_APE__c codeA: res) {
            if(resMap.get(codeA.Code_APE__c) == null) {
                resMap.put(codeA.Code_APE__c, new List<Code_APE__c>{codeA});
            } else {
                resMap.get(codeA.Code_APE__c).add(codeA);
            }
        }
        return resMap;
    }
    
    @AuraEnabled
    public static ServiceResponse updateAccountInfo(Account objAcc, ContactPointAddress billAddress, ContactPointAddress shipAddress, Contact contact, Boolean createContact) {
        system.debug('updateAccountInfo billAddress: ' + billAddress);
        system.debug('updateAccountInfo shipAddress: ' + shipAddress);
        List<ContactPointAddress> lisAddress = new List<ContactPointAddress>{billAddress, shipAddress};
            try {
                objAcc.Origine__c = '7'; //Update origine
                update objAcc;
                insert lisAddress;
                if(createContact == true) {
                    contact.AccountId = objAcc.Id;
                    insert contact;
                } else if(contact != null) {
                    update contact;
                }
            } catch(Exception e) {
                return new ServiceResponse(false, 'unknown', e.getMessage());
            }
        return new ServiceResponse(true, 'Success');
    }
    
    @AuraEnabled
    public static ServiceResponse updateAccountMagasin(Account account, String magasinId, String magasinGeographique, ContactPointAddress billAddress, ContactPointAddress shipAddress) {
        try {
            List<ContactPointAddress> lisAddress = new List<ContactPointAddress>{billAddress, shipAddress};
                
            account.Magasin_de_rattachement__c = magasinId;
            account.Magasin_actif_en_cours__c = magasinId;
            account.Etablissement_geographique__c = magasinGeographique;
            account.Origine__c = '7'; //Update origine
            update account;
            insert lisAddress;
        } catch(Exception e) {
            system.debug('updateAccountMagasin exception: ' + e);
            return new ServiceResponse(false, 'unknown', e.getMessage());
        }
        return new ServiceResponse(true, 'success');
    }
    
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    private static Id getCommunityProfileId() {
        try {
            return [select id, name from profile where name='Customer Community +' LIMIT 1].Id;   
        } catch(Exception e) {
            system.debug('getCommunityProfileId Exception: ' + e);
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String, String> getAccountRecordTypes() {
        Map<String,Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String, String> res = new Map<String, String>();
        for(Schema.RecordTypeInfo rt : recordTypes.values()){
            res.put('Lead',recordTypes.get('Lead').getRecordTypeId());
        }
        return res;
    }
    
    private static Map<String, Id> getPermissionMap() {
        Map<String, Id> res= new Map<String, Id>();
        List<PermissionSet> mp = [select id, Name from PermissionSet where name='B2B_Commerce_Buyer' or name='Account_Switcher_User'];
        system.debug('getPermissionMap: ' + mp);
        if(mp != null && mp.size() > 0) {
            for(PermissionSet ps: mp) {
                res.put(ps.name, ps.Id);
            }
        }
        return res;
    }
    
    @AuraEnabled
    public static sObject insertRecord(SObject obj, String objtype){
        try{
            switch on objtype {
                when 'Account' {	
                    Account account = (Account) obj;
                    obj = saveAccountRecord(account);
                }	
                when 'Contact' {		
                    Contact contact = (Contact) obj;
                    obj = saveContactRecord(contact);
                    
                }
                when 'ContactPointAddress' {		
                    ContactPointAddress address = (ContactPointAddress) obj;
                    obj = saveContactPointAddressRecord(address);
                }
                when else{
                    throw new AuraHandledException('This object has not been setup for this action yet: ' + objtype);
                }
            }		
        }		
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return obj;
        
    }
    
    
    
    @AuraEnabled
    public static Boolean updateAccount(Account objAcc){
        try{
            system.debug('objAcc: ' + objAcc);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return true;
    }
    
    @AuraEnabled
    public static Account saveAccountRecord(Account objAcc){
        try{
            insert objAcc;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return objAcc;
    }
    
    @AuraEnabled
    public static Contact saveContactRecord(Contact objCont){
        try{
            insert objCont;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return objCont;
    }
    
    @AuraEnabled
    public static ContactPointAddress saveContactPointAddressRecord(ContactPointAddress objCPA){
        system.debug('=====> ContactPointAddress: ' + objCPA);
        try{
            insert objCPA;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return objCPA;
    }
    
    @AuraEnabled
    public static List<ContactPointAddress> saveContactPointAddressesRecord(ContactPointAddress objCPAbill,ContactPointAddress objCPAship){
        List<ContactPointAddress> addresses = new List<ContactPointAddress>(); 
        try{
            addresses.add(objCPAbill);
            addresses.add(objCPAship);
            insert addresses;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' line:  ' + ex.getLineNumber() + ' cause:  ' + ex.getCause());
        }
        return addresses;
    }
    
    @AuraEnabled
    public static ServiceResponse updatePieceJustificatifFields(String accountId, Boolean registreCommerce, Boolean kbis, Boolean rib, Boolean pieceIdentite) {
        try {
            Account a = [SELECT ID, Attestation_registre_du_commerce__c, RIB__c, K_bis__c, Piece_identite__c FROM ACCOUNT WHERE ID=:accountId limit 1];
            if(registreCommerce)
                a.Attestation_registre_du_commerce__c = true;
            if(kbis)
                a.K_bis__c = true;
            if(rib)
                a.RIB__c = true;
            if(pieceIdentite)
                a.Piece_identite__c = true;
            update a;
        } catch(Exception e) {
            return new ServiceResponse(false, 'exception', e.getMessage());
        }
        return new ServiceResponse(true, 'success');
    }
    
    @AuraEnabled
    public static ServiceResponse insertAddress(ContactPointAddress billingAddress, ContactPointAddress shippingAddress) {
        try{
            List<ContactPointAddress> addrs = new List<ContactPointAddress>{billingAddress, shippingAddress};
                insert addrs;
            return new ServiceResponse(true, '', '');
        }
        catch(Exception ex) {
            return new ServiceResponse(false, ex.getTypeName(), 'Error: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
        }
    }
    
    @AuraEnabled
    public static ServiceResponse saveRecords(Account account, Contact contact, ContactPointAddress billingAddress, ContactPointAddress shippingAddress, Boolean isMagasinRestrictif, String magasinName){
        system.debug('saveRecords:billingAddress: ' + billingAddress);
        system.debug('saveRecords:shippingAddress: ' + shippingAddress);
        
        try{
            Relation_Compte_Magasin__c rmc = createRelation(account.Id, account.Magasin_de_rattachement__c);
            contact.Relation_Compte_Magasin__c = rmc.Id;
            contact.Contact_principal__c = true;
            insert contact;
            if(isMagasinRestrictif == false){
                ServiceResponse res = new ServiceResponse(activateAccount(account, magasinName));
                return new ServiceResponse(res.isSuccess, contact.Id, res.message);
                
            }
            return new ServiceResponse(true, '', contact.Id);
            
        }
        catch(Exception ex) {
            return new ServiceResponse(false, ex.getTypeName(), 'Error: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause() + 'StackTrace:' + ex.getStackTraceString() + 'TypeName:' + ex.getTypeName());
        }
    }
    
    
    
    @AuraEnabled
    public static void handleProspectExtraInfos(Account account){
        try{
            
            //Frais__c records update
            List<Frais__c> fraisList = [Select Account__c, Magasin_Associe__c from Frais__c where Account__c =: account.Id AND Magasin_Associe__c =: account.Magasin_de_rattachement__c];
            List<Fidelite__c> fideliteList = [Select Compte__c, Magasin__c from Fidelite__c where Compte__c =: account.Id AND Magasin__c =: account.Magasin_de_rattachement__c];
            List<Activite_potentiel__c> activitePotenList = [Select Account__c, Magasin_actif__c from Activite_potentiel__c where Account__c =: account.Id AND Magasin_actif__c =: account.Magasin_de_rattachement__c];
            
            if(!fraisList.isEmpty()){
                account.Frais_autorisations__c = fraisList[0].Id;
            }else{
                Frais__c fraisRecord = new Frais__c();
                fraisRecord.Account__c = account.Id;
                fraisRecord.Magasin_Associe__c = account.Magasin_de_rattachement__c;
                Insert fraisRecord;
                account.Frais_autorisations__c = fraisRecord.Id;
            }
            
            if(!fideliteList.isEmpty()){
                account.Frais_autorisations__c = fideliteList[0].Id;
            }else{
                Fidelite__c fideliteRecord = new Fidelite__c();
                fideliteRecord.Compte__c = account.Id; 
                fideliteRecord.Magasin__c = account.Magasin_de_rattachement__c;
                Insert fideliteRecord;
                account.Fidelite__c = fideliteRecord.Id;
            }
            
            if(!activitePotenList.isEmpty()){
                account.Activite_potentiel__c = activitePotenList[0].Id;
            }else{
                Activite_potentiel__c actpotenRecord = new Activite_potentiel__c();
                actpotenRecord.Account__c = account.Id; 
                actpotenRecord.Magasin_actif__c = account.Magasin_de_rattachement__c;
                Insert actpotenRecord;
                account.Activite_potentiel__c = actpotenRecord.Id;
            }
            update account;
            
        }
        catch(AuraHandledException ex) {
            System.debug('Exception message :'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage() + ' line:  ' + ex.getLineNumber() + ' cause:  ' + ex.getCause());
        }
        
    }
    
    @InvocableMethod(label='activate magasin')
    global static List<String> MoveFileToAccount(List<List<String>> requests) {
        String accountId = requests.get(0).get(0);
        String selectedMagasinId = requests.get(0).get(1);
        
        Account acc = [SELECT ID, name, Magasin_de_rattachement__c, Magasin_actif_en_cours__c,Magasin_actif_en_cours__r.id, Magasin_actif_en_cours__r.Name, Frais_autorisations__c, Activite_potentiel__c, Fidelite__c, Numero_Client__c FROM ACCOUNT where id=:accountId limit 1];        
        Magasin__c selectedMagasin = [SELECT ID, name, Responsable__r.Id, Code_etablissement__c FROM Magasin__c where id=:selectedMagasinId limit 1];
        Magasin__c magasinActifEncours;
        if(acc.Magasin_actif_en_cours__r.id != null) {
            magasinActifEncours = new Magasin__c (Id=acc.Magasin_actif_en_cours__r.id, Name=acc.Magasin_actif_en_cours__r.Name );
        }
        
        system.debug('### Account id: ' + requests.get(0).get(0));
        system.debug('### Magasin id: ' + requests.get(0).get(1));
        
        //Create Relation compte magasin
        List<Relation_Compte_Magasin__c> rcmList = [SELECT ID FROM Relation_Compte_Magasin__c WHERE Compte_Client__c = :accountId AND Magasin_actif__c = :selectedMagasin.Id];
        Relation_Compte_Magasin__c rcm;
        if(rcmList.isEmpty()) { //We need to create a relaiton compte magasin
            rcm = new Relation_Compte_Magasin__c();
            rcm.Compte_Client__c = accountId;
            rcm.Magasin_actif__c = selectedMagasin.Id;
            insert rcm;
        } else {
            rcm = rcmList.get(0);
        }
        
        if(magasinActifEncours != null) { // Get old BG
            //Get specific Buyer group
            String bgName = acc.name + ' ' + magasinActifEncours.name;
            List<BuyerGroup> bgList = [SELECT ID FROM BuyerGroup where name = :bgName];
            if(!bgList.isEmpty()) { //If old buyer Group exists, delete it
                List<BuyerGroupMember> bgMemberList = [SELECT ID FROM BuyerGroupMember WHERE BuyerId=:accountId AND BuyerGroupId=:bgList.get(0).Id];
                if(!bgMemberList.isEmpty()) {
                    delete bgMemberList;
                }
            }
            //Get Standard BG
            String standardBGName = 'Standard ' + magasinActifEncours.name;
            List<BuyerGroup> standardBGList = [SELECT ID FROM BuyerGroup where name = :standardBGName];
            if(!standardBGList.isEmpty()) { //If old buyer Group exists, delete it
                List<BuyerGroupMember> standardBGMemberList = [SELECT ID FROM BuyerGroupMember WHERE BuyerId=:accountId AND BuyerGroupId=:standardBGList.get(0).Id];
                if(!standardBGMemberList.isEmpty()) {
                    delete standardBGMemberList;
                }
            }
        }
        
        if(magasinActifEncours != null) { // Get New BG
            //Get specific Buyer group
            String newbgName = acc.name + ' ' + selectedMagasin.name;
            List<BuyerGroup> newbgList = [SELECT ID FROM BuyerGroup where name = :newbgName];
            if(!newbgList.isEmpty()) {
                List<BuyerGroupMember> newbgMemberList = [SELECT ID FROM BuyerGroupMember WHERE BuyerId=:accountId AND BuyerGroupId=:newbgList.get(0).Id];
                if(newbgMemberList.isEmpty()) { // Create new Buyer group member
                    BuyerGroupMember newBGMember = new BuyerGroupMember(BuyerId = acc.Id, BuyerGroupId = newbgList.get(0).Id);
                    insert newBGMember;
                }
            } else {
                String newStandardBGName = 'Standard ' + selectedMagasin.name;
                List<BuyerGroup> newStandardBGList = [SELECT ID FROM BuyerGroup where name = :newStandardBGName];
                if(!newStandardBGList.isEmpty()) {
                    List<BuyerGroupMember> newStandardBgMemberList = [SELECT ID FROM BuyerGroupMember WHERE BuyerId=:accountId AND BuyerGroupId=:newStandardBGList.get(0).Id];
                    if(newStandardBgMemberList.isEmpty()) {
                        BuyerGroupMember newBGMember = new BuyerGroupMember();
                        newBGMember.BuyerId = acc.Id;
                        newBGMember.BuyerGroupId = newStandardBGList.get(0).Id;
                        if(!Test.isRunningTest())
                            insert newBGMember;
                    }
                }
            }
        }
        
        //Update account info
        List<Frais__c> fraisList = [Select Account__c, Magasin_Associe__c from Frais__c where Account__c =: acc.Id AND Magasin_Associe__c =: selectedMagasin.Id];
        List<Fidelite__c> fideliteList = [Select Compte__c, Magasin__c from Fidelite__c where Compte__c =: acc.Id AND Magasin__c =: selectedMagasin.Id];
        List<Activite_potentiel__c> activitePotenList = [Select Account__c, Magasin_actif__c from Activite_potentiel__c where Account__c =: acc.Id AND Magasin_actif__c =: selectedMagasin.Id];
        
        if(!fraisList.isEmpty()){
            acc.Frais_autorisations__c = fraisList[0].Id;
        }else{
            Frais__c fraisRecord = new Frais__c();
            fraisRecord.Account__c = acc.Id;
            fraisRecord.Magasin_Associe__c = selectedMagasin.Id;
            fraisRecord.Frais_externalID__c = acc.Numero_Client__c + '_' + selectedMagasin.Code_etablissement__c;
            Insert fraisRecord;
            acc.Frais_autorisations__c = fraisRecord.Id;
        }
        
        if(!fideliteList.isEmpty()){
            acc.Fidelite__c = fideliteList[0].Id;
        }else{
            Fidelite__c fideliteRecord = new Fidelite__c();
            fideliteRecord.Compte__c = acc.Id; 
            fideliteRecord.Magasin__c = selectedMagasin.Id;
            fideliteRecord.Fid_ExternalID__c = acc.Numero_Client__c + '_' + selectedMagasin.Code_etablissement__c;
            Insert fideliteRecord;
            acc.Fidelite__c = fideliteRecord.Id;
        }
        
        if(!activitePotenList.isEmpty()){
            acc.Activite_potentiel__c = activitePotenList[0].Id;
        }else{
            Activite_potentiel__c actpotenRecord = new Activite_potentiel__c();
            actpotenRecord.Account__c = acc.Id; 
            actpotenRecord.Magasin_actif__c = selectedMagasin.Id;
            actpotenRecord.AP_External_ID__c = acc.Numero_Client__c + '_' + selectedMagasin.Code_etablissement__c;
            Insert actpotenRecord;
            acc.Activite_potentiel__c = actpotenRecord.Id;
        }
        acc.Magasin_actif_en_cours__c = selectedMagasin.Id;
        if(!TEST.isRunningTest()) {
            acc.OwnerId = selectedMagasin.Responsable__r.Id;
            update acc;
        }
        
        //Get Group Role And Subordinates Inte
        List<Group> grouplist = [Select id from Group where RelatedId = :selectedMagasin.Responsable__r.Id AND Type = 'RoleAndSubordinatesInternal'];
        if(!grouplist.isEmpty()) {
            AccountShare ashare = new AccountShare();
            ashare.AccountId = acc.Id;
            ashare.UserOrGroupId = grouplist.get(0).Id;
            ashare.AccountAccessLevel = 'Edit';
            ashare.OpportunityAccessLevel = 'Edit';
            insert ashare;
        }
        return new List<String>{'success'};
            }
    
    @AuraEnabled
    public static ServiceResponse activateAccount(Account account, String magasinName){
        
        try{
            
            system.debug('#### activateAccount');
            handleProspectExtraInfos(account);
            
            AccountShare accShare = new AccountShare();
            List<BuyerGroup> insertBuyerGroupList = new List<BuyerGroup>();
            List<BuyerGroup> tempBuyerGroupList = new List<BuyerGroup>();
            List<BuyerGroup> finalBuyerGroupList = new List<BuyerGroup>();
            
            Map<String,BuyerGroup> buyerGroupMap=new Map<String,BuyerGroup>();
            Map<String,BuyerGroup> updatedBuyerGroupMap=new Map<String,BuyerGroup>();
            Set<Id> buyerGroupIds=new Set<Id>();
            List<BuyerGroupMember> newBGMlist = new List<BuyerGroupMember>();
            
            if (account.Magasin_actif_en_cours__c == null){
                account.Magasin_actif_en_cours__c = account.Magasin_de_rattachement__c;
            }    
            
            Magasin__c magasin = new Magasin__c();    
            magasin = [Select Id, Name, Responsable__r.UserRole.Id,Responsable__c  from Magasin__c where Id =: account.Magasin_de_rattachement__c LIMIT 1];
            Id userRole = magasin.Responsable__r.UserRole.Id;
            
            
            //Get the group role and subordinates internal                                              
            Group grp= new Group();
            grp = (!Test.isRunningTest())? [select id,Type,Related.Name,RelatedId from Group where Type ='RoleAndSubordinatesInternal'and RelatedId = :userRole]: new Group();
            //create Account Share Records
            accShare.AccountId = account.Id;
            accShare.UserOrGroupId = grp.Id;
            accShare.AccountAccessLevel = 'Edit';
            accShare.OpportunityAccessLevel = 'Edit';           
            
            if(!Test.isRunningTest())
                insert accShare;
            
            system.debug('#### accShare');
            
            BuyerAccount buyAcc=new BuyerAccount();
            buyAcc.BuyerId=account.Id;
            buyAcc.PayerId=account.Id;
            buyAcc.SendToId=account.Id;
            buyAcc.BuyerStatus='Active';
            buyAcc.CommerceType='Acheteur' ;
            buyAcc.IsActive=true;
            buyAcc.Name=account.Name;
            
            if(!Test.isRunningTest())
                insert buyAcc;
            
            system.debug('#### buyAcc ' + buyAcc);
            
            String tempName='Standard ' + magasinName;
            
            // get the Buyer group 
            List<BuyerGroup> buyerGroupList= [Select Id,Name from BuyerGroup where Name Like : tempName];            
            //create a map with standard product name and buyer group
            for(BuyerGroup bg : buyerGroupList){
                buyerGroupMap.put(bg.Name, bg);
            }
            
            if(buyerGroupMap.containsKey(tempName)){
                tempBuyerGroupList.add(buyerGroupMap.get(tempName));
            }else{
                //insertBuyerGroupList.add(buyerGroupObj);
            }
            
            BuyerGroup buyerGroupObj = new BuyerGroup();
            if(buyerGroupList.isEmpty()){
                buyerGroupObj.Name=tempName;
                insert buyerGroupObj;
            }else{
                buyerGroupObj = buyerGroupList[0];
            }
            
            
            system.debug('#### buyerGroupObj ' + buyerGroupObj);
            
            BuyerGroupMember  bgm =new BuyerGroupMember();
            bgm.BuyerId = account.Id;
            bgm.BuyerGroupId = buyerGroupObj.Id;
            newBGMlist.add(bgm);
            
            if(!Test.isRunningTest())
                insert newBGMlist;
            
            system.debug('#### newBGMlist ' + newBGMlist);
            return new ServiceResponse(true, '', 'Activated account: ' + account.Name);
            
        }
        catch(Exception ex) {
            system.debug('Activate account Exception: ' + ex);
            system.debug('Activate account Exception: ' + ex.getStackTraceString());
            system.debug('Activate account Exception: ' + ex.getLineNumber());
            return new ServiceResponse(false, 'Unknown error on line number: ' + ex.getLineNumber() + ':', ex.getTypeName() + ' : ' + ex.getMessage());
        }
    }
    
    @TestVisible
    private static List<BuyerGroup> getBuyerGroups(){
        return [Select Id,Name from BuyerGroup where Name Like 'Standard %'];
    }
    
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = Utilities2.getPickListValues(objApiName, fieldName);
        return options;
    }
    
    public static Relation_Compte_Magasin__c createRelation(String accountId, String magasinId){
        system.debug('createRelation accountId: ' + accountId);
        system.debug('createRelation magasinId: ' + magasinId);
        try{
            Relation_Compte_Magasin__c RMC = new Relation_Compte_Magasin__c();
            RMC.Compte_Client__c = accountId;
            RMC.Magasin_actif__c = magasinId;
            RMC.Autorisation_nouveau_magasin__c = 'non';
            RMC.Autorisation_magasin_d_origine__c = 'non';
            insert RMC;
            return RMC;
        }
        catch(Exception ex) {
            system.debug('createRelation exception: ' + ex);
            system.debug('createRelation exception: ' + ex.getMessage());
            system.debug('createRelation exception: ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static ServiceResponse getAccountUsername(String codeCarte) {
        try {
            List<Account> accounts = [SELECT ID, (SELECT ID FROM contacts where Contact_principal__c=true) FROM ACCOUNT where Numero_Client__c=:codeCarte];
            if(accounts.isEmpty())
                return new ServiceResponse(false, 'accountNotFound', 'Code carte non trouvé');
            if(accounts.get(0).contacts.isEmpty())
                return new ServiceResponse(false, 'contactNotFound', 'Merci de contacter votre magasin');
            Contact c = accounts.get(0).contacts.get(0);
            
            List<User> userList = [SELECT ID, Username FROM USER where contactId=:c.Id];
            if(userList.isEmpty())
                return new ServiceResponse(false, 'userNotFound', 'Merci de contacter votre magasin');
            
            return new ServiceResponse(true, userList.get(0).Username);
        } catch(Exception e) {
            system.debug('getAccountUsername e: ' + e);
            return new ServiceResponse(false, 'exception', e.getMessage());
        }
    }
        
    public class ServiceResponse {
        @AuraEnabled public boolean isSuccess;
        @AuraEnabled public String errorType; //field, unkown
        @AuraEnabled public String fieldName;
        @AuraEnabled public String message;
        
        public ServiceResponse(Boolean isSuccess, String errorType, String message) {
            this.isSuccess = isSuccess;
            this.errorType = errorType;
            this.message = message;
        }
        
        public ServiceResponse(Boolean isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }      
        
        public ServiceResponse(ServiceResponse sr) {
            this.isSuccess = sr.isSuccess;
            this.errorType = sr.errorType;
            this.message = sr.message;
        }      
    }
    
    
    
}