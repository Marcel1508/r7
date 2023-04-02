/**
 * @description       : 
 * @author            : Ajay.Kumar Tiwari
 * @group             : 
 * @last modified on  : 09-01-2021
 * @last modified by  : Ajay.Kumar Tiwari
**/
@IsTest
private class AccountinfoServiceTest {
     @IsTest
    private static void accountInfoData(){
        //Create a magasinRec
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec ;
        //Create a Codes_Postaux__c
        Codes_Postaux__c cPo = TestDataFactory.createCodePostauxRecord('10115','10115','DE','BERLIN'); 
        insert cPo;
        //Create a Account
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        accTest.En_cours_de_creation_au_reg_du_commerce__c = true;
        Insert accTest;
        //Create a ContactPointAddress
        ContactPointAddress cpAddress=new ContactPointAddress();
        cpAddress=TestDataFactory.createContactPointAddressRecord(cpAddress,'');
        cpAddress.ParentId=accTest.Id;
        cpAddress.IsDefault=true;
        cpAddress.N_habite_pas_ladresse_indiquee__c=true;
        cpAddress.Nom_de_voie__c='test';
        cpAddress.Complement_d_adresse__c='115/288D';
        cpAddress.AddressType='Shipping';
        cpAddress.Numero_de_voie__c='99';
        cpAddress.Type_de_voie__c='AV';
        cpAddress.Pays__c='DE';
        cpAddress.Codes_Postaux__c = cPo.Id;
        insert cpAddress;
        //Create a Contact
        Contact contact = TestDataFactory.createContactRecord(accTest.id);
        contact.Roles__c = 'Propriétaire';
        insert contact;

        Test.startTest();
            AccountinfoService.getAccountInfo(String.valueOf(accTest.Id),'Account');
            AccountinfoService.getAccountInfo(String.valueOf(contact.Id),'Contact');
            AccountinfoService.getAccountInfo(String.valueOf(cpAddress.Id),'ContactPointAddress');
        Test.stopTest();
    }
}