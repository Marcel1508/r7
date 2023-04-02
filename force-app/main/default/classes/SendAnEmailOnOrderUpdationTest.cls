/* .
code coverage odf SendAnEmailOnOrderUpdation.
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          08-05-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 
@IsTest
private class SendAnEmailOnOrderUpdationTest {
    
    @testSetup static void setup() {
        
        MagasinTriggerHandler.bypassTrigger=true;
        AccountTriggerHandler.bypassTrigger = true;
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('magasinTest');
        Insert magasinRec;
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
        Insert accTest;
        Contact contactTest = TestDataFactory.createContactRecord(accTest.id);
        Insert contactTest;
        
        User customer = TestDataFactory.createUserRecord();
        customer.ContactId = contactTest.id;
        Insert customer;
        System.runAs(customer) {
            Id pricebookId = Test.getStandardPricebookId();
            Order orderRec = TestDataFactory.createOrder(pricebookId);
            Insert orderRec;        
                
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'Facture_PDF_disponible';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
                
        } 
    }

    @IsTest
    static void testPositiveMailSend() {
        
            List<Magasin__c> magasins = [SELECT Id FROM Magasin__c  LIMIT 1];
            List<Order> orders = [SELECT Id, AccountId FROM Order  LIMIT 1];
            
            List<Order> ordr = orders; 
            List<Magasin__c> magasin = magasins;
            List<Id> orderId=new List<Id>();
            if(!ordr.isEmpty()) {
                orderId.add(ordr[0].Id);
                Facture__c factureObj = new Facture__c(
                Commande__c = ordr[0].Id,                                       // Commande
                //  Montant_total__c = 787.99,
                Magasin__c = magasin[0].Id, // Montant total,
            Code_carte_client__c= ordr[0].AccountId
            );
            insert factureObj;
            
            String yourFilesContent = 'TheBlogReaders.com File upload content';
            
            ContentVersion conVer = new ContentVersion();
            
            conVer.PathOnClient = 'testing.jpg'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'Testing Files'; // Display name of the files
            conVer.VersionData = Blob.valueOf(yourFilesContent); // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            
        
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record 
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = factureObj.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
        }
        
        Test.startTest();
        SendAnEmailOnOrderUpdation.sendEmailWithAttachment(orderId); 
        Test.stopTest();
        
    }
}