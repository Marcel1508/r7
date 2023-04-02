/**
* @author       jan.straka@bluewolf
* @date         2021-05-03
* @description  Controller for CancelOrderQA aura component
**/
public with sharing class CancelOrderQAController {
    private static final String DRAFT_ORDER = 'Draft order';
    private static final String EN_ATTENTE_DE_PREPARATION = Constants.EN_ATTENTE_DE_PREPARATION;
    private static final String EN_COURS_DE_PREPARATION = Constants.EN_COURS_DE_PREPARATION;
    private static final String ANNULEE = Constants.ANNULEE;
    @TestVisible
    private static final String EXCEPTION_MESSAGE = Label.EXCEPTION_MESSAGE;
    private static Set<String> allowedStatuses = new Set<String>{DRAFT_ORDER, EN_ATTENTE_DE_PREPARATION, EN_COURS_DE_PREPARATION};

    @AuraEnabled
    public static void checkStatus(Id orderId) {
        try {
            Order order = [SELECT Id, Status FROM Order WHERE Id = :orderId];

            if (!allowedStatuses.contains(order.Status)) {
                throw Utilities.newAuraHandledException(EXCEPTION_MESSAGE);
            }
        } catch (exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void cancelOrder(Id orderId) {
        try {
            Order orderToUpdate = new Order(
                Id = orderId,
                Status = ANNULEE
            );
            update orderToUpdate;
        } catch (exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
}