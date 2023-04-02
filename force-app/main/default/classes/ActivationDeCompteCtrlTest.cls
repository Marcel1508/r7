/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          18-04-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/
@isTest
class ActivationDeCompteCtrlTest {
    @testSetup static void setup() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        
        Magasin__c mag=new Magasin__c();
        mag=CommonTestData.createMagasinRecord(mag);
        insert mag;
  
        Account acc=new Account();
        acc=CommonTestData.createAccountRecord(acc);
        acc.Magasin_de_rattachement__c= mag.Id;
        acc.Magasin_actif_en_cours__c= mag.Id;
        insert acc;

    }

    private static List<Account> getAccount() {
        return [SELECT Id,Statut_Fiche_client__c,Magasin_actif_en_cours__c,Magasin_de_rattachement__c,IsBuyer FROM Account  LIMIT 1];
    }
    
    @IsTest
    public static void testCreateAccountShare() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        ActivationDeCompteCtrl.FlowRequest fr = new ActivationDeCompteCtrl.FlowRequest();
        GroupMember gm = [select id, UserOrGroupId, Groupid, group.name from GroupMember where group.developerName like '%Magasin%' limit 1];
        fr.accountId = getAccount().get(0).Id;
      //  fr.groupId = gm.UserOrGroupId;
        List<Account> accList = getAccount(); 
        Test.startTest();
        ActivationDeCompteCtrl.createAccountShare(new List<ActivationDeCompteCtrl.FlowRequest>{fr});
        Test.stopTest();
        List<AccountShare> accSh = [SELECT id FROM AccountShare];
        system.assertNotEquals(null, accSh);
    }
    
    @IsTest
    static void testBuyerGroupCreation(){
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        List<Account> accList = getAccount(); 
        Test.startTest();
        ActivationDeCompteCtrl.updateNonActivateAccount(accList); 
        Test.stopTest();
        
    }
}