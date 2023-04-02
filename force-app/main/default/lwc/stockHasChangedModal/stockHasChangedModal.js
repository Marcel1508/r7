import { LightningElement, api, wire,track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StockHasChangedModal extends LightningElement {
    @api showModal = false;
    @api changedItems=[];
    @api currencyCode='EUR';

    onClose(event) {
        this.dispatchEvent(new CustomEvent('closestockmodal'));
    }
}