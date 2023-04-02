/**
* @author       jan.straka@bluewolf
* @date         2021-06-16
* @description  Test class for FullCalendarController
**/
@IsTest
private class FullCalendarControllerTest {
    
    private static final Datetime NOW = Datetime.now();
    private static final Date TODAY = Date.today();
    private static List<Date> dates {
        get {
            if (dates == null) {
                dates = new List<Date>();
                for (Integer i = 0; i < 201; i++) {
                    dates.add(TODAY.addDays(i + 1));
                }
            }
            return dates;
        }
        set;
    }
    private static final Time TIME_DEBUT = Time.newInstance(10, 30, 00, 00);
    private static final Time TIME_FIN = Time.newInstance(14, 59, 59, 00);
    private static Map<String, Schema.RecordTypeInfo> SLOT_RECORD_TYPES = 
        Schema.SObjectType.Creneau_Salesforce__c.getRecordTypeInfosByDeveloperName();


    @IsTest
    private static void testGetOppo() {
        List<Creneau_Salesforce__c> testCreneaux = (List<Creneau_Salesforce__c>)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.Magasin__c, new SObjectParentProviders.GenericParentProvider(Magasin__c.SObjectType))
                .count(201).create().getRecords();
        
        Test.startTest();
        String result = FullCalendarController.getOppo();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result JSON is empty');
        System.assert(result.contains('"Id":"' + testCreneaux[0].Id + '"'), 'First Creneaux (Id: ' + testCreneaux[0].Id + ') should be retrieved');
        System.assert(result.contains('"Id":"' + testCreneaux[100].Id + '"'), 'Middle Creneaux (Id: ' + testCreneaux[100].Id + ') should be retrieved');
        System.assert(result.contains('"Id":"' + testCreneaux[200].Id + '"'), 'Last Creneaux (Id: ' + testCreneaux[200].Id + ') should be retrieved');
    }

    @IsTest
    private static void testFetchEvents() {
        List<Event> testEvents = (List<Event>)
            new SObjectBuilder(Event.SObjectType)
                .count(201).create().getRecords();
        
        Test.startTest();
        List<Event> resultEvents = FullCalendarController.fetchAllEvents();
        Test.stopTest();

        System.assertEquals(100, resultEvents.size(), 'Bad count of fetched events');
    }

    private static Magasin__c createMagasin() {
        return (Magasin__c)
            new SObjectBuilder(Magasin__c.SObjectType)
                .create().getRecord();
    }

    private static Account createAccount(Id magasinId) {
        return (Account)
            new SObjectBuilder(Account.SObjectType)
            .put(Account.Name, 'TEST ACCOUNT') 
            .put(Account.Statut_Fiche_client__c, 'Lead') 
            .put(Account.Magasin_de_rattachement__c, magasinId)
            .put(Account.Magasin_actif_en_cours__c, magasinId)
            .create().getRecord();
    }

    private static Order createOrder(Id accountId, String postalCode) {
        return (Order)
            new SObjectBuilder(Order.SObjectType)
                .put(Order.AccountId, accountId)
                .put(Order.ShippingPostalCode, postalCode)
                .create().getRecord();
    }

    private static OrderDeliveryMethod createDeliveryMethod (String methodName) {
        return (OrderDeliveryMethod)
            new SObjectBuilder(OrderDeliveryMethod.SObjectType)
                .put(OrderDeliveryMethod.Name, methodName)
                .create().getRecord();
    }

    private static OrderDeliveryGroup createDeliveryGroup(Id orderId, Id methodId) {
        return (OrderDeliveryGroup)
            new SObjectBuilder(OrderDeliveryGroup.SObjectType)
                .put(OrderDeliveryGroup.DeliverToName, 'Dummy')
                .put(OrderDeliveryGroup.OrderId, orderId)
                .put(OrderDeliveryGroup.OrderDeliveryMethodId, methodId)
                .create().getRecord();
    }

    @IsTest
    private static void testGetSlots_Drive() {
        Magasin__c testMagasin = createMagasin();
        Account testAccount = createAccount(testMagasin.Id);
        Order testOrder = createOrder(testAccount.Id, null);
        OrderDeliveryMethod testDeliveryMethod = createDeliveryMethod('Drive');
        OrderDeliveryGroup testDeliveryGroup = createDeliveryGroup(testOrder.Id, testDeliveryMethod.Id);

        List<Creneau_Salesforce__c> testSlots = (List<Creneau_Salesforce__c>)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.RecordTypeId, SLOT_RECORD_TYPES.get('Planning_de_drive').getRecordTypeId())
                .put(Creneau_Salesforce__c.Type_de_planning__c, 'Drive')
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .put(Creneau_Salesforce__c.Capacite__c, 10)
                // .put(Creneau_Salesforce__c.Capacite_disponible__c, 10)
                .put(Creneau_Salesforce__c.Date__c, new SObjectFieldProviders.ListProvider(dates))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, TIME_DEBUT)
                .put(Creneau_Salesforce__c.Heure_de_fin__c, TIME_FIN)
                .put(Creneau_Salesforce__c.Temps_de_preparation__c, null)
                // .put(Creneau_Salesforce__c.Date_limite_de_commande__c, NOW.addHours(1))
                .count(201).create().getRecords();

        Test.startTest();
        List<FullCalendarController.CreneauWrapper> results = FullCalendarController.getSlots(testOrder.Id);
        Test.stopTest();

        System.assertEquals(201, results.size(), 'Bad count of retrieved slots');
    }

    @IsTest
    private static void testGetSlots_DriveDeporte() {
        Magasin__c testMagasin = createMagasin();
        Account testAccount = createAccount(testMagasin.Id);
        Order testOrder = createOrder(testAccount.Id, null);
        OrderDeliveryMethod testDeliveryMethod = createDeliveryMethod('Drive déporté');
        OrderDeliveryGroup testDeliveryGroup = createDeliveryGroup(testOrder.Id, testDeliveryMethod.Id);

        List<Creneau_Salesforce__c> testSlots = (List<Creneau_Salesforce__c>)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.RecordTypeId, SLOT_RECORD_TYPES.get('Planning_de_drive').getRecordTypeId())
                .put(Creneau_Salesforce__c.Type_de_planning__c, 'Drive déporté')
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .put(Creneau_Salesforce__c.Capacite__c, 10)
                // .put(Creneau_Salesforce__c.Capacite_disponible__c, 10)
                .put(Creneau_Salesforce__c.Date__c, new SObjectFieldProviders.ListProvider(dates))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, TIME_DEBUT)
                .put(Creneau_Salesforce__c.Heure_de_fin__c, TIME_FIN)
                .put(Creneau_Salesforce__c.Temps_de_preparation__c, null)
                // .put(Creneau_Salesforce__c.Date_limite_de_commande__c, NOW.addHours(1))
                .count(201).create().getRecords();

        Test.startTest();
        List<FullCalendarController.CreneauWrapper> results = FullCalendarController.getSlots(testOrder.Id);
        Test.stopTest();

        System.assertEquals(201, results.size(), 'Bad count of retrieved slots');
    }

    @IsTest
    private static void testGetSlots_LivraisonWithReserves() {
        Magasin__c testMagasin = createMagasin();
        Account testAccount = createAccount(testMagasin.Id);
        Order testOrder = createOrder(testAccount.Id, '12345');
        OrderDeliveryMethod testDeliveryMethod = createDeliveryMethod('Livraison');
        OrderDeliveryGroup testDeliveryGroup = createDeliveryGroup(testOrder.Id, testDeliveryMethod.Id);

        Creneau_Magasin_Recurrent__c testSlotRecurrent = (Creneau_Magasin_Recurrent__c)
            new SObjectBuilder(Creneau_Magasin_Recurrent__c.SObjectType)
                .put(Creneau_Magasin_Recurrent__c.Magasin__c, testMagasin.Id)
                .put(Creneau_Magasin_Recurrent__c.Capacite__c, 300)
                .put(Creneau_Magasin_Recurrent__c.Heure_de_debut__c, TIME_DEBUT)
                .put(Creneau_Magasin_Recurrent__c.Heure_de_fin__c, TIME_FIN)
                .put(Creneau_Magasin_Recurrent__c.Temps_de_preparation__c, 0)
                .put(Creneau_Magasin_Recurrent__c.Jour__c, 'Lundi')
                .create().getRecord();
        List<Creneau_Reserve__c> testSlotReserves = (List<Creneau_Reserve__c>)
            new SObjectBuilder(Creneau_Reserve__c.SObjectType)
                .put(Creneau_Reserve__c.Compte_client__c, testAccount.Id)
                .put(Creneau_Reserve__c.Creneau_Magasin__c, testSlotRecurrent.Id)
                // .put(Creneau_Reserve__c.ID_magasin_TECH__c, testMagasin.Id)
                .count(201).create().getRecords();
        List<Creneau_Salesforce__c> testSlots = (List<Creneau_Salesforce__c>)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.RecordTypeId, SLOT_RECORD_TYPES.get('Planning_de_livraison').getRecordTypeId())
                .put(Creneau_Salesforce__c.Type_de_planning__c, 'Livraison')
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .put(Creneau_Salesforce__c.Capacite__c, 10)
                // .put(Creneau_Salesforce__c.Capacite_disponible__c, 10)
                .put(Creneau_Salesforce__c.Date__c, new SObjectFieldProviders.ListProvider(dates))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, TIME_DEBUT)
                .put(Creneau_Salesforce__c.Heure_de_fin__c, TIME_FIN)
                .put(Creneau_Salesforce__c.Temps_de_preparation__c, null)
                // .put(Creneau_Salesforce__c.Date_limite_de_commande__c, NOW.addHours(1))
                .put(Creneau_Salesforce__c.Creneau_Recurrent__c, testSlotRecurrent.Id)
                .count(201).create().getRecords();

        Test.startTest();
        List<FullCalendarController.CreneauWrapper> results = FullCalendarController.getSlots(testOrder.Id);
        Test.stopTest();

        System.assertEquals(201, results.size(), 'Bad count of retrieved slots');
    }

    @IsTest
    private static void testGetSlots_LivraisonWithoutReserves() {
        Magasin__c testMagasin = createMagasin();
        Account testAccount = createAccount(testMagasin.Id);
        Order testOrder = createOrder(testAccount.Id, '12345');
        OrderDeliveryMethod testDeliveryMethod = createDeliveryMethod('Livraison');
        OrderDeliveryGroup testDeliveryGroup = createDeliveryGroup(testOrder.Id, testDeliveryMethod.Id);

        Creneau_Magasin_Recurrent__c testSlotRecurrent = (Creneau_Magasin_Recurrent__c)
            new SObjectBuilder(Creneau_Magasin_Recurrent__c.SObjectType)
                .put(Creneau_Magasin_Recurrent__c.Magasin__c, testMagasin.Id)
                .put(Creneau_Magasin_Recurrent__c.Capacite__c, 300)
                .put(Creneau_Magasin_Recurrent__c.Heure_de_debut__c, TIME_DEBUT)
                .put(Creneau_Magasin_Recurrent__c.Heure_de_fin__c, TIME_FIN)
                .put(Creneau_Magasin_Recurrent__c.Temps_de_preparation__c, 0)
                .put(Creneau_Magasin_Recurrent__c.Jour__c, 'Lundi')
                //.put(Creneau_Magasin_Recurrent__c.Creneau_affilie_une_zone__c, true)
                // .put(Creneau_Magasin_Recurrent__c.Nombre_de_zones_affiliees__c, 1)
                .create().getRecord();
        Zone_de_livraison__c testZoneDeLivraison = (Zone_de_livraison__c)
            new SObjectBuilder(Zone_de_livraison__c.SObjectType)
                .put(Zone_de_livraison__c.Magasin__c, testMagasin.Id)
                .create().getRecord();
        Zone_reservees__c testZoneReservee = (Zone_reservees__c)
            new SObjectBuilder(Zone_reservees__c.SObjectType)
                .put(Zone_reservees__c.Creneau__c, testSlotRecurrent.Id)
                .put(Zone_reservees__c.Zone_de_livraison__c, testZoneDeLivraison.Id)
                .create().getRecord();
        Code_postal_de_Zone__c testCodePostal = (Code_postal_de_Zone__c)
            new SObjectBuilder(Code_postal_de_Zone__c.SObjectType)
                .put(Code_postal_de_Zone__c.Zone_de_livraison__c, testZoneDeLivraison.Id)
                .create().getRecord();
        List<Creneau_Salesforce__c> testSlots = (List<Creneau_Salesforce__c>)
            new SObjectBuilder(Creneau_Salesforce__c.SObjectType)
                .put(Creneau_Salesforce__c.RecordTypeId, SLOT_RECORD_TYPES.get('Planning_de_livraison').getRecordTypeId())
                .put(Creneau_Salesforce__c.Type_de_planning__c, 'Livraison')
                .put(Creneau_Salesforce__c.Magasin__c, testMagasin.Id)
                .put(Creneau_Salesforce__c.Capacite__c, 10)
                // .put(Creneau_Salesforce__c.Capacite_disponible__c, 10)
                .put(Creneau_Salesforce__c.Date__c, new SObjectFieldProviders.ListProvider(dates))
                .put(Creneau_Salesforce__c.Heure_de_debut__c, TIME_DEBUT)
                .put(Creneau_Salesforce__c.Heure_de_fin__c, TIME_FIN)
                .put(Creneau_Salesforce__c.Temps_de_preparation__c, null)
                // .put(Creneau_Salesforce__c.Date_limite_de_commande__c, NOW.addHours(1))
                .put(Creneau_Salesforce__c.Creneau_Recurrent__c, testSlotRecurrent.Id)
                .count(201).create().getRecords();

        Test.startTest();
        List<FullCalendarController.CreneauWrapper> results = FullCalendarController.getSlots(testOrder.Id);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Bad count of retrieved slots');
    }

    @IsTest
    private static void testGetSlots_unknownDeliveryMethod() {
        Magasin__c testMagasin = createMagasin();
        Account testAccount = createAccount(testMagasin.Id);
        Order testOrder = createOrder(testAccount.Id, null);
        OrderDeliveryMethod testDeliveryMethod = createDeliveryMethod('INVALID');
        OrderDeliveryGroup testDeliveryGroup = createDeliveryGroup(testOrder.Id, testDeliveryMethod.Id);
        Exception caughtException;

        Test.startTest();
        try {
            FullCalendarController.getSlots(testOrder.Id);
            System.assert(false, 'Should fail here');
        } catch(Exception e) {
            caughtException = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException, 'Exception should be caught');
        System.assertEquals('Unknown delivery method: INVALID',  caughtException.getMessage(), 'Bad message of caught exception');
        System.assertEquals('System.AuraHandledException',  caughtException.getTypeName(), 'Bad type of caught exception');
    }
    
}