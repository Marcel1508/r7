/**
* @author       aymen.mtir@ibm.com, maud.vasseur@ibm.com
* @date         2021-02-25
* @description  Controller for fullCalendar LWC component (Slot Booking Calendar)
**/
public with sharing class FullCalendarController {

    private static final Datetime TIME_NOW = Datetime.now();
    private static final String DRIVE = Constants.drive;
    private static final String DRIVE_DEPORTE = Constants.DRIVE_DEPORTE;
    private static final String LIVRAISON = Constants.LIVRAISON;  
    
    public class CreneauWrapper {
        @AuraEnabled public String title;
        @AuraEnabled public Datetime dateTimeDebut;
        @AuraEnabled public Datetime dateTimeFin;
        @AuraEnabled public String id;
        @AuraEnabled public String color;
        @AuraEnabled public Decimal capaciteDisponible;
        @AuraEnabled public String preparationtimestring;
        @AuraEnabled public String slotDate;
        @AuraEnabled public String slotTimedebut;
        @AuraEnabled public String slotTimefin;
        
        public CreneauWrapper(Creneau_Salesforce__c creneau, String deliveryType) {
            /*String color = 
                (deliveryType == LIVRAISON) ? 'green' :
                (deliveryType == DRIVE) ? 'blue' :
                (deliveryType == DRIVE_DEPORTE) ? 'navy' :
                'gray';*/
            String color = 'blue';
            TimeZone tz = UserInfo.getTimeZone();
            Datetime now = Datetime.now();
            Integer offset = tz.getOffset(now);

            this.title = creneau.Name;
            this.dateTimeDebut = DateTime.newInstance(creneau.Date__c, creneau.Heure_de_debut__c).addSeconds(offset/1000);
            this.datetimeFin = DateTime.newInstance(creneau.Date__c, creneau.Heure_de_fin__c).addSeconds(offset/1000);
            this.id = creneau.Id;
            this.color = color;
            this.capaciteDisponible = creneau.Capacite_disponible__c;
            this.preparationtimestring = String.valueOf(creneau.Temps_de_preparation__c);
            this.slotDate = creneau.Date__c.format();
            this.slotTimedebut = String.valueOf(creneau.Heure_de_debut__c).left(5);
            this.slotTimefin = String.valueOf(creneau.Heure_de_fin__c).left(5);
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static String getOppo() {
        List<Creneau_Salesforce__c> oppoList = [
            SELECT Id, Name, Date__c, Heure_de_debut__c, Heure_de_fin__c, Capacite_disponible__c, Type_de_planning__c, Temps_de_preparation__c 
            FROM Creneau_Salesforce__c];
        return JSON.serialize(oppoList); 
    }

    @AuraEnabled
    public static List<Event> fetchAllEvents() {
        List<Event> eventList = [
            SELECT Id, Subject, WhatId, WhoId, Description, EndDate, EndDateTime, OwnerId, ActivityDate, ActivityDateTime 
            FROM Event LIMIT 100];
        return eventList;
    }

    @AuraEnabled
    public static List<CreneauWrapper> getSlots(String orderId) {

        Order order = [SELECT Id, AccountId,Account.Id, Account.Magasin_actif_en_cours__c,(SELECT Id, OrderDeliveryMethodId, OrderDeliveryMethod.Id,OrderDeliveryMethod.Name FROM OrderDeliveryGroups), ShippingPostalCode FROM Order WHERE Id = :orderId];
        String deliveryMethodName = order.OrderDeliveryGroups[0].OrderDeliveryMethod.Name;
        String magasinActifEnCoursId = order.Account.Magasin_actif_en_cours__c;

        List<Creneau_Salesforce__c> creneauxPotentiels = new List<Creneau_Salesforce__c>();
        if (deliveryMethodName == DRIVE || deliveryMethodName == DRIVE_DEPORTE ) {
            creneauxPotentiels = [
                SELECT Id, Name, Date__c, Heure_de_debut__c, Heure_de_fin__c, Type_de_planning__c, Capacite_disponible__c, Temps_de_preparation__c, Date_limite_de_commande__c
                FROM Creneau_Salesforce__c 
                WHERE Type_de_planning__c = :deliveryMethodName
                AND Magasin__c = :magasinActifEnCoursId
                AND Date_limite_de_commande__c > :TIME_NOW];
        } else if (deliveryMethodName == LIVRAISON) {
            List<Creneau_Reserve__c> creneauxReserves = [
                SELECT Id, Creneau_Magasin__c
                FROM Creneau_Reserve__c
                WHERE Compte_client__c = :order.account.Id
                AND ID_magasin_TECH__c = :magasinActifEnCoursId];
            
            if (creneauxReserves.size() > 0) {
                creneauxPotentiels = [
                    SELECT Id, Name, Date__c, Heure_de_debut__c, Heure_de_fin__c, Creneau_Recurrent__c, Type_de_planning__c, Capacite_disponible__c, Temps_de_preparation__c, Date_limite_de_commande__c
                    FROM Creneau_Salesforce__c 
                    WHERE Creneau_Recurrent__c IN :Pluck.ids(Creneau_Reserve__c.Creneau_Magasin__c, creneauxReserves)];
            } else {
                List<Creneau_Salesforce__c> tempCreneaux = [
                    SELECT Id, Name, Date__c, Heure_de_debut__c, Heure_de_fin__c, Type_de_planning__c, Creneau_Recurrent__c, Capacite_disponible__c, Temps_de_preparation__c, Date_limite_de_commande__c
                    FROM Creneau_Salesforce__c 
                    WHERE Type_de_planning__c = :deliveryMethodName
                    AND Magasin__c = :magasinActifEnCoursId
                    AND Creneau_Recurrent__r.Creneau_affilie_une_zone__c = TRUE
                    AND Date_limite_de_commande__c > :TIME_NOW];

                List<Zone_reservees__c> zonesReservees = [
                    SELECT Id, Zone_de_livraison__c, Creneau__c
                    FROM Zone_reservees__c 
                    WHERE Creneau__c IN :Pluck.ids(Creneau_Salesforce__c.Creneau_Recurrent__c, tempCreneaux)];
                Map<Id, List<Zone_reservees__c>> zonesReserveesMap = new Map<Id, List<Zone_reservees__c>>();
                for (Zone_reservees__c zr : zonesReservees) {
                    List<Zone_reservees__c> zrList = zonesReserveesMap.get(zr.Creneau__c);
                    if (zrList == null) {
                        zrList = new List<Zone_reservees__c>();
                    }
                    zrList.add(zr);
                    zonesReserveesMap.put(zr.Creneau__c, zrList);
                }

                List<Code_postal_de_Zone__c> postalCodes = [
                    SELECT Id, Zone_de_livraison__c
                    FROM Code_postal_de_Zone__c 
                    WHERE Code_Postal__c = :order.ShippingPostalCode
                    AND Zone_de_livraison__c IN :Pluck.ids(Zone_reservees__c.Zone_de_livraison__c, zonesReservees)];
                Map<Id, List<Code_postal_de_Zone__c>> postalCodesMap = new Map<Id, List<Code_postal_de_Zone__c>>();
                for (Code_postal_de_Zone__c pc : postalCodes) {
                    List<Code_postal_de_Zone__c> pcList = postalCodesMap.get(pc.Zone_de_livraison__c);
                    if (pcList == null) {
                        pcList = new List<Code_postal_de_Zone__c>();
                    }
                    pcList.add(pc);
                    postalCodesMap.put(pc.Zone_de_livraison__c, pcList);
                }

                Map<Id, Creneau_Salesforce__c> creneauxMap = new Map<Id, Creneau_Salesforce__c>();
                for (Creneau_Salesforce__c c : tempCreneaux) {
                    List<Zone_reservees__c> tZones = zonesReserveesMap.get(c.Creneau_Recurrent__c);
                    if (tZones == null || tZones.isEmpty()) { continue; }
                    for (Zone_reservees__c zr : tZones) {
                        List<Code_postal_de_Zone__c> tCodes = postalCodesMap.get(zr.Zone_de_livraison__c);
                        if (tCodes == null || tCodes.isEmpty()) { continue; }
                        creneauxMap.put(c.Id, c);
                    }
                }
                creneauxPotentiels = creneauxMap.values();
            }
        } else {
            throw Utilities.newAuraHandledException('Unknown delivery method: ' + deliveryMethodName);
        }

        List<CreneauWrapper> slotsToDisplay = new List<CreneauWrapper>();
        for (Creneau_Salesforce__c cp : creneauxPotentiels) {
            if ((cp.Temps_de_preparation__c == null || cp.Date_limite_de_commande__c > TIME_NOW) && cp.Capacite_disponible__c > 0) {
                slotsToDisplay.add(new CreneauWrapper(cp, deliveryMethodName));
            }
        }

        return slotsToDisplay;
    }
}