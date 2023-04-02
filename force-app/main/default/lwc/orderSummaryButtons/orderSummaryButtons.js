import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import apex_disableButtons from '@salesforce/apex/OrderSummaryButtonsController.disableButtons';
import apex_orderAgain from '@salesforce/apex/OrderSummaryButtonsController.orderAgain';
import apex_cancelOrder from '@salesforce/apex/OrderSummaryButtonsController.cancelOrder';
import apex_adjustOrder from '@salesforce/apex/OrderSummaryButtonsController.adjustOrder';

const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class OrderSummaryButtons extends LightningElement {

    cancelOrderButton = {};
    adjustOrderButton = {};
    againOrderButton = {};
    @api recordId;

    connectedCallback() {
        this.disableButtons();
    }

    onCancelOrderClick() {
        this.cancelOrder();
    }

    onAgainOrderClick() {
        this.orderAgain();
    }

    onAdjustOrderClick() {
        this.adjustOrder();
    }

    disableButtons() {
        let cmp = this;
        apex_disableButtons({ summaryId: this.recordId })
        .then (result => {
            cmp.cancelOrderButton = result.cancelButton;
            cmp.adjustOrderButton = result.adjustButton;
            cmp.againOrderButton = result.againButton;
        })
        .catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            }));
        })
    }
    
    
    orderAgain() {
        let cmp = this;
        apex_orderAgain({ summaryId: this.recordId })
        .then (result => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Succès',
                message: cmp.againOrderButton.success,
                variant: 'success',
            }));
            cmp.disableButtons();
            cmp.handleCartUpdate();
        })
        .catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erreur',
                message: error.body.message,
                variant: 'error',
            }));
        })
    }
    
    cancelOrder() {
        let cmp = this;
        apex_cancelOrder({ summaryId: this.recordId })
        .then (result => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Succès',
                message: cmp.cancelOrderButton.success,
                variant: 'success',
            }));
            cmp.disableButtons();
        })
        .catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erreur',
                message: error.body.message,
                variant: 'error',
            }));
        })
    }
    
    adjustOrder() {
        let cmp = this;
        apex_adjustOrder({ summaryId: this.recordId })
        .then (result => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Succès',
                message: cmp.adjustOrderButton.success,
                variant: 'success',
            }));
            cmp.disableButtons();
            cmp.handleCartUpdate();
        })
        .catch(error => {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erreur',
                message: error.body.message,
                variant: 'error',
            }));
        })
    }
    
    handleCartUpdate() {
        // Update Cart Badge
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
        // Notify any other listeners that the cart items have updated
        // fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
    }


}