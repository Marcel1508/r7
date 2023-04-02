@isTest
public class ContactTriggerHandlerTest {
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
    }
    
    @isTest
    private static void test() {
        Contact ck = new Contact();
        ck.accountId = [SELECT ID FROM ACCOUNT LIMIT 1].Id;
        ck.LastName = 'khayou';
        ck.Roles__c = 'Propriétaire';
        ck.Contact_principal__c = true;
        insert ck;
        Contact cm = [SELECT ID, Contact_principal__c FROM CONTACT WHERE LastName='Marouane' LIMIT 1];
        system.assertEquals(false, cm.Contact_principal__c, 'The first created contact must not be principal');
        
        //Update second contact
        cm.Contact_principal__c = true;
        update cm;
        ck = [SELECT ID, Contact_principal__c FROM CONTACT WHERE LastName='khayou' LIMIT 1];
        system.assertEquals(false, ck.Contact_principal__c);
    }
}