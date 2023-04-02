({
    getMarketPayUrl : function(component) {
        var action = component.get("c.preauthorize");
        action.setParams({ orderId: component.get("v.orderId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                if (returnValue.success) {
                    component.set('v.marketPayUrl', returnValue.redirectUrl);
                    component.set('v.errorCode', '');
                    component.set('v.errorMessage', '');
                } else {
                    console.error('callout === ', returnValue);
                    component.set('v.errorCode', returnValue.errorCode);
                    component.set('v.errorMessage', returnValue.errorMessage);
                    this.showToast('ERROR', returnValue.errorCode + ': ' + returnValue.errorMessage, 'Error', null);
                }
            } else {
                let errors = response.getError();
                console.error('error', errors);
                component.set('v.errorCode', 'UNKNOWN');
                component.set('v.errorMessage', errors[0].message);
                this.showToast('ERROR', errors[0].message, 'Error', null);
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