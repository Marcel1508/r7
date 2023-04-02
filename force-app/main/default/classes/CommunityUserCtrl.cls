/* 
-------------------------------------------------------------------------
Version#     Date                  Author                 Description
-------------------------------------------------------------------------
1.0          07-Apl-2021        	   Preethi.u              Initial Version
-------------------------------------------------------------------------
*/ 

public  without sharing class CommunityUserCtrl {
    public static List<CommunityUser> createUser(list<Account> accList){
        List<CommunityUser> results = new List<CommunityUser>();
        CommunityUser response = new CommunityUser();
        results.add(response);
        response.isSuccess = False;
        try{
            Set<String> accountSetIds = new Set<String>();
            Set<String> accountIds = new Set<String>();
            Map<String,User> existingUserMap=new Map<String,User>();
            existingUserMap=getExistingUser();
            List<String> processedAccountList =new List<String>(); 
            Set<ID> userSetID = new Set<ID>();
            
            for(Account accRecord : accList){
                accountSetIds.add(accRecord.Id);
            }
            List<User> userList = new List<User>();
            Map<String, Contact> contactMap = fetchConMap(accountSetIds);  
            Profile profRecord=[SELECT Id FROM Profile WHERE Name='Customer Community +' LIMIT 1];
            for(Contact conRec :contactMap.values()){
                if(!existingUserMap.containsKey(conRec.Email)){

                    User userRecord = New User(
                    UserName = conRec.Email,
                    FirstName = conRec.FirstName,
                    LastName = conRec.LastName,
                    email = conRec.Email,
                    contactID = conRec.id,
                    Alias = conRec.LastName.substring(0,1)+conRec.Email.substring(0,3),
                    CommunityNickName = conRec.Email,
                    ProfileID = profRecord.id,
                    TimeZoneSidKey = 'Europe/Paris', 
                    LocaleSidKey = 'fr_FR_EURO', 
                    EmailEncodingKey = 'UTF-8', 
                    LanguageLocaleKey = 'fr'
                );
                userList.add(userRecord);    
                }else{
                    userSetID.add(existingUserMap.get(conRec.Email).Id);
                }
                
            }
           
            if(!userList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(userList, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        userSetID.add(sr.getId());
                    }
                }
            }
                
                List<User> userRecordsList = [Select lastName, ContactId, Contact.AccountId,Contact.Account.Name from User where ID IN :userSetID];
                response.result = 'success';
                String error = '';
                response.insertedUser = '';
                for(User u : userRecordsList){
                    if(contactMap.containsKey(u.ContactId)){
                        if(response.insertedUser != ''){
                            response.insertedUser = response.insertedUser +', '+u.LastName;
                        }else{
                            response.insertedUser = 'Success : '+u.LastName;
                        }
                        response.isSuccess = true;
                        processedAccountList.add(u.Contact.Account.Name);
                        response.processedAccounts = listToString(processedAccountList);
                       
                        contactMap.remove(u.ContactId);
                    }
                    accountIds.add(u.Contact.AccountId);
                }
                for(Contact conRect : contactMap.values()){
                    if(error!=''){
                        error = error+', '+conRect.LastName;
                    }else{
                        error= ' Error : '+conRect.LastName;
                    } 
                }
                
                if(response.insertedUser!=''){
                    response.insertedUser = response.insertedUser+error;  
                }else{
                    response.insertedUser = error;
                }
                
                // update contact 
                if(!accountIds.isEmpty()){
                    //added by ajay start ** to store the only account ids
                    response.processedAccountIds=accountIds;
                    //added by ajay end ** to store the only account ids
                    updateContacts(accountIds);
                }

                if(!userSetID.isEmpty()){
                    assignUserPermission(userSetID); 
                }
            



        }catch(Exception ex) {
            response.result = 'error:' + ex.getMessage();
            response.isSuccess = false;
                    }
        return results;
    }
    
    public static Map<String, Contact> fetchConMap(Set<String> accSetIds){
        Map<String, Contact> conMap = new Map<String, Contact>();
        List<Contact> conList = [Select Id,Account.ID, Roles__c,Email,FirstName,LastName,Contact_principal__c ,Account.Magasin_actif_en_cours__c,AccountId
                                                from Contact where 
                                                Account.ID IN :accSetIds AND Email != NULL AND Contact_principal__c = True];
        for(Contact conRecord : conList){
            conMap.put(conRecord.Id, conRecord);
        } 
        return conMap;
    }
    
    @Future
    public static void assignUserPermission(set<Id> userListIds){
        
        List<Permissionset> permissionList = [Select name from Permissionset where name IN('B2B_Commerce_Buyer','Account_Switcher_User')];
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Map<String,PermissionSetAssignment> existingUserIdVsPermissiontSet=new Map<String,PermissionSetAssignment>();
        existingUserIdVsPermissiontSet= getpemrissionAssignments(userListIds);

        for (User u : [SELECT ID,UserRole.Name,Profile.Name,IsActive FROM User WHERE  ID IN : userListIds]){
            if(!existingUserIdVsPermissiontSet.containsKey(u.Id)){

                PermissionSetAssignment psa1 = new PermissionSetAssignment (PermissionSetId = permissionList[0].id, AssigneeId = u.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = permissionList[1].id, AssigneeId = u.Id);
            permissionSetList.add(psa1);
            permissionSetList.add(psa2);
            }
        }
        if(!permissionSetList.isEmpty()){
            Insert permissionSetList;
        }
    }
    
    //return the list of Accounts Name to Concatenate Name
    public static String listToString(List<String> aList) {
        String allstring = string.join(aList,',');
        return allstring;
    }

    public static string buildCompositeKey(String accId, String magasinActifEnCours){
        String compositeKey = accId+magasinActifEnCours;
        return compositeKey;
    }

    // contact update relation compte magasin  with account' relation compte magasin
    public static void updateContacts(Set<String> accountIds){
        Map<String,Relation_Compte_Magasin__c> mapRelationCompteMagasin=getRelCompteMagasinMap(accountIds);
        List<Contact> updateContacts=new List<Contact>();

        Map<String,Contact> mapIdVsContact=fetchConMap(accountIds);

        for(Contact con : mapIdVsContact.values()){
                String acIdMagActifCompositeKey =AccountActivationCtrl.buildCompositeKey(con.AccountId, con.Account.Magasin_actif_en_cours__c);
                if(mapRelationCompteMagasin.containsKey(acIdMagActifCompositeKey)){
                    con.Relation_Compte_Magasin__c=mapRelationCompteMagasin.get(acIdMagActifCompositeKey).Id;
                    updateContacts.add(con);
                }
        }
        if(!updateContacts.isEmpty()){
            update updateContacts;
        }
    }

    // get the map of exising Relation Compete Magasin realed to that  accounts
    private static Map<String,Relation_Compte_Magasin__c> getRelCompteMagasinMap(Set<String> accountIds){
        Map<String,Relation_Compte_Magasin__c> mapRelationMagasin=new Map<String,Relation_Compte_Magasin__c>();

        List<Relation_Compte_Magasin__c> competeMagasins= [Select Id,Compte_Client__c,Magasin_actif__c from Relation_Compte_Magasin__c 
                                                                                                        where Compte_Client__c in : accountIds];

        for(Relation_Compte_Magasin__c rcm :competeMagasins){
            String relCompteMagaCompositeKey = buildCompositeKey(rcm.Compte_Client__c, rcm.Magasin_actif__c);
                    mapRelationMagasin.put(relCompteMagaCompositeKey, rcm);
            
        }
        return mapRelationMagasin;
    }
 
    // get the map of email and user-added by Ajay
    private static Map<String,User> getExistingUser(){
        Map<String,User> mapEmailVsUser=new Map<String,User>();

        List<User> users= [Select Id,Username,Email from User where Profile.Name='Customer Community +'];

        for(User usr :users){
            mapEmailVsUser.put(usr.Email, usr);
        }
        return mapEmailVsUser;
    }
    // get the map of user id and permission set -Added by Ajay
    private static Map<String,PermissionSetAssignment> getpemrissionAssignments(set<Id> userIds){
        Map<String,PermissionSetAssignment> mapUserIdVsPermissiontSet=new Map<String,PermissionSetAssignment>();

        List<PermissionSetAssignment> permissionAssignmnets= [Select AssigneeId, PermissionSet.Name from PermissionSetAssignment 
                            where AssigneeId IN :userIds  and PermissionSet.Name IN ('B2B_Commerce_Buyer','Account_Switcher_User')];

        for(PermissionSetAssignment permissionAssignmnet :permissionAssignmnets){
            mapUserIdVsPermissiontSet.put(permissionAssignmnet.AssigneeId, permissionAssignmnet);
        }
        return mapUserIdVsPermissiontSet;
    }




    public without sharing class CommunityUser {
        
        @InvocableVariable( label = 'Updated Accounts' )
        public String insertedUser;
        
        @InvocableVariable
        public String result;
        
        public Boolean isSuccess;
        
        public String processedAccounts;
       
        public set<String> processedAccountIds; //added by ajay  ** to store the only account ids

        
    }
}