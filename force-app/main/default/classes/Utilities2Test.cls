@isTest
public class Utilities2Test {
    
    private static Order createOrder(Id accountId) {
        return (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, accountId)
                .create().getRecord();
    }
    
    
    @IsTest
    private static void getPickListValuesTest(){
        List < Map < String, String >> options = Utilities2.getPickListValues('Account', 'Forme_juridique__c');
        system.assert(options != null);
    }
    
    @IsTest
    private static void calculateFraisTest(){
        Map<String,String> stringFields = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais fixes'};
        Map<String,Decimal> decimalFields = new Map<String,Decimal>{'fraisTauxDeMajorationLivraison'=> 10,'fraisForfaitMajorationLivraison'=> 10, 'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2};
        Map<String,String> stringFields1 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais par zone de chalandise'};
        Map<String,Decimal> decimalFields1 = new Map<String,Decimal>{'fraisForfaitMajorationZone'=> 10,'fraisTauxDeMajorationZone'=> 10, 'fraisTauxDeMajorationPreparation'=> 2, 'fraisTauxDeMajorationPreparationDrive'=>2};
        Map<String,String> stringFields2 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais par tranche de CA'};
        Map<String,Decimal> decimalFields2 = new Map<String,Decimal>{'fraisCADebutTranche1'=> 20,'fraisTauxDeMajorationZone'=> 10, 'fraisCAFinTranche1'=> 105, 'fraisForfaitLivraisonCATranche1'=>2, 'fraisTauxMajorationCATranche1'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields3 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais par tranche de CA'};
        Map<String,Decimal> decimalFields3 = new Map<String,Decimal>{'fraisCADebutTranche2'=> 20,'fraisTauxDeMajorationZone'=> 10, 'fraisCAFinTranche2'=> 105, 'fraisForfaitLivraisonCATranche2'=>2, 'fraisTauxMajorationCATranche2'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields4 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais par tranche de CA'};
        Map<String,Decimal> decimalFields4 = new Map<String,Decimal>{'fraisCADebutTranche3'=> 20,'fraisTauxDeMajorationZone'=> 10, 'fraisCAFinTranche3'=> 105, 'fraisForfaitLivraisonCATranche3'=>2, 'fraisTauxMajorationCATranche3'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields5 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais par tranche de CA'};
        Map<String,Decimal> decimalFields5 = new Map<String,Decimal>{'fraisCADebutTranche4'=> 20,'fraisTauxDeMajorationZone'=> 10, 'fraisCAFinTranche4'=> 105, 'fraisForfaitLivraisonCATranche4'=>2, 'fraisTauxMajorationCATranche4'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields6 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Frais par tranche de CA'};
        Map<String,Decimal> decimalFields6 = new Map<String,Decimal>{'fraisCADebutTranche5'=> 20,'fraisTauxDeMajorationZone'=> 10, 'fraisCAFinTranche5'=> 105, 'fraisForfaitLivraisonCATranche5'=>2, 'fraisTauxMajorationCATranche5'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        
        Map<String,String> stringFields7 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> '','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields7 = new Map<String,Decimal>{'fraisCADebutTranche5'=> 20,'fraisTauxDeMajorationZone'=> 10, 'fraisCAFinTranche5'=> 105, 'fraisForfaitLivraisonCATranche5'=>2, 'fraisTauxMajorationCATranche5'=>2,'fraisTauxDeMajorationPreparation'=> 2, 'fraisTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields8 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais fixes','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields8 = new Map<String,Decimal>{'magasinTauxDeMajorationLivraison'=> 10,'magasinForfaitMajorationLivraison'=> 10, 'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2};
        Map<String,String> stringFields9 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais par tranche de CA','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields9 = new Map<String,Decimal>{'magasinCADebutTranche1'=> 20,'fraisTauxDeMajorationZone'=> 10, 'magasinCAFinTranche1'=> 105, 'magasinForfaitLivraisonCATranche1'=>2, 'magasinTauxMajorationCATranche1'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields10 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais par tranche de CA','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields10 = new Map<String,Decimal>{'magasinCADebutTranche2'=> 20,'fraisTauxDeMajorationZone'=> 10, 'magasinCAFinTranche2'=> 105, 'magasinForfaitLivraisonCATranche2'=>2, 'magasinTauxMajorationCATranche2'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields11 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais par tranche de CA','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields11 = new Map<String,Decimal>{'magasinCADebutTranche3'=> 20,'fraisTauxDeMajorationZone'=> 10, 'magasinCAFinTranche3'=> 105, 'magasinForfaitLivraisonCATranche3'=>2, 'magasinTauxMajorationCATranche3'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields12 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais par tranche de CA','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields12 = new Map<String,Decimal>{'magasinCADebutTranche4'=> 20,'fraisTauxDeMajorationZone'=> 10, 'magasinCAFinTranche4'=> 105, 'magasinForfaitLivraisonCATranche4'=>2, 'magasinTauxMajorationCATranche4'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };
        Map<String,String> stringFields13 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais par tranche de CA','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields13 = new Map<String,Decimal>{'magasinCADebutTranche5'=> 20,'fraisTauxDeMajorationZone'=> 10, 'magasinCAFinTranche5'=> 105, 'magasinForfaitLivraisonCATranche5'=>2, 'magasinTauxMajorationCATranche5'=>2,'magasinTauxDeMajorationPreparation'=> 2, 'magasinTauxDeMajorationPreparationDrive'=>2 };    
        Map<String,String> stringFields14 = new Map<String,String>{'magasinTypeDeFraisDeLivraison'=> 'Frais par zone de chalandise','fraisTypeDeFraisDeLivraison'=> 'Pas de frais négociés'};
        Map<String,Decimal> decimalFields14 = new Map<String,Decimal>{'magasinForfaitMajorationZone'=> 10,'magasinTauxDeMajorationZone'=> 10, 'fraisTauxDeMajorationPreparation'=> 2, 'fraisTauxDeMajorationPreparationDrive'=>2};

        Account acc = TestDataFactory.createMagasinWithAcc();
        System.debug('accId'+acc.Id);
        Order o = createOrder(acc.Id);
        System.debug('orderId'+o.Id);
        OrderDeliveryGroup odg = new OrderDeliveryGroup(DeliverToName='nom', OrderId = o.Id);
        insert odg;
        Test.startTest();
        OrderDeliveryGroup updatedOdg = Utilities2.calculateFrais(2, 2,odg,100,decimalFields, stringFields);
        OrderDeliveryGroup updatedOdg1 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields1, stringFields1);
        OrderDeliveryGroup updatedOdg2 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields2, stringFields2);
        OrderDeliveryGroup updatedOdg3 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields3, stringFields3);
        OrderDeliveryGroup updatedOdg4 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields4, stringFields4);
        OrderDeliveryGroup updatedOdg5 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields5, stringFields5);
        OrderDeliveryGroup updatedOdg6 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields6, stringFields6);
        OrderDeliveryGroup updatedOdg7 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields7, stringFields7);
        OrderDeliveryGroup updatedOdg8 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields8, stringFields8);
        OrderDeliveryGroup updatedOdg9 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields9, stringFields9);
        OrderDeliveryGroup updatedOdg10 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields10, stringFields10);
        OrderDeliveryGroup updatedOdg11 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields11, stringFields11);
        OrderDeliveryGroup updatedOdg12 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields12, stringFields12);
        OrderDeliveryGroup updatedOdg13 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields13, stringFields13);
        OrderDeliveryGroup updatedOdg14 = Utilities2.calculateFrais(2, 2,odg,100,decimalFields14, stringFields14);
        Test.stopTest();
    }
    
    @IsTest
    private static void getTwoSimilarProductsAndPricesTest(){
        Account accountTest = TestDataFactory.createMagasinWithAcc();
        Product2 productTest = TestDataFactory.createProduct();
        Product2 productTest1 = TestDataFactory.createProduct();
        Product2 productTest2 = TestDataFactory.createProduct();
        Product2 productTest3 = TestDataFactory.createProduct();
        Product2 productTest4 = TestDataFactory.createProduct();

        productTest.Prix_de_vente_tarif_T2__c= 11;
        update productTest;
        
        Id magasinId = [SELECT Magasin_actif_en_cours__c FROM Account where Id=: accountTest.Id][0].Magasin_actif_en_cours__c;
        Magasin__c magasin = new Magasin__c(Id=magasinId,Rang_tarifaire__c = 'T2');
        update magasin;
        Offre_Produit_Magasin__c opmTest = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        List<Offre_Produit_Magasin__c> similarOPMs = new List<Offre_Produit_Magasin__c>();
        similarOPMs.add(opmTest);
        Offre_Produit_Magasin__c SimilarOpmTest = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        similarOPMs.add(SimilarOpmTest);
        Offre_Produit_Magasin__c SimilarOpmTest1 = TestDataFactory.createOPM(magasinId, productTest1.Id, 'O');
        SimilarOpmTest1.Prix_de_vente_magasin__c = 10;
        update SimilarOpmTest1;
        similarOPMs.add(SimilarOpmTest1);
        Offre_Produit_Magasin__c SimilarOpmTest2 = TestDataFactory.createOPM(magasinId, productTest2.Id, 'O');
        update SimilarOpmTest2;
        similarOPMs.add(SimilarOpmTest2);
        List<Offre_produit_Magasin__c> opms = Utilities2.getTwoSimilarProductsAndPrices(productTest.Id,similarOPMs);
        Offre_Produit_Magasin__c SimilarOpmTest3 = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        similarOPMs.add(SimilarOpmTest3);
        Offre_Produit_Magasin__c SimilarOpmTest4 = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        similarOPMs.add(SimilarOpmTest4);
        Offre_Produit_Magasin__c SimilarOpmTest5 = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        similarOPMs.add(SimilarOpmTest5);
        List<Offre_produit_Magasin__c> opms3 = Utilities2.getTwoSimilarProductsAndPrices(productTest.Id,similarOPMs); 
        Offre_Produit_Magasin__c SimilarOpmTest6 = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        similarOPMs.add(SimilarOpmTest6);
        Offre_Produit_Magasin__c SimilarOpmTest7 = TestDataFactory.createOPM(magasinId, productTest.Id, 'O');
        similarOPMs.add(SimilarOpmTest7);
        List<Offre_produit_Magasin__c> opms4 = Utilities2.getTwoSimilarProductsAndPrices(productTest.Id,similarOPMs); 

    }
    
    @IsTest
    private static void calculatePromotionTest(){
        Account accountTest = TestDataFactory.createMagasinWithAcc();
        Id magasinId = [SELECT Magasin_actif_en_cours__c FROM Account where Id=: accountTest.Id][0].Magasin_actif_en_cours__c;
        Product2 productTest = TestDataFactory.createProduct();
        WebCart cart = TestDataFactory.createCart(accountTest.Id);
        CartDeliveryGroup cdg = TestDataFactory.createCartDeliveryGroup(cart.Id);
        CartItem cartItemTest = TestDataFactory.createCartItem(cart.Id, productTest.Id, cdg.Id, 50);
        cartItemTest.Quantity= 1;
        update cartItemTest;
        Mecanique_Promotion__c mecaniquePromo = TestDataFactory.createMecaniquePromotion('', 'BRI');
        Promotion__c promo = TestDataFactory.createPromotion(magasinId,productTest.Id, Date.today().addDays(-2), Date.today().addDays(+2), mecaniquePromo.Id);
        Promotion__c promo1 = [SELECT Id,Type_de_promotion__c,Remise_en_e__c,Prix_sous_mecanique__c FROM Promotion__c WHERE Id=: promo.Id];
        Map<String, Promotion__c> promotionMap = new Map<String, Promotion__c>{productTest.Id=>promo1};
        List<CartItem> cartItemsList = new List<CartItem>{cartItemTest};
        List<CartItem> result = Utilities2.calculatePromotion(cartItemsList,promotionMap);
        Mecanique_Promotion__c mecaniquePromo1 = TestDataFactory.createMecaniquePromotion('P', 'LVHO');
        mecaniquePromo1.Quantite_minimum_de_commande__c = 3;
        mecaniquePromo1.Remise_euro__c= 1;
        mecaniquePromo1.Remise__c=0.5;
        update mecaniquePromo1;
        Promotion__c promo2 = TestDataFactory.createPromotion(magasinId,productTest.Id, Date.today().addDays(-2), Date.today().addDays(+2), mecaniquePromo1.Id);
        promo2.Prix_de_vente_promotion__c= 12;
        update promo2;
        Promotion__c promo3 = [SELECT Id,Type_de_promotion__c,Remise_en_e__c,Prix_sous_mecanique__c,Remise_en_p__c, Type_d_offre__c,Prix_de_vente_promotion__c,Quantite_minimum_de_commande__c FROM Promotion__c WHERE Id=: promo2.Id];
        Map<String, Promotion__c> promotionMap1 = new Map<String, Promotion__c>{productTest.Id=>promo3};
        List<CartItem> result1 = Utilities2.calculatePromotion(cartItemsList,promotionMap1);
        Mecanique_Promotion__c mecaniquePromo2 = TestDataFactory.createMecaniquePromotion('M', 'LVHO');
        mecaniquePromo2.Remise_euro__c= 1;
        update mecaniquePromo2;
        Promotion__c promo4 = TestDataFactory.createPromotion(magasinId,productTest.Id, Date.today().addDays(-2), Date.today().addDays(+2), mecaniquePromo2.Id);
        promo4.Prix_de_vente_promotion__c= 12;
        update promo4;
        Promotion__c promo5 = [SELECT Id,Type_de_promotion__c,Remise_en_e__c,Prix_sous_mecanique__c,Remise_en_p__c, Type_d_offre__c,Prix_de_vente_promotion__c,Quantite_minimum_de_commande__c FROM Promotion__c WHERE Id=: promo4.Id];
        Map<String, Promotion__c> promotionMap2 = new Map<String, Promotion__c>{productTest.Id=>promo5};
        List<CartItem> result2 = Utilities2.calculatePromotion(cartItemsList,promotionMap2);
        Mecanique_Promotion__c mecaniquePromo3 = TestDataFactory.createMecaniquePromotion('', '');
        Promotion__c promo6 = TestDataFactory.createPromotion(magasinId,productTest.Id, Date.today().addDays(-2), Date.today().addDays(+2), mecaniquePromo3.Id);
        promo6.Prix_de_vente_promotion__c= 12;
        update promo6;
        Promotion__c promo7 = [SELECT Id,Type_de_promotion__c,Remise_en_e__c,Prix_sous_mecanique__c,Remise_en_p__c, Type_d_offre__c,Prix_de_vente_promotion__c,Quantite_minimum_de_commande__c FROM Promotion__c WHERE Id=: promo6.Id];
        Map<String, Promotion__c> promotionMap3 = new Map<String, Promotion__c>{productTest.Id=>promo7};
        List<CartItem> result3 = Utilities2.calculatePromotion(cartItemsList,promotionMap3);
    }
    
    @IsTest
    private static void createErrorLogBatchTest(){
       Magasin__c  magasinTest = TestDataFactory.createMagasinRecord();
       magasinTest.Autoriser_livraison_aux_nouveaux_clients__c= true;
       update( magasinTest);
       
    }
       
    }