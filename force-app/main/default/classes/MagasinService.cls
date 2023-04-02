/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Classe de service de l'objet Magasin
* @TestClass : MagasinService_TST
**/

public with sharing class MagasinService {
      
       public List<Magasin__c> filterMagasin (List<Magasin__c> newRecords, Map<Id,Magasin__c> oldRecords, String filterType) {
       List<Magasin__c> filteredRecords = new List<Magasin__c>();
       if(filterType == 'pricebook')
       {
           for (Magasin__c newRecord : newRecords) {
           Magasin__c oldRecord = oldRecords.get(newRecord.Id);
           if(oldRecord.Rang_tarifaire__c != newRecord.Rang_tarifaire__c){
                filteredRecords.add(newRecord);
           }
       }
       }else if(filterType == 'venteAuPCB'){
           for (Magasin__c newRecord : newRecords) {
           Magasin__c oldRecord = oldRecords.get(newRecord.Id);
           if(oldRecord.Vente_au_PCB__c != newRecord.Vente_au_PCB__c){
                filteredRecords.add(newRecord);
           }
       }
           
       }else
       {
           for (Magasin__c newRecord : newRecords) {
           Magasin__c oldRecord = oldRecords.get(newRecord.Id);
           if((oldRecord.Extension_de_gamme__c != newRecord.Extension_de_gamme__c)
             || (oldRecord.Rang_tarifaire__c != newRecord.Rang_tarifaire__c)){
                filteredRecords.add(newRecord);
           }
       }
           
       }
             
       return filteredRecords;
   }


    public List<Offre_Produit_Magasin__c> getOPMs(List<Magasin__c> newRecords) {
        List<Offre_Produit_Magasin__c> listOPM = [
            SELECT Id, 
            name, 
			Produit__c,
            Actif_Aquilon__c,
            Produit_actif__c, 
			Produit_avec_assortiment_text__c,
            Code_departement__c,
            Statut__c,
			Magasin__c,
            Extension_de_gamme__c,
			Produit_en_extension_de_gamme__c,
            Prix_de_vente_magasin_au_conditionnement__c,
            Prix_de_vente_magasin__c,
            Prix_de_vente_tarif_T2__c,
            Prix_de_vente_tarif_T3__c,
            Prix_T3_au_conditionnement_de_vente__c,
            Prix_T2_au_conditionnement_de_vente__c,
            Produit__r.Prix_de_vente_tarif_T2__c,
            Produit__r.Prix_de_vente_tarif_T3__c,
            Magasin__r.Extension_de_gamme__c,
            Ref_tarifaire_magasin__c,
			Rang_tarifaire__c,
			Niveau_de_stock__c,
			En_cours_de_commande__c,
			Rupture_entrepot1__c
            FROM Offre_Produit_Magasin__c 
            WHERE Magasin__c = :newRecords
		];
        
        return listOPM;
    }
    
}