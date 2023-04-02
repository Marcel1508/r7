/**
 * @author : Marouane Khayou
 * @date : 17/02/2021
 * @description : class to handle slots creation
 */
public without sharing class GenerateSlots_Service {
    private static Map<String, String> weekDaysFormat = new Map<String, String>{
        '1' => 'Lundi',
        '2' => 'Mardi',
        '3' => 'Mercredi',
        '4' => 'Jeudi',
        '5' => 'Vendredi',
        '6' => 'Samedi',
        '7' => 'Dimanche'
    };
    private static Map<String, Integer> daysOffset = new Map<String, Integer>{
        'Lundi' => 0,
        'Mardi' => 1,
        'Mercredi' => 2,
        'Jeudi' => 3,
        'Vendredi' => 4,
        'Samedi' => 5,
        'Dimanche' => 6
    };
    @testVisible
    private static Integer weekOffset = 8;

    public static void generateCreneaux(List<Creneau_Magasin_Recurrent__c> creneaux, Date todayDate) {
        List<Creneau_Salesforce__c> creneauxSalesforceToCreate = new List<Creneau_Salesforce__c>();
        //List<Creneau_Magasin_Recurrent__c> creneaux = getCreneauxMagasinRecurrent(getYesterday(todayDate));
        List<Creneau_Magasin_Recurrent__c> creneauxToInit = new List<Creneau_Magasin_Recurrent__c>();
        List<Creneau_Magasin_Recurrent__c> creneauxToIncrement = new List<Creneau_Magasin_Recurrent__c>();

        Date weekStart = todayDate.toStartofWeek();

        if (creneaux != null && creneaux.size() > 0) {
            for (Creneau_Magasin_Recurrent__c creneau : creneaux) {
                if (!creneau.is_slots_generated__c) {
                    creneauxToInit.add(creneau);
                } else {
                    creneauxToIncrement.add(creneau);
                }
            }
            for (Creneau_Magasin_Recurrent__c crm : creneauxToInit) {
                Date startDate = weekStart.addDays(daysOffset.get(crm.Jour__c));
                List<Creneau_Salesforce__c> res = createCreneauxForDate(crm, startDate, weekOffset);
                creneauxSalesforceToCreate.addAll(res);
            }
            for (Creneau_Magasin_Recurrent__c crm : creneauxToIncrement) {
                Date startDate = (weekStart.addDays(daysOffset.get(crm.Jour__c))).addDays(7 * weekOffset);
                List<Creneau_Salesforce__c> res = createCreneauxForDate(crm, startDate, 1);
                creneauxSalesforceToCreate.addAll(res);
            }
        }
        if (creneauxSalesforceToCreate.size() > 0) {
            insert creneauxSalesforceToCreate;
            updateIsSlotsCreated(creneauxToInit, creneauxToIncrement, todayDate);
        }
    }

    public static void updateIsSlotsCreated(
        List<Creneau_Magasin_Recurrent__c> creneauxToInit,
        List<Creneau_Magasin_Recurrent__c> creneauxToIncrement,
        Date todayDate
    ) {
        List<Creneau_Magasin_Recurrent__c> creneauxToUpdate = new List<Creneau_Magasin_Recurrent__c>();
        for (Creneau_Magasin_Recurrent__c cmr : creneauxToInit) {
            cmr.is_slots_generated__c = true;
            cmr.last_increment_date__c = todayDate;
            creneauxToUpdate.add(cmr);
        }
        for (Creneau_Magasin_Recurrent__c cmr : creneauxToIncrement) {
            cmr.last_increment_date__c = todayDate;
            creneauxToUpdate.add(cmr);
        }
        update creneauxToUpdate;
    }

    public static String getQuery(Date todayDate) {
        Date yesterD = getYesterday(todayDate);
        DateTime myDateTime = (DateTime) yesterD;
        String dayOfWeek = myDateTime.format('u'); //** Format method return Day number of week (1 = Monday, ..., 7 = Sunday) **//
        String day = weekDaysFormat.get(dayOfWeek);
        String formattedToday = getFormattedTodayDate(todayDate);

        String query =
            'SELECT ID, is_slots_generated__c, last_increment_date__c, jour__c, Heure_de_debut__c, Heure_de_fin__c, Capacite__c, Type_de_planning__c, Temps_de_preparation__c, Magasin__c FROM Creneau_Magasin_Recurrent__c WHERE is_slots_generated__c = FALSE OR (jour__c = \'' +
            day +
            '\' AND last_increment_date__c != ' +
            formattedToday +
            ')';
        return query;
    }

    private static String getFormattedTodayDate(Date todayDate) {
        DateTime dt = DateTime.newInstance(todayDate.year(), todayDate.month(), todayDate.day());
        String formattedDate = dt.format('YYYY-MM-dd');
        return formattedDate;
    }

    /*@testVisible
    private static List<Creneau_Magasin_Recurrent__c> getCreneauxMagasinRecurrent(Date d) {
        DateTime myDateTime = (DateTime) d;
        String dayOfWeek = myDateTime.format('u'); //** Format method return Day number of week (1 = Monday, ..., 7 = Sunday)
        String day = weekDaysFormat.get(dayOfWeek);
        
        List<Creneau_Magasin_Recurrent__c> res = [SELECT ID, is_slots_generated__c, jour__c, Heure_de_debut__c, Heure_de_fin__c, Capacite__c, Type_de_planning__c, Temps_de_preparation__c, Magasin__c FROM Creneau_Magasin_Recurrent__c WHERE is_slots_generated__c = FALSE OR jour__c = :day];
        
        return res;
    }
    
    private static List<Creneau_Salesforce__c> getCreneauxSalesforce(List<Id> idCreneauxMagasinRecurrent) {
        List<Creneau_Salesforce__c> res = [SELECT ID FROM Creneau_Salesforce__c where Creneau_Recurrent__c in :idCreneauxMagasinRecurrent];
        if(res != null && res.size() >0)
            return res;
        return null;
    }*/

    @testVisible
    private static List<Creneau_Salesforce__c> createCreneauxForDate(
        Creneau_Magasin_Recurrent__c creneau,
        Date startDate,
        Integer offset
    ) {
        List<Creneau_Salesforce__c> res = new List<Creneau_Salesforce__c>();
        Id recTypeId;
        if (creneau.Type_de_planning__c == Constants.DRIVE || creneau.Type_de_planning__c == Constants.DRIVE_DEPORTE) {
            recTypeId = getDriveRecordType();
        } else if (creneau.Type_de_planning__c == Constants.LIVRAISON) {
            recTypeId = getLivraisonRecordType();
        }
        for (Integer i = 0; i < offset; i++) {
            Creneau_Salesforce__c cs = new Creneau_Salesforce__c();
            cs.Heure_de_debut__c = creneau.Heure_de_debut__c;
            cs.Heure_de_fin__c = creneau.Heure_de_fin__c;
            cs.Capacite__c = creneau.Capacite__c;
            cs.Creneau_Recurrent__c = creneau.Id;
            cs.Date__c = startDate;
            cs.Jour__c = creneau.Jour__c;
            cs.Type_de_planning__c = creneau.Type_de_planning__c;
            cs.Temps_de_preparation__c = creneau.Temps_de_preparation__c;
            cs.Magasin__c = creneau.Magasin__c;
            if (recTypeId != null) {
                cs.RecordTypeId = recTypeId;
            }
            res.add(cs);
            startDate = startDate.addDays(7);
        }
        return res;
    }
    @testVisible
    private static Id getDriveRecordType() {
        try {
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Creneau_Salesforce__c.getRecordTypeInfosByDeveloperName();
            Id pRecTypeId = recordTypes.get('Planning_de_drive').getRecordTypeId();
            return pRecTypeId;
        } catch (Exception e) {
            return null;
        }
    }
    @testVisible
    private static Id getLivraisonRecordType() {
        try {
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Creneau_Salesforce__c.getRecordTypeInfosByDeveloperName();
            Id lRecTypeId = recordTypes.get('Planning_de_livraison').getRecordTypeId();
            return lRecTypeId;
        } catch (Exception e) {
            return null;
        }
    }

    private static Date getYesterday(Date d) {
        return d.addDays(-1);
    }
}