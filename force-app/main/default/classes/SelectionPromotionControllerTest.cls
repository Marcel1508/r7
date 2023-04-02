/*------------------------------------
Author : Youssef JAMIL
Class : SelectionPromotionController
------------------------------------*/

@isTest
public class SelectionPromotionControllerTest {
    
    @testsetup static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Admin']; 
        User u = new User(Alias = 'standt', Email = 'user@carrefour.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName = Math.random()+'user@carrefour.com');
        insert u;
        System.runAs(u){
            Id userId = u.Id;
             Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        	magasinRec.Minimum_Commande_Drive__c = 1.0;
            magasinRec.Minimum_Commande_Drive_Deporte__c = 1.0;
            magasinRec.Minimum_Commande_Livraison__c = 1.0;
            magasinRec.Responsable__c = userId;
            Insert magasinRec ;
            
           Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

            //create Account
            Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Client',magasinRec);
            accTest.RecordTypeId = clientRecordTypeId;
            accTest.En_cours_de_creation_au_reg_du_commerce__c = true;
            Insert accTest;
            
             //create Contact
            Contact contactTest = TestDataFactory.createContactRecord(accTest.id);
            Insert contactTest;
            
            Product2 product = TestDataFactory.createGenericProduct();
            product.Code_rayon__c='32';
            product.Libelle_rayon__c = 'Boucherie';
            insert product;
            
            En_tete_Promotion__c promoHeader = new En_tete_Promotion__c(Name = 'pHeaderTest', Date_de_fin_de_l_action_promo__c = Date.today().addDays(7));
            insert promoHeader;
            
            Promotion__c promoLine = new Promotion__c (Produit__c=product.Id, Magasin__c = magasinRec.Id, En_tete_Promotion__c = promoHeader.Id );
            insert promoLine;
            
            DateTime sendDate = DateTime.newInstance(2022, 1, 31, 7, 7, 10);
            Campaign cmp = new Campaign(Name='campaignTest', Type='Email - Promotions', Template__c='Promotions avec rayons', Selected_Rayons__c='Boulangerie', Magasin__c = magasinRec.Id, Promotion_Header__c = promoHeader.Id, send_date__c = sendDate);
            insert cmp;
            
            
            Campaign_Config__c cmpsetting = new Campaign_Config__c();
            cmpsetting.RT_Campaign_EmailPromo__c = '0000000000';
            cmpsetting.RT_Campaign_MessageContenus__c = '1111111111';
            cmpsetting.RT_Campaign_ReadOnly__c = '2222222222';
            
            insert cmpsetting;
        }
    }
    
    @isTest
    public static void getCampaignTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        Campaign cmp; 
        System.runAs(u){
            Id cmpId = [select id, name from campaign where name='campaignTest'].id;
            Test.startTest();
            cmp = SelectionPromotionController.getCampaign(cmpId);
            SelectionPromotionController.getCampaignMembers(cmpId);
            Test.stopTest();    
        }
        //Assert the result
        System.assertEquals(cmp.Name,'campaignTest','Camapaign Name is OK');
        System.assertEquals(cmp.Type,'Email - Promotions','Campaign Type is OK');
        System.assertEquals(cmp.Template__c,'Promotions avec rayons','Campaign Template is OK');

    }
    
    @isTest
    public static void  getShelvesByPriorityTest(){
        SelectionPromotionController.rayonPromoMdt =(List<RayonsPriority_Setting__mdt>) JSON.deserialize('[{"DeveloperName":"Boucherie", "Label" : "Boucherie", "Priority__c" : 1}]', List<RayonsPriority_Setting__mdt>.class);

        Test.startTest();
        Map<String, String> shelfPriorityMap = SelectionPromotionController.getShelvesByPriority();
        Test.stopTest();
        //Assert the result
        System.assertEquals(shelfPriorityMap.get('1'), null, 'shelfPriorityMap does not contains item with keySet = 1');
    }
    
    @isTest
    public static void  getPromotionSetByTemplateTest(){
        
SelectionPromotionController.tplPromoMdt =(Template_Promotion_Setting__mdt) JSON.deserialize('{"DeveloperName":"Promotions_multi_produits","Label":"Promotions avec rayons", "Number_of_Promotions__c" : 9, "Nb_Max_Promo_Shelf__c" : 3}', Template_Promotion_Setting__mdt.class);

        Test.startTest();
        Template_Promotion_Setting__mdt shelfPriorityMap = SelectionPromotionController.getPromotionSetByTemplate('Promotions avec rayons');
        Test.stopTest();
        //Assert the result
        System.assertEquals(shelfPriorityMap.Label,'Promotions avec rayons','shelfPriorityMap.Label is Promotions avec rayons ');
    }
    
    @isTest
    public static void updateStringFieldCampaignTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        Campaign cmp;
        String oldValue;
        System.runAs(u){
            cmp = [select id, selected_rayons__c, name from campaign where name='campaignTest'];
            oldValue = cmp.selected_rayons__c;
            Test.startTest();
             cmp = (Campaign) SelectionPromotionController.updateFieldSObject(cmp.Id, 'Campaign', 'Selected_Rayons__c', 'Brasserie');
            Test.stopTest();
        }
        //Assert the result
        System.assertNotEquals(oldValue, cmp.selected_rayons__c,'');
     }

    @isTest
    public static void updateDateTimeFieldCampaignTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        Campaign cmp;
        DateTime oldValue;
        System.runAs(u){
            cmp = [select id, send_date__c, name from campaign where name='campaignTest'];
            oldValue = cmp.send_date__c;
            DateTime newValue = DateTime.newInstance(2022, 1, 31, 8, 7, 10);
            Test.startTest();
            cmp = (Campaign) SelectionPromotionController.updateFieldSObject(cmp.Id, 'Campaign', 'Send_Date__c', '2022-01-31 07:07:10');
            Test.stopTest();
        }
        //Assert the result
        System.assertNotEquals(oldValue, cmp.send_date__c,'');
     }
    
 	@isTest
    public static void getProductsByShelfTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        Map <string, Map<string, Map<String, List<String>>>> productsByShelfMap = new Map <string, Map<string, Map<String, List<String>>>>();
        System.runAs(u){
            Campaign cmp = [select id, Magasin__c, Promotion_Header__c, send_date__c, name from campaign where name='campaignTest'];

            Test.startTest();
            productsByShelfMap = SelectionPromotionController.getProductsByShelf(cmp.Promotion_Header__c, cmp.Magasin__c);
            Test.stopTest();
        }
        //Assert the results
        System.assert(productsByShelfMap.isEmpty(),'');
    }
    
    @isTest
    public static void updateCampLeadStatusTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        List<CampaignMember> cmpMbrs;
        System.runAs(u){
            Campaign cmp = [select id, send_date__c, name from campaign where name='campaignTest'];
            
            Lead leadTest = new Lead(LastName = 'TestLastName', FirstName = 'TestFirstName', Company='CompanyTest',  Email = 'testLead@org.com');
            insert leadTest;
        
            CampaignMember cmpMbr = new CampaignMember(CampaignId=cmp.Id, LeadId = leadTest.Id);
            insert cmpMbr;

            Test.startTest();
            cmpMbrs = SelectionPromotionController.updateCampMbrStatus(cmp.Id, new List<Id>{leadTest.Id},'Lead', 'Validé');
            Test.stopTest();
        }
        //Assert the result
        System.assert(cmpMbrs[0].Status == 'Validé','Status is validated');
    }
    @isTest
    public static void updateCampContactStatusTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        List<CampaignMember> cmpMbrs;
        System.runAs(u){
            Campaign cmp = [select id, send_date__c, name from campaign where name='campaignTest'];
            Magasin__c magasin = [select id, Name from Magasin__c where Name = 'magasinTest' limit 1];

            Account accTest = [select id from Account where Name ='TestAcc'];
            Contact contactTest = [select id from Contact where LastName='TestContact'];
            
            //create campaign member from contact
            CampaignMember cmpMbr = new CampaignMember(CampaignId=cmp.Id, ContactId = contactTest.Id);
            insert cmpMbr;

            Test.startTest();
            cmpMbrs = SelectionPromotionController.updateCampMbrStatus(cmp.Id, new List<Id>{contactTest.Id},'Contact', 'Validé');
            Test.stopTest();
        }
        System.assert(cmpMbrs[0].Status == 'Validé', 'Status is validated');
    }
    
    @isTest
    public static void addLeadToCampaignTest(){
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        CampaignMember cmpMbr;
        Campaign cmp;
        System.runAs(u){
            cmp = [select id, send_date__c, name from campaign where name='campaignTest'];
            cmpMbr = SelectionPromotionController.addLeadTestToCampaign(cmp.Id, u.Id);
        }
        //Assert the result
        System.assert(cmpMbr.CampaignId == cmp.Id, 'Campaign have been created'); 
    }
    
    
    @IsTest
    private static void testCampaignSetting() {
        User u = [select id, name from user where username LIKE '%carrefour.com' limit 1];
        Campaign_Config__c cmpSetting;
        System.runAs(u){
            Test.startTest();
                cmpSetting = SelectionPromotionController.getCampaignSettings();
            Test.stopTest();
        }
        System.assert(cmpSetting.RT_Campaign_EmailPromo__c == '0000000000', '');

    }

}