/**
 * @CreatedBy       : Chandra Sekhar
 * @Date            : 09/08/2021
 * @Company         : IBM, Bluewolf
 * @Description     : Scheduler Class to run the BatchToShareActiviteAccWithMagasin class every Morning 7 AM 
 */
public without sharing class ScheduleBatchToShareAccounts implements Schedulable {
   public void execute(SchedulableContext SC) {
      BatchToShareActiviteAccWithMagasin batchObj = new BatchToShareActiviteAccWithMagasin(); 
      Database.executeBatch(batchObj, 50);
   }
}