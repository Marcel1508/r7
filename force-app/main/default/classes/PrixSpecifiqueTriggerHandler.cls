/**
* @author : Maud Vasseur - IBM Lille
* @date : 12/2020
* @description : Handler du trigger Prix_specifiques__c
**/

public class PrixSpecifiqueTriggerHandler {
    private final List<Prix_specifiques__c> newRecords;
    private final Map<Id, Prix_specifiques__c> oldRecords;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    @testVisible private PrixSpecifiqueService PrixSpecifiqueService = new PrixSpecifiqueService();
    
    public PrixSpecifiqueTriggerHandler(List<Prix_specifiques__c> newRecords, Map<Id, Prix_specifiques__c> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
    }
    
    public void bypassTrigger(){
        User currentUser = [Select Id, Bypass_Trigger__c FROM user WHERE Id=:userInfo.getUserId()];
        if (currentUser.Bypass_Trigger__c != null && currentUser.Bypass_Trigger__c.contains('PrixSpecifiqueTrigger')) { 
            System.debug('Le trigger sur objet Prix spécifiques est bypassé pour cet utilisateur');
            bypassTrigger = true;
        }
    }
    
    /*public void beforeInsert() {
        bypassTrigger();
        if (!bypassTrigger) { 
            if (firstRun) {
                firstRun = false;
				PrixSpecifiqueService.checkInformationRelatedToPrixSpecifiques(newRecords);
            }
        }
    }
    
    public void beforeUpdate(){
        bypassTrigger();
        if (!bypassTrigger) { 
            if (firstRun) {
                firstRun = false;
                PrixSpecifiqueService.checkInformationRelatedToPrixSpecifiques(newRecords);
        	}
        }
    }*/
    
    public void afterInsert() {
        bypassTrigger();
        if (!bypassTrigger) { 
            //if (firstRun) {
                //firstRun = false;
				PrixSpecifiqueService.checkInformationRelatedToPrixSpecifiques(newRecords);
            //}
        }
    }
    
    public void afterUpdate(){
        bypassTrigger();
        if (!bypassTrigger) { 
            //if (firstRun) {
                //firstRun = false;
                List<Prix_specifiques__c> spesToDeactivate = new List<Prix_specifiques__c>();
                List<Prix_specifiques__c> spesToActivate = new List<Prix_specifiques__c>();
                
                for(Prix_specifiques__c spe : newRecords){
                    if(spe.Date_de_fin_d_application__c != oldRecords.get(spe.Id).Date_de_fin_d_application__c && spe.Date_de_fin_d_application__c< Date.Today() ){
                        spesToDeactivate.add(spe);
                    }else if(spe.Date_de_fin_d_application__c != oldRecords.get(spe.Id).Date_de_fin_d_application__c && spe.Date_de_fin_d_application__c>= Date.Today()){
                        spesToActivate.add(spe);
                    }
                }
        	//}
                 
                PrixSpecifiqueService.ActivateDeactivatePriceBookEntries(spesToDeactivate,spesToActivate);
        }
    }
    

}