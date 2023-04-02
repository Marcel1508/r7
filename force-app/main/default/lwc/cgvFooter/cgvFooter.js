import { LightningElement } from 'lwc';

export default class CgvFooter extends LightningElement {
    currentYear;
    connectedCallback() {
        var aujd = new Date();
        this.currentYear = aujd.getFullYear();
    }
}