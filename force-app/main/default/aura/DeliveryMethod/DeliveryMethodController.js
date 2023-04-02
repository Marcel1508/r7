({
    init : function(component, event, helper) {
        helper.getDeliveryMethods(component);
    },

    handleRadioClick : function(component, event, helper) {
        helper.selectDeliveryMethod(component, event);
    },

    handleCheckboxClick : function(component, event, helper) {
        helper.registerToBeCalledBackPreference(component);
    },
    
    handleComponentEvent : function(component, event, helper) {
        helper.test(component,event);
    }

})