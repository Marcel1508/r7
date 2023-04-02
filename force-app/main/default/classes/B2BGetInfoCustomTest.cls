@IsTest
public class B2BGetInfoCustomTest {
    @isTest
    private static void testGetInfoCustom(){
        AccountTriggerHandler.bypassTrigger = true;
        MagasinTriggerHandler.bypassTrigger = true;
        
        profile p = [Select Id,Name from profile Where Name ='Customer Community Plus User'];
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        Insert magasinRec;
        
        Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Client',magasinRec); 
        testAccount.RecordTypeId = clientRecordTypeId;
        testAccount.Numero_Siret__c = '66204244900014';
        Insert testAccount;
        
        Contact textContact = (Contact) new sObjectbuilder(Contact.sObjectType)
            .put(Contact.LastName, 'TEST Contact')
            .put(Contact.AccountId, testAccount.Id)
            .put(Contact.Roles__c, 'Autre')
            .create().getRecord();
        
        BuyerAccount buyerAccount = TestDataFactory.createBuyerAccount(testAccount.id);
        Insert buyerAccount;
        
        Product2 prod = TestDataFactory.createGenericProduct();
        prod.Code_departement__c ='4';
        Insert prod;
        
        List<Offre_Produit_Magasin__c> testOPM = (List<Offre_Produit_Magasin__c>) new SObjectBuilder(Offre_Produit_Magasin__c.SObjectType)
            .put(Offre_Produit_Magasin__c.Name, 'TEST OPM')
            .put(Offre_Produit_Magasin__c.Magasin__c, magasinRec.id)
            .put(Offre_Produit_Magasin__c.Produit__c, prod.id)
            .put(Offre_Produit_Magasin__c.Produit_actif__c, 'O')
            .put(Offre_Produit_Magasin__c.Statut__c, '2')
            .put(Offre_Produit_Magasin__c.Prix_de_vente_magasin__c, 0)
            .put(Offre_Produit_Magasin__c.Niveau_de_stock__c, 4)
            .put(Offre_Produit_Magasin__c.En_cours_de_commande__c, 2)
            .count(1).create().getRecords();
        
        Network network = [SELECT Id, Name FROM Network WHERE Name = 'Promocash' LIMIT 1][0];
        User currentUser = [Select Id, Bypass_Trigger__c FROM user WHERE Id=:userInfo.getUserId()];
        NetworkMember membership = [SELECT NetworkID, MemberID FROM NetworkMember WHERE memberID = :currentUser.id][0];
        
        WebStore store = TestDataFactory.createWebStoreRecord();
        Insert store;
        WebCart webCart = TestDataFactory.createWebCartRecord(testAccount.Id);
        webCart.WebStoreId = store.Id;
        Insert webCart; 
        
        //Create a Wishlist
        Wishlist wishList = TestDataFactory.createwishListRecord(store.Id,testAccount.Id);
        Insert wishList;
        
        WishlistItem witem = new WishlistItem(
            Name = 'Test',
            WishlistId = wishList.Id,
            Product2Id = prod.Id,
            Quantite__c = 2
        );
        insert witem;
        B2BUtilsCustom.communityIdToWebStoreIdCache.put(network.Id, store.Id);
        
        Test.startTest();
        
        webStore getStore = [select id from WebStore][0];
        AccountTriggerHandler.bypassTrigger = true;
        
        B2BGetInfoCustom.getCartSummary(network.id, testAccount.Id);
        B2BGetInfoCustom.addToCartPromocashQuantity(network.Id, prod.Id, '2', testAccount.Id);
        B2BGetInfoCustom.addToCartPromocashUnique(prod.Id, testAccount.Id, network.Id);
        B2BGetInfoCustom.addWishlistToCartPromocash(wishList.Id, testAccount.Id, network.Id);
        B2BGetInfoCustom.addToListsPromocash(prod.Id, wishList.Id, testAccount.Id, network.Id);
        B2BGetInfoCustom.addWishlistToCartPromocash1(wishList.Id, testAccount.Id, network.Id);
        
        B2BGetInfoCustom.getWishlistSummaries(testAccount.Id, network.Id);        
        B2BGetInfoCustom.getWishlistSummariesRefresh(testAccount.Id, network.Id);
        B2BGetInfoCustom.getLoggedAsDetails();
        B2BGetInfoCustom.getPromocashCommunityId();
        
        B2BGetInfoCustom.createWishlist('TestList', testAccount.Id, network.Id, UserInfo.getUserId());
        
        B2BGetInfoCustom.getWishlistInfosTeleSales(wishList.Id);
        B2BGetInfoCustom.getWishlistCreatedByNameTeleSales(wishList.Id);
        B2BGetInfoCustom.getWishlistLastModifiedByNameTeleSales(wishList.Id);
        B2BGetInfoCustom.getFavWishlistId(testAccount.Id);
        B2BGetInfoCustom.deleteWishlist(wishList.Id, network.Id);
        B2BGetInfoCustom.updateWishlist(testAccount.Id, wishList.Id, network.Id, 'new Name', [SELECT ID, Name FROM USER LIMIT 1].Name);
        B2BGetInfoCustom.updateWishlistLMB(testAccount.Id, network.Id, [SELECT ID, Name FROM USER LIMIT 1].Name, wishList.Id);
        B2BGetInfoCustom.removeWishlistItem(testAccount.Id, wishList.Id, network.Id, null,null);
        B2BGetInfoCustom.getWishlistItems(testAccount.Id, wishList.Id, network.Id);
        B2BGetInfoCustom.getQuantityWishlistItem(testAccount.Id, wishList.Id, witem.Id);
        B2BGetInfoCustom.getProduct2(network.Id, prod.Id, testAccount.Id);
        B2BGetInfoCustom.getProductWithCustomFields(network.Id, prod.Id, testAccount.Id, new List<String>{'test'});
        B2BGetInfoCustom.getProductExtraInfo(prod.Id, testAccount.Id);
        B2BGetInfoCustom.getOffreProduitMagasin(prod.Id, testAccount.Id);
        B2BGetInfoCustom.getPrixSpecifique(prod.Id, testAccount.Id, testOPM.get(0).Id);
        B2BGetInfoCustom.manualShareRead(testAccount.Id, [SELECT ID, Name FROM USER LIMIT 1].Id);
        B2BGetInfoCustom.checkDisplayingSimilarProduct(prod.Id, testAccount.Id);
        B2BGetInfoCustom.shareWishlistsWithAccountse(wishList.Id, new List<String>{testAccount.Id}, [SELECT ID, Name FROM USER LIMIT 1].Name, network.Id, testAccount.Id);
        B2BGetInfoCustom.shareWishlistsWithAccounts(wishList.Id, new List<String>{testAccount.Id});
        B2BGetInfoCustom.shareWishlistsWithAccountsf(wishList.Id, new List<String>{testAccount.Id}, [SELECT ID, Name FROM USER LIMIT 1].Id, network.Id, testAccount.Id);
        B2BGetInfoCustom.getCurrentSessionInfos();
        B2BGetInfoCustom.getAccessibleAccountsCount();
        B2BGetInfoCustom.findRecords('Test', 'Contact', 'Name', 'Name');
        B2BGetInfoCustom.getPickListValues('Account', 'Type');
        B2BGetInfoCustom.getSimilarProduct(prod.Id, testAccount.Id);
        B2BGetInfoCustom.checkDisplayingSimilarProductLA(prod.Id, testAccount.Id);
        B2BGetInfoCustom.getProductPrice2(network.Id, prod.Id, testAccount.Id);
        B2BGetInfoCustom.checkStockAndEnCoursForProducts(new List<String>{prod.Id}, testAccount.Id);
        B2BGetInfoCustom.checkStockAndEnCours(prod.Id, testAccount.Id);
        B2BGetInfoCustom.checkProductIsPFT(prod.Id, testAccount.Id);
        B2BGetInfoCustom.checkProductIsInStock(prod.Id, testAccount.Id);
        B2BGetInfoCustom.getPrixSpecifiqueProduct(prod.Id, testAccount.Id);
        B2BGetInfoCustom.getDisplayedProductName(prod.Id);
        prod.Libelle_commercial__c = 'Libelle commercial';
        update prod;
        B2BGetInfoCustom.getDisplayedProductName(prod.Id);
        prod.Libelle_fournisseur__c = 'Libelle fournisseur';
        update prod;
        B2BGetInfoCustom.getDisplayedProductName(prod.Id);
        B2BGetInfoCustom.getCurrentMagasinActif(testAccount.Id);
        Test.stopTest();
        
    }    
    
    private static Magasin__c createMagasin(Boolean enabled) {
        Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('Test Magasin');
        magasinRec.Autoriser_livraison_aux_nouveaux_clients__c = enabled;
        magasinRec.Responsable__c= UserInfo.getUserId();
        Insert magasinRec;
        return magasinRec;
    }
    
    private static Account createAccount(Magasin__c magasinId) {
        Account testAccount = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinId); 
        Insert testAccount;
        return testAccount;
    }
    
    private static Order createOrder(Id accountId) {
        return (Order)
            new SObjectBuilder(Order.SObjectType)
            .put(Order.AccountId, accountId)
            .create().getRecord();
    }
    
    private static Frais__c createFrais(Id accountId, Id magasinId, String modes) {
        delete [SELECT Id FROM Frais__c];
        return (Frais__c)
            new SObjectBuilder(Frais__c.SObjectType)
            .put(Frais__c.Account__c, accountId)
            .put(Frais__c.Magasin_Associe__c, magasinId)
            .put(Frais__c.Mode_de_livraison__c, modes)
            .create().getRecord();
    }
}