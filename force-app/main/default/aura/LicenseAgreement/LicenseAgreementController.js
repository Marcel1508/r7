({
    init: function(component) {
        var action = component.get("c.getLicenseAgreement");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.myVal', response.getReturnValue());
            } else {
                console.log('Error: ', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})