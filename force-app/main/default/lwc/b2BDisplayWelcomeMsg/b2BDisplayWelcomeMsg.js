import { LightningElement } from 'lwc';
import getAccountDataInfos from "@salesforce/apex/B2BGetInfoCustom.getAccountDataInfos";
import { track, wire, api } from "lwc";

export default class B2BDisplayWelcomeMsg extends LightningElement {
    @api effectiveAccountId;
    @track acctName = '';

    connectedCallback() {
        if(this.effectiveAccountId == '000000000000000' || this.effectiveAccountId == undefined) {
            this.acctName = '';
        } else {
            getAccountDataInfos({
                effectiveAccountId: this.effectiveAccountId
            })
            .then(res => {
                console.log('B2BDisplayWelcomeMsg res: ', res);
                this.acctName = 'Bonjour, '+res[0].Name;
            })
            .catch(err => {
                this.acctName = '';
                console.log('B2BDisplayWelcomeMsg err: ', err);
            })
        } 
    }
}