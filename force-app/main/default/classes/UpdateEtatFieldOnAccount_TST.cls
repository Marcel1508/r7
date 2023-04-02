/**
 * @CreatedBy       : Suliman A.
 * @Date            : 16/08/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A test class for UpdateEtatFieldOnAccount_BATCH.  
 */

@isTest
private class UpdateEtatFieldOnAccount_TST {
    public static final String CRON_EXP = '0 0 0 01 12 ? 2025';
    private static Account createAccount(Id magasinId) {
        return (Account)
            new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.OwnerId, UserInfo.getUserId())
            .put(Account.Numero_Client__c, 'testSch1')
            .put(Account.Enseigne_commerciale__c, 'PA1')
            .put(Account.Forme_juridique__c, '01')
            .put(Account.Numero_Client__c, 'testSch1')
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
            .put(Activite_potentiel__c.Date_derniere_facture__c, Date.today())
            .create().getRecord();
    }
    
    @testSetup
    static void setup() {
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin.Id);
        Activite_potentiel__c activite = createFidelite(account.Id, magasin.Id);
        activite = [SELECT ID, AP_External_ID__c FROM Activite_potentiel__c LIMIT 1];
        system.assert(activite.AP_External_ID__c != null);
    }
    
    @isTest 
    static void testActivityPotentielInOneMonth() {
        Test.startTest();
        	UpdateEtatFieldOnAccount_BATCH myBatchObject = new UpdateEtatFieldOnAccount_BATCH();
			Database.executeBatch(myBatchObject);
        Test.stopTest();
        Account acc = [SELECT ID, Statut_Client_sur_le_magasin__c FROM Account WHERE Numero_Client__c = 'testSch1' LIMIT 1];
        System.assertEquals(Constants.ACTIF_ACHETANT, acc.Statut_Client_sur_le_magasin__c);
    }
    @isTest 
    static void testActivityPotentielBtwOneAndThreeMonths() {
        Activite_potentiel__c activite = [SELECT ID, AP_External_ID__c, Date_derniere_facture__c FROM Activite_potentiel__c LIMIT 1];
        activite.Date_derniere_facture__c = Date.today().addDays(-62);
        update activite;
        
        Test.startTest();
        	UpdateEtatFieldOnAccount_BATCH myBatchObject = new UpdateEtatFieldOnAccount_BATCH();
			Database.executeBatch(myBatchObject);
        Test.stopTest();
        Account acc = [SELECT ID, Statut_Client_sur_le_magasin__c FROM Account WHERE Numero_Client__c = 'testSch1' LIMIT 1];
        System.assertEquals('Actif_Non_Achetant', acc.Statut_Client_sur_le_magasin__c);
    }
    @isTest 
    static void testActivityPotentielBeforeThreeMonths() {
        Activite_potentiel__c activite = [SELECT ID, AP_External_ID__c, Date_derniere_facture__c FROM Activite_potentiel__c LIMIT 1];
        activite.Date_derniere_facture__c = Date.today().addDays(-92);
        update activite;
        Test.startTest();
        	UpdateEtatFieldOnAccount_BATCH myBatchObject = new UpdateEtatFieldOnAccount_BATCH();
			Database.executeBatch(myBatchObject);
        Test.stopTest();
        Account acc = [SELECT ID, Statut_Client_sur_le_magasin__c FROM Account WHERE Numero_Client__c = 'testSch1' LIMIT 1];
        System.assertEquals('Inactif', acc.Statut_Client_sur_le_magasin__c);
    }
    @isTest 
    static void testSCH() {
        Test.startTest();
        	UpdateEtatFieldOnAccount_SCH sch = new UpdateEtatFieldOnAccount_SCH();
        	String jobId = System.schedule('UpdateEtatFieldOnAccount', CRON_EXP, sch);
        	sch.execute(null);
        Test.stopTest();
        Account acc = [SELECT ID, Statut_Client_sur_le_magasin__c FROM Account WHERE Numero_Client__c = 'testSch1' LIMIT 1];
        Activite_potentiel__c activite = [SELECT ID, AP_External_ID__c, Date_derniere_facture__c FROM Activite_potentiel__c LIMIT 1];
                        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals(Constants.ACTIF_ACHETANT, acc.Statut_Client_sur_le_magasin__c);
    }
    
}