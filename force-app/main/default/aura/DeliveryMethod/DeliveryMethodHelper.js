({
    getDeliveryMethods : function(component) {
        let action = component.get("c.getDeliveryMethodsForCheckoutFlow");
        let cartId = component.get("v.cartId");
        let orderId = component.get("v.orderId");
        action.setParams({ cartId: cartId,
                          orderId: orderId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                let indicateurFEF = returnValue[0].indicateurFEF;
                if(indicateurFEF == "O" && returnValue[0].montantFEF >0)
                {for (let i = 0; i < returnValue.length; i++) 
                	{
                     let shippingFeeWithoutFE = returnValue[i].shippingFee - returnValue[0].montantFEF;
                     returnValue[i].shippingFeeWithoutFEF = shippingFeeWithoutFE.toFixed(2);
                	}
                }
                else
                {for (let i = 0; i < returnValue.length; i++) 
                	{
                     let shippingFeeWithoutFE = returnValue[i].shippingFee;
                     returnValue[i].shippingFeeWithoutFEF = shippingFeeWithoutFE;
                	}
                }    
                component.set('v.deliveryMethodOptions', returnValue);
                console.log(returnValue);
                this.setMethod(component, 0);
                
            } else {
                let errors = response.getError();
                console.error('error', errors);
                this.showToast('Erreur', errors[0].message, 'Error', null);
            }
        });

        $A.enqueueAction(action);
    },

    selectDeliveryMethod : function(component, event) {
        this.setMethod(component, event.getSource().get('v.value'));

        let livr = event.getSource().get('v.label');
      
        if(livr == 'Livraison') {
            component.set('v.displayAdresseLivraison', true);
        }else {
            component.set('v.displayAdresseLivraison', false);
          
        }
    },

    setMethod : function(component, index) {
        let methods = component.get('v.deliveryMethodOptions');
        component.set('v.deliveryMethodValue', methods[index].methodId);
        component.set('v.deliveryMethodLabel', methods[index].methodName);
        component.set('v.deliveryMethodFee', methods[index].shippingFee);
        methods.forEach(method => method.selected = false);
        methods[index].selected = true;
        component.set('v.deliveryMethodOptions', methods);
    },

    test :  function(component, event) {
        var valueFromChild = event.getParam("adresseLivraisonId");
        component.set("v.selectedAddressIdValue", valueFromChild);
    },

    registerToBeCalledBackPreference: function(component) {
        let action = component.get("c.registerToBeCalledBackPreference");
        let cartId = component.get("v.cartId");
        let toBeCalledBack = component.get("v.toBeCalledBack");
        action.setParams({ 
            cartId: cartId,
            toBeCalledBack: toBeCalledBack 
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var toastEvent = $A.get("e.force:showToast");
    			 toastEvent.setParams({
        		 	"title": "Succès",
                    "type" : "success",
        			"message": response.getReturnValue()
    			});
    			toastEvent.fire();
                //this.showToast('SUCCESS', response.getReturnValue(), 'Success', null);
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