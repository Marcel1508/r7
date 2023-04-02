@isTest
public class GenerateSlots_ServiceTest {
    @istest
    private static void testCreateCreneauxForDate() {
         Magasin__c  magasin = TestDataFactory.createGenericMagasin('magasinTest');
        magasin.Adresse_du_drive_deporte__c = 'aa'; 
        magasin.Pourcentage_additionel_carte__c = 12;
        magasin.Minimum_Commande_Livraison__c = 1;
        magasin.Minimum_Commande_Drive__c = 1;
        magasin.Minimum_Commande_Drive_Deporte__c = 1;
        magasin.API_Key__c = 'api';
        insert magasin;
        
        Creneau_Magasin_Recurrent__c creneau = createCreneau(Time.newInstance(10, 0, 0, 0), Time.newInstance(11, 0, 0, 0), 20, 'Lundi', 'Livraison', magasin);
        creneau.Temps_de_preparation__c = 12;
        insert creneau;
        GenerateSlots_Service.weekOffset = 2;
        List<Creneau_Salesforce__c> res = GenerateSlots_Service.createCreneauxForDate(creneau, Date.newInstance(2020, 02, 01), GenerateSlots_Service.weekOffset);
        system.assertEquals(Time.newInstance(10, 0, 0, 0), res.get(0).Heure_de_debut__c);
        system.assertEquals(Time.newInstance(11, 0, 0, 0), res.get(1).Heure_de_fin__c);
        system.assertEquals(Date.newInstance(2020, 02, 01), res.get(0).Date__c);
        system.assertEquals(Date.newInstance(2020, 02, 08), res.get(1).Date__c);
    } 
    
    @isTest
    private static void testGenerateCreneaux() {
         Magasin__c  magasin = TestDataFactory.createGenericMagasin('magasinTest');
        magasin.Adresse_du_drive_deporte__c = 'aa';
        magasin.Pourcentage_additionel_carte__c = 12;
        magasin.Minimum_Commande_Livraison__c = 1;
        magasin.Minimum_Commande_Drive__c = 1;
        magasin.Minimum_Commande_Drive_Deporte__c = 1;
        magasin.API_Key__c = 'api';
        insert magasin;
        Creneau_Magasin_Recurrent__c creneau = createCreneau(Time.newInstance(10, 0, 0, 0), Time.newInstance(11, 0, 0, 0), 20, 'Lundi', 'Livraison', magasin);
        creneau.Temps_de_preparation__c = 12;
        insert creneau;
        GenerateSlots_Service.weekOffset = 2;
        
        // First Test on **22/02/2020**
        Date todayDate = Date.newInstance(2021, 02, 22);
        List<Creneau_Magasin_Recurrent__c> creneaux = (List<Creneau_Magasin_Recurrent__c>)Database.query(GenerateSlots_Service.getQuery(todayDate));
        GenerateSlots_Service.generateCreneaux(creneaux, todayDate);
        List<Creneau_Salesforce__c> createdSlots = [SELECT ID, Date__c, Jour__c, Creneau_Recurrent__c, recordTypeId FROM Creneau_Salesforce__c order by Date__c asc];
                        system.assertEquals(2, createdSlots.size());
        system.assertEquals(Date.newInstance(2021, 02, 22), createdSlots.get(0).Date__c);
        system.assertEquals(creneau.Id, createdSlots.get(0).Creneau_Recurrent__c);
        system.assertEquals(GenerateSlots_Service.getLivraisonRecordType(), createdSlots.get(0).recordTypeId);
        system.assertEquals(Date.newInstance(2021, 03, 01), createdSlots.get(1).Date__c, 'Second slot created must have date=01/03/2020, its 22/02/2020 + 7 days');
        system.assertEquals(creneau.Id, createdSlots.get(1).Creneau_Recurrent__c);
        system.assertEquals(true, [SELECT ID, is_slots_generated__c FROM Creneau_Magasin_Recurrent__c].is_slots_generated__c);
        // *** Test in the same date on **22/02/2020** (we shouldn't have any slot created)
        creneaux = (List<Creneau_Magasin_Recurrent__c>)Database.query(GenerateSlots_Service.getQuery(todayDate));
        GenerateSlots_Service.generateCreneaux(creneaux, todayDate);
        createdSlots = [SELECT ID, Date__c, Jour__c, Creneau_Recurrent__c, recordTypeId FROM Creneau_Salesforce__c order by Date__c asc];
                system.assertEquals(2, createdSlots.size());
        
        // Second Test next Day **23/02/2020**
        todayDate = Date.newInstance(2021, 02, 23);
        creneaux = (List<Creneau_Magasin_Recurrent__c>)Database.query(GenerateSlots_Service.getQuery(todayDate));
        GenerateSlots_Service.generateCreneaux(creneaux, todayDate);
        //GenerateSlots_Service.generateCreneaux(Date.newInstance(2021, 02, 23));
        createdSlots = [SELECT ID, Date__c, Jour__c, Creneau_Recurrent__c FROM Creneau_Salesforce__c order by Date__c asc];
        system.assertEquals(3, createdSlots.size());
        system.assertEquals(Date.newInstance(2021, 03, 08), createdSlots.get(2).Date__c, 'We must have a new slot created next week');
        system.assertEquals(creneau.Id, createdSlots.get(2).Creneau_Recurrent__c);
        // *** Second Test In the same Day **23/02/2020** (we shouldn't have any slot created)
        creneaux = (List<Creneau_Magasin_Recurrent__c>)Database.query(GenerateSlots_Service.getQuery(todayDate));
        GenerateSlots_Service.generateCreneaux(creneaux, todayDate);
        createdSlots = [SELECT ID, Date__c, Jour__c, Creneau_Recurrent__c, recordTypeId FROM Creneau_Salesforce__c order by Date__c asc];
        system.assertEquals(3, createdSlots.size());
        
        // Second Test next Day **24/02/2020** (we will create a new recurrent slot)
        Creneau_Magasin_Recurrent__c creneau2 = createCreneau(Time.newInstance(10, 0, 0, 0), Time.newInstance(11, 0, 0, 0), 20, 'Mardi', 'Drive déporté', magasin);
        insert creneau2;
        todayDate = Date.newInstance(2021, 02, 24);
        creneaux = (List<Creneau_Magasin_Recurrent__c>)Database.query(GenerateSlots_Service.getQuery(todayDate));
        GenerateSlots_Service.generateCreneaux(creneaux, todayDate);
        
        //GenerateSlots_Service.generateCreneaux(Date.newInstance(2021, 02, 24));
        createdSlots = [SELECT ID, Date__c, Jour__c, Creneau_Recurrent__c FROM Creneau_Salesforce__c order by Date__c asc];
        List<Creneau_Salesforce__c> createdSlots2 = [SELECT ID, Date__c, Jour__c, Creneau_Recurrent__c, recordTypeId FROM Creneau_Salesforce__c where Creneau_Recurrent__c=:creneau2.Id order by Date__c asc];
        system.assertEquals(5, createdSlots.size());
        system.assertEquals(2, createdSlots2.size());
        system.assertEquals(Date.newInstance(2021, 02, 23), createdSlots2.get(0).Date__c);
        system.assertEquals(Date.newInstance(2021, 03, 02), createdSlots2.get(1).Date__c);
        system.assertEquals(GenerateSlots_Service.getDriveRecordType(), createdSlots2.get(1).recordTypeId);
    }
    
    private static Creneau_Magasin_Recurrent__c createCreneau(Time heureDebut, Time heureFin, Integer capacite, String jour, String typePlanning, Magasin__c magasin) {
        Creneau_Magasin_Recurrent__c cr = new Creneau_Magasin_Recurrent__c();
        cr.Heure_de_debut__c = heureDebut;
        cr.Heure_de_fin__c = heureFin;
        cr.Capacite__c = capacite;
        cr.Jour__c = jour;
        cr.Temps_de_preparation__c = 12;
        cr.Type_de_planning__c = typePlanning;
        cr.Magasin__c = magasin.Id;

        if(CR.Type_de_planning__c == 'Drive' || CR.Type_de_planning__c == 'Drive déporté') {
            cr.RecordTypeId = getDriveRecordType();
        } else if(CR.Type_de_planning__c == 'Livraison') {
            cr.RecordTypeId = getLivraisonRecordType();
        }

        return cr;
    }
    
    private static Id getLivraisonRecordType() {
        try {
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Creneau_Magasin_Recurrent__c.getRecordTypeInfosByDeveloperName();
            Id lRecTypeId = recordTypes.get('Planning_de_livraison').getRecordTypeId();
                        return lRecTypeId;
        } catch(Exception e) {
                        return null;
        }
    }
    
    private static Id getDriveRecordType() {
        try {
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Creneau_Magasin_Recurrent__c.getRecordTypeInfosByDeveloperName();
            Id lRecTypeId = recordTypes.get('Planning_de_drive').getRecordTypeId();
                        return lRecTypeId;
        } catch(Exception e) {
                        return null;
        }
    }
}