/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          18-04-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 

@isTest
public class UpdateActiveMagasinsTest {
    
    @testSetup static void setup() {
        
         Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec ;

        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        Insert accTest;

        Contact con = TestDataFactory.createContactRecord(accTest.id);
        Insert con;
        
        Relation_Compte_Magasin__c rcm =new Relation_Compte_Magasin__c();
        rcm.Compte_Client__c=accTest.Id;
        rcm.Magasin_actif__c=magasinRec.Id;
        insert rcm;

    }
    private static List<Account> getAccount() {
        return [SELECT Id,Statut_Fiche_client__c,Magasin_actif_en_cours__c,Magasin_de_rattachement__c,IsBuyer FROM Account  LIMIT 1];
    }
 	private static List<Contact> getContact() {
        return [select Id,Roles__c,AccountID,Email,FirstName,LastName,Contact_principal__c from Contact LIMIT 1];
    }
    @IsTest
    static void testAccountUpdation(){
        List<Account> accList = getAccount(); 
        List<Contact> conList=getContact();
        UpdateActiveMagasins.FlowInput reqInput = new UpdateActiveMagasins.FlowInput();
        reqInput.accountList =accList; 
        Test.startTest();
        UpdateActiveMagasins.updateMagasinActifEnCours( new List<UpdateActiveMagasins.FlowInput>{reqInput}); 
        Test.stopTest();
        
    }
}