@isTest
public class creneauMagasinRecurrTriggerHandlerTest {
    
    @testSetup
    private static void initData() {
        Magasin__c c = new Magasin__c();
        c.API_Key__c ='TEST';
        c.Pourcentage_additionel_carte__c = 2;
        c.Minimum_Commande_Livraison__c  = 1;
        c.Minimum_Commande_Drive__c = 2;
        c.Minimum_Commande_Drive_Deporte__c = 1;
        insert c;
        Creneau_Magasin_Recurrent__c cr = new Creneau_Magasin_Recurrent__c(Heure_de_debut__c=Time.newInstance(13, 00, 00, 22), Heure_de_fin__c=Time.newInstance(20, 00, 00, 22), Capacite__c = 20, Temps_de_preparation__c= 19, jour__c='Lundi', magasin__c = c.Id);
        insert cr;
        Creneau_Salesforce__c cs = new Creneau_Salesforce__c(magasin__c=c.id, Creneau_Recurrent__c=cr.Id);
        insert cs;
    }
    
    @isTest
    private static void test() {
        Creneau_Magasin_Recurrent__c cr = [SELECT ID FROM Creneau_Magasin_Recurrent__c limit 1];
        cr.Heure_de_debut__c = Time.newInstance(10, 00, 00, 22);
        cr.Heure_de_fin__c = Time.newInstance(11, 00, 00, 00);
        cr.Capacite__c = 10;
        cr.Temps_de_preparation__c = 10;
        update cr;
    }
    
    
}