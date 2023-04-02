import { api,track, LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/B2BCartControllerCustom.getCartSummary';
import getDel from '@salesforce/apex/DeliveryMethodController.getDeliveryMethods';

import { registerListener, unregisterAllListeners } from 'c/pubsubCustom';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtilsCustom';

const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class ShippingModeSelection extends LightningElement {
    /**
     * An event fired when the cart items change.
     * This event is a short term resolution to update any sibling component that may want to update their state based
     * on updates in the cart items.
     *
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     *
     * @event CartContents#cartitemsupdated
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * The pricing information for the cart summary's total.
     *
     * @typedef {Object} Prices
     *
     * @property {String} [originalPrice]
     *  The  list price aka "strikethrough" price (i.e. MSRP) of the cart.
     *  If the value is null, undefined, or empty, the list price will not be displayed.
     *
     * @property {String} finalPrice
     *   The final price of the cart.
     */

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    deliveryMethods;
    errorFetchingMethods = false;
    errorFetchingMethodsMessage = '';

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    wiredPageRef(pageRef){
        this.pageRef = pageRef;
        if(this.pageRef)         
            registerListener(
                CART_ITEMS_UPDATED_EVT,
                this.getUpdatedCartSummary,
                this
                );
    }

    // @wire(getDel, { cartId: '$recordId' })
    // deliveryMethods;

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     * We want to start listening for the 'cartitemsupdated'
     *
     * NOTE:
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     */
    connectedCallback() {
        console.log('connectedCallback');
        console.log(this.recordId);
        getDel({
            cartId: this.recordId
        })
            .then((result) => {
                console.log('resultresult');
                console.log(result);
                this.deliveryMethods = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log('Error fetching delivery methods');
                console.log(e);
                console.log(e.body.message);
                this.errorFetchingMethods = true;
                this.errorFetchingMethodsMessage = 'La récupération des frais a échoué. Veuillez contacter votre administrateur Salesforce.';
            });

        registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );
        // Initialize 'cartsummary' as soon as the component is inserted in the DOM  by
        // calling getCartSummary imperatively.
        this.getUpdatedCartSummary();
    }

    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

        /**
     * The pricing information to be displayed in the summary
     * @type {Prices}
     */
    get prices() {
        console.log('prices1');
        return {
            originalPrice: this.cartSummary && this.cartSummary.totalListPrice,
            finalPrice: this.cartSummary && this.cartSummary.totalProductAmount
        };
    }

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {String}
     */
    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    /**
     * Representation for Cart Summary
     *
     * @type {object}
     * @readonly
     * @private
     */
    cartSummary;

    /**
     * Get cart summary from the server via imperative apex call
     */
    getUpdatedCartSummary() {
        console.log('get new summary');
        getCartSummary({
            communityId: communityId,
            activeCartOrId: this.recordId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((cartSummary) => {
                this.cartSummary = cartSummary;
                console.log('this.cartSummary');
                console.log(this.cartSummary);
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    get hasRetrievedDeliveryMethods(){
        return this.deliveryMethods !== undefined;
    }

    get hasDeliveryMethods(){
        return this.deliveryMethods.length > 0;
    }

}