public class OpmTrigger_Batch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, Magasin__c, Produit__c, Produit_actif__c, Produit_avec_assortiment_text__c, Prix_de_vente_magasin__c, Prix_de_vente_tarif_T2__c,'+
                                        'Prix_de_vente_tarif_T3__c, Prix_unite__c, Ref_tarifaire_magasin__c, Statut__c, Produit_en_extension_de_gamme__c, Code_departement__c, Actif_Aquilon__c, Niveau_de_stock__c,'+
                                        'En_cours_de_commande__c, Rupture_entrepot1__c, Rang_tarifaire__c,'+
                                        +' Prix_de_vente_magasin_au_conditionnement__c, Prix_T2_au_conditionnement_de_vente__c, Prix_T3_au_conditionnement_de_vente__c, Extension_de_gamme__c, Magasin__r.Name FROM Offre_Produit_Magasin__c WHERE produit__c != NULL AND LastModifiedDate = TODAY');
    }
    
    public void execute(Database.BatchableContext BC, List<Offre_Produit_Magasin__c> scope){
        OffreProduitMagasinService offreProduitMagasinService = new OffreProduitMagasinService();
        
        offreProduitMagasinService.startProductFlow(scope);
        offreProduitMagasinService.upsertPriceBooksOPM(scope);
        update scope;
        offreProduitMagasinService.updatePriceBooksOPMWithSpe(scope);
    }
    
    public void finish(Database.BatchableContext BC){}
}