/**
* @author       jan.straka@bluewolf
* @date         2021-02-03
* @description  Tests for Utilities class
**/
@IsTest
private class UtilitiesTest {
     @testsetup static void setup(){
         User u = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
         System.runAs(u){
            Id userId = u.Id;
            Magasin__c magasin = new Magasin__c(Name='magasinTest' , Minimum_Commande_Drive__c = 1.0, Minimum_Commande_Drive_Deporte__c = 1.0, Minimum_Commande_Livraison__c= 1.0, Responsable__c=userId);
            insert magasin;
             
            Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

            //create Account
            Account accTest = new Account (Name = 'TestAcc', RecordTypeId = clientRecordTypeId, Magasin_de_rattachement__c = magasin.Id,
                                           Magasin_actif_en_cours__c = magasin.Id, En_cours_de_creation_au_reg_du_commerce__c = true,
                                         	 ShippingCountry = 'France');
            insert accTest;
            
            //create Contact
            Contact contactTest = new Contact(LastName='TestContact',  Telephone_portable__c = '06 11 22 33 44',
                                              AccountId = accTest.Id, Roles__c='Autre');
            insert contactTest;
        }
    }
    
    @IsTest
    private static void testSetBypassesToCurrentUser() {
        Test.startTest();
        Utilities.setBypassesToCurrentUser(null, null, null, null);
        Test.stopTest();

        User currentUser = [SELECT Bypass_PB__c, Bypass_Trigger__c, Bypass_VR__c, Bypass_WF__c FROM User WHERE Id = :UserInfo.getUserId()];
        System.assertEquals(null, currentUser.Bypass_PB__c, 'Bad processes to be bypassed');
        System.assertEquals(null, currentUser.Bypass_Trigger__c, 'Bad triggers to be bypassed');
        System.assertEquals(null, currentUser.Bypass_VR__c, 'Bad validation rules to be bypassed');
        System.assertEquals(null, currentUser.Bypass_WF__c, 'Bad workflows to be bypassed');
    }

    @IsTest
    private static void testFormatPhoneNumber() {
        String formattedNumber;
        Test.startTest();
        formattedNumber = Utilities.formatPhone('06 22 12 15 42', 'FR');
        Test.stopTest();
        System.assertEquals(formattedNumber, '33622121542');
    }
    
    @IsTest
    private static void testformatContactPhone() {
        Utilities.countryCodesMdt =(List<Country_Codes_Setting__mdt>) JSON.deserialize('[{"DeveloperName":"France", "Contry_Code__c" : "FR"}]', List<Country_Codes_Setting__mdt>.class);
        User u = [SELECT id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Contact> contactLst;
        System.runAs(u){
            contactLst = [SELECT id, AccountId, formattedPhone__c, Telephone_portable__c from Contact];
            Test.startTest();
            	Utilities.formatContactPhone(contactLst); 
            Test.stopTest();
        }
        System.assertEquals([SELECT formattedPhone__c from Contact].formattedPhone__c, '33611223344');
    }
    
    @IsTest
    private static void testNewAuraHandledException() {
        String testMessage = 'Test Message'; 
        
        Test.startTest();
        AuraHandledException result = Utilities.newAuraHandledException(testMessage);
        Test.stopTest();

        System.assertEquals(testMessage, result.getMessage(), 'Bad message set');
    }
}