@isTest
public class FormatPhoneNumberBatchTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser){
            Magasin__c magasin = new Magasin__c(Name='magasinTest' , Minimum_Commande_Drive__c = 1.0, Minimum_Commande_Drive_Deporte__c = 1.0, Minimum_Commande_Livraison__c= 1.0, Responsable__c=currentUser.Id);
            insert magasin;
            
            Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
            
            // insert 5 accounts
            for (Integer i=0;i<5;i++) {
                accounts.add(new Account(name='Account '+i, RecordTypeId = clientRecordTypeId, 
                                         Magasin_de_rattachement__c = magasin.Id, 
                                         Magasin_actif_en_cours__c = magasin.Id, En_cours_de_creation_au_reg_du_commerce__c = true,
                                         ShippingCountry = 'France'));
            }
            insert accounts;
            // Add contact to accounts just inserted
            for (Account account : [select id from account]) {
                contacts.add(new Contact(firstname='firstTest', Telephone_portable__c = '0652515254',
                                         lastname='lastTest', Roles__c='Autre', accountId=account.id));
            }
            insert contacts;
        }

    }
    
    @isTest static void testFormatPhoneNumberBatch() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser){
            Test.startTest();
            FormatPhoneNumberBatch batch = new FormatPhoneNumberBatch('France', 'FR');
            Id batchId = Database.executeBatch(batch);
            Test.stopTest();
        }
        String formattedPhone = [Select id, formattedPhone__c from Contact limit 1].formattedPhone__c;
        System.assertEquals('33652515254' , formattedPhone);
      
    }
}