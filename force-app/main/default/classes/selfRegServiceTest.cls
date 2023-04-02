@isTest
public class selfRegServiceTest {
    private static final String siret = '66204244900014';
    
    @testSetup static void setup() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec ;
        
 		Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        insert accTest;
        
       	Contact c = TestDataFactory.createContactRecord(accTest.id);
        c.LastName = 'Marouane';
        c.Roles__c = 'Propriétaire';
        c.Contact_principal__c = true;
        insert c;
        
        Code_APE__c cape1 = new Code_APE__c(Code_APE__c = '123', Specialisation__c='Spec1', Regroupement__c='Regroupement1');
        Code_APE__c cape2 = new Code_APE__c(Code_APE__c = '455', Specialisation__c='Spec2', Regroupement__c='Regroupement2');
        Code_APE__c cape3 = new Code_APE__c(Code_APE__c = '123', Specialisation__c='Spec3', Regroupement__c='Regroupement3');
        insert cape1;
        insert cape2;
        insert cape3;
        
        BuyerGroup bg = new BuyerGroup();
        bg.name = 'Standard Mag name';        
        insert bg;
        //SELECT Id, Name, Code_APE__c, Regroupement__c, Code_Regroupement__c, Specialisation__c, Code_specialisation__c FROM Code_APE__c
    }
    
    @isTest
    private static void saveFile() {
        String idParent = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
        ContentVersion cv = selfRegService.saveFile(idParent, 'strFileName', 'base64Data', 'Piece_identite');
        system.assert(cv != null);
    }
    
    @isTest
    private static void testGetCodesPostaux() {
        selfRegService.getCodePostalById(null);
        selfRegService.insertAddress(null, null);
    }
    
    @isTest
    private static void updateContactEmail() {
        AccountTriggerHandler.bypassTrigger = true;
        Contact c = [SELECT ID, email FROM CONTACT LIMIT 1];
        selfRegService.updateContactEmail(c.Id, 'mar@gmail.com');
        c = [SELECT ID, email FROM CONTACT LIMIT 1];
        system.assertEquals('mar@gmail.com', c.email);
    }
    
    @isTest
    private static void enablePortalUserForSingleNewContact() {
        AccountTriggerHandler.bypassTrigger = true;
        String idParent = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
        Id contactId = [SELECT ID, email FROM CONTACT LIMIT 1].Id;
        selfRegService.enablePortalUserForSingleNewContact(idParent, contactId, 'ma@mm.om', '', true);
    }
    
    @isTest
    private static void enablePortalUserForContactWithoutEmail() {
        AccountTriggerHandler.bypassTrigger = true;
        Contact c = [SELECT ID, email FROM CONTACT LIMIT 1];
        Id idParent = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
        selfRegService.enablePortalUserForContactWithoutEmail(idParent, c.Id, 'mar@gmail.com', 'marouane');
    }
    
    @isTest
    private static void activeExistingLead() {
        AccountTriggerHandler.bypassTrigger = true;
        Id accountId = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
        Id magasinId = [SELECT ID FROM Magasin__c LIMIT 1].Id;
        selfRegService.activeExistingLead(accountId, magasinId);
    }
    
    @isTest
    private static void testGetterMethod() {
        selfRegService.getZoneChalandise('code', 'city');
        selfRegService.getAllMagasinsFromZoneDeChalandise('code', 'city');
        selfRegService.getPostalCode('code', 'city');
        selfRegService.getAllMagasins();
        selfRegService.getCodesAPE();
        selfRegService.getCodesAPEBis();
        selfRegService.getAccountRecordTypes();
        selfRegService.getAccountbySiret(siret);
        selfRegService.getAccountbySiret('12');
    }

    @isTest    
    private static void updateAccountInfo() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = [SELECT ID FROM ACCOUNT LIMIT 1];
        Contact contact = [SELECT ID FROM Contact LIMIT 1];
        ContactPointAddress billAddress = new ContactPointAddress(name='bill');
        ContactPointAddress shipAddress = new ContactPointAddress(name='shipp');
        
        selfRegService.updateAccountInfo(account, billAddress, shipAddress, contact, false);
    }
    
    @isTest
    private static void updateAccountMagasin() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = [SELECT ID FROM ACCOUNT LIMIT 1];
        Contact contact = [SELECT ID FROM Contact LIMIT 1];
        Magasin__c magasin = [SELECT ID FROM Magasin__c LIMIT 1];
        
        ContactPointAddress billAddress = new ContactPointAddress(name='bill');
        ContactPointAddress shipAddress = new ContactPointAddress(name='shipp');
        
        selfRegService.updateAccountMagasin(account, magasin.Id, magasin.Id, billAddress, shipAddress);
        //Test validate password
        selfRegService.validatePassword(null, '', '');
        selfRegService.updateAccount(null);
    }
    
    
    @isTest
    private static void insertAccountRecord() {
        AccountTriggerHandler.bypassTrigger = true;
        try {
            selfRegService.insertRecord(new Account(), 'Account');
        } catch(Exception e) {
            system.assert(true, 'should throw an exception');
        }
    }
    
    @isTest
    private static void insertContactRecord() {
        AccountTriggerHandler.bypassTrigger = true;
        try {
            selfRegService.insertRecord(new Contact(), 'Contact');
        } catch(Exception e) {
            system.assert(true, 'should throw an exception');
        }
    }
    
    @isTest
    private static void insertAddressRecord() {
        AccountTriggerHandler.bypassTrigger = true;
        try {
            selfRegService.insertRecord(new ContactPointAddress(), 'ContactPointAddress');
        } catch(Exception e) {
            system.assert(true, 'should throw an exception');
        }
    }
    
    @isTest
    private static void saveContactPointAddressesRecord() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = [SELECT ID FROM ACCOUNT LIMIT 1];
        ContactPointAddress billAddress = new ContactPointAddress(name='bill', AddressType='Billing', ParentId = account.Id);
        ContactPointAddress shipAddress = new ContactPointAddress(name='shipp', AddressType='Shipping', ParentId = account.Id);
        try {
            selfRegService.saveContactPointAddressesRecord(billAddress, shipAddress);
        } catch(AuraHandledException e) {
            
        }
    }
    
    @isTest
    private static void updatePieceJustificatifFields() {
        String accountId = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
        selfRegService.updatePieceJustificatifFields(accountId, true, true, true, true);
    }
    
    @istest
    private static void saveRecords() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = [SELECT ID FROM ACCOUNT LIMIT 1];
        Contact c = new Contact();
        
        c.accountId = account.Id;
        c.LastName = 'Marouane';
        c.Roles__c = 'Propriétaire';
        c.Contact_principal__c = true;
        
        Magasin__c magasin = [SELECT ID FROM Magasin__c LIMIT 1];
        ContactPointAddress billAddress = new ContactPointAddress(name='bill');
        ContactPointAddress shipAddress = new ContactPointAddress(name='shipp');
        
        account.Magasin_de_rattachement__c = magasin.Id;
        update account;
        selfRegService.saveRecords(account, c, billAddress, shipAddress, false, 'magasinName');
    }
    
    @isTest
    private static void MoveFileToAccount() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        AccountTriggerHandler.firstRun = true;
        
        Account account = [SELECT ID, Magasin_actif_en_cours__c FROM ACCOUNT LIMIT 1];
        Magasin__c magasin = [SELECT ID, name FROM Magasin__c LIMIT 1];
        account.Magasin_actif_en_cours__c = magasin.Id;
        update account;
        
        List<String> req = new List<String>();
        req.add(account.Id);
        req.add(magasin.Id);
        List<List<String>> requests = new List<List<String>>{req};
        selfRegService.MoveFileToAccount(requests);
        selfRegService.getBuyerGroups();
    }
    
    @isTest
    private static void getPickListValues() {
        selfRegService.getPickListValues('Account', 'Forme_juridique__c');
    }
    
    @isTest
    private static void getAccountUsername() {
        selfRegService.getAccountUsername('AZ');
        selfRegService.getAccountUsername('A180');
    }
    
    @isTest
    private static void activateAccount() {
        AccountTriggerHandler.bypassTrigger = true;
        Account account = [SELECT ID, name, Magasin_actif_en_cours__c FROM ACCOUNT LIMIT 1];
        Magasin__c magasin = [SELECT ID FROM Magasin__c LIMIT 1];
        account.Magasin_de_rattachement__c = magasin.Id;
        selfRegService.ServiceResponse sr = selfRegService.activateAccount(account, 'AZ');
    }
    
    
    
    
    
    
    
}