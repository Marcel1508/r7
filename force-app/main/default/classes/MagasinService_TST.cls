/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Classe de test de la classe MagasinService
**/

@IsTest
public class MagasinService_TST {
    
    private static Magasin__c createMagasin(String extension, String rang) {
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('TEST Magasin');
        magasinRec.Extension_de_gamme__c= extension;
        magasinRec.Rang_tarifaire__c= rang;
        Insert magasinRec ;
        return magasinRec;
    }
    private static Account createAccount(Magasin__c magasinId) {
        Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinId);
        insert accTest;
        return accTest;
    }
    private static Product2 createProduct() {
        Product2 prd = TestDataFactory.createGenericProduct();
        Insert prd;
        return prd;
    }
    
    private static Pricebook2 createPriceBook() {
        return (Pricebook2) new SObjectBuilder(Pricebook2.SObjectType)
            .put(Pricebook2.Name, 'Standard TEST Magasin')
            .put(Pricebook2.isActive, True)
            .create().getRecord();
    }
    private static Offre_Produit_Magasin__c createOPM(Id magasinId, Id productId, String produitActif) {
        return (Offre_Produit_Magasin__c) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinId)
            .put(Offre_Produit_Magasin__c.Produit__c, productId)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, produitActif)
            .create().getRecord();
    }
    private static CommerceEntitlementProduct createCEP() {
        Magasin__c mag = [select Id, Name from Magasin__c where name = 'TEST Magasin' Limit 1];
        Product2 prd = [select Id,name from Product2 where name='TEST Product' Limit 1];
        CommerceEntitlementPolicy conEP = new CommerceEntitlementPolicy();
        conEP.Libelle_Etablissement__c = mag.Id;
        conEP.Name = 'Test conEP';
        Insert conEP;
        return (CommerceEntitlementProduct) new SObjectBuilder(CommerceEntitlementProduct.SObjectType)
            .put(CommerceEntitlementProduct.productId, prd.id)
            .put(CommerceEntitlementProduct.policyId, conEP.Id)
            .create().getRecord();
    }
    
    
    @IsTest
    private static void testUpdateOPM(){
        OffreProduitMagasinTriggerHandler.bypassTrigger = true;
        Magasin__c testMagasin = createMagasin('oui','T2');
        Account testAccount = createAccount(testMagasin);
        Product2 testProduct = createProduct();
        //Instantiate the Pricebook2 record with StandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        //Insert a price book entry for the standard price book.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = testProduct.Id,
            UnitPrice = 10000, 
            IsActive = true
        );
        insert standardPrice;
        Pricebook2 testPricebook = createPriceBook();
        Offre_Produit_Magasin__c testOPM = createOPM(testMagasin.Id, testProduct.Id,'O');
        CommerceEntitlementProduct cep = createCEP();
        Test.startTest(); 
        MagasinTriggerHandler.firstRun = true;
        testMagasin.Extension_de_gamme__c = 'non';
        testMagasin.Rang_tarifaire__c = 'T3';
        update testMagasin;
        testOPM.Produit_actif__c = 'N';
        testOPM.Quantite_minimum_de_commande__c = 10;
        update testOPM;
                
        List <Offre_produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c, Produit_actif__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.assertEquals('N', resultTestOPM.get(0).Produit_actif__c);
        Test.stopTest();
    }
}