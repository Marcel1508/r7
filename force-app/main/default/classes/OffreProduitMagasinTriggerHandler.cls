/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Handler du trigger Offre_produit_Magasin__c
**/

public with sharing class OffreProduitMagasinTriggerHandler {
    private final List<Offre_Produit_Magasin__c> newRecords;
    private final Map<Id, Offre_Produit_Magasin__c> oldRecords;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    @testVisible private static OffreProduitMagasinService OffreProduitMagasinService = new OffreProduitMagasinService();
    @testVisible private static PrixSpecifiqueService PrixSpecifiqueService = new PrixSpecifiqueService();

    
    public OffreProduitMagasinTriggerHandler(List<Offre_Produit_Magasin__c> newRecords, Map<Id, Offre_Produit_Magasin__c> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
    }
    
    public void bypassTrigger(){
        //Edit by Marouane (ticket SIC-588): Bypass the trigger in case of a batch execution and if one of records has (Execute_Trigger__c = True, this value is sent from NIFI in case of Bulk API) 
        bypassTrigger = (System.isBatch() && newRecords.get(0).Execute_Trigger__c)? True: False;
    }
    
    public void beforeInsert() {
        bypassTrigger();
        if (!bypassTrigger) {
            if (firstRun) {
                firstRun = false;
                OffreProduitMagasinService.startProductFlow(newRecords);
                OffreProduitMagasinService.createPriceBook(newRecords);
            }
        }
    }
    
    public void beforeUpdate() {
        bypassTrigger();
        if (!bypassTrigger) {
                        if (firstRun){
                firstRun = false;
                List<Offre_Produit_Magasin__c> filteredOPMs = OffreProduitMagasinService.filterOPMs(newRecords, oldRecords);
                                OffreProduitMagasinService.startProductFlow(filteredOPMs);
                List<Offre_Produit_Magasin__c> filteredOPMsPriceAndprixSpecifiques = OffreProduitMagasinService.filterOPMsPriceAndPrixSpecifiques(newRecords, oldRecords);
                if (!filteredOPMsPriceAndprixSpecifiques.isEmpty()){
                    OffreProduitMagasinService.updatePriceBooksOPMWithSpe(filteredOPMsPriceAndprixSpecifiques);
                    
                }
            }
        }
    }
}