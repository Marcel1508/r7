/**
* @author       jan.straka@bluewolf
* @date         2021-01-08
* @description  Controller for PaymentMethod aura component
**/
public with sharing class PaymentMethodController {
    @TestVisible
    private static final String ERROR_ACCOUNT_FEES_NOT_FOUND = System.Label.PaymentMethod_AccountAuthorisationsNotFound;
    @TestVisible
    private static final String ERROR_BILLING_ADDRESSES_NOT_FOUND = System.Label.PaymentMethod_BillingAddressesNotFound;
    @TestVisible
    private static final String ERROR_METHODS_NOT_FOUND = System.Label.PaymentMethod_MethodsNotFound;

    public class BillingAddressWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
    }

    public class PaymentMethodWrapper {
        @AuraEnabled public String onlinePayment;
        @AuraEnabled public String paymentType;
        @AuraEnabled public String label;

        public PaymentMethodWrapper(Payment_Method__mdt paymentMethod) {
            this.onlinePayment = paymentMethod.Commande_Payee__c;
            this.paymentType = paymentMethod.Moyen_de_Paiement__c;
            this.label = paymentMethod.Label;
        }
    }
    @TestVisible
    private static ConnectApi.CartSummary cartSummary;

    @AuraEnabled
    public static List<BillingAddressWrapper> getBillingAddresses(String cartId) {
        try {
            WebCart cart = [SELECT Id, AccountId FROM WebCart WHERE Id = :cartId];
            List<ContactPointAddress> billingAddresses = [
                SELECT Id, City, Street, Country, PostalCode 
                FROM ContactPointAddress 
                WHERE ParentId = :cart.AccountId 
                AND AddressType = 'Billing'];
            if (!billingAddresses.isEmpty()) {
                List<BillingAddressWrapper> wBillingAddresses = new List<BillingAddressWrapper>();
                for (ContactPointAddress billingAddress : billingAddresses) {
                    BillingAddressWrapper wBillingAddress = new BillingAddressWrapper();
                    wBillingAddress.value = billingAddress.Id;
                    wBillingAddress.label = 
                        billingAddress.Street + ', ' + 
                        billingAddress.City + ' ' + 
                        billingAddress.PostalCode + ' ' + 
                        billingAddress.Country;
                    wBillingAddresses.add(wBillingAddress);
                }
                return wBillingAddresses;
            } else {
                throw Utilities.newAuraHandledException(ERROR_BILLING_ADDRESSES_NOT_FOUND);
            }
        } catch (Exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PaymentMethodWrapper> getPaymentMethods(String cartId) {
        try {
            if (!Test.isRunningTest()) {
                Id webStoreId = [SELECT WebStoreId, NetworkId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
                cartSummary = ConnectApi.CommerceCart.getCartSummary(webstoreId, null, cartId);
            }
            
            Account account = [SELECT Id, Frais_autorisations__c,(SELECT Id, echeance__c FROM Frais__r) FROM Account WHERE Id = :cartSummary.accountId];
            if(account.Frais__r.isEmpty() || account.Frais__r == null )
            {
                throw Utilities.newAuraHandledException(ERROR_ACCOUNT_FEES_NOT_FOUND);
            }
            Frais__c accountAuthorisations = account.Frais__r[0];

            List<PaymentMethodWrapper> methods = new List<PaymentMethodWrapper>();
            for (Payment_Method__mdt paymentMethod : [SELECT Id, Label, Moyen_de_Paiement__c, Commande_Payee__c FROM Payment_Method__mdt ORDER BY Label]) {
                if (accountAuthorisations.echeance__c != null || paymentMethod.Commande_Payee__c == 'O') {
                    methods.add(new PaymentMethodWrapper(paymentMethod));
                }
            }

            if (!methods.isEmpty()) {
                return methods;
            } else {
                throw Utilities.newAuraHandledException(ERROR_METHODS_NOT_FOUND);
            }
        } catch (Exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
}