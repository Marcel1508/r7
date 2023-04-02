@isTest
public class GenerateSlotsBatchTest {
	
    @isTest
    private static void test() {
        Magasin__c magasin = new Magasin__c();
        magasin.name='Test';
        magasin.Adresse_du_drive_deporte__c = 'aa';
        magasin.Pourcentage_additionel_carte__c = 12;
        magasin.Minimum_Commande_Livraison__c = 1;
        magasin.Minimum_Commande_Drive__c = 1;
        magasin.Minimum_Commande_Drive_Deporte__c = 1;
        insert magasin;
        Creneau_Magasin_Recurrent__c creneau = createCreneau(Time.newInstance(10, 0, 0, 0), Time.newInstance(11, 0, 0, 0), 20, 'Lundi', 'Livraison', magasin);
        creneau.Temps_de_preparation__c = 12;
        insert creneau;
        
        Test.startTest();
        Database.executeBatch(new GenerateSlotsBatch(Date.newInstance(2021, 04, 16)), 200);
        Test.stopTest();
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