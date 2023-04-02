import { LightningElement, api, track } from 'lwc';

export default class SelfRegSiretExistsNotKeyAccountComponent extends LightningElement {
    errorPage = false;
    @track selectedStep = "Step1";
    @api account;
    @api street;
    @api city;
    @api state;
    @api country;
    @api postalCode;

    connectedCallback() {

    }





    get isSelectStep1() {
        return this.selectedStep === "Step1";
    }
}