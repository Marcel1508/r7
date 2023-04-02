/**
* @author       aymen.mtir@ibm
* @date         2020-11-01
* @description  TriggerHandler for OrderTrigger
**/
public class OrderTriggerHandler {
    private final List<Order> newRecords;
    private final Map<Id, Order> oldRecords;
    private final Map<Id, Order> newRecordsMap;
    @testVisible private static Boolean bypassTrigger = false;
    @testVisible private static Boolean firstRun = true;
    @testVisible private static Boolean ordersSendToAquilon = false;
    private static OrderService service = new OrderService();
    
    public OrderTriggerHandler(List<Order> newRecords, Map<Id, Order> oldRecords, Map<Id, Order> newRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newRecordsMap = newRecordsMap;
    }
    
    public void afterInsertMethod() {
        if (bypassTrigger) { return; }
        if (firstRun) { 
            firstRun = false;
            Set<Id> orderIds = new Set<Id>();
            for (Order newRecord : newRecords) {
                if (newRecord.AccountId != null) {
                    orderIds.add(newRecord.Id);
                }
            }
            List<Order> orders = service.getOrders(orderIds);
            service.fillNumeroDeCommand(orders);
            service.markFirstOrder(orders); 
            service.removeAccountDeliveryAuthorizations(newRecords);
            if (!System.isFuture() && !System.isBatch()) {
                //Send related account to ApiGee then orders
                /*OrderResultsToApigee_SVC.sendRelatedAccount(newRecords);*/
                system.debug(' from trigger insert condition ----->>');
                OrderResultsToApigee_SVC.getOrders('AInsert', newRecords);
            }
        }
        
    }
    
    public void afterUpdateMethod() {
        
        //Edit By Marouane
        //At the end of the checkout we noticed that the order is not sent to Aquilon, B2B commerce cloud make a lot of updates that fire the Trigger many times so the "firstrun" variable 
        //turns to false and the OrderResultsToApigee_SVC is not called
        List<order> orderToSendToAquilon = new List<Order>();
        for(Order o: newRecords) {
            if(oldRecords.get(o.id).Status == 'Draft order' && o.Status == '1' && o.Aquilon_Synchronisation_Statut__c == null && o.Aquilon_synchronisation_details__c == null && !firstRun && !ordersSendToAquilon) {
                orderToSendToAquilon.add(o);
            }
        }
        if(!orderToSendToAquilon.isEmpty()) {
            ordersSendToAquilon = true;
            OrderResultsToApigee_SVC.getOrders('AInsert', orderToSendToAquilon);
        }
        //End of edit code
        if (bypassTrigger) { return; }
        if (firstRun) { 
            firstRun = false;
            system.debug('afterUpdateMethod()');
            if (bypassTrigger) { return; }
            Set<Id> setOfId = new Set<Id>();
            service.removeAccountDeliveryAuthorizations(newRecords);
            system.debug('future--->'+System.isFuture()+'Batch12 : '+System.isBatch());
            //Edit by marouane
            /*Map<Id, Order> ordersToSendToAcquilon = new Map<Id, Order>();
            if(!System.isBatch()) {
                for(Order o: newRecords) {
                    if(oldRecords.get(o.Id).Status != o.Status && Status = '2' && o.is_BDP_generated__c)
                        ordersToSendToAcquilon.put(o.Id, o);
                }
            }
            if(!ordersToSendToAcquilon.isEmpty())
                OrderResultsToApigee_SVC.checkOrderStatus(ordersToSendToAcquilon, oldRecords);*/
            
            if (!System.isFuture() && !System.isBatch()) {
                service.voidCancelledOrders(newRecords, oldRecords);
                service.captureTerminatedOrders(newRecords, oldRecords);
                //OrderResultsToApigee_SVC.getOrders('AUpdate', newRecordsMap, oldRecords);
                OrderResultsToApigee_SVC.checkOrderStatus(newRecordsMap, oldRecords);
            }

         } 
        
    }
    
    public void afterDeleteMethod() {
        if (bypassTrigger) { return; }
    } 
}