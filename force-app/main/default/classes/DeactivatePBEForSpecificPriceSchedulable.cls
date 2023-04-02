public class DeactivatePBEForSpecificPriceSchedulable implements Schedulable{
    
     public Static void execute(SchedulableContext sc){
      DeactivatePBEForSpecificPriceBatch dpbs = new DeactivatePBEForSpecificPriceBatch();
        Database.executeBatch(dpbs);
     }

}