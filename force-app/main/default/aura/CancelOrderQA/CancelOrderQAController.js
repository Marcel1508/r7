({

    onInit : function(component, event, helper) {
        helper.checkStatus(component);
    },

    onYesClick : function(component, event, helper) {
        helper.cancelOrder(component);
    },

    onNoClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})