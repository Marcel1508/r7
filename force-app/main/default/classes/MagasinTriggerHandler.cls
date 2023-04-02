/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Handler du trigger Magasin
**/

public with sharing class MagasinTriggerHandler {
    private final List<Magasin__c> newRecords;
    private final Map<Id, Magasin__c> oldRecords;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    @testVisible private static MagasinService MagasinService = new MagasinService();
    @testVisible private static OffreProduitMagasinService OffreProduitMagasinService = new OffreProduitMagasinService();
    
    public MagasinTriggerHandler(List<Magasin__c> newRecords, Map<Id, Magasin__c> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
    }
    
    public void bypassTrigger(){
        User currentUser = [Select Id, Bypass_Trigger__c FROM user WHERE Id=:userInfo.getUserId()];
        if (currentUser.Bypass_Trigger__c != null && currentUser.Bypass_Trigger__c.contains('MagasinTrigger')) { 
                        bypassTrigger = true;
        } 
    }
    
    public void afterUpdate() {
        bypassTrigger();
        if (!bypassTrigger) { 
        	if (firstRun) {
                firstRun = false;
                List<Magasin__c> filteredMagasins = MagasinService.filterMagasin(newRecords, oldRecords,'others');
                if (!filteredMagasins.isEmpty()){
                    //List<Offre_Produit_Magasin__c> opms = magasinService.getOPMs(filteredMagasins);
                    //MagasinService.startProductFlow(opms);
                    MagasinTriggerServiceBatch batch = new MagasinTriggerServiceBatch(filteredMagasins);
       				database.executebatch(batch, 10);
                }
                List<Magasin__c> filteredMagasinsPricebook = MagasinService.filterMagasin(newRecords, oldRecords,'pricebook');
                if (!filteredMagasinsPricebook.isEmpty()){
                    List<Offre_Produit_Magasin__c> opms = magasinService.getOPMs(filteredMagasins);
                    OffreProduitMagasinService.updatePriceBooksOPM(opms);
                }
                
                List<Magasin__c> filteredMagasinsVenteAuPcb = MagasinService.filterMagasin(newRecords, oldRecords,'venteAuPCB');
                if (!filteredMagasinsVenteAuPcb.isEmpty()){
                    List<Offre_Produit_Magasin__c> opmsVenteAuPcb = magasinService.getOPMs(filteredMagasinsVenteAuPcb);
                    OffreProduitMagasinService.updatePriceBooksOPM(opmsVenteAuPcb);
                }
            }
        }
    }
}