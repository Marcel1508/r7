({
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

    getCheckoutSummary : function(component) {
        var action = component.get("c.getCheckoutSummary");
        action.setParams({ 
            inStockOrderId: component.get("v.inStockOrderId"),
            outOfStockOrderId: component.get("v.outStockOrderId"),
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
			if (state === "SUCCESS") {
                component.set('v.summary', response.getReturnValue());
                console.log(component.get('v.summary'));
            } else {
                let errors = response.getError();
                console.error('error', errors);
                this.showToast('ERROR', errors[0].message, 'Error', null);
            }
        });
        $A.enqueueAction(action);
    }
})