({
    getPaymentMethods : function(component) {
        var action = component.get("c.getPaymentMethods");
        let cartId = component.get("v.cartId");
        action.setParams({ cartId: cartId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                component.set('v.paymentMethodOptions', returnValue);
                this.setMethod(component, 0);
            } else {
                let errors = response.getError();
                console.error('error === ', errors);
                this.showToast('ERROR1', errors[0].message, 'Error', null);
            }
        });
        $A.enqueueAction(action);
    },

    selectDeliveryMethod : function(component, event) {
        this.setMethod(component, event.getSource().get('v.value'));
    },

    setMethod : function(component, index) {
        let methods = component.get('v.paymentMethodOptions');
        component.set('v.selectedPaymentType', methods[index].paymentType);
        component.set('v.selectedOnlinePayment', methods[index].onlinePayment);
        methods.forEach(method => method.selected = false);
        methods[index].selected = true;
        component.set('v.paymentMethodOptions', methods);
    },

    getBillingAddresses : function(component) {
        var action = component.get("c.getBillingAddresses");
        let cartId = component.get("v.cartId");
        action.setParams({ cartId: cartId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                component.set('v.billingAddresses', returnValue);
                component.set('v.contactPointAddressId', returnValue[0].value);
            } else {
                let errors = response.getError();
                console.error('error ===>', errors);
                this.showToast('ERROR2', errors[0].message, 'Error', null);
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        if (!$A.util.isEmpty(toastEvent)) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type || "other",
                "mode": mode || "dismissible"
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    },
})