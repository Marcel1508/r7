import { LightningElement, track, api } from 'lwc';
import executeCancelCartAsyncAction from '@salesforce/apex/B2BCartControllerCustom.executeCancelCartAsyncAction';

import labelLockedCartMessage from '@salesforce/label/c.B2B_Cart_locked_message';
import labelCancelCheckout from '@salesforce/label/c.B2B_Cart_cancel_checkout';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";


const CART_UNLOCK_EVENT = 'cartunlockevent';

export default class cartCancelCheckoutBannerCustom extends LightningElement {
    @track contacts;
    @track error;

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    @api
    cartId;    


    get labels() {
        return {
            labelLockedCartMessage,
            labelCancelCheckout,
        };
    }

    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    cancelCartCheckout() {
        executeCancelCartAsyncAction({cartId: this.cartId})
            .then(result => {
                if (showDebug) { console.log ('SUCCESS'); }
                const cartId = this.cartId;
                this.dispatchEvent(
                    new CustomEvent(CART_UNLOCK_EVENT, {
                        bubbles: true,
                        composed: true,
                        cancelable: false,
                        detail: {
                            cartId
                        }
                    })
                );

            })
            .catch(error => {
                this.error = error;
                if (showDebug) { console.log ('ERROR '+error); }
            });
    }
}