({
    init : function(component, event, helper) {
        helper.getPaymentMethods(component);
        helper.getBillingAddresses(component);
    },

    handleRadioClick : function(component, event, helper) {
        helper.selectDeliveryMethod(component, event);
    },

    onChange : function(component, event, helper) {
        component.set("v.contactPointAddressId", component.find('select').get('v.value'));
    }
})