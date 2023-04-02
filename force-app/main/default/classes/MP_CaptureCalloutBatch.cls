/**
* @author       jan.straka@bluewolf
* @date         2021-04-19
* @description  Batch apex for MarketPay capture API callout
**/
public with sharing class MP_CaptureCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private final Set<Id> orderIds;
    private final static String CAPTURED_SUCCESS = 'Captured - Success';
    private final static String CAPTURED_ERROR = 'Captured - Error';
    private final static String CANCELLED_SUCCESS = 'Cancelled - Success';
    private final static String CANCELLED_ERROR = 'Cancelled - Error';
    private final static String DELTA_VOID_SUCCESS = 'Delta Void - Success';
    private final static String DELTA_VOID_ERROR = 'Delta Void - Error';
    
    public MP_CaptureCalloutBatch(Set<Id> orderIds) {
        this.orderIds = orderIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Preauthorize_Uuid__c, CurrencyIsoCode, OrderNumber, GrandTotalAmount, Magasin_actif__c
            FROM Order 
            WHERE Id IN :this.orderIds]);
    }

    public void execute(Database.BatchableContext bc, List<Order> scope) {

        Map<Id, Magasin__c> magasins = new Map<Id, Magasin__c>([
            SELECT Id, Pourcentage_additionel_carte__c, API_Key__c FROM Magasin__c WHERE Id = :Pluck.ids(Order.Magasin_actif__c, scope)]);
        
        Map<Id, List<Facture__c>> facturesByOrderId = new Map<Id, List<Facture__c>>();
        for (Facture__c f : [SELECT  Id, Commande__c, Montant_TTC_de_la_facture__c FROM Facture__c WHERE Commande__c IN :scope]) {
            List<Facture__c> factures = facturesByOrderId.get(f.Commande__c);
            if (factures == null) {
                factures = new List<Facture__c>();
            }
            factures.add(f);
            facturesByOrderId.put(f.Commande__c, factures);
        }
    
        for (Order order : scope) {
            Magasin__c magasin = magasins.get(order.Magasin_actif__c);
            List<Facture__c> factures = facturesByOrderId.get(order.Id);

            if (magasin == null) {
                order.Capture_Response_Attempt_1__c = 
                    'Magasin was not found [Order ID: ' + order.Id + ', Magasin ID: ' + order.Magasin_actif__c + ']';
            } else if (factures == null || factures.size() != 1) {
                Integer facturesCnt = factures == null ? 0 : factures.size();
                order.Capture_Response_Attempt_1__c = 
                    'Invalid count of related Facture records.' + '\n' +
                    'Expected: 1, Actual: ' + facturesCnt + '\n' + 
                    'Factures: ' + factures;
            } else {
                try {
                    MP_CaptureResponse cRes = MP_Callout.capture(order, magasin, factures[0], 1);
                    order.Capture_Response_Attempt_1__c = cRes.body;
                    order.Capture_Uuid_Attempt_1__c = cRes.uuid;

                    if (!cRes.success) {
                        try {
                            cRes = MP_Callout.capture(order, magasin, factures[0], 2);
                            order.Capture_Response_Attempt_2__c = cRes.body;
                            order.Capture_Uuid_Attempt_2__c = cRes.uuid;

                            if (!cRes.success) {
                                try {
                                    cRes = MP_Callout.capture(order, magasin, factures[0], 3);
                                    order.Capture_Response_Attempt_3__c = cRes.body;
                                    order.Capture_Uuid_Attempt_3__c = cRes.uuid;
                                } catch (Exception e) {
                                    order.Capture_Response_Attempt_3__c = e.getMessage();
                                }
                            }
                        } catch (Exception e) {
                            order.Capture_Response_Attempt_2__c = e.getMessage();
                        }
                    }

                    order.Capture_Status__c = (cRes.success) ? CAPTURED_SUCCESS : CAPTURED_ERROR;
                    if (cRes.success && factures[0].Montant_TTC_de_la_facture__c < order.GrandTotalAmount * (1 + magasin.Pourcentage_additionel_carte__c / 100)) {
                        try {
                            MP_VoidResponse vRes = MP_Callout.void(order, magasin);
                            order.Delta_Void_Response__c = vRes.body;
                            order.Delta_Void_Uuid__c = vRes.uuid;
                            order.Delta_Void_Status__c = (vRes.success) ? DELTA_VOID_SUCCESS : DELTA_VOID_ERROR;
                        } catch (Exception e) {
                            order.Delta_Void_Response__c = e.getMessage();
                        }
                    }
                } catch (Exception e) {
                    order.Capture_Response_Attempt_1__c = e.getMessage();
                }
            }
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc) {
    }
}