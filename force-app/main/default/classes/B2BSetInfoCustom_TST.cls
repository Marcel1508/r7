/**
 * @CreatedBy       : Suliman A.
 * @Date            : 01/07/2021
 * @Company         : IBM, Bluewolf
 * @Description     : B2BSetInfoCustom test class.  
 */

@isTest
public class B2BSetInfoCustom_TST {

    @isTest
    static void setFavListTest(){
        //Create CodeAPI
        Code_APE__c codeAPE = TestDataFactory.createCodeAPE('Test APE');
        Insert codeAPE;
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;
        // Create an account
        Account acc = new Account(
            Forme_juridique__c = '01',
            Name = 'Test ApiGee',
            BillingStreet = '12 Rue Test',
            BillingPostalCode = '1012',
            BillingCity = 'Paris',
            Specialisation__c = '1A',
            Theme__c = '34;25;37',
            Email__c = 'test@test.co',
            Categorie__c = '1',
            Attestation_registre_du_commerce__c = false,
            BillingCountryCode = 'FR',
            NPAI_facturation__c = true,
            ShippingStreet = '12 Rue test',
            ShippingPostalCode = '1012',
            ShippingCity = 'Paris',
            NPAI_livraison__c = true,
            K_bis__c = true,
            RIB__c = true,
            Chaine_bloquee__c = false,
            Statut_Fiche_client__c = 'Prospect',
            Enseigne_commerciale__c = 'Test',
            Code_APE__c = codeAPE.Id,
            Magasin_de_rattachement__c = magasinRec.Id,
            Magasin_actif_en_cours__c = magasinRec.Id
        ); 
        insert acc;
        
        //Create a web store
        WebStore testWebStore = TestDataFactory.createWebStoreRecord();
        Insert testWebStore;
        //Create a Wishlist
        Wishlist wishList = TestDataFactory.createwishListRecord(testWebStore.id,acc.id);
        Insert wishList;
        
        Test.startTest();
        	System.assertEquals(wishList.Id, B2BSetInfoCustom.setFavWishlistId(acc.Id, wishList.Id));
        Test.stopTest();
    }
}