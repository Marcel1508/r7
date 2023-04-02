/* .
--------------------------------------------------------------------------------------
Version#     Date                        Author                    Description
--------------------------------------------------------------------------------------
1.0          09-04-2021                  preethi.u@ibm.com         Initial Version
--------------------------------------------------------------------------------------
*/ 

@isTest
private class  CommunityUserCtrlTest {

    @testSetup static void setup() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'Test Magasin')
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .create ()
            .getRecord(); 
        Account accRec = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'Test Account') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasinRec.Id)
            .put(Account.Magasin_actif_en_cours__c, magasinRec.Id)
            .create ()
            .getRecord(); 
       Contact textContact = (Contact) new sObjectbuilder(Contact.sObjectType)
            .put(Contact.FirstName, 'TEST')
            .put(Contact.LastName, 'Contact')
            .put(Contact.Roles__c, 'Propriétaire')
            .put(Contact.Contact_principal__c, True)
            .put(Contact.Email, 'TestPromoCash@carrefour.com')
            .put(Contact.AccountId, accRec.Id)
            .create().getRecord();
        
          User owner = (User) new SObjectBuilder(User.sObjectType)
            .put(User.FirstName, 'Test')
            .put(User.LastName, 'User')
            .put(User.username, 'etest@test.com')
            .put(User.Email, 'etest@carrefour.com')
            .put(User.CommunityNickname, 'testnickname')
            .put(User.ProfileId, new SObjectFieldProviders.ProfileProvider('Customer Community Plus User'))
            .put(User.contactID, textContact.id)
            
            .getRecord();
    }
    
     private static User queryUserRec() {
        return [SELECT Id,FirstName FROM User where FirstName ='Test' LIMIT 1];
    }
     private static List<Account> queryAccountRec() {
        return [SELECT Id,Statut_Fiche_client__c,Magasin_actif_en_cours__c,Magasin_de_rattachement__c,IsBuyer FROM Account where Name ='Test Account' LIMIT 1];
    }
    
    @IsTest
    static void testUserCreation(){
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        User userList = queryUserRec(); 
        
        set<id> ids = new set<id>();
        set<String> accIds = new set<String>();
        List<String> acList = new List<String>();
        String accId;
        String magasinActifEnCours;
            
        for(User ur : [SELECT Id,FirstName,contactID,Contact.AccountId,Contact.Name FROM User where FirstName ='Test' LIMIT 1]){
                        ids.add(ur.id);
            accIds.add(ur.Contact.AccountId);
            acList.add(ur.Contact.Name);
        }
        Test.startTest();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		insert r;

        List<Account> accList = queryAccountRec(); 
        for(Account ac : accList){
            accId = ac.id;
            magasinActifEnCours = ac.Magasin_actif_en_cours__c;
        }
        
        CommunityUserCtrl.createUser(accList);
       // CommunityUserCtrl.assignUserPermission(ids);
        CommunityUserCtrl.updateContacts(accIds);
        CommunityUserCtrl.listToString(acList);
        CommunityUserCtrl.buildCompositeKey(accId,magasinActifEnCours);
        Test.stopTest();
    }
}