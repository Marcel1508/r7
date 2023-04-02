({
    checkStatus : function(component) {
        let action = component.get("c.checkStatus");
        action.setParams({ orderId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            } else {
                let errors = response.getError();
                console.error('error', errors);
                this.showToast('ERROR', errors[0].message, 'Error', null);
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);
    },
    
    cancelOrder : function(component) {
        let action = component.get("c.cancelOrder");
        action.setParams({ orderId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('Succès', 'La commande est annulée', 'Success', null);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                let errors = response.getError();
                console.error('error', errors);
                this.showToast('Erreur', errors[0].message, 'Error', null);
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function(title, message, type, mode) {
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
    }
})