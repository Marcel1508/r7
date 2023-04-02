/**
 * @author       jan.straka@bluewolf, aymen.mtir@ibm, Suliman Abdel
 * @date         2021-01-22
 * @description  Service class for Order object
 **/
public without sharing class OrderService {
    private static final String LIVRAISON = Constants.LIVRAISON;
    private static final String ANNULEE = Constants.ANNULEE;
    private static final String TERMINEE = Constants.TERMINEE;

    /**
     * @author       aymen.mtir@ibm
     * @date         2020-11-01
     * @description  mark the first Order on account and order
     **/
    public void markFirstOrder(List<Order> orders) {
        List<Account> accountsToUpdate = new List<Account>();
        List<Order> ordersToUpdate = new List<Order>();

        Map<Id, Order> accountOrderMap = new Map<Id, Order>();
        for (Order o : orders) {
            accountOrderMap.put(o.AccountId, o);
        }
        List<Account> parentAccounts = [
            SELECT
                Id,
                Name,
                FirstOrder__c,
                (
                    SELECT Id, Name, Status, FirstOrderAccount__c
                    FROM Orders
                )
            FROM Account
            WHERE Id IN :accountOrderMap.keySet()
        ];

        for (Account parentAcc : parentAccounts) {
            if (parentAcc.Orders.size() == 1) {
                // && parentAcc.FirstOrder__c == null
                parentAcc.FirstOrder__c = accountOrderMap.get(parentAcc.Id).Id;
                accountOrderMap.get(parentAcc.Id).FirstOrderAccount__c = parentAcc.Id;

                ordersToUpdate.add(accountOrderMap.get(parentAcc.Id));
                accountsToUpdate.add(parentAcc);
            } else if (parentAcc.Orders.size() > 1) {
                parentAcc.FirstOrder__c = null;
                for (Order o : parentAcc.Orders) {
                    o.FirstOrderAccount__c = null;
                    ordersToUpdate.add(o);
                }
                //accountOrderMap.get(parentAcc.Id).FirstOrderAccount__c = null;
                accountsToUpdate.add(parentAcc);
            }
        }
        //update accountOrderMap.values();
        update ordersToUpdate;
        update accountsToUpdate;
    }

    /**
     * @author       jan.straka@bluewolf
     * @date         2021-01-22
     * @description  remove delivery authorization from frais if account's magasin doesn't allow it for new accounts
     **/
    public void removeAccountDeliveryAuthorizations(List<Order> orders) {
        List<Account> accounts = [
            SELECT Id, Magasin_actif_en_cours__c
            FROM Account
            WHERE
                Id IN :Pluck.ids(Order.AccountId, orders)
                AND FirstOrder__c = NULL
                AND Magasin_actif_en_cours__r.Autoriser_livraison_aux_nouveaux_clients__c = FALSE
        ];

        List<Frais__c> frais = [
            SELECT Id, Mode_de_livraison__c
            FROM Frais__c
            WHERE
                Account__c IN :Pluck.ids(accounts)
                AND Magasin_Associe__c IN :Pluck.ids(Account.Magasin_actif_en_cours__c, accounts)
        ];

        List<Frais__c> fraisToUpdate = new List<Frais__c>();
        for (Frais__c f : frais) {
            if (f.Mode_de_livraison__c != null) {
                List<String> modes = f.Mode_de_livraison__c.split(';');
                if (modes.contains(LIVRAISON)) {
                    modes.remove(modes.indexOf(LIVRAISON));
                }
                f.Mode_de_livraison__c = String.join(modes, ';');
                fraisToUpdate.add(f);
            }
        }

        update fraisToUpdate;
    }

    /**
     * @author       jan.straka@bluewolf
     * @date         2021-03-31
     * @description  do a Market Pay void callout in case the Order is cancelled
     **/
    public void voidCancelledOrders(List<Order> newRecords, Map<Id, Order> oldRecords) {
        Set<Id> cancelledOrderIds = new Set<Id>();

        for (Order newRecord : newRecords) {
            Order oldRecord = oldRecords.get(newRecord.Id);
            if (newRecord.Status != oldRecord.Status && newRecord.Status == ANNULEE && newRecord.Preauthorize_Uuid__c != null) {
                cancelledOrderIds.add(newRecord.Id);
            }
        }

        if (!cancelledOrderIds.isEmpty()) {
            Id batchInstanceId = Database.executeBatch(new MP_VoidCalloutBatch(cancelledOrderIds), 10);
        }
    }

    /**
     * @author       jan.straka@bluewolf
     * @date         2021-04-19
     * @description  do a Market Pay capture callout in case the Order is terminated
     **/
    public void captureTerminatedOrders(List<Order> newRecords, Map<Id, Order> oldRecords) {
        Set<Id> terminatedOrderIds = new Set<Id>();

        for (Order newRecord : newRecords) {
            Order oldRecord = oldRecords.get(newRecord.Id);
            if (newRecord.Status != oldRecord.Status && newRecord.Status == TERMINEE && newRecord.Preauthorize_Uuid__c != null) {
                terminatedOrderIds.add(newRecord.Id);
            }
        }

        if (!terminatedOrderIds.isEmpty()) {
            Id batchInstanceId = Database.executeBatch(new MP_CaptureCalloutBatch(terminatedOrderIds), 1);
        }
    }

    /**
     * @author       Suliman Abdel
     * @date         12/05/2021
     * @description  In before creation of Order, fill Numero_de_commande__c field by concatenation of Code_etablissement & Ordernumber
     **/
    public void fillNumeroDeCommand(List<Order> orders) {
        List<Order> ordersToUpdate = new List<Order>();
        for (Order newRecord : orders) {
            if (newRecord.Code_Etablissement__c != null && newRecord.OrderNumber != null) {
                String orderNum = newRecord.Code_Etablissement__c + '_' + newRecord.OrderNumber;
                newRecord.Numero_de_commande__c = orderNum;
                ordersToUpdate.add(newRecord);
            }
        }
        update ordersToUpdate;
    }

    public List<Order> getOrders(Set<Id> orderIds) {
        List<Order> orders = [
            SELECT Id, Name, Status, AccountId, FirstOrderAccount__c, OrderNumber, Code_Etablissement__c, Numero_de_commande__c
            FROM Order
            WHERE id = :orderIds
        ];
        return orders;
    }
}