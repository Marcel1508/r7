/* .test coverage for contact point address trigger
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          21-06-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 
@IsTest
private class ContactPointAddressTriggerHandlerTest {
    @testSetup static void setup() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec ;

        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        accTest.En_cours_de_creation_au_reg_du_commerce__c = true;
        insert accTest;
    }
    @IsTest
    static void contactPointDML(){
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        List<ContactPointAddress> cpaList=new List<ContactPointAddress>();
        ContactPointAddress cpAddress=new ContactPointAddress();
        cpAddress=TestDataFactory.createContactPointAddressRecord(cpAddress,'');
        cpAddress.ParentId=[SELECT ID FROM ACCOUNT LIMIT 1].Id;
      
        //cpAddress.Type_de_voie__c='Chemin';
        cpAddress.IsDefault=true;
        cpAddress.N_habite_pas_ladresse_indiquee__c=true;
        cpAddress.Nom_de_voie__c='test';
       // cpAddress.Code_postal__c='2054';
       // cpAddress.Ville_commune__c='Knapur';
        cpAddress.Complement_d_adresse__c='115/288D';
        cpAddress.AddressType='Shipping';
        cpAddress.Numero_de_voie__c='99';
        cpAddress.Type_de_voie__c='AV';
        cpAddress.Pays__c = 'CH';
        
        //S.A _ 03/08/2021 _ Create Code Postaux
        Codes_Postaux__c codePostaux = new Codes_Postaux__c(
            Name = 'CP120',
            Code_postal__c = '93200',
            Commune__c = 'Saint Denis',
            pays__c = 'CH'
        );
        insert codePostaux;
        //END - S.A _ 03/08/2021 _ Create Code Postaux

        cpAddress.Codes_Postaux__c=codePostaux.Id;
        
        ContactPointAddress cpAddress1=new ContactPointAddress();
        cpAddress1=TestDataFactory.createContactPointAddressRecord(cpAddress1,'');
        cpAddress1.ParentId=[SELECT ID FROM ACCOUNT LIMIT 1].Id;
        
       // cpAddress1.Type_de_voie__c='Chemin';
        cpAddress1.IsDefault=true;
        cpAddress1.N_habite_pas_ladresse_indiquee__c=true;
        cpAddress1.Nom_de_voie__c='test';
        //cpAddress1.Code_postal__c='2054';
      //  cpAddress1.Ville_commune__c='Knapur';
        cpAddress1.Complement_d_adresse__c='115/288D';
        cpAddress1.AddressType='Billing';
         cpAddress1.Numero_de_voie__c='99';
        cpAddress1.Type_de_voie__c='AV';
        //START - S.A 03/08/2021
        cpAddress1.Complement_d_adresse__c='3 rue cata';
        cpAddress1.Codes_Postaux__c=codePostaux.Id;
        cpAddress1.pays__c = 'CH';
        cpAddress1.ExternalID__c = 'A123';
        //END - S.A 03/08/2021
        
        cpaList.add(cpAddress);
        cpaList.add(cpAddress1);

        ContactPointAddress cpAddressDel=new ContactPointAddress();
        cpAddressDel=TestDataFactory.createContactPointAddressRecord(cpAddressDel,'');
        cpAddressDel.ParentId=[SELECT ID FROM ACCOUNT LIMIT 1].Id;
        cpAddressDel.Pays__c = 'CH';
        cpAddressDel.Codes_Postaux__c = codePostaux.Id;
        Test.startTest();
        insert cpaList; 
      
         cpaList[0].Street='sahj edu';
        //cpaList[0].Ville_commune__c='alley';
        cpaList[0].Nom_de_voie__c='test1234';
        cpaList[1].Street='sahj edu';
      //  cpaList[1].Ville_commune__c='alley';
        cpaList[1].Nom_de_voie__c='test12';
        ContactPointAddressTriggerHandler.firstRun=true;

        update cpaList;
        insert cpAddressDel;
        delete cpAddressDel;
        Test.stopTest();
        
    }
    
    //Create Billing or Shipping address
    //S.A 03/08/2021
    @IsTest
    static void createShippingOrBillingAddressByDefault(){
        //Profile prof = [select id from profile where name LIKE '%marketing%'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = UserInfo.getProfileId();
        user.username = 'septembertwo@carrefour.com';
        user.email = 'septembertwo@carrefour.com';
        user.Alias = 'standt';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US'; 
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Los_Angeles';
        insert user;
        //S.A _ 03/08/2021 _ Create Code Postaux
        Codes_Postaux__c codePostaux = new Codes_Postaux__c(
            Name = 'CP120',
            Code_postal__c = '93200',
            Commune__c = 'Saint Denis',
            pays__c = 'CH'
        );
        insert codePostaux;
        //END - S.A _ 03/08/2021 _ Create Code Postaux
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c mag = TestDataFactory.createGenericMagasin('AM-AccountData');
        mag.Responsable__c=user.Id;
        mag.API_Key__c  = 'LtsFKJQih9U0Z5mHGm38oSMBc5Nkiq';
        mag.Code_etablissement__c='8500';
        mag.Pourcentage_additionel_carte__c = 12;
        mag.Minimum_Commande_Drive__c = 12;
        mag.Minimum_Commande_Livraison__c = 6;
        mag.Minimum_Commande_Drive_Deporte__c = 10;
        insert mag;

        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',mag); 
        testAccount.En_cours_de_creation_au_reg_du_commerce__c = true;
        Insert testAccount;
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        
        ContactPointAddress cpa = new ContactPointAddress();
        cpa.ParentId=testAccount.Id;
        cpa.Name = 'Billing Address Test';
        cpa.IsDefault=true;
        cpa.N_habite_pas_ladresse_indiquee__c=false;
        cpa.Nom_de_voie__c='test 123';
        cpa.Complement_d_adresse__c='116/289D';
        cpa.AddressType='Shipping';
        cpa.Numero_de_voie__c='98';
        cpa.Type_de_voie__c='BP';
        cpa.Complement_d_adresse__c='4 rue cata';
        cpa.Codes_Postaux__c=codePostaux.Id;
        cpa.ExternalID__c = 'A1267';
        cpa.Pays__c = 'CH';
        insert cpa;
    }
}