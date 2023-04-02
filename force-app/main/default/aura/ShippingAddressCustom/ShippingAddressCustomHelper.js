({
    getAddresses: function (component, event, helper) {
        let action = component.get("c.getContactPointAddress");
        action.setParams({
            cartId: component.get("v.cartId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if (result.isSuccess && result.message == "SUCCESS") {
                    var wrappper = JSON.parse(result.response);
                    console.log('$$$$ wrappper = ' + JSON.stringify(wrappper));
                    component.set('v.WrapperData', wrappper);
                    if (component.get('v.selectedAddressId') == null) {
                        component.set('v.selectedAddressId', wrappper.contactPointAddresses[0].value);
                      //  component.set('v.selectedAddressId2', wrappper.contactPointAddresses[0].value);
                      
                        console.log('$$$ bb 11 bbb = '+ component.get('v.selectedAddressId') ); 
                    }

                } else {
                    this.showToast(component, event, "error", "error", result.message);
                }
            } else if (state === "ERROR") {
                this.showToast(component, event, "error", "error", "Something went wrong!!");

            } else {
                this.showToast(component, event, "error", "error", "Something went wrong!!");
            }


            var compEvent = component.getEvent("sampleComponentEvent");
            compEvent.setParams({
                "adresseLivraisonId" : component.get("v.selectedAddressId") 
            });
            compEvent.fire();

           // console.log('$$$ bb 11 ccccc = '+ component.get('v.selectedAddressId') ); 
    
           
          //  console.log('$$$ bb 11 eeeee = '+ component.get('v.selectedAddressId') ); 

        });
        $A.enqueueAction(action);
    },
    showToast: function (component, event, titleValue, typeValue, messageValue) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: titleValue,
            message: messageValue,
            duration: " 5000",
            key: "info_alt",
            type: typeValue,
            mode: "dismissible"
        });
        toastEvent.fire();
    }
})