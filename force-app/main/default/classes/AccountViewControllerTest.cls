/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          07-07-2021           Ajay.Tiwari3 @ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
@IsTest
public  class AccountViewControllerTest {
   
    @IsTest
    static void selectedAccount(){
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec ;
        
        List<account> lstAccount=new list<Account>();
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        lstAccount.add(accTest);        
        insert lstAccount;
        test.startTest();
		
        Test.setCurrentPage(Page.AccountListView);
        apexpages.standardsetcontroller std=new apexpages.StandardSetController(lstAccount);
        std.setselected(lstAccount);
        
        AccountViewController obj=new AccountViewController(std);
        obj.getAccountListView();
    test.stopTest();
    }

}