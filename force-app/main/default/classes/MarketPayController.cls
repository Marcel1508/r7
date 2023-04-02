/**
* @author       jan.straka@bluewolf
* @date         2020-02-03
* @description  MarketPay component controller
**/
public with sharing class MarketPayController {

    @TestVisible
    private static final String PREAUTHORIZED_AWAITING_CALLBACK = 'Preauthorized - Awaiting Callback';
    @TestVisible 
    private static final String PREAUTHORIZED_ERROR = 'Preauthorized - Error';

    @AuraEnabled
    public static MP_PreauthorizeResponse preauthorize(String orderId) {
        try {
            if (orderId == null) {
                throw Utilities.newAuraHandledException('In-stock order Id is not defined');
            }

            Order order = [
                SELECT Id, OrderNumber, GrandTotalAmount, CurrencyIsoCode, Description, Account.Name, BillingAddress, ShippingAddress, Magasin_actif__c, 
                Magasin_actif__r.Id,  Magasin_actif__r.Pourcentage_additionel_carte__c, Magasin_actif__r.API_Key__c
                FROM Order
                WHERE Id = :orderId];

            if (order.Magasin_actif__r.Id == null) {
                throw Utilities.newAuraHandledException('Magasin was not found [Order ID: ' + order.Id + ', Magasin ID: ' + order.Magasin_actif__c + ']');
            }
            
            Magasin__c magasin = new Magasin__c(id=order.Magasin_actif__r.Id,Pourcentage_additionel_carte__c = order.Magasin_actif__r.Pourcentage_additionel_carte__c,API_Key__c= order.Magasin_actif__r.API_Key__c );

            User currentUser = [SELECT Id, ContactId, LanguageLocaleKey,
                                Contact.Id, Contact.FirstName, Contact.LastName, Contact.Birthdate, Contact.Salutation, Contact.Email, Contact.Phone, 
                                Contact.Telephone_portable__c, Contact.MobilePhone, Contact.AssistantPhone, Contact.HomePhone, Contact.OtherPhone
                                FROM User WHERE Id = :UserInfo.getUserId()];

            if (currentUser.Contact.Id == null) {
                throw Utilities.newAuraHandledException('Contact was not found [Order ID: ' + order.Id + ', Contact Id: ' + currentUser.ContactId + ']');
            }
            
            Contact contact = new Contact(id=currentUser.Contact.Id,FirstName = currentUser.Contact.FirstName, LastName = currentUser.Contact.LastName, Birthdate = currentUser.Contact.Birthdate, Salutation = currentUser.Contact.Salutation, Email = currentUser.Contact.Email,Phone=currentUser.Contact.Phone, 
                                Telephone_portable__c = currentUser.Contact.Telephone_portable__c, MobilePhone = currentUser.Contact.MobilePhone, AssistantPhone = currentUser.Contact.AssistantPhone, HomePhone = currentUser.Contact.HomePhone, OtherPhone = currentUser.Contact.OtherPhone );

            MP_PreauthorizeResponse pRes = MP_Callout.preauthorize(order, contact, currentUser, magasin);
            order.Preauthorize_Response__c = pRes.body;
            order.Preauthorize_Uuid__c = pRes.uuid;
            order.Preauthorize_Status__c = (pRes.success) ? PREAUTHORIZED_AWAITING_CALLBACK : PREAUTHORIZED_ERROR;
            update order;

            return pRes;
        } catch (Exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
}