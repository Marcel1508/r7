/**
* @author       jan.straka@bluewolf
* @date         2021-04-14
* @description  Apex Controller for OrderSummaryRecordBanner
**/
public with sharing class OrderSummaryButtonsController {
	@testVisible private static OrderSummary orderSummaryMock;
    @testVisible private static List<OrderItem> orderItemsMock;
    
    private static final String EN_ATTENTE_DE_PREPARATION = Constants.EN_ATTENTE_DE_PREPARATION;
    private static final String EN_COURS_DE_PREPARATION = Constants.EN_COURS_DE_PREPARATION;
    private static final String DRAFT_ORDER = Label.DRAFT_ORDER;
    private static final String ANNULEE = Constants.ANNULEE;
    private static final String CARD_BANCAIRE = 'Carte Bancaire'; //todo: this value will be changed
    
    private static final String CANCELBUTTON_LABEL = 'Cancel Order';
    private static final String CANCELBUTTON_ERRORTITLE = 'Cannot cancel the order - please ask support for help.';
    private static final String CANCELBUTTON_SUCCESS = 'Order cancelled';

    private static final String ADJUSTBUTTON_LABEL = 'Adjust Order';
    private static final String ADJUSTBUTTON_ERRORTITLE = 'Cannot adjust the order - please ask support for help.';
    private static final String ADJUSTBUTTON_SUCCESS = 'Items are placed back to cart';

    private static final String AGAINBUTTON_LABEL = 'Order Again';
    private static final String AGAINBUTTON_ERRORTITLE = 'Cannot order again - please ask support for help.';
    private static final String AGAINBUTTON_SUCCESS = 'Items are placed again';
    

    public class ButtonWrapper {
        @AuraEnabled public PropertyWrapper cancelButton;
        @AuraEnabled public PropertyWrapper adjustButton;
        @AuraEnabled public PropertyWrapper againButton;
    }

    public class PropertyWrapper {
        @AuraEnabled public Boolean disabled;
        @AuraEnabled public String title;
        @AuraEnabled public String label;
        @AuraEnabled public String success;

        public PropertyWrapper(Boolean disabled, String title, String label, String success) {
            this.disabled = disabled;
            this.title = (disabled) ? title : '';
            this.label = label;
            this.success = success;
        } 
    }
    
    @AuraEnabled
    public static ButtonWrapper disableButtons(Id summaryId) {
        try {
            OrderSummary summary = (!Test.isRunningTest())? [SELECT OriginalOrder.Status, OriginalOrder.Moyen_de_Paiement__c FROM OrderSummary WHERE Id = :summaryId]: orderSummaryMock;

            String orderStatus = summary.OriginalOrder.Status;
            String orderPaymentType = summary.OriginalOrder.Moyen_de_Paiement__c;

            ButtonWrapper returnWrapper = new ButtonWrapper();
            returnWrapper.cancelButton = new PropertyWrapper(
                !(orderStatus == DRAFT_ORDER || orderStatus == EN_ATTENTE_DE_PREPARATION),
                CANCELBUTTON_ERRORTITLE,
                CANCELBUTTON_LABEL,
                CANCELBUTTON_SUCCESS);
            returnWrapper.adjustButton = new PropertyWrapper(
                !(orderStatus == DRAFT_ORDER || orderStatus == EN_ATTENTE_DE_PREPARATION), 
                ADJUSTBUTTON_ERRORTITLE,
                ADJUSTBUTTON_LABEL,
                ADJUSTBUTTON_SUCCESS);
            returnWrapper.againButton = new PropertyWrapper(
                false, 
                AGAINBUTTON_ERRORTITLE,
                AGAINBUTTON_LABEL,
                AGAINBUTTON_SUCCESS);

            return returnWrapper;
        } catch (exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void cancelOrder(Id summaryId) {
        try {
            OrderSummary summary = (!Test.isRunningTest())? [SELECT OriginalOrderId FROM OrderSummary WHERE Id = :summaryId]: orderSummaryMock;
            Order orderToUpdate = new Order(
                Id = summary.OriginalOrderId,
                Status = ANNULEE
            );
            update orderToUpdate;
        } catch (exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void orderAgain(Id summaryId) {
        try {
            Id webstoreId;
            if (!Test.isRunningTest()) {
                webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
            }

            OrderSummary summary = (!Test.isRunningTest())? [SELECT OriginalOrderId, OriginalOrder.AccountId, OriginalOrder.Account.Name FROM OrderSummary WHERE Id = :summaryId]: orderSummaryMock;
            List<OrderItem> orderItems = (!Test.isRunningTest())? [SELECT Id, Product2Id, Quantity FROM OrderItem WHERE OrderId = :summary.OriginalOrderId]: orderItemsMock;

            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for (OrderItem oi : orderItems) {
                ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
                cartInput.productId = oi.Product2Id;
                cartInput.quantity = String.valueOf(oi.Quantity);
                cartInput.type = ConnectApi.CartItemType.PRODUCT;
                batchInputs.add(new ConnectApi.BatchInput(cartInput));
            }
            
            ConnectApi.CommerceCart.addItemsToCart(webstoreId, summary.OriginalOrder.AccountId, 'active', batchInputs);

            
        } catch (exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void adjustOrder(Id summaryId) {
        try {
            Id webstoreId;
            if (!Test.isRunningTest()) {
                webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
            }

            OrderSummary summary = (!Test.isRunningTest())? [SELECT OriginalOrderId, OriginalOrder.AccountId, OriginalOrder.Account.Name FROM OrderSummary WHERE Id = :summaryId]: orderSummaryMock;
            List<OrderItem> orderItems = (!Test.isRunningTest())? [SELECT Id, Product2Id, Quantity FROM OrderItem WHERE OrderId = :summary.OriginalOrderId]: orderItemsMock;

            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for (OrderItem oi : orderItems) {
                ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
                cartInput.productId = oi.Product2Id;
                cartInput.quantity = String.valueOf(oi.Quantity);
                cartInput.type = ConnectApi.CartItemType.PRODUCT;
                batchInputs.add(new ConnectApi.BatchInput(cartInput));
            }
            
            ConnectApi.CommerceCart.addItemsToCart(webstoreId, summary.OriginalOrder.AccountId, 'active', batchInputs);

            Order orderToUpdate = new Order(
                Id = summary.OriginalOrderId,
                Status = ANNULEE
            );
            update orderToUpdate;
        } catch (exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
}