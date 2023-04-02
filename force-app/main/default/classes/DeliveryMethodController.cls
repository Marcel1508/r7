/**
 * @author       jan.straka@bluewolf, Suliman.Abdelgadeir@ibm
 * @date         2020-12-13
 * @description  Controller for DeliveryMethod aura component
 **/
public with sharing class DeliveryMethodController {
    @TestVisible
    private static final String PREF_UPDATE_SUCCESS = System.Label.DeliveryMethod_ToBeCalledBack_registered;
    @TestVisible
    private static final String ERROR_WE_SHOULD_HAVE_ONLY_ONE_ORDER_DELIVERY_GROUP = System.Label.DeliveryMethod_ShouldHaveOnlyODG;
    @TestVisible
    private static final String ERROR_METHODS_NOT_FOUND = System.Label.DeliveryMethod_MethodsNotFound;
    @TestVisible
    private static final String ERROR_ACCOUNT_FEES_NOT_FOUND = System.Label.DeliveryMethod_AccountFeesNotFound;
    @TestVisible
    private static final String ERROR_MAGASIN_FEES_NOT_FOUND = System.Label.DeliveryMethod_MagasinFeesNotFound;
    @TestVisible
    private static Set<String> fraisFields {
        get {
            if (fraisFields == null) {
                fraisFields = new Set<String>();
                fraisFields.addAll(Pluck.strings(OrderDeliveryMethod.Minimum_Account__c, deliveryMethods));
            }
            return fraisFields;
        }
        set;
    }
    @TestVisible
    private static Set<String> magasinFields {
        get {
            if (magasinFields == null) {
                magasinFields = new Set<String>();
                magasinFields.addAll(Pluck.strings(OrderDeliveryMethod.Minimum_Magasin__c, deliveryMethods));
            }
            return magasinFields;
        }
        set;
    }
    @TestVisible
    private static List<OrderDeliveryMethod> deliveryMethods {
        get {
            if (deliveryMethods == null) {
                deliveryMethods = [
                    SELECT Id, Name, Minimum_Account__c, Minimum_Magasin__c
                    FROM OrderDeliveryMethod
                    WHERE IsActive = TRUE
                    ORDER BY Name
                ];
            }
            return deliveryMethods;
        }
        set;
    }
    @TestVisible
    private static ConnectApi.CartSummary cartSummary;

    public class DeliveryMethodWrapper {
        @AuraEnabled
        public String methodId;
        @AuraEnabled
        public String methodName;
        @AuraEnabled
        public Decimal shippingFee;
        @AuraEnabled
        public Decimal shippingFeeWithoutFEF;
        @AuraEnabled
        public Decimal minimum;
        @AuraEnabled
        public String currencyCode;
        @AuraEnabled
        public String indicateurFEF;
        @AuraEnabled
        public Decimal montantFEF;

        public DeliveryMethodWrapper(
            String methodId,
            String methodName,
            Decimal shippingFee,
            Decimal minimum,
            String currencyCode,
            String indicateurFEF,
            Decimal montantFEF
        ) {
            this.methodId = methodId;
            this.methodName = methodName;
            this.shippingFee = shippingFee;
            this.minimum = minimum;
            this.currencyCode = currencyCode;
            this.indicateurFEF = indicateurFEF;
            this.montantFEF = montantFEF;
            this.shippingFeeWithoutFEF = 0;
        }

        public DeliveryMethodWrapper(String methodId, String methodName, Decimal minimum, String currencyCode) {
            this.methodId = methodId;
            this.methodName = methodName;
            this.minimum = minimum;
            this.currencyCode = currencyCode;
        }
    }

    private static OrderDeliveryGroup getOrderDeliveryGroup(Id orderId) {
        List<OrderDeliveryGroup> orderDeliveryGroups = [
            SELECT Drive_Deporte_Fees_Tech__c, Drive_Fees_Tech__c, Livraison_Fees_Tech__c
            FROM orderDeliveryGroup
            WHERE OrderId = :orderId
        ];
        if (orderDeliveryGroups.size() != 1) {
            throw Utilities.newAuraHandledException(ERROR_WE_SHOULD_HAVE_ONLY_ONE_ORDER_DELIVERY_GROUP);
        }
        return orderDeliveryGroups[0];
    }

    private static Account getAccountMagasinAndFrais(Id accountId) {
        List<String> magasinFields1 = new List<String>();
        List<String> fraisFields1 = new List<String>();
        for (String magasinField : magasinFields) {
            magasinField = 'Magasin_actif_en_cours__r.' + magasinField;
            magasinFields1.add(magasinField);
        }

        for (String fraisField : fraisFields) {
            fraisField = 'Frais_autorisations__r.' + fraisField;
            fraisFields1.add(fraisField);
        }

        String accountQueryString =
            'SELECT ' +
            String.join(new List<String>(magasinFields1), ', ') +
            ', ' +
            String.join(new List<String>(fraisFields1), ', ') +
            ', ' +
            'Magasin_actif_en_cours__r.Id, ' +
            'Magasin_actif_en_cours__c, ' +
            'Magasin_actif_en_cours__r.CurrencyIsoCode, ' +
            'Magasin_actif_en_cours__r.Montant_FEF__c, ' +
            'Frais_autorisations__r.CurrencyIsoCode, ' +
            'Frais_autorisations__c, ' +
            'Frais_autorisations__r.Id, ' +
            'Frais_autorisations__r.Magasin_Associe__c, ' +
            'Frais_autorisations__r.Indicateur_FEF__c, ' +
            'Frais_autorisations__r.Mode_de_livraison__c ' +
            'FROM Account ' +
            'WHERE Id = :accountId';
        List<Account> accounts = Database.query(String.escapeSingleQuotes(accountQueryString));

        account acc = accounts[0];

        if (acc.Magasin_actif_en_cours__r.Id == null) {
            throw Utilities.newAuraHandledException(ERROR_MAGASIN_FEES_NOT_FOUND);
        }

        if (acc.Frais_autorisations__r.Id == null) {
            throw Utilities.newAuraHandledException(ERROR_ACCOUNT_FEES_NOT_FOUND);
        }

        return acc;
    }

    private static List<DeliveryMethodWrapper> getDeliveryForAll(String cartId, String orderId) {
        List<DeliveryMethodWrapper> methods = new List<DeliveryMethodWrapper>();
        if (!Test.isRunningTest()) {
            Id webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
            cartSummary = ConnectApi.CommerceCart.getCartSummary(webstoreId, null, cartId);
        }
        Account account = getAccountMagasinAndFrais(cartSummary.accountId);
        OrderDeliveryGroup orderDeliveryGroup = orderId != null ? getOrderDeliveryGroup(orderId) : null;

        Map<String, Decimal> feesMap = orderId != null
            ? new Map<String, Decimal>{
                  Constants.LIVRAISON => orderDeliveryGroup.Livraison_Fees_Tech__c,
                  Constants.DRIVE => orderDeliveryGroup.Drive_Fees_Tech__c,
                  Constants.DRIVE_DEPORTE => orderDeliveryGroup.Drive_Deporte_Fees_Tech__c
              }
            : null;
        List<String> selections = account.Frais_autorisations__r.Mode_de_livraison__c != null
            ? account.Frais_autorisations__r.Mode_de_livraison__c.split(';')
            : new List<String>();

        for (OrderDeliveryMethod deliveryMethod : deliveryMethods) {
            if (selections.contains(deliveryMethod.Name)) {
                Decimal minimum;
                Decimal fees;
                Decimal montantFEF;
                String indicateurFEF;
                String currencyCode;
                if (account.Frais_autorisations__r.get(deliveryMethod.Minimum_Account__c) == null) {
                    minimum = (Decimal) account.Magasin_actif_en_cours__r.get(deliveryMethod.Minimum_Magasin__c);
                } else {
                    minimum = (Decimal) account.Frais_autorisations__r.get(deliveryMethod.Minimum_Account__c);
                }

                fees = (Orderid != null) ? (Decimal) feesMap.get(deliveryMethod.Name).setScale(2) : null;
                currencyCode = account.Frais_autorisations__r.CurrencyIsoCode;
                indicateurFEF = account.Frais_autorisations__r.Indicateur_FEF__c;
                montantFEF = account.Magasin_actif_en_cours__r.Montant_FEF__c;
                methods.add(
                    new DeliveryMethodWrapper(
                        deliveryMethod.Id,
                        deliveryMethod.Name,
                        fees,
                        minimum,
                        currencyCode,
                        indicateurFEF,
                        montantFEF
                    )
                );
            }
        }

        if (!methods.isEmpty()) {
            return methods;
        } else {
            return null;
        }
    }

    //CreatedBy Suliman, To include new solution of Fees (Frais)

    @AuraEnabled
    public static List<DeliveryMethodWrapper> getDeliveryMethods(String cartId, String orderId) {
        List<DeliveryMethodWrapper> methods = getDeliveryForAll(cartId, orderId);
        if (methods != null) {
            return methods;
        } else {
            throw Utilities.newAuraHandledException(ERROR_METHODS_NOT_FOUND);
        }
    }

    @AuraEnabled
    public static List<DeliveryMethodWrapper> getDeliveryMethodsForCheckoutFlow(String cartId, String orderId) {
        List<DeliveryMethodWrapper> methods = getDeliveryForAll(cartId, orderId);
        List<DeliveryMethodWrapper> methodsToReturn = new List<DeliveryMethodWrapper>();
        if (methods != null) {
            for (DeliveryMethodWrapper method : methods) {
                if (
                    Decimal.valueOf(cartSummary.totalProductAmount) >= method.minimum ||
                    Decimal.valueOf(cartSummary.totalProductAmount) == 0
                ) {
                    methodsToReturn.add(
                        new DeliveryMethodWrapper(
                            method.methodId,
                            method.methodName,
                            method.shippingFee,
                            method.minimum,
                            method.currencyCode,
                            method.indicateurFEF,
                            method.montantFEF
                        )
                    );
                }
            }
        }

        if (!methodsToReturn.isEmpty()) {
            return methodsToReturn;
        } else {
            throw Utilities.newAuraHandledException(ERROR_METHODS_NOT_FOUND);
        }
    }

    @AuraEnabled
    public static String registerToBeCalledBackPreference(String cartId, Boolean toBeCalledBack) {
        try {
            WebCart cart = new WebCart(Id = cartId, To_Be_Called_Back__c = toBeCalledBack);
            update cart;
            return PREF_UPDATE_SUCCESS;
        } catch (Exception e) {
            throw Utilities.newAuraHandledException(e.getMessage());
        }
    }
}