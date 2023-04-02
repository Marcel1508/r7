public class DeactivatePBEForSpecificPriceBatch implements Database.Batchable<sObject>{
    private PrixSpecifiqueService speService = new PrixSpecifiqueService();
    
    String query = 'SELECT Id, Offre_Produit_Magasin__c, Produit__c, Reference_client__r.Name, Libelle_etablissement__r.Name, Libelle_etablissement__c FROM Prix_specifiques__c WHERE Date_de_fin_d_application__c < Today and isActive__c = true ';

    public Database.QueryLocator start(Database.BatchableContext bc){
       return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Prix_specifiques__c> scope){
        
        speService.activateDeactivatePriceBookEntries(scope, new List<Prix_specifiques__c>());

        for(Prix_specifiques__c spe : scope){
            spe.isActive__c = false;
        }
        update Scope;
    }

    public void finish(Database.BatchableContext BC){
        // do nothing      
    }
}