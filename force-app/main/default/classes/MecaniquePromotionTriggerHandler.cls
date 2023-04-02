/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          22-03-2021           ajay.tiwari3@ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
public  class MecaniquePromotionTriggerHandler {
    private final  Map<Id, Mecanique_Promotion__c> newRecords;
    private final Map<Id, Mecanique_Promotion__c> oldRecords;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    private static MecaniquePromotionService service = new MecaniquePromotionService();
    
    public MecaniquePromotionTriggerHandler(Map<Id,Mecanique_Promotion__c> newRecords, Map<Id, Mecanique_Promotion__c> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
    }
    
    public void afterInsertMethod() {
        if (bypassTrigger) { return; }
      else{
          if(firstRun){
            firstRun = false;
            service.updatePromotions(newRecords);
          }
      }
    }
        
}