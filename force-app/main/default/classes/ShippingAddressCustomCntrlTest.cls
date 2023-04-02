/* .
Test class for ShippingAddressCustomCntrl apex class.
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          27-04-2021           Ajay.Tiwari3 @ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
@IsTest
private class ShippingAddressCustomCntrlTest {
    @testSetup static void setup() {
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
        Insert magasinRec ;
    
        Account acc = TestDataFactory.createGenericAccountRecord('Test Account','Lead',magasinRec);
        Insert acc;

         //Create a Codes_Postaux__c
         Codes_Postaux__c cPo = TestDataFactory.createCodePostauxRecord('10115','10115','DE','BERLIN'); 
         insert cPo;

		ContactPointAddress cpAddress=new ContactPointAddress();
        cpAddress=TestDataFactory.createContactPointAddressRecord(cpAddress,'Billing');
        cpAddress.ParentId=acc.Id;
        cpAddress.IsDefault = true;
        cpAddress.Pays__c='DE';
        cpAddress.Codes_Postaux__c = cPo.Id;
        insert cpAddress;

        Webstore wbestore = TestDataFactory.createWebStoreRecord();
		Insert wbestore;
        
        WebCart wcRec = TestDataFactory.createWebCartRecord(acc.id);
        wcRec.WebStoreId=wbestore.Id;
        Insert wcRec;
    }

    private static List<Magasin__c> getMagasin() {
        return [SELECT id FROM Magasin__c  LIMIT 1];
    }
    
    private static List<WebCart> getCart() {
        return [SELECT Id,WebStoreId, AccountId FROM WebCart  LIMIT 1];
    }

    private static List<Webstore> getWebStore() {
        return [SELECT Id FROM Webstore  LIMIT 1];
    }
    
     private static List<Account> getAccount() {
        return [SELECT Id,Statut_Fiche_client__c,
                Magasin_de_rattachement__c,Magasin_actif_en_cours__c FROM Account  LIMIT 1];
    }
    
    @IsTest
    static void testPositiveGetAddress(){

        AuraResponse ar;
        List<WebCart> cart = getCart(); 
        Test.startTest();
        ar= ShippingAddressCustomCntrl.getContactPointAddress(cart[0].Id); 
        Test.stopTest();

        System.assertEquals(ar.isSuccess, true, 'Expecting Success');
        
    }

    @IsTest
    static void testNegativeGetAddress(){
         List<Magasin__c> magasinList = getMagasin();
		List<Account> acc=getAccount();
        List<WebCart> wcard=getCart();
		AuraResponse ar;
        
        Test.startTest();
        ar= ShippingAddressCustomCntrl.getContactPointAddress(wcard[0].Id); 
        Test.stopTest();
		System.assertEquals(ar.isSuccess, true, 'Expecting Error');
        
    }
    @IsTest
    static void testException(){
        
		AuraResponse ar;
        
        Test.startTest();
        ar= ShippingAddressCustomCntrl.getContactPointAddress('903'); 
        Test.stopTest();
		System.assertEquals(ar.isSuccess, false, 'Expecting Error');
        
    }
}