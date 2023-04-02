import { LightningElement } from 'lwc';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class TestDynamicButtonAdd extends LightningElement {

    renderedCallback(){
        let linput = document.createElement('input');
        if (showDebug) { console.log ('sfdghdgsqe');}
            document.querySelectorAll('b2b_buyer_cart-add-to-cart-button').forEach(element => {
                element.innerHTML = "ddd"; //Contains HTML elements
                element.appendChild(linput)
            });
            if (showDebug) { console.log (document.querySelectorAll('b2b_buyer_cart-add-to-cart-button'));}
            
            if (showDebug) { console.log ('sfdghdgsqe after');}

   }

}