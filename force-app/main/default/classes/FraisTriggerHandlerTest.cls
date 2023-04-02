@isTest
public class FraisTriggerHandlerTest {
    private static final String LIVRAISON = 'Livraison';
    private static final String DRIVE = 'Drive';
    private static final String DRIVE_DEPORTE = 'Drive déporté';
    private static final String ALL_METHODS = String.join(new List<String>{LIVRAISON, DRIVE, DRIVE_DEPORTE}, ';');
    
	@isTest
    private static void test() {
        OrderTriggerHandler.bypassTrigger = true;
        Magasin__c magasin = createMagasin(true);
        Zone_de_Chalandise__c zoneDeChalandise = createZonedeChalandise(magasin.Id,'Angouleme','16000','2');
        Account account = createAccount(magasin.Id);
        Frais__c frais = createFrais(account.Id, magasin.Id, ALL_METHODS);
        frais = [SELECT ID, Frais_externalID__c FROM Frais__c LIMIT 1];
        system.assert(frais.Frais_externalID__c != null);
        account.ShippingCity ='city';
        update account; 
        update frais;
    }
    
    private static Account createAccount(Id magasinId) {
        return (Account)
            new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.OwnerId, UserInfo.getUserId())
            .put(Account.Numero_Client__c, 'num123')
            .put(Account.ShippingPostalCode,'16000')
            .put(Account.ShippingCity,'Angouleme')
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
    
    private static Frais__c createFrais(Id accountId, Id magasinId, String modes) {
        delete [SELECT Id FROM Frais__c];
        return (Frais__c)
            new SObjectBuilder(Frais__c.SObjectType)
                .put(Frais__c.Account__c, accountId)
                .put(Frais__c.Magasin_Associe__c, magasinId)
                .put(Frais__c.Mode_de_livraison__c, modes)
                .create().getRecord();
    }
    
    private static Zone_de_Chalandise__c createZonedeChalandise(Id magasinId, String city, String postalCode, String codeChalandise) {
        return (Zone_de_Chalandise__c)
            new SObjectBuilder(Zone_de_Chalandise__c.SObjectType)
                .put(Zone_de_Chalandise__c.Magasin__c, magasinId)
                .put(Zone_de_Chalandise__c.Code_postal_text__c,postalCode)
                .put(Zone_de_Chalandise__c.Libelle_ville__c,city)
                .put(Zone_de_Chalandise__c.Code_Chalandise__c,codeChalandise)
                .create().getRecord();
    }
}