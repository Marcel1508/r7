/**
 * @CreatedBy       : Suliman A.
 * @Date            : 01/07/2021
 * @Company         : IBM, Bluewolf
 * @Description     : CustomLookupController test class.  
 */

@isTest
public class CustomLookupController_TST {
    
     @IsTest
     static void customLookupControllerInstantiation() {
          CustomLookupController controller = new CustomLookupController();
          System.assertNotEquals(controller, null);
     }
    
    @isTest
    static void testIsGerantOrCommercial(){
        System.assertEquals('PT1', CustomLookupController.isGerantOrCommercial(UserInfo.getUserId()));
    }
    
    @isTest
    static void testCreateCreneau(){
        //Create a Magasin
        Magasin__c magasin = new Magasin__c(
        	Name = 'Magasin Test ApiGee',
            API_Key__c = 'MagasinTestApiGee',
            Minimum_Commande_Drive_Deporte__c = 22,
            Minimum_Commande_Livraison__c = 10,
            Minimum_Commande_Drive__c = 8,
            Pourcentage_additionel_carte__c = 5,
            Autoriser_livraison_aux_nouveaux_clients__c = true,
            Responsable__c = UserInfo.getUserId()
        );
        insert magasin;
        
        //Create APE
        Code_APE__c codeAPE = new Code_APE__c(
        	APE_code__c = 'P13',
            Name = 'Test APE',
            Code_specialisation__c = 'A1'
        );
        Insert codeAPE;
        
        // Create an account
        Account acc = new Account(
            Magasin_actif_en_cours__c = Magasin.Id,
            Forme_juridique__c = '01',
            Name = 'Test ApiGee',
            Numero_Client__c = '12Test',
            Enseigne_commerciale__c = 'PA1',
            code_APE__c = codeAPE.Id,
            Origine__c = '4',
            //Numero_Siret__c = '1111',
            BillingStreet = '12 Rue Test',
            BillingPostalCode = '1012',
            BillingCity = 'Paris',
            Specialisation__c = '1A',
            Theme__c = '34;25;37',
            Email__c = 'test@test.co',
            Piece_identite__c = false,
            Categorie__c = '1',
            Attestation_registre_du_commerce__c = false,
          //  BillingCountry = 'France',
            BillingCountryCode = 'FR',
            NPAI_facturation__c = true,
            ShippingStreet = '12 Rue test',
            ShippingPostalCode = '1012',
            ShippingCity = 'Paris',
           // ShippingCountry = 'France',
            ShippingCountryCode = 'FR',
            NPAI_livraison__c = true,
            K_bis__c = true,
            RIB__c = true,
            Chaine_bloquee__c = false,
            Statut_Fiche_client__c = 'Prospect',
            Aquilon_Synchronisation_Statut__c = '',
            Aquilon_synchronisation_details__c = ''
        ); 
        AccountTriggerHandler.bypassTrigger = true;
        insert acc;
        
        //Create pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create an Order
        Order ord = new Order(
            AccountId = acc.Id,
            //Code_etablissement__c = '1313',
            //Num_client__c = '01',
            Mode_de_retrait__c = '1',
            //OrderNumber = '1111',
            Commande_en_stock__c = 'O',
            Commande_payee__c = 'O',
            Montant_Commande_TTC__c = 23,
            Status = 'Draft order',
            EffectiveDate = system.today(),
            Origine_de_la_commande__c = 'E-commerce',
            Pricebook2Id =  pricebookId
        ); 
        insert ord;
        
        //Create Creneau_Salesforce__c
        Creneau_Salesforce__c creneauSalesforce = new Creneau_Salesforce__c(
        	Magasin__c = magasin.Id
        );
        insert creneauSalesforce;
        
        //Initiate Creneau_client__c
        Creneau_client__c creneauClient = new Creneau_client__c(
        	Commande__c = ord.Id,
            Creneau_Salesforce__c = creneauSalesforce.Id
        );
        
        //Create a web store
        WebStore testWebStore = new WebStore(
            Name='TestWebStore',
            DefaultLanguage='fr'
        );
        insert testWebStore;
        
        //Create a Cart
        WebCart cart = new WebCart(
            Name='Cart',
            WebStoreId=testWebStore.Id,
            AccountId=acc.Id
        );
        insert cart;
        
        List<String> accountId = new List<String>();
        accountId.add(acc.Id);
        
        List<ConnectApi.WishlistItemInput> wishlistItemInputs = new List<ConnectApi.WishlistItemInput>();
        List<ConnectApi.WishlistInput> wishlistInputs = new List<ConnectApi.WishlistInput>();
        
        Test.startTest();
        CustomLookupController.createCreneau(creneauClient, ord.Id);
        CustomLookupController.returnAllTaxes(String.valueOf(cart.Id));
        CustomLookupController.createWishlists(accountId, 'wishListTest', String.valueOf(testWebStore.Id), wishlistItemInputs, wishlistInputs);
        Test.stopTest();
    }
	
    @isTest
    static void testLookupController() {
        //Create a Magasin
        Magasin__c magasin = new Magasin__c(
            Name = 'Magasin Test ApiGee',
            API_Key__c = 'MagasinTestApiGee',
            Minimum_Commande_Drive_Deporte__c = 22,
            Minimum_Commande_Livraison__c = 10,
            Minimum_Commande_Drive__c = 8,
            Pourcentage_additionel_carte__c = 5,
            Autoriser_livraison_aux_nouveaux_clients__c = true,
            Responsable__c = UserInfo.getUserId()
        );
        insert magasin;
        //Create APE
        Code_APE__c codeAPE = new Code_APE__c(
        	APE_code__c = 'P13',
            Name = 'Test APE',
            Code_specialisation__c = 'A1'
        );
        Insert codeAPE;
        
        // Create an account
        Account acc = new Account(
            Magasin_actif_en_cours__c = Magasin.Id,
            Forme_juridique__c = '01',
            Name = 'Test ApiGee',
            Numero_Client__c = '12Test',
            Enseigne_commerciale__c = 'PA1',
            code_APE__c = codeAPE.Id,
            Origine__c = '4',
            //Numero_Siret__c = '1111',
            BillingStreet = '12 Rue Test',
            BillingPostalCode = '1012',
            BillingCity = 'Paris',
            Specialisation__c = '1A',
            Theme__c = '34;25;37',
            Email__c = 'test@test.co',
            Piece_identite__c = false,
            Categorie__c = '1',
            Attestation_registre_du_commerce__c = false,
          //  BillingCountry = 'France',
            BillingCountryCode = 'FR',
            NPAI_facturation__c = true,
            ShippingStreet = '12 Rue test',
            ShippingPostalCode = '1012',
            ShippingCity = 'Paris',
           // ShippingCountry = 'France',
            ShippingCountryCode = 'FR',
            NPAI_livraison__c = true,
            K_bis__c = true,
            RIB__c = true,
            Chaine_bloquee__c = false,
            Statut_Fiche_client__c = 'Prospect',
            Aquilon_Synchronisation_Statut__c = '',
            Aquilon_synchronisation_details__c = ''
        ); 
        AccountTriggerHandler.bypassTrigger = true;
        insert acc;
        
        List<String> accountId = new List<String>();
        accountId.add(acc.Id);
        
        Test.startTest();
        CustomLookupController.findRecords('test', 'Account','Name',10);
        CustomLookupController.findRecords2('test', 'Account','Name', 'Name', magasin.Name);
        CustomLookupController.returnUser(UserInfo.getName());
        CustomLookupController.returnUserId(UserInfo.getName());
        CustomLookupController.returnUserAccountMap(accountId);
        Test.stopTest();
    }
}