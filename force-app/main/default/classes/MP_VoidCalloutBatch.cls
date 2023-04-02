/**
* @author       jan.straka@bluewolf
* @date         2021-04-05
* @description  Batch apex for MarketPay void API callout
**/
public with sharing class MP_VoidCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private final Set<Id> orderIds;
    private static String CANCELLED_SUCCESS = 'Cancelled - Success';
    private static String CANCELLED_ERROR = 'Cancelled - Error';

    public MP_VoidCalloutBatch(Set<Id> orderIds) {
        this.orderIds = orderIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Preauthorize_Uuid__c, Magasin_actif__c
            FROM Order 
            WHERE Id IN :orderIds]);
    }

    public void execute(Database.BatchableContext bc, List<Order> scope) {
        Map<Id, Magasin__c> magasins = new Map<Id, Magasin__c>([
            SELECT Id, API_Key__c
            FROM Magasin__c 
            WHERE Id = :Pluck.ids(Order.Magasin_actif__c, scope)]);

        for (Order order : scope) {
            Magasin__c magasin = magasins.get(order.Magasin_actif__c);
            if (magasin == null) {
                order.Void_Response__c = 
                    'Magasin was not found [Order ID: ' + order.Id + ', Magasin ID: ' + order.Magasin_actif__c + ']'; 
            } else {
                try {
                    MP_VoidResponse vRes = MP_Callout.void(order, magasin);
                    order.Void_Response__c = vRes.body;
                    order.Void_Uuid__c = vRes.uuid;
                    order.Void_Status__c = (vRes.success) ? CANCELLED_SUCCESS : CANCELLED_ERROR;
                } catch (Exception e) {
                    order.Void_Response__c = e.getMessage();
                }
            }
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc) {}
}