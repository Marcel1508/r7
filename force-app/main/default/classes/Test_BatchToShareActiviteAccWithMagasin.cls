/**
 * @CreatedBy       : Chandra Sekhar
 * @Date            : 09/09/2021
 * @Company         : IBM, Bluewolf
 * @Description     : Test class for classes BatchToShareActiviteAccWithMagasin,
 * BatchToShareInformationAccWithMagasin,BatchToShareFraisAccWithMagasin,BatchToShareFideliteAccWithMagasin.  
 */
@isTest
public class Test_BatchToShareActiviteAccWithMagasin {
	@isTest
    private static void test_execute() {
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin.Id);
        Activite_potentiel__c activite= createActivite(account.Id, magasin.Id);
        Information_financiere__c info = createInfo(account.Id, magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id);
        Fidelite__c fidelite = createFidelite(account.Id, magasin.Id);
        Test.startTest();
        //Database.executeBatch(new BatchToShareActiviteAccWithMagasin(),1);
        String sch = '0 0 7 * * ?';
        String jobId = System.schedule('BatchToShareActiviteAccWithMagasin',sch, new ScheduleBatchToShareAccounts());
        Test.stopTest();
    }
    
    private static Account createAccount(Id magasinId) {
        Code_APE__c codeAPE = new Code_APE__c(
          APE_code__c = 'P13',
            Name = 'Test APE',
            Code_specialisation__c = 'A1'
        );
        Insert codeAPE;
        return (Account)
            new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.OwnerId, UserInfo.getUserId())
            .put(Account.Numero_Client__c, 'num123')
            .put(Account.Statut_Fiche_client__c,'Prospect')
            .put(Account.Enseigne_commerciale__c,'Testing')
            .put(Account.Forme_juridique__c,'07')
            .put(Account.Categorie__c,'1')
            .put(Account.Code_APE__c,codeAPE.Id)
            .create().getRecord();
    }
    
    private static Magasin__c createMagasin(Boolean enabled) {
        return (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Autoriser_livraison_aux_nouveaux_clients__c, enabled)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.code_etablissement__c, 'eta')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 1)
            .put(Magasin__c.API_Key__c, 'key1')
            .put(Magasin__c.Minimum_Commande_Drive__c, 0) 
            .put(Magasin__c.Minimum_Commande_Livraison__c, 1) 
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 10)
            .create().getRecord();
    }
    
    private static Information_financiere__c createInfo(Id accountId, Id magasinId) {
        return (Information_financiere__c)
            new SObjectBuilder(Information_financiere__c.SObjectType)
            .put(Information_financiere__c.account__c, accountId)
            .put(Information_financiere__c.Magasin__c, magasinId)
            .create().getRecord();
    }
    private static Frais__c createFrais(Id accountId, Id magasinId) {
        return (Frais__c)
            new SObjectBuilder(Frais__c.SObjectType)
            .put(Frais__c.account__c, accountId)
            .put(Frais__c.Magasin_Associe__c, magasinId)
            .create().getRecord();
    }
    private static Fidelite__c createFidelite(Id accountId, Id magasinId) {
        return (Fidelite__c)
            new SObjectBuilder(Fidelite__c.SObjectType)
            .put(Fidelite__c.Compte__c, accountId)
            .put(Fidelite__c.Magasin__c, magasinId)
            .create().getRecord();
    }
    private static Activite_potentiel__c createActivite(Id accountId, Id magasinId) {
        return (Activite_potentiel__c)
            new SObjectBuilder(Activite_potentiel__c.SObjectType)
            .put(Activite_potentiel__c.Account__c, accountId)
            .put(Activite_potentiel__c.Magasin_actif__c, magasinId)
            .create().getRecord();
    }
}