@isTest
public class ActivateCustomerUserServiceTest {
    
    
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

            Contact textContact1 = (Contact) new sObjectbuilder(Contact.sObjectType)
            .put(Contact.FirstName, 'TEST')
            .put(Contact.LastName, 'Contact1')
            .put(Contact.Roles__c, 'Propriétaire')
            .put(Contact.Contact_principal__c, True)
            .put(Contact.Email, 'TestPromoCashh@carrefour.com')
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
    
    @isTest
    private static void testIsCustomerUserEnabled() {
        ActivateCustomerUserService.isCustomerUserEnabled('contactId');
    }
    
    @isTest
    private static void testChangeUsername() {
        String newEmail = 'mar@carrefour.com';
        User u = [SELECT ID, username FROM USER LIMIT 1];
        ActivateCustomerUserService.ChangeUsername(u.Id, newEmail);
        u = [SELECT ID, username FROM USER LIMIT 1];
        system.assertNotEquals(null, u.Username);
    }
    
    @isTest
    private static void testGetCustomerUser() {
        User u = ActivateCustomerUserService.GetCustomerUser('az');
        system.assertEquals(null, u);
    }

    @isTest
    private static void testEnablePortalUserForContact() {
        Contact con = [Select id,LastName,email from Contact where LastName='Contact1' limit 1 ];
        Contact con1 = [Select id,LastName,email from Contact where LastName='Contact1' limit 1 ];  
        
        ActivateCustomerUserService.enablePortalUserForContact(con.Id,'TestPromoCassh@carrefour.com','testFirstName','testLastName');
        ActivateCustomerUserService.enablePortalUserForContact(con1.Id,'TestPromoCcassh@carrefour.com','testFirstName','testLastName');
        ActivateCustomerUserService.applyPermissions(con.Id);
        
    }
}