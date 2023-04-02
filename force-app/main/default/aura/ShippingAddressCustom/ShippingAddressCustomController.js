({
    doInit: function (component, event, helper) {
        helper.getAddresses(component, event, helper);
    },

    handleChange: function (component, event, helper) {

        var changeValue = event.getParam("value");
        component.set('v.selectedAddressId', changeValue);
      
        var compEvent = component.getEvent("sampleComponentEvent");
        compEvent.setParams({
            "adresseLivraisonId" : component.get("v.selectedAddressId") 
        });

        compEvent.fire();
    },
  
})