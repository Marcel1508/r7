import { LightningElement,track } from 'lwc';
import blockedCartInfo from '@salesforce/label/c.Cart_Info_Message';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";


export default class UnblockCart extends LightningElement {
    cartMessage = blockedCartInfo;
	@track label_1;
	@track label_2;
    connectedCallback() {
        if(this.cartMessage){
			const labels = this.cartMessage.split("-");
			if (showDebug) { console.log ('Test---'+JSON.stringify(labels));}
			this.label_1 = labels[0];
			this.label_2 = labels[1];
		}
    }
}