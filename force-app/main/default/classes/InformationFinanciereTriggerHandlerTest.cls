@isTest
public class InformationFinanciereTriggerHandlerTest {
    @isTest
    private static void test() {
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin.Id);
        Information_financiere__c info = createInfo(account.Id, magasin.Id);
        info = [SELECT ID, Info_fi_ExternalID__c FROM Information_financiere__c LIMIT 1];
        system.assert(info.Info_fi_ExternalID__c != null);
    }
    
    private static Account createAccount(Id magasinId) {
        return (Account)
            new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.OwnerId, UserInfo.getUserId())
            .put(Account.Numero_Client__c, 'num123')
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
}