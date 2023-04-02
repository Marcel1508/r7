/**
* @CreatedBy       : Hari DIGBO
* @Date            : 15/02/2023
* @Company         : IBM
* @Description     : Batch Class to delete some record's Object 
*/
public without sharing class BatchToDeleteRecordsObject implements Database.Batchable<sObject> {
   public String query;

   public Database.QueryLocator start(Database.BatchableContext bc){
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext bc, List<sObject> scope){
      delete scope;
      DataBase.emptyRecycleBin(scope);
   }

   public void finish(Database.BatchableContext bc){
       
   }
}