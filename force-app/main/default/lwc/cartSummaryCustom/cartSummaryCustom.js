import { api, LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/B2BCartControllerCustom.getCartSummary';
import getCartSummaryPromo from '@salesforce/apex/B2BCartControllerCustom.getCartSummaryPromo';
import getAllTaxes from '@salesforce/apex/CustomLookupController.returnAllTaxes';
import hasVignetteAlcool from '@salesforce/apex/B2BCartControllerCustom.hasVignetteAlcool';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";


import { registerListener, unregisterAllListeners } from 'c/pubsubCustom';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtilsCustom';
import { getVignetteAlcool } from 'c/productDetailsDisplayCustom';
//import { get } from 'https';

const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class CartSummaryCustom extends LightningElement {
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


    @track taxes = [];
    @track hasVignetteAlcool ;
    @track tvataxwithvignette;
    @track taxeswithoutvignette = [];
    @track montantEcotaxe;
    @track hasMontantEcotaxe = false;
    @track taxeswithoutvignetteToDisplay = [];
    @track taxesToDisplay = [];
    @track ecotaxeArray = [];

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
                this.refreshCartItems,
                this
            );
    }

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     * We want to start listening for the 'cartitemsupdated'
     *
     * NOTE:
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     */
    connectedCallback() {
        /*registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );*/
        // Initialize 'cartsummary' as soon as the component is inserted in the DOM  by
        // calling getCartSummary imperatively.
        this.getUpdatedCartSummary();
        this.getTaxes();
        this.hasVignette();
      
    }

    renderedCallback(){
       // this.getTaxes();
       // this.hasVignette();
          
    }

    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    /**
     * The labels used in the template.
     * To support localization, these should be stored as custom labels.
     *
     * To import labels in an LWC use the @salesforce/label scoped module.
     * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
     *
     * @type {Object}
     * @private
     * @readonly
     */
    get labels() {
        return {
            cartSummaryHeader: 'Récapitulatif de commande',
            totalInStock:'Articles disponibles',
            totalOutOfStock:'Articles indisponibles',
            totalHT: 'Total HT',
            total: 'Total TTC'
        };
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
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

        return {
            grandTotal: this.cartContent && this.cartContent.cartItemCollection.cartSummary.grandTotalAmount,
            originalPrice: this.cartContent && this.cartContent.cartItemCollection.cartSummary.totalListPrice,
            totalHT: this.cartContent && this.cartContent.cartItemCollection.cartSummary.totalProductAmount,
            productAmountInStock: this.cartContent && this.cartContent.productAmountInStock,
            productQuantityInStock: this.cartContent && this.cartContent.productQuantityInStock,
            productAmountOutOfStock: this.cartContent && this.cartContent.productAmountOutOfStock,
            montantVignetteCotisation: this.vignetteAlcoolCotisation()
        };
    }

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {String}
     */
    get currencyCode() {

        return (this.cartContent && this.cartContent.cartItemCollection.cartSummary.currencyIsoCode) || 'USD';
    }

    /**
     * Representation for Cart Summary
     *
     * @type {object}
     * @readonly
     * @private
     */
    cartContent;

    /**
     * Get cart summary from the server via imperative apex call
     */
    getUpdatedCartSummary() {
        getCartSummaryPromo({
            communityId: communityId,
            activeCartOrId: this.recordId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
               this.cartContent = result;
               this.cartContent.promoCartItems.forEach(function(cartItem){
                const cItem = { ...cartItem };
                cItem.totalPrice = cItem.cartItemResult.cartItem.totalPrice;
                return cItem;
            });
         
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                if (showDebug) { console.log(e); }
            });
    }

    refreshCartItems() {
        console.log('---refreshCartItems');
        this.getUpdatedCartSummary();
        this.getTaxes();
    }

    hasVignette() {
        hasVignetteAlcool({
            cId: this.recordId
        })
        .then((result) => {
            this.hasVignetteAlcool = result;    
        })
        .catch((e) => {
            // Handle cart summary error properly
            // For this sample, we can just log the error
            if (showDebug) { console.log(e); }
        });
    }

   

    /**
     * Get cart summary from the server via imperative apex call
     */
    getTaxes() {
        getAllTaxes({
            cartId: this.recordId
        })
        .then((result) => {
            console.log('tax result ==== ' + JSON.stringify(result));
            this.taxes = result;
           
            this.ecotaxeArray = this.taxes.filter(function(elem){
                return elem.startsWith('Ecotaxe');
            });
          
            if(this.ecotaxeArray.length > 0) {
                this.montantEcotaxe = this.taxes[1].replace('Ecotaxe :', ''); 
                if(this.montantEcotaxe > 0) {
                    this.hasMontantEcotaxe = true;
                } 
            } else {
                this.montantEcotaxe = 0;
                this.hasMontantEcotaxe = false;
            }
            
            if(this.hasVignetteAlcool){
                this.tvataxwithvignette = this.taxes[0].replace('TVA','TVA*');
              
                for (var i = 1, len = this.taxes.length; i < len; ++i) {
                    this.taxeswithoutvignette[i-1]= this.taxes[i];
                }
                //taxeswithoutvignette to display without ecotaxe
                if(this.hasMontantEcotaxe){ 
                    this.taxeswithoutvignetteToDisplay =  this.taxeswithoutvignette.filter(function(elem){
                        return !elem.startsWith('Ecotaxe');
                    });
                }else {
                    this.taxeswithoutvignetteToDisplay = this.taxeswithoutvignette;
                }
                if (showDebug) { console.log('this taxeswithoutvignetteToDisplay ' + this.taxeswithoutvignetteToDisplay); } 
            }
            //taxes to display without ecotaxe
            if(this.hasMontantEcotaxe){ 
                this.taxesToDisplay =  this.taxes.filter(function(elem){
                    return !elem.startsWith('Ecotaxe');
                });
            }else {
                this.taxesToDisplay =  this.taxes;
            }

            if (showDebug) { console.log('this.taxes ' + this.taxes); }
            if (showDebug) { console.log('this taxesToDisplay ' + this.taxesToDisplay); }         
            if (showDebug) { console.log('this montantEcotaxe ' + this.montantEcotaxe); } 
            if (showDebug) { console.log('this.cartid ' + this.recordId); }

        })
        .catch((e) => {
            // Handle cart summary error properly
            // For this sample, we can just log the error
            if (showDebug) { console.error('error == '+e); }
        });
    }
      

    get hasTaxes(){
        return this.taxes !== undefined;
    }

    // get taxesNotNull(){
    //     return this.taxes !== null;
    // }
    /**
     * Should the original price be shown
     * @returns {boolean} true, if we want to show the original (strikethrough) price
     * @private
     */
    get showOriginal() {
        if (showDebug) {console.log('EDEC showOriginal: '); }

        return displayOriginalPrice(
            true,
            true,
            this.prices.finalPrice,
            this.prices.originalPrice
        );
    }

    /**
     * Gets the dynamically generated aria label for the original price element
     * @returns {string} aria label for original price
     * @private
     */
    get ariaLabelForOriginalPrice() {

        if (showDebug) { console.log('EDEC ariaLabelForOriginalPrice: ');  }

        return getLabelForOriginalPrice(
            this.currencyCode,
            this.prices.originalPrice
        );
    }

    get vignetteAlcoolCotisation(){
        return getVignetteAlcool();
    }
}