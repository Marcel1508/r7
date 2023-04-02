/**
* @description       : 
* @author            : Ajay.Kumar Tiwari
* @group             : 
* @last modified on  : 09-29-2021
* @last modified by  : Ajay.Kumar Tiwari
* Modifications Log 
* Ver   Date         Author              Modification
* 1.0   06-30-2021   Ajay.Kumar Tiwari   Initial Version
**/
@IsTest
private class AccountTriggerHandlerTest {
    @testSetup static void setup() {
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User u = new User(
            ProfileId = pf.Id,
            LastName = 'Gerant Zone blanche',
            Email = 'puser000@carrefour.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert u;
    }
    private static User queryUserRec() {
        return [SELECT Id,FirstName FROM User where LastName ='Gerant Zone blanche' LIMIT 1];
    }
    @IsTest
    static void testCases1(){
        MagasinTriggerHandler.bypassTrigger=true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;
        
        Code_APE__c codeAPE = TestDataFactory.createCodeAPE('Test APE');
        Insert codeAPE;
        
        user u=queryUserRec();
        Zone_de_chalandise__c zone= new Zone_de_chalandise__c();
        zone.Code_postal_text__c='02180';
        zone.Libelle_ville__c='Paris';
        zone.Magasin__c=magasinRec.Id;
        insert zone;
        
        List<Account> accountList=new List<Account>();
        Account acc = TestDataFactory.createGenericAccountRecord('TestAcc','Prospect',magasinRec);
        acc.Numero_Siret__c='66204244900014';
        acc.Code_Chaine__c='test';
        acc.Enseigne_commerciale__c='text data';
        acc.code_APE__c = codeAPE.Id;
        acc.Forme_juridique__c = '01';
        acc.Categorie__c = '1';
        acc.Origine__c='4';
        
        Account acc1=TestDataFactory.createGenericAccountRecord('TestAcc','Prospect',magasinRec);
        acc1.Numero_Siret__c='66204244900014';
        acc1.Enseigne_commerciale__c='text data';
        acc1.code_APE__c = codeAPE.Id;
        acc1.Forme_juridique__c = '01';
        acc1.Categorie__c = '1';
        acc1.Code_Chaine__c='test';
        acc1.Origine__c='4';
        accountList.add(acc);
        accountList.add(acc1);
        
        Test.startTest();
        insert accountList;
        accountList[0].ShippingPostalCode='02180';
        accountList[0].ShippingCity='Paris';
        accountList[0].Statut_Fiche_client__c='Lead';
        accountList[1].ShippingPostalCode='02180';
        accountList[1].ShippingCity='Paris';
        update accountList;
        Test.stopTest();
        
    }
    @IsTest
    private static void testFilterAccountsForCheckSiret() {
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        magasinRec.Code_etablissement__c = '32';
        Insert magasinRec;
        Account account = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        account.OwnerId=UserInfo.getUserId();
        account.SirenText__c='662042449';
        account.Numero_Siret__c='66204244900014';
        account.Numero_Client__c='CL123';
        account.Forme_juridique__c='07';
        account.Enseigne_commerciale__c='ENS';
        account.Origine__c='4';
        account.Categorie__c='1';
        account.ShippingPostalCode='123';
        insert account;
        List<Account> res = new AccountService().filterAccountsForCheckSiret(new List<Account> {account});
        system.assert(!res.isEmpty());
    }
    
    @IsTest
    private static void testFilterAccountsForCheckSiret2() {
         Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        magasinRec.Code_etablissement__c = '32';
        Insert magasinRec;
        AccountTriggerHandler.bypassTrigger = true;
        Account account = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        account.OwnerId=UserInfo.getUserId();
        account.SirenText__c='662042449';
        account.Numero_Siret__c='66204244900014';
        account.Numero_Client__c='CL123';
        account.Forme_juridique__c='07';
        account.Enseigne_commerciale__c='ENS';
        account.Origine__c='4';
        account.Categorie__c='1';
        account.ShippingPostalCode='123';
        insert account;
        
        Map<Id, Account> oldRecordsMap = new Map<Id, Account>();
        oldRecordsMap.put(account.Id, account);
        
        List<Account> res = new AccountService().filterAccountsForCheckSiret(new List<Account> {account}, oldRecordsMap);
        system.assert(res.isEmpty());
    }
    
    
    @IsTest
    private static void testUpdateExternalId() {
         Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        magasinRec.Code_etablissement__c = '32';
        Insert magasinRec;
        
        Account account = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        account.OwnerId=UserInfo.getUserId();
        account.SirenText__c='662042449';
        account.Numero_Siret__c='66204244900014';
        account.Numero_Client__c='CL123';
        account.Forme_juridique__c='07';
        account.Enseigne_commerciale__c='ENS';
        account.Origine__c='4';
        account.Categorie__c='1';
        account.ShippingPostalCode='123';
        insert account;
        Frais__c fr = new Frais__c(Magasin_Associe__c = magasinRec.Id, account__c = account.Id);
        insert fr;
        Fidelite__c fid = new Fidelite__c(Magasin__c = magasinRec.Id, compte__c = account.Id);
        insert fid;
        Activite_potentiel__c ap = new Activite_potentiel__c(Magasin_actif__c = magasinRec.Id, account__c = account.Id);
        insert ap;
        Information_financiere__c ifo = new Information_financiere__c(magasin__c = magasinRec.Id, account__c = account.Id);
        insert ifo;
        AccountTriggerHandler.firstRun = true;
        account.Numero_Client__c = '123';
       
        update account;
    }
    
    @IsTest
    private static void testIsAccountDataComplete() { //todo: @Marouane
        
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;
        
        Account account = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        account.OwnerId=UserInfo.getUserId();
        account.SirenText__c='662042449';
        account.Numero_Siret__c='66204244900014';
        account.Numero_Client__c='CL123';
        account.Forme_juridique__c='07';
        account.Enseigne_commerciale__c='ENS';
        account.Origine__c='4';
        account.Categorie__c='1';
        account.ShippingPostalCode='123';
        insert account;
        
        account = [SELECT ID, Numero_Client__c, Forme_juridique__c, name, Enseigne_commerciale__c, Origine__c, Code_etablissement__c, Categorie__c, Magasin_actif_en_cours__c, FirstOrder__c  from account limit 1];
        Account accountNotComplete = new Account(Numero_Client__c = 'CL123', Forme_juridique__c = '07', name = 'ACC', Enseigne_commerciale__c = 'ENS', Origine__c = '7', Categorie__c = 'Test');
        
        String codeAPE = 'apeCode';
        Contact c = new Contact(LastName = 'Last', firstName = 'first');
        ContactPointAddress ship = new ContactPointAddress(Numero_de_voie__c = '10',Nom_de_voie__c='test' ,Type_de_voie__c = 'Rue', postalCode='98000', City = 'Paris',CountryCode = 'Fr');
        ContactPointAddress bill = new ContactPointAddress(Numero_de_voie__c = '10',Nom_de_voie__c='test' ,Type_de_voie__c = 'Rue', postalCode='98000', City = 'Paris', CountryCode = 'Fr');
        
        Boolean res1 = new AccountService().isAccountDataComplete(account, c, bill, ship, codeAPE);
        Boolean res11 = new AccountService().isAccountDataComplete(account, null, bill, ship, codeAPE);
        Boolean res2 = new AccountService().isAccountDataComplete(accountNotComplete, c, bill, ship, codeAPE);
        Boolean res3 = new AccountService().isAccountDataComplete(account, c, bill, ship, null);
        Boolean res4 = new AccountService().isAccountDataComplete(account, c, null, ship, codeAPE);
        Boolean res5 = new AccountService().isAccountDataComplete(account, c, bill, null, codeAPE);
        new AccountService().upsertFrais(new Map<Id, Account>{account.Id => account});
        new AccountService().upsertFrais(new Map<Id, Account>{account.Id => account});
        
        system.assert(res1, 'info complete');
        system.assert(res2 == false, 'info not complete');
        system.assert(res3 == false, 'info not complete, ape not complete');
        system.assert(res4 == false, 'info not complete, bill not complete');
        system.assert(res5 == false, 'info not complete, ship not complete');
    }
}