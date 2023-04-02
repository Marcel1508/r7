@isTest
public class ActivitePotentielTriggerHandlerTest {
 @isTest
    private static void test() {
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin.Id);
        Activite_potentiel__c activite = createFidelite(account.Id, magasin.Id);
        activite = [SELECT ID, AP_External_ID__c FROM Activite_potentiel__c LIMIT 1];
        system.assert(activite.AP_External_ID__c != null);
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
    
    private static Activite_potentiel__c createFidelite(Id accountId, Id magasinId) {
        return (Activite_potentiel__c)
            new SObjectBuilder(Activite_potentiel__c.SObjectType)
            .put(Activite_potentiel__c.account__c, accountId)
            .put(Activite_potentiel__c.Magasin_actif__c, magasinId)
            .create().getRecord();
    }
}