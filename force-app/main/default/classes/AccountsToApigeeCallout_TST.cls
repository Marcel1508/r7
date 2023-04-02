/**
 * @CreatedBy       : Suliman A.
 * @Date            : 14/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A test class for AccountsToApigeeCallout_SVC AND AccountResultsToApigee_SVC classes, it uses 'AccountsHttpCalloutMock_TST' to receive the mock response that we specified.  
 */

@isTest
private class AccountsToApigeeCallout_TST {
    
    public static Account createAccount(){
        AccountTriggerHandler.bypassTrigger = true;
        //Create a Magasin
        Magasin__c Magasin = new Magasin__c(
        	Name = 'Test Magasin',
        	Code_etablissement__c = '123',
            Pourcentage_additionel_carte__c = 12,
            Minimum_Commande_Drive__c = 10, 
            Minimum_Commande_Livraison__c = 5, 
            Minimum_Commande_Drive_Deporte__c = 15, 
            API_Key__c = '12Test'
        ); 
        insert Magasin;
        
        
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
            Numero_Client__c = '12Tes',
            Enseigne_commerciale__c = 'PA',
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
            En_cours_de_creation_au_reg_du_commerce__c = True,
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
            Aquilon_synchronisation_details__c = '',
            Code_Chaine__c='testew'
            
        ); 
        insert acc;
        
        
        
        //Create a Contact
        Contact contact = new Contact(
        	LastName = 'Test',
            FirstName = 'Contacto',
            AccountId = acc.Id,
            Roles__c = 'Propriétaire',
            Contact_principal__c = True,
            Telephone_portable__c='8675654534'
        );
        insert contact;
        
        //Create Information_financiere
        Information_financiere__c infoFinance = new Information_financiere__c(
        	Account__c = acc.Id,
            Magasin__c = Magasin.Id
        );
        insert infoFinance;
        
        //Create a Codes Postaux
        Codes_Postaux__c codePosteaux = new Codes_Postaux__c(
        	Code_postal__c = '75011',
            Name = 'CP_02',
            Pays__c='AF',
            Commune__c = 'Paris'
            
        );
        insert codePosteaux;
        
        //Create a Shipping add
        ContactPointAddress shippingAddr = new ContactPointAddress(
        	Numero_de_voie__c = '11',
            Type_de_voie__c = 'AV',
            Nom_de_voie__c = 'La Parrandera ',
            Name = 'Shipping Address',
            postalCode = '75000',
            City = 'Paris',
           // Country = 'France',
            CountryCode = 'FR',
            AddressType = 'Shipping',
            IsDefault = True,
            ParentId = acc.Id
        );
        insert shippingAddr;
        
        //Create a Shipping add
        ContactPointAddress billingAddr = new ContactPointAddress(
        	Numero_de_voie__c = '11',
            Type_de_voie__c = 'AV',
            Nom_de_voie__c = 'La Parrandera',
            Name = 'Billing Address',
            postalCode = '75000',
            City = 'Paris',
           // Country = 'France',
            CountryCode = 'FR',
            AddressType = 'Billing',
            IsDefault = True,
            ParentId = acc.Id
        );
        insert billingAddr;
        
        return acc;
    }

public static Account createLargeLengthAccount(){
        AccountTriggerHandler.bypassTrigger = true;
        //Create a Magasin
        Magasin__c Magasin = new Magasin__c(
        	Name = 'Test Magasin1',
        	Code_etablissement__c = '12398',
            Pourcentage_additionel_carte__c = 15,
            Minimum_Commande_Drive__c = 14, 
            Minimum_Commande_Livraison__c = 15, 
            Minimum_Commande_Drive_Deporte__c = 12, 
            API_Key__c = '127Test'
        ); 
        insert Magasin;
        
        
        Code_APE__c codeAPE = new Code_APE__c(
        	APE_code__c = 'P14',
            Name = 'Test APeE1',
            Code_specialisation__c = 'A2'
        );
        Insert codeAPE;
        
        // Create an account
        Account acc = new Account(
            Magasin_actif_en_cours__c = Magasin.Id,
            Forme_juridique__c = '01',
            Name = 'Test ApiGee words should be more than 28 for testing purpose pppppppppppppppppppppppppppp',
            Numero_Client__c = '12test',
            Enseigne_commerciale__c = 'words should be more than 28 for testing purpose pppppppppppppppppppppppppppp',
            code_APE__c = codeAPE.Id,
            Origine__c = '4',
            Numero_Siret__c = '89322742100011',
            BillingStreet = '12 Rue Test',
            BillingPostalCode = '1012',
            BillingCity = 'Paris',
            Specialisation__c = '1A',
            Theme__c = '34;25;37',
            Email__c = 'test@test.co',
            Piece_identite__c = false,
            Categorie__c = '1',
            En_cours_de_creation_au_reg_du_commerce__c = True,
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
            Aquilon_synchronisation_details__c = '',
            Code_Externe_Chaine_Text__c='qk'
        ); 
        insert acc;
        
        
        
        //Create a Contact
        Contact contact = new Contact( 
        	LastName = 'Test data with large amount data twenty words',
            FirstName = 'Contacto data with large ',
            AccountId = acc.Id,
            Roles__c = 'Propriétaire',
            Contact_principal__c = True,
            Telephone_portable__c='000000000000000987'
        );
        insert contact;
        
        //Create Information_financiere
        Information_financiere__c infoFinance = new Information_financiere__c(
        	Account__c = acc.Id,
            Magasin__c = Magasin.Id,
             Nom_banque__c = 'Boursoramauytrertyuioiuy', 
            Siret_Payeur__c = '41040946000756',
            complment_adresse_Banque__c='qwertyuiqwertyuiqwertyuiqwertyui',
            Ville_Banque__c='qwertqwertqwertqwertqwert',
            Code_banque__c='qwert',
            Code_guichet__c='qwert',
            N_de_compte__c='qwertyuiopq',
            Cle_RIB__c='qw',
            BIC__c='qazwsxedcrf',
           Code_IBAN__c='test the character of thirty twooo',
            Type_voie_Banque__c='qwert',
            numro_de_voie_Banque__c='qwert',
            Code_postal_Banque__c='qwert'

        );
        insert infoFinance;
        
        //Create a Codes Postaux
        Codes_Postaux__c codePosteaux = new Codes_Postaux__c(
        	Code_postal__c = '75011',
            Name = 'CP_02',
            Commune__c = 'Paris',
            Pays__c='AF'
        );
        insert codePosteaux;
        
        //Create a Shipping add
        ContactPointAddress shippingAddr = new ContactPointAddress(
        	Numero_de_voie__c = '11098',
            Type_de_voie__c = 'AV',
            Nom_de_voie__c = 'La Parrandera',
            Name = 'Shipping Address',
            postalCode = '75000',
            City = 'Paris',
           // Country = 'France',
            CountryCode = 'FR',
            AddressType = 'Shipping',
            Complement_d_adresse__c='test data for address for more than thirty words .testing.',
            IsDefault = True,
            ParentId = acc.Id
          
        );
        insert shippingAddr;
        
        //Create a Shipping add
        ContactPointAddress billingAddr = new ContactPointAddress(
        	Numero_de_voie__c = '11980',
            Type_de_voie__c = 'AV',
            Nom_de_voie__c = 'La Parrandera',
            Name = 'Billing Address',
            postalCode = '75000',
              Complement_d_adresse__c='test data for address for more than thirty words .testing.testing.testing.testing',
            City = 'Paris',
           // Country = 'France',
            CountryCode = 'FR',
            AddressType = 'Billing',
            IsDefault = True,
            ParentId = acc.Id
          
        );
        insert billingAddr;
        
        
    
        return acc;
    }
    
	@isTest
    static void testPostCallout() {
        //List<Account> accountList = createAccount();
        Account acc = createAccount();
        Account acc1 = createLargeLengthAccount();
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AccountsHttpCalloutMock_TST());  
        // This causes a fake response to be sent
        String expectedValue = '{"detailed_account" : {"attributes" : {"N_client__c" : "01557","Code_etablissement__c" : "1313","Forme_juridique__c" : "01","Name" : "Test ApiGee","Numero_Siret__c" : "1111","BillingStreet" : "12 Rue Test","BillingPostalCode" : "1012","BillingCity" : "Paris","Specialisation__c" : "1A","Theme__c" : "25;37","Libell_code_APE__c" : "-","Email__c" : "test@test.co","Piece_identite__c" : false,"Categorie__c" : "1","Attestation_registre_du_commerce__c" : false,"BillingCountryCode" : "FR","NPAI_facturation__c" : true,"ShippingStreet" : "12 Rue test","ShippingPostalCode" : "1012","ShippingCity" : "Paris","ShippingCountryCode" : "FR","NPAI_livraison__c" : true,"K_bis__c" : true,"RIB__c" : true,"Chaine_bloquee__c" : false}';
        
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        	//AccountResultsToApigee_SVC.getAccounts('AInsert', accountList);
       		 AccountResultsToApigee_SVC.getAccounts('AInsert', getAccount(acc.Id));
        	AccountResultsToApigee_SVC.getAccounts('AInsert', getAccount(acc1.Id));
            AccountsToApigeeCallout_SVC.accountPostOrPutCallout('', expectedValue, acc.Id, '', '', '');
        Test.stopTest();
    }
    
    @isTest
    static void testPutCallout() {
        //List<Account> accountList = createAccount();
        Account acc = createAccount();
        Account acc1 = createLargeLengthAccount();
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AccountsHttpCalloutMock_TST()); 
        // This causes a fake response to be sent
        String expectedValue = '{"detailed_account" : {"attributes" : {"N_client__c" : "01557","Code_etablissement__c" : "1313","Forme_juridique__c" : "01","Name" : "Test ApiGee","Numero_Siret__c" : "1111","BillingStreet" : "12 Rue Test","BillingPostalCode" : "1012","BillingCity" : "Paris","Specialisation__c" : "1A","Theme__c" : "25;37","Libell_code_APE__c" : "-","Email__c" : "test@test.co","Piece_identite__c" : false,"Categorie__c" : "1","Attestation_registre_du_commerce__c" : false,"BillingCountryCode" : "FR","NPAI_facturation__c" : true,"ShippingStreet" : "12 Rue test","ShippingPostalCode" : "1012","ShippingCity" : "Paris","ShippingCountryCode" : "FR","NPAI_livraison__c" : true,"K_bis__c" : true,"RIB__c" : true,"Chaine_bloquee__c" : false}';
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        	//AccountResultsToApigee_SVC.getAccounts('AUpdate', accountList);
       		AccountResultsToApigee_SVC.getAccounts('AUpdate',  getAccount(acc.Id));
        AccountResultsToApigee_SVC.getAccounts('AUpdate',  getAccount(acc1.Id));
            AccountsToApigeeCallout_SVC.accountPostOrPutCallout('01557', expectedValue, acc.Id, '', '', '');
        Test.stopTest();
    }
    
    
    private static List<Account> getAccount(Id accountID){
        return [SELECT Id, Name, Type, RecordTypeId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode,
                ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, Phone, Fax, AccountNumber,
                Website, PhotoUrl, Sic, Industry, AnnualRevenue, NumberOfEmployees, Description, Rating, Site, CurrencyIsoCode, OwnerId, CreatedDate, IsBuyer, 
                SAP_Account__c, Reference_client__c, Fidelite__c, Frais_autorisations__c, Numero_Siret__c, FirstOrder__c, 
                Adresse_siege_social__c, X1er_achat__c, Solde_client__c, Autonumber__c, Etat_activite_etablissement__c, Changement_de_mag_de_rattachement__c, Email__c,
                Code_etablissement__c,  Demande_refusee__c, Numero_Client__c,  Aquilon_Synchronisation_Statut__c, 
                Aquilon_Synchronisation_details__c, MaxProspectNumber__c, Mode_de_reglement__c, Relation_magasin_geographique__c, Supprime__c, ifAccountSentToAkeneo__c,
                SirenText__c, NPAI_livraison__c, Magasin_actif_en_cours__c, Code_NAF_entreprise__c, NPAI_facturation__c, Chaine_bloquee__c, Activite_potentiel__c,
                Libelle_Chaine_nationale__c, Forme_juridique__c, NICText__c, Palier_de_RFA_du_client__c, Palier_de_RFA_entite_capitalistique__c,
                Origine_creation_magasin__c, Specialisation_new__c, N_client__c, Echeance__c, Enseigne_commerciale__c, Etablissement_geographique__c,
                Regroupement__c, Origine__c, Contact_principal_la_creation__c, Categorie__c, Specialisation__c, SiretText__c, Code_Externe_Chaine_Text__c,
                Entite_capitalistique__c, CountDefaultExpeditionAddresses__c, CountDefaultFacturationAddresses__c, K_bis__c, Piece_identite__c, RIB__c,
                Commentaires__c, Parent_ultime__c, Activite__c, Code_commune__c, N_association__c, Theme__c, Attestation_registre_du_commerce__c,
                Date_creation_etablissement__c, Etablissements_actifs__c, Statut_Client_sur_le_Magasin__c, Statut_Fiche_client__c,
                Assigne_a__c, Magasin_de_rattachement__c, Client_grand_compte__c, Zone_blanche__c, Code_Chaine__c, Email_du_contact__c, 
                Client_desactive__c, Pour_la_les_raison_s__c, En_cours_de_creation_au_reg_du_commerce__c, Telephone_Siret__c, Code_INSEE__c, Code_Zone_de_chalandise__c, 
                Code_APE__c, Libell_code_APE__c, Assigne_au_user__c, Type_de_client__c, ete__c, Hiver__c, Date_fermeture_etablissement__c FROM Account where id =: accountID];
    }


   public class AccountsHttpCalloutMock_TST implements HttpCalloutMock {
    
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"detailed_account" : {"attributes" : {"N_client__c" : "01557","Code_etablissement__c" : "1313","Forme_juridique__c" : "01","Name" : "Test ApiGee","Numero_Siret__c" : "1111","BillingStreet" : "12 Rue Test","BillingPostalCode" : "1012","BillingCity" : "Paris","Specialisation__c" : "1A","Theme__c" : "25;37","Libell_code_APE__c" : "-","Email__c" : "test@test.co","Piece_identite__c" : false,"Categorie__c" : "1","Attestation_registre_du_commerce__c" : false,"BillingCountry" : "France","NPAI_facturation__c" : true,"ShippingStreet" : "12 Rue test","ShippingPostalCode" : "1012","ShippingCity" : "Paris","ShippingCountry" : "France","NPAI_livraison__c" : true,"K_bis__c" : true,"RIB__c" : true,"Chaine_bloquee__c" : false}}');
            response.setStatusCode(200);
            return response; 
        }
    
    }
    
}