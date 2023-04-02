/**
 * @CreatedBy       : Suliman A.
 * @Date            : 23/08/2021
 * @Company         : IBM, Bluewolf
 * @Description     : A test class for UpdateTypeDeClientOnAccount_BATCH.
 */

@isTest
private class UpdateTypeDeClientOnAccount_TST {
    public static String CRON_EXP = '0 0 12 1/1 * ? *';
    private static Account createAccount(Id magasinId) {
        return (Account) new SObjectBuilder(Account.SObjectType)
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.OwnerId, UserInfo.getUserId())
            .put(Account.Numero_Client__c, 'testSch2')
            .create()
            .getRecord();
    }

    private static Magasin__c createMagasin(Boolean enabled) {
        return (Magasin__c) new SObjectBuilder(Magasin__c.SObjectType)
            .put(Magasin__c.Autoriser_livraison_aux_nouveaux_clients__c, enabled)
            .put(Magasin__c.Responsable__c, UserInfo.getUserId())
            .put(Magasin__c.code_etablissement__c, 'eta')
            .put(Magasin__c.Pourcentage_additionel_carte__c, 1)
            .put(Magasin__c.API_Key__c, 'key1')
            .put(Magasin__c.Minimum_Commande_Drive__c, 0)
            .put(Magasin__c.Minimum_Commande_Livraison__c, 1)
            .put(Magasin__c.Minimum_Commande_Drive_Deporte__c, 10)
            .create()
            .getRecord();
    }

    private static Facture__c createFacture(Id accountId, Id magasinId, Decimal MTHTTX1, Decimal MTHTTX2, Decimal MTHTTX3) {
        return (Facture__c) new SObjectBuilder(Facture__c.SObjectType)
            .put(Facture__c.Code_carte_client__c, accountId)
            .put(Facture__c.Magasin__c, magasinId)
            .put(Facture__c.Date_de_facture__c, Date.today())
            .put(Facture__c.MTHTTX1__c, MTHTTX1)
            .put(Facture__c.MTHTTX2__c, MTHTTX2)
            .put(Facture__c.MTHTTX3__c, MTHTTX3)
            .create()
            .getRecord();
    }

    @testSetup
    static void setup() {
        Magasin__c magasin = createMagasin(true);
        Account account = createAccount(magasin.Id);
        Facture__c facture = createFacture(account.Id, magasin.Id, 2000, 4000, 1000);
        facture = [SELECT ID, Montant_total_HT__c FROM Facture__c LIMIT 1];
        system.assert(facture.Montant_total_HT__c != null);
    }

    @isTest
    static void testMontant_total_HT_LESS_THAN_8000() {
        // change client's type so changes from process can be perceived
        Account a = [SELECT Id, Type_de_Client__c FROM Account WHERE Numero_Client__c = 'testSch2'];
        a.Type_de_Client__c = 'A';
        update a;

        Test.startTest();
        UpdateTypeDeClientOnAccount_BATCH myBatchObject = new UpdateTypeDeClientOnAccount_BATCH();
        Database.executeBatch(myBatchObject);
        Test.stopTest();

        Account acc = [
            SELECT ID, Type_de_client__c
            FROM Account
            WHERE Numero_Client__c = 'testSch2'
            LIMIT 1
        ];
        System.assertEquals('C', acc.Type_de_client__c);
    }

    @isTest
    static void testMontant_total_HT_BTN_BETWEEN_8000_AND_30000() {
        Facture__c facture = [
            SELECT ID, Montant_total_HT__c
            FROM Facture__c
            LIMIT 1
        ];
        facture.MTHTTX1__c = 4000;
        facture.MTHTTX2__c = 5000;
        update facture;

        Test.startTest();
        UpdateTypeDeClientOnAccount_BATCH myBatchObject = new UpdateTypeDeClientOnAccount_BATCH();
        Database.executeBatch(myBatchObject);
        Test.stopTest();
        Account acc = [
            SELECT ID, Type_de_client__c
            FROM Account
            WHERE Numero_Client__c = 'testSch2'
            LIMIT 1
        ];
        System.assertEquals('B', acc.Type_de_client__c);
    }

    @isTest
    static void testMontant_total_HT_MORE_THAN_30000() {
        Facture__c facture = [
            SELECT ID, Montant_total_HT__c
            FROM Facture__c
            LIMIT 1
        ];
        facture.MTHTTX1__c = 40000;
        facture.MTHTTX2__c = 5000;
        update facture;

        Test.startTest();
        UpdateTypeDeClientOnAccount_BATCH myBatchObject = new UpdateTypeDeClientOnAccount_BATCH();
        Database.executeBatch(myBatchObject);
        Test.stopTest();
        Account acc = [
            SELECT ID, Type_de_client__c
            FROM Account
            WHERE Numero_Client__c = 'testSch2'
            LIMIT 1
        ];
        System.assertEquals('A', acc.Type_de_client__c);
    }

    @isTest
    static void testSCH() {
        Test.startTest();
        UpdateTypeDeClientOnAccount_SCH sch = new UpdateTypeDeClientOnAccount_SCH();
        String jobId = System.schedule('UpdateTypeDeClientOnAccount', CRON_EXP, sch);
        sch.execute(null);
        Test.stopTest();
        Account acc = [
            SELECT ID, Type_de_client__c
            FROM Account
            WHERE Numero_Client__c = 'testSch2'
            LIMIT 1
        ];
        Facture__c facture = [
            SELECT ID, Montant_total_HT__c
            FROM Facture__c
            LIMIT 1
        ];
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [
            SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
            FROM AsyncApexJob
            WHERE JobType = 'ScheduledApex'
        ];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('C', acc.Type_de_client__c);
    }
}