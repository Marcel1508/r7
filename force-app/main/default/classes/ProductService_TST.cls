/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Class test of ProductService class
**/

@IsTest
public class ProductService_TST {
    
    @IsTest
    private static void testUpdateProduct(){   
        //Produit non actif sur update
        //=>    Désactive le produit avec statut 5
        CommerceEntitlementPolicy  cmp= new CommerceEntitlementPolicy();
        cmp.Name='Guest Policy';
        insert cmp;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Id=pricebookId,Name = 'Standard Price Book', Description = 'Price Book Products', IsActive = true);
        update pb;


        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Rang_tarifaire__c , 'T2')

            .create().getRecord();
        Magasin__c testMagasin1 = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Rang_tarifaire__c , 'T3')

            .create().getRecord();

        List< Product2>  prodList = new List<Product2>();
        Product2 testProduct = new Product2();
        testProduct.put('Name', 'TEST Product');
        testProduct.put('Extension_de_gamme__c', true);
        prodList.add(testProduct);
        
        Product2 testProduct1 = new Product2();
        testProduct1.put('Name', 'TEST Product');
        testProduct1.put('Extension_de_gamme__c', true);
        testProduct1.put('Prix_de_vente_tarif_T2__c',30);
        prodList.add(testProduct1);

        Product2 testProduct2 = new Product2();
        testProduct2.put('Name', 'TEST Product');
        testProduct2.put('Extension_de_gamme__c', true);
        prodList.add(testProduct2);
        
        Product2 testProduct3 = new Product2();
        testProduct3.put('Name', 'TEST Product');
        testProduct3.put('Extension_de_gamme__c', true);
        prodList.add(testProduct3);
        
        Product2 testProduct4 = new Product2();
        testProduct4.put('Name', 'TEST Product');
        testProduct4.put('Extension_de_gamme__c', true);
        prodList.add(testProduct4);
        
        Product2 testProduct5 = new Product2();
        testProduct5.put('Name', 'TEST Product');
        testProduct5.put('Extension_de_gamme__c', true);
        prodList.add(testProduct5);
        
        Product2 testProduct6 = new Product2();
        testProduct6.put('Name', 'TEST Product');
        testProduct6.put('Extension_de_gamme__c', true);
        prodList.add(testProduct6);
        
        Product2 testProduct7 = new Product2();
        testProduct7.put('Name', 'TEST Product');
        testProduct7.put('Extension_de_gamme__c', true);
        prodList.add(testProduct7);

        Insert prodList;

        List<Offre_Produit_Magasin__c> testOPM = new List<Offre_Produit_Magasin__c>();
        Offre_Produit_Magasin__c opm1 = new Offre_Produit_Magasin__c();
        opm1.put('Name', 'TEST OPM');
        opm1.put('Magasin__c', testMagasin.Id);
        opm1.put('Produit__c', testProduct.Id);
        opm1.put('Produit_actif__c', 'O');
		testOPM.add(opm1);
        
        Offre_Produit_Magasin__c opm2 = new Offre_Produit_Magasin__c();
        opm2.put('Name', 'TEST OPM');
        opm2.put('Magasin__c', testMagasin.Id);
        opm2.put('Produit__c', testProduct.Id);
        opm2.put('Produit_actif__c', 'N');
        opm2.put('Prix_de_vente_magasin__c',0);
		testOPM.add(opm2);
        
        Offre_Produit_Magasin__c opm3 = new Offre_Produit_Magasin__c();
        opm3.put('Name', 'TEST OPM');
        opm3.put('Magasin__c', testMagasin1.Id);
        opm3.put('Produit__c', testProduct1.Id);
        opm3.put('Produit_actif__c', 'O');
        opm3.put('Prix_de_vente_magasin__c',0);
        opm3.Niveau_de_stock__c=1;
		testOPM.add(opm3);
        
        Offre_Produit_Magasin__c opm4 = new Offre_Produit_Magasin__c();
        opm4.put('Name', 'TEST OPM');
        opm4.put('Magasin__c', testMagasin.Id);
        opm4.put('Produit__c', testProduct2.Id);
        opm4.put('Produit_actif__c', 'O');
        opm4.put('Actif_Aquilon__c',true);
        opm3.En_cours_de_commande__c=1;

        testOPM.add(opm4);
        
        insert testOPM;

        
       /* Offre_Produit_Magasin__c opm4 = new Offre_Produit_Magasin__c();
        opm1.put('Name', 'TEST OPM');
        opm1.put('Magasin__c', testMagasin.id);
        opm1.put('Produit__c', testProduct.id);
        opm1.put('Produit_actif__c', 'O');
		testOPM.add(opm1);*/




        
        Test.startTest(); 
        List< Product2>  prodList1 = new List<Product2>();

        testProduct.Prix_de_vente_tarif_T2__c=100;
        testProduct.Prix_de_vente_tarif_T3__c =100;
        testProduct.Produit_avec_assortiment__c='1';
        testProduct.Niveau_d_assortiment__c='1';
        testProduct.Code_departement__c='1';
        testProduct.Conditionnement_de_commande_PCB__c='1';
        testProduct.Extension_de_gamme__c=true;
        prodList1.add(testProduct);
        testProduct1.Extension_de_gamme__c = false;
        testProduct1.Prix_de_vente_tarif_T2__c=100;
        testProduct1.Prix_de_vente_tarif_T3__c =100;
        testProduct1.Produit_avec_assortiment__c='0';
        testProduct1.Niveau_d_assortiment__c='1';
        testProduct1.Code_departement__c='1';
        testProduct1.Conditionnement_de_commande_PCB__c='1';
        testProduct1.Extension_de_gamme__c=true;
        prodList1.add(testProduct1);
        
        testProduct2.Extension_de_gamme__c = false;
        testProduct2.Prix_de_vente_tarif_T2__c=50;
        testProduct2.Produit_avec_assortiment__c='0';
        testProduct2.Niveau_d_assortiment__c='1';
        testProduct2.Code_departement__c='1';
        testProduct2.Conditionnement_de_commande_PCB__c='1';
        testProduct2.Extension_de_gamme__c=false;
        prodList1.add(testProduct2);
        
        testProduct3.Produit_avec_assortiment__c='0';
        prodList1.add(testProduct3);
        testProduct4.Niveau_d_assortiment__c='1';
        prodList1.add(testProduct4);
        testProduct5.Code_departement__c='1';
        prodList1.add(testProduct5);
        testProduct6.Conditionnement_de_commande_PCB__c='1';
        prodList1.add(testProduct6);
        testProduct7.Extension_de_gamme__c=false;
        prodList1.add(testProduct7);



        testOPM.get(0).Produit_actif__c = 'N';
        update prodList1;
        update testOPM;
        
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c, Produit_actif__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.assertEquals('N', resultTestOPM.get(0).Produit_actif__c);
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortOnePrixDeVenteNoActifAquilon(){
        //Produit Assortiment 1, prix de vente T2 OK, NO Actif aquilon
        //=>    Désactive le produit avec statut 5
        
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '1')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, 7)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, 5)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortOnePrixDeVenteActifAquilonAvecStock(){   
        //Produit Assortiment 1, prix de vente T2 OK, Actif aquilon, avec stock
        //=>    Active le produit avec statut 3
        
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '1')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, 7)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, 5)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteT3(){   

        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = T3, département 2, Actif Aquilon, avec stock, Rupture Entrepot = false      
        //=>    Active le produit avec statut 3
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T3')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, 6)
            .put(Product2.Prix_de_vente_tarif_T3__c, 5)
            .put(Product2.Code_departement__c, '2')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartDeux(){   

        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 2       
        //=>    Désactive le produit avec statut 5
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
        @IsTest
    private static void testProductAssortZeroNoExtDeGammePrixDeVenteDepartDeuxStock(){   

        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 2       
        //=>    Active le produit avec statut 3
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, false)
            .put(Product2.Prix_de_vente_tarif_T2__c, 5)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroNoExtDeGammePrixDeVenteNullDepartDeux(){   

        //Produit Assortiment 0 avec Produit Extension de Gamme = false, prix de vente = null, département 2       
        //=>    Désactive le produit avec statut 5
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, false)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '2')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreAquilonStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, avec stock,rupture entrepot = false
        //=>    Active le produit avec statut 3
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
       // System.assertEquals('3', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon = false, 
        //avec stock, rupture entrepot = false
        //=>    Active le produit avec statut 1
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
      //  System.assertEquals('1', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
        @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonNoStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon = false, 
        //avec stock, rupture entrepot = false
        //=>    Désactive le produit avec statut 4
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        //System.assertEquals('4', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoStockRuptureEntrepotExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = oui
        //=>    Active le produit avec statut 2
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
       // System.assertEquals('2', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoStockRuptureEntrepotNoExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = non
        //=>    Désactive le produit avec statut 5
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'non')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonNoStockRuptureEntrepotExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), No Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = oui
        //=>    Active le produit avec statut 2
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
       // System.assertEquals('2', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreNoAquilonNoStockRuptureEntrepotNoExtGamMagasin(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), No Actif aquilon, sans stock, 
        //rupture entrepot = true, Extension de Gamme Magasin = non
        //=>    Désactive le produit avec statut 5
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'non')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, false)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
        System.assertEquals('5', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreAquilonNoStockNoRup(){
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, sans stock, rupture entrepot = false
        //=>    Désactive le produit avec statut 4
           Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 0)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 0)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, false)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
      //  System.assertEquals('4', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }
    
    @IsTest
    private static void testProductAssortZeroExtDeGammePrixDeVenteNullDepartQuatreStockRuptureEntrepot(){   
        //Produit Assortiment 0 avec Extension de Gamme, prix de vente = null, département 4 (pole frais), Actif aquilon, avec stock, rupture entrepot = true
        //=>    Active le produit avec statut 1
        Magasin__c testMagasin = (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Name, 'TEST Magasin')
            .put(Magasin__c.Extension_de_gamme__c, 'oui')
            .put(Magasin__c.Rang_tarifaire__c, 'T2')
            .create().getRecord();
            
        Product2 testProduct = (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Produit_avec_assortiment__c, '0')
            .put(Product2.Extension_de_gamme__c, true)
            .put(Product2.Prix_de_vente_tarif_T2__c, null)
            .put(Product2.Prix_de_vente_tarif_T3__c, null)
            .put(Product2.Code_departement__c, '4')
            .create().getRecord();
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, testMagasin.Id)
            .put(Offre_Produit_Magasin__c.Produit__c, testProduct.Id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, null)
            .put(Offre_Produit_Magasin__c.Actif_Aquilon__c, true)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .put(Offre_Produit_Magasin__c.Rupture_entrepot1__c, true)
            .count(1).create().getRecords();
        
        Test.startTest();
        Update testOPM;
        List <Offre_Produit_Magasin__c> resultTestOPM = [SELECT Name, Statut__c FROM Offre_Produit_Magasin__c WHERE Name = 'TEST OPM'];
        System.debug('Statut OPM : ' + resultTestOPM.get(0).Statut__c);
      //  System.assertEquals('1', resultTestOPM.get(0).Statut__c);
        Test.stopTest();
    }

    @IsTest
    private static void testProductCategoryProductCreation(){   
        ProductCatalog pc=new ProductCatalog();
        pc.Name='Test Promomcash';
        insert pc;
      List<ProductCategory> proCategories=new List<ProductCategory>();
  
        ProductCategory depart=new ProductCategory();
        depart.CatalogId=pc.Id;
        depart.Name='EPICERIE';
        depart.Category_External_Id__c='DEPART_8';
        depart.Code_categorie__c='8';
        depart.Type_de_categorie__c='DEPART';
        proCategories.add(depart);
        
        ProductCategory rayon=new ProductCategory();
        rayon.CatalogId=pc.Id;
        rayon.Name='SURGELES';
        rayon.Category_External_Id__c='RAYONS_38';
        rayon.Code_categorie__c='38';
        rayon.Type_de_categorie__c='RAYONS';
        proCategories.add(rayon);
        
        ProductCategory fam=new ProductCategory();
        fam.CatalogId=pc.Id;
        fam.Name='ELECTRICITE';
        fam.Category_External_Id__c='FAMBCG_387';
        fam.Code_categorie__c='387';
        fam.Type_de_categorie__c='FAMBCG';
        proCategories.add(fam);
        
        ProductCategory sfam=new ProductCategory();
        sfam.CatalogId=pc.Id;
        sfam.Name='ANCHOIS';
        sfam.SousFamilleExternalId__c='SFABCG_012_387';
        sfam.Code_categorie__c='012';
        sfam.Type_de_categorie__c='SFABCG';
        proCategories.add(sfam);
        
        insert proCategories;
        List<ProductCategory> proCategoriesNew=new List<ProductCategory>();
  
        ProductCategory depart1=new ProductCategory();
        depart1.CatalogId=pc.Id;
        depart1.Name='EPICERIEe';
        depart1.Category_External_Id__c='DEPART_9';
        depart1.Code_categorie__c='9';
        depart1.Type_de_categorie__c='DEPART';
        proCategoriesNew.add(depart1);
        
        ProductCategory rayon1=new ProductCategory();
        rayon1.CatalogId=pc.Id;
        rayon1.Name='SURGELESs';
        rayon1.Category_External_Id__c='RAYONS_36';
        rayon1.Code_categorie__c='36';
        rayon1.Type_de_categorie__c='RAYONS';
        proCategoriesNew.add(rayon1);
        
        ProductCategory fam1=new ProductCategory();
        fam1.CatalogId=pc.Id;
        fam1.Name='ELECTRICITEe';
        fam1.Category_External_Id__c='FAMBCG_397';
        fam1.Code_categorie__c='397';
        fam1.Type_de_categorie__c='FAMBCG';
        proCategoriesNew.add(fam1);
        
        ProductCategory sfam1=new ProductCategory();
        sfam1.CatalogId=pc.Id;
        sfam1.Name='ANCHOISs';
        sfam1.SousFamilleExternalId__c='SFABCG_012_397';
        sfam1.Code_categorie__c='012';
        sfam1.Type_de_categorie__c='SFABCG';
        proCategoriesNew.add(sfam1);
        
        insert proCategoriesNew;
      
      List<Product2> prlist=new List<Product2>();
  
      for(Integer i=0;i<5;i++){
          Product2 pr=new Product2();
          pr.Name='test bulk data'+i;
          pr.Code_departement__c='8';
          pr.Code_rayon__c='38';
          pr.Code_famille__c='387';
          pr.Code_sous_famille__c='012';
          prlist.add(pr);
      }
      
  
       
      
        Test.startTest();
        Product2 pr=new Product2();
        List<Product2> updatePrlist=new List<Product2>();
    
        insert prlist;
        pr.Name='test aj prod';
        insert pr;

        prlist[0].Code_departement__c='9';
        prlist[0].Code_rayon__c='36';
        prlist[0].Code_famille__c='397';
        prlist[0].Code_sous_famille__c='012';

        pr.Code_departement__c='8';
        pr.Code_rayon__c='38';
        pr.Code_famille__c='387';
        pr.Code_sous_famille__c='012';
        
        updatePrlist.add(pr);
        updatePrlist.add(prlist[0]);


        update updatePrlist;
           
        Test.stopTest();
    }

    /*******************************************************************************************************************
    * @description  Check if the populateLibellFinalField() method sets the field value as expected
    *
    * @result       method populates field with the Libelles_Data_Load__c field value as expected
    *******************************************************************************************************************/
    @IsTest
    static void testPopulateLibellFinalWithDataLoadSuccess() {
        List<Product2> products = new List<Product2>();
        Integer numOfRecords = 5;
        for(Integer i=0;i<numOfRecords;i++){
            products.add(
                    new Product2(
                            Name = 'test bulk data'+i,
                            Libelles_Data_Load__c = 'data_load',
                            Libelle_fournisseur__c = 'Libelle_fournisseur__c',
                            Libelle_commercial__c = 'Libelle_commercial__c',
                            Code_departement__c = '8',
                            Code_rayon__c = '38',
                            Code_famille__c = '387',
                            Code_sous_famille__c = '012'
                    )
            );
        }
        Assert.areEqual(numOfRecords, products.size());
        insert products;

        products = [
                SELECT Name, Libell_Final_TA__c, Libelles_Data_Load__c, Libelle_fournisseur__c, Libelle_commercial__c
                FROM Product2
                WHERE Id IN: products
        ];
        for(Product2 product : products) {
            Assert.areEqual(product.Libell_Final_TA__c, product.Libelles_Data_Load__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelle_fournisseur__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelle_commercial__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Name);
        }
    }

    /*******************************************************************************************************************
    * @description  Check if the populateLibellFinalField() method sets the field value as expected
    *
    * @result       method populates field with the Libelle_fournisseur__c field value as expected
    *******************************************************************************************************************/
    @IsTest
    static void testPopulateLibellFinalWithFournisseurSuccess() {
        List<Product2> products = new List<Product2>();
        Integer numOfRecords = 5;
        for(Integer i=0;i<numOfRecords;i++){
            products.add(
                    new Product2(
                            Name = 'test bulk data'+i,
                            Libelles_Data_Load__c = null,
                            Libelle_fournisseur__c = 'Libelle_fournisseur__c',
                            Libelle_commercial__c = 'Libelle_commercial__c',
                            Code_departement__c = '8',
                            Code_rayon__c = '38',
                            Code_famille__c = '387',
                            Code_sous_famille__c = '012'
                    )
            );
        }
        Assert.areEqual(numOfRecords, products.size());
        insert products;

        products = [
                SELECT Name, Libell_Final_TA__c, Libelles_Data_Load__c, Libelle_fournisseur__c, Libelle_commercial__c
                FROM Product2
                WHERE Id IN: products
        ];
        for(Product2 product : products) {
            Assert.areEqual(product.Libell_Final_TA__c, product.Libelle_fournisseur__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelles_Data_Load__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelle_commercial__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Name);
        }
    }

    /*******************************************************************************************************************
    * @description  Check if the populateLibellFinalField() method sets the field value as expected
    *
    * @result       method populates field with the Libelle_commercial__c field value as expected
    *******************************************************************************************************************/
    @IsTest
    static void testPopulateLibellFinalWithCommercialSuccess() {
        List<Product2> products = new List<Product2>();
        Integer numOfRecords = 5;
        for(Integer i=0;i<numOfRecords;i++){
            products.add(
                    new Product2(
                            Name = 'test bulk data'+i,
                            Libelles_Data_Load__c = null,
                            Libelle_fournisseur__c = null,
                            Libelle_commercial__c = 'Libelle_commercial__c',
                            Code_departement__c = '8',
                            Code_rayon__c = '38',
                            Code_famille__c = '387',
                            Code_sous_famille__c = '012'
                    )
            );
        }
        Assert.areEqual(numOfRecords, products.size());
        insert products;

        products = [
                SELECT Name, Libell_Final_TA__c, Libelles_Data_Load__c, Libelle_fournisseur__c, Libelle_commercial__c
                FROM Product2
                WHERE Id IN: products
        ];
        for(Product2 product : products) {
            Assert.areEqual(product.Libell_Final_TA__c, product.Libelle_commercial__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelle_fournisseur__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelles_Data_Load__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Name);
        }
    }

    /*******************************************************************************************************************
    * @description  Check if the populateLibellFinalField() method sets the field value as expected
    *
    * @result       method populates field with the Name field value as expected
    *******************************************************************************************************************/
    @IsTest
    static void testPopulateLibellFinalWithNameSuccess() {
        List<Product2> products = new List<Product2>();
        Integer numOfRecords = 5;
        for(Integer i=0;i<numOfRecords;i++){
            products.add(
                    new Product2(
                            Name = 'test bulk data'+i,
                            Libelles_Data_Load__c = null,
                            Libelle_fournisseur__c = null,
                            Libelle_commercial__c = null,
                            Code_departement__c = '8',
                            Code_rayon__c = '38',
                            Code_famille__c = '387',
                            Code_sous_famille__c = '012'
                    )
            );
        }
        Assert.areEqual(numOfRecords, products.size());
        insert products;

        products = [
                SELECT Name, Libell_Final_TA__c, Libelles_Data_Load__c, Libelle_fournisseur__c, Libelle_commercial__c
                FROM Product2
                WHERE Id IN: products
        ];
        for(Product2 product : products) {
            Assert.areEqual(product.Libell_Final_TA__c, product.Name);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelle_commercial__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelle_fournisseur__c);
            Assert.areNotEqual(product.Libell_Final_TA__c, product.Libelles_Data_Load__c);
        }
    }

}