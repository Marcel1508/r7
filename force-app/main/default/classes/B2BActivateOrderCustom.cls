/**
*
* Promocash order activate for the checkout flow
* Main difference with standard is that this takes an order id as input, as opposed to a cart id
*
*/
public without sharing class B2BActivateOrderCustom {
    public without sharing class RequestWrapper {
        @InvocableVariable(required=true)
        public Id cartId;

        @InvocableVariable(required=true)
        public Id inStockOrderId;

    }

    private static final String EN_ATTENTE_DE_PREPARATION = Constants.EN_ATTENTE_DE_PREPARATION;

    @InvocableMethod(label='Activate order for Promocash' description='Activate the order' category='Promocash')
    public static void activateOrder(List<RequestWrapper> request) {
       Order inStockOrder = [SELECT Id, Tech_Creneau_Salesforce__c, AccountId, OrderNumber FROM Order WHERE Id = :request[0].inStockOrderId];
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        Creneau_client__c creneau = new Creneau_Client__c();
        creneau.Creneau_Salesforce__c = inStockOrder.Tech_Creneau_Salesforce__c;
        creneau.Compte_client__c = inStockOrder.AccountId;
        creneau.Reserve_par__c = currentUser.ContactId;
        creneau.Commande__c = inStockOrder.Id;
        insert creneau;
    
        inStockOrder.Status = EN_ATTENTE_DE_PREPARATION;
        inStockOrder.Creneau_client__c = creneau.Id;
        update inStockOrder;

        if (!Test.isRunningTest()) { ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = inStockOrder.Id;
            osir.orderLifeCycleType = 'UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        }
     }
}