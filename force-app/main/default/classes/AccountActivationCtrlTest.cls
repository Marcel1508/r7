/* .
--------------------------------------------------------------------------------------
Version#     Date                        Author                    Description
--------------------------------------------------------------------------------------
1.0          09-04-2021                  preethi.u@ibm.com         Initial Version
--------------------------------------------------------------------------------------
*/ 

@isTest
private class  AccountActivationCtrlTest {
    
    @testSetup static void setup() {
        Magasin__c  magasinRec = (Magasin__c ) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'Test Magasin')
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.Code_etablissement__c, '7500') 
            .create ()
            .getRecord(); 
        
        Code_APE__c codeAPE = new Code_APE__c(
        	APE_code__c = 'P13',
            Name = 'Test APE',
            Code_specialisation__c = 'A1'
        );
        Insert codeAPE;
        Account accRec = (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'Test Account') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasinRec.Id)
            .put(Account.Magasin_actif_en_cours__c, magasinRec.Id)
            .put(Account.SirenText__c, '662042449')
            .put(Account.Numero_Siret__c, '66204244900014')
            .put(Account.Numero_Client__c, 'CL123')
            .put(Account.code_APE__c, codeAPE.Id)
            .put(Account.Forme_juridique__c, '07')
            .put(Account.Enseigne_commerciale__c, 'ENS')
            .put(Account.Origine__c, '7')
            .put(Account.Categorie__c, '1')
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
    
    private static List<Account> queryAccountRec() {
        return [SELECT Id,name, Statut_Fiche_client__c,Magasin_actif_en_cours__c,Magasin_de_rattachement__c,IsBuyer FROM Account where Name ='Test Account' LIMIT 1];
    }
    private static Frais__c queryFraisRec() {
        return [SELECT Id,Account__c,Magasin_Associe__c FROM Frais__c where Account__r.Name ='Test Account' LIMIT 1];
    }
    private static Fidelite__c queryFideliteRec() {
        return [SELECT Id,Compte__c, Magasin__c FROM Fidelite__c where Compte__r.Name ='Test Account' LIMIT 1];
    }
    private static Activite_potentiel__c queryActiviteRec() {
        return [SELECT Id,Account__c, Magasin_actif__c FROM Activite_potentiel__c where Account__r.Name ='Test Account' LIMIT 1];
    }
    
    
    @IsTest
    static void testAccountActivation(){
        List<Account> accList = queryAccountRec(); 
        AccountActivationCtrl.FlowInput reqInput = new AccountActivationCtrl.FlowInput();
        reqInput.nonActivatedaccountList =accList; 
        reqInput.accountList =accList; 
        Test.startTest();
        AccountActivationCtrl.checkChidRecords(
            new List<AccountActivationCtrl.FlowInput>{reqInput}
        );
        Test.stopTest();
        Frais__c fraisRec = queryFraisRec();
        System.assertEquals(fraisRec.Account__c, accList[0].Id,'');
        
        Fidelite__c fideliteRec = queryFideliteRec();
        System.assertEquals(fideliteRec.Compte__c, accList[0].Id,'');
        
        Activite_potentiel__c activiteRec = queryActiviteRec();
        System.assertEquals(activiteRec.Account__c, accList[0].Id,'');
    }
   
}