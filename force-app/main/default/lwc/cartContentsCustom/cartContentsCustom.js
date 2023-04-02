import { api, wire, track, LightningElement } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import updateCartItem from '@salesforce/apex/B2BCartControllerCustom.updateCartItem';
import deleteCartItem from '@salesforce/apex/B2BCartControllerCustom.deleteCartItem';
import deleteCart from '@salesforce/apex/B2BCartControllerCustom.deleteCart';
import createCart from '@salesforce/apex/B2BCartControllerCustom.createCart';
import { resolve } from 'c/cmsResourceResolverCustom';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsubCustom';
import executeCancelCartAsyncAction from '@salesforce/apex/B2BCartControllerCustom.executeCancelCartAsyncAction';
import deleteDraftOrder from '@salesforce/apex/B2BCartControllerCustom.deleteOrder';

import { isCartClosed } from 'c/cartUtilsCustom';

// custom Promocash call to get cart items details
import getCartItemsPromo from '@salesforce/apex/B2BCartControllerCustom.getCartItemsPromo';

// custom Promocash call to save cart items split state
import updateSplitQuantities from '@salesforce/apex/B2BCartControllerCustom.updateSplitQuantities';
import getCartItemExtraInfos from '@salesforce/apex/B2BCartControllerCustom.getCartItemExtraInfos';
import getCartItems from '@salesforce/apex/B2bCommerceApiService.getCartItems';

// labels
import loadingCartItems from '@salesforce/label/c.B2B_Cart_Items_Articles_disponibles';
import clearCartButton from '@salesforce/label/c.B2B_Cart_Clear_cart';
import sortBy from '@salesforce/label/c.B2B_Cart_Sort_by';
import cartHeader from '@salesforce/label/c.B2B_Cart_Header';
import emptyCartHeaderLabel from '@salesforce/label/c.B2B_Cart_empty_cart_header';
import emptyCartBodyLabel from '@salesforce/label/c.B2B_Cart_empty_cart_body';
import closedCartLabel from '@salesforce/label/c.B2B_Cart_closed_cart';
import CreatedDateDesc from '@salesforce/label/c.B2B_Cart_sort_create_date_desc';
import CreatedDateAsc from '@salesforce/label/c.B2B_Cart_sort_create_date_asc';
import NameAsc from '@salesforce/label/c.B2B_Cart_sort_name_asc';
import NameDesc from '@salesforce/label/c.B2B_Cart_sort_name_desc';
import inStockItemsSection from '@salesforce/label/c.B2B_Cart_Items_Articles_disponibles';
import outOfStockItemsSection from '@salesforce/label/c.B2B_Cart_Items_Articles_indisponibles';

import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
//import STATUS_FIELD from '@salesforce/schema/WebCart.Status';

const CART_STATUS_FIELDS = [
    'WebCart.Status'
];


// Event name constants
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

// Locked Cart Status
const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout']);

/**
 * A sample cart contents component.
 * This component shows the contents of a buyer's cart on a cart detail page.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Sample Cart Contents Component'
 *
 * @fires CartContents#cartchanged
 * @fires CartContents#cartitemsupdated
 */

export default class CartContents extends NavigationMixin(LightningElement) {
    @track communityId = communityId;
    /**
     * An event fired when the cart changes.
     * This event is a short term resolution to update the cart badge based on updates to the cart.
     *
     * @event CartContents#cartchanged
     *
     * @type {CustomEvent}
     *
     * @export
     */

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
     * A cart line item.
     *
     * @typedef {Object} CartItem
     *
     * @property {ProductDetails} productDetails
     *   Representation of the product details.
     *
     * @property {number} quantity
     *   The quantity of the cart item.
     *
     * @property {string} originalPrice
     *   The original price of a cart item.
     *
     * @property {string} salesPrice
     *   The sales price of a cart item.
     *
     * @property {string} totalPrice
     *   The total sales price of a cart item, without tax (if any).
     *
     * @property {string} totalListPrice
     *   The total original (list) price of a cart item.
     *
     * @property {string} inStock
     *   EDEC: the inStock boolean
     *
     * @property {Promotion} promo
     *   EDEC: the inStock boolean
     *
     * @property {ProductImage} promo
     *   EDEC: the inStock boolean
     *
     * @property {Tax} tva
     *   the tva rate
     * @property {Tax} ecotax
     *   the ecotax rate
     * @property {Tax} consigne
     *   the consigne rate
     * @property {Tax} vignette
     *   the vignette rate
     */

         /**
     * Details for a product containing product information
     *
     * @typedef {Object} Promotion
     *
     * @property {string} key
     *
     * @property {date} Date_de_debut_de_promotion__c
     *
     * @property {date} Date_de_fin_de_promotion__c
     *
     * @property {string} Id
     *
     * @property {string} Libelle_periode_de_promotion__c
     *
     * @property {string} Produit__r.Libelle_du_conditionnement_vente__c
     *
     * @property {boolean} Mecanique_Promotion_TECH__c
     *
     * @property {string} Phrase_offre__c
     *
     * @property {number} Prix_de_vente_promotion__c
     *
     * @property {number} Prix_sous_mecanique__c
     *
     * @property {string} Produit__c
     *
     * @property {number} Quantite_minimum_de_commande__c
     *
     * @property {number} Quantite_offerte__c
     *
     * @property {number} Quantite_payee__c
     *
     * @property {number} Remise_en_e__c
     *
     * @property {number} Remise_en_p__c
     *
     * @property {string} Type_d_offre__c
     *
     * @property {string} Type_de_promotion__c
     *
     * //EDEC
     */

         /**
     * Details for a product containing product information
     *
     * @typedef {Object} Tax
     *
     * @property {string} key
     *
     * @property {number} Amount
     *
     * @property {string} CartId
     *
     * @property {string} CartItemId
     *
     * @property {string} Name
     *
     * @property {date} TaxCalculationDate
     *
     * @property {number} TaxRate
     *
     * @property {string} TaxType
     *
     * //EDEC
     */

      /**
     * Details for a product containing product information
     *
     * @typedef {Object} ProductImage
     *
     * @property {string} key
     *
     * @property {string} Id
     *
     * @property {string} Name
     *
     * @property {string} AlternativeText__c
     *
     * @property {string} Image_ExternalId__c
     *
     * @property {string} ProductId__c
     *
     * @property {string} Product_Image_URL__c
     *
     * @property {string} Product_URL_Vignette__c
     *
     * @property {string} Titre__c
     *
     * @property {number} Ordre_Affichage__c
     *
     * //EDEC
     */


    /**
     * Details for a product containing product information
     *
     * @typedef {Object} ProductDetails
     *
     * @property {string} productId
     *   The unique identifier of the item.
     *
     * @property {string} sku
     *  Product SKU number.
     *
     * @property {string} name
     *   The name of the item.
     *
     * @property {ThumbnailImage} thumbnailImage
     *   The quantity of the item.
     *
     * //EDEC
     * @property {string} family
     */

    /**
     * Image information for a product.
     *
     * @typedef {Object} ThumbnailImage
     *
     * @property {string} alternateText
     *  Alternate text for an image.
     *
     * @property {string} id
     *  The image's id.
     *
     * @property {string} title
     *   The title of the image.
     *
     * @property {string} url
     *   The url of the image.
     */

    /**
     * Representation of a sort option.
     *
     * @typedef {Object} SortOption
     *
     * @property {string} value
     * The value for the sort option.
     *
     * @property {string} label
     * The label for the sort option.
     */

     rayonSort = '';
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

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    // @wire(CurrentPageReference)
    // pageRef;
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
    /**
     * Total number of items in the cart
     * @private
     * @type {Number}
     */
    _cartItemCount = 0;

    /**
     * A list of cartItems.
     *
     * @type {CartItem[]}
     */
    cartItems;


    /*@wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD]})
    cartStatusRecord;*/

    //cartStatus="notdefined";
/*
    get cartStatus() {
        //if (showDebug) { console.log ('EDEC cartStatus cartStatusRecord: '+cartStatusRecord);
        //return this.cartStatusRecord.data.fields.Status.value;
        return "status";
    }
*/


    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        unregisterAllListeners(this);
    }



    /**
     * A list of sortoptions useful for displaying sort menu
     *
     * @type {SortOption[]}
     */
    sortOptions = [
        { value: 'CreatedDateDesc', label: this.labels.CreatedDateDesc },
        { value: 'CreatedDateAsc', label: this.labels.CreatedDateAsc },
        { value: 'NameAsc', label: this.labels.NameAsc },
        { value: 'NameDesc', label: this.labels.NameDesc },
        { value: 'RayonDesc', label: 'Rayon A à Z' },
        { value: 'RayonAsc', label: 'Rayon Z à A' }
    ];

    /**
     * Specifies the page token to be used to view a page of cart information.
     * If the pageParam is null, the first page is returned.
     * @type {null|string}
     */
    pageParam = null;

    /**
     * Sort order for items in a cart.
     * The default sortOrder is 'CreatedDateDesc'
     *    - CreatedDateAsc—Sorts by oldest creation date
     *    - CreatedDateDesc—Sorts by most recent creation date.
     *    - NameAsc—Sorts by name in ascending alphabetical order (A–Z).
     *    - NameDesc—Sorts by name in descending alphabetical order (Z–A).
     * @type {string}
     */
    sortParam = 'CreatedDateDesc';

    /**
     * Is the cart currently disabled.
     * This is useful to prevent any cart operation for certain cases -
     * For example when checkout is in progress.
     * @type {boolean}
     */
    isCartClosed = false;

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {string}
     */
    currencyCode;


    /**
     *
     * EDEC
     * @type {string}
     */
    cartDescription;


    @track isStockChangedModalOpen = false;
    @track changesSaved = false;

    @track promotions;
    @track taxes;
    @track offres;
    @track productimages;
    /**
     * A map of cartItems with quantities (split,available).
     *
     * @type {quantityObj[]}
     */
    quantitiesMap;


    /**
     * A list of cartItemIds as strings
     *
     * @type {String[]}
     */
    cartItemIds;

    /**
     * A list of changes in stock since cart modification
     *
     * @type {String[]}
     */
    @track changedItems=[];


    /**
     * Gets whether the cart item list is empty.
     *
     * @type {boolean}
     * @readonly
     */
    get isCartEmpty() {
        // If the items are an empty array (not undefined or null), we know we're empty.
        return Array.isArray(this.cartItems) && this.cartItems.length === 0;
    }

    /**
     * The labels used in the template.
     * To support localization, these should be stored as custom labels.
     *
     * To import labels in an LWC use the @salesforce/label scoped module.
     * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
     *
     *
     *
     * @type {Object}
     * @private
     * @readonly
     */
    get labels() {
        return {
            loadingCartItems,
            clearCartButton : 'Vider le panier',
            sortBy,
            cartHeader : 'Mon Panier',
            emptyCartHeaderLabel,
            emptyCartBodyLabel,
            closedCartLabel,
            CreatedDateDesc,
            CreatedDateAsc,
            NameAsc,
            NameDesc,
            inStockItemsSection,
            outOfStockItemsSection,
            addtolist:'Tout ajouter à la liste'
        };
    }

    /**
     * Gets the cart header along with the current number of cart items
     *
     * @type {string}
     * @readonly
     * @example
     * 'Cart (3)'
     */
    get cartHeader() {
        return `${this.labels.cartHeader} (${this._cartItemCount})`;
    }

    /**
     * Gets whether the item list state is indeterminate (e.g. in the process of being determined).
     *
     * @returns {boolean}
     * @readonly
     */
    get isCartItemListIndeterminate() {
        return !Array.isArray(this.cartItems);
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
    doInit = false;

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     */
    connectedCallback() {
        // Initialize 'cartItems' list as soon as the component is inserted in the DOM.
        this.updateCartItems();
        this.doInit = true;

        if(!this.changesSaved && this.cartItems?.length > 0){
            if (showDebug) { console.log ('===> rendered call back start'); }
            this.getPromotionAndTaxesInCartItems();
            this.markCartItemsQuantities();

            if (showDebug) { console.log ('===> rendered call back end'); }
        }
    }

    getPromotionAndTaxesInCartItems(){
        let cartItemsExtract = [];
        let cItems = this.cartItems;
        let cartItemsLocal = this.cartItems;
        let cartItemsT = [];

        if (showDebug) { console.log ('===> getPromotionAndTaxesInCartItems start'); }

        cItems.forEach(function(cartItem){
            if(cartItem.inStock || !cartItem.inStock){
                let cartItemextract = {
                    "cartItemId": cartItem.cartItemResult.cartItem.cartItemId,
                    "productId": cartItem.cartItemResult.cartItem.productId,
                };
                cartItemsExtract.push(cartItemextract);
                }
        });

        getCartItemExtraInfos({
            cartItemsExtract: cartItemsExtract,
            effectiveAccountId: this.resolvedEffectiveAccountId

           })
           .then((result) => {
            if (showDebug) { console.log ('===> getCartItemExtraInfos start'); }

            let allpromos = Object.keys(result[0]).map(key=> ({ key: key, ...result[0][key] }));
            let alltaxes = Object.keys(result[1]).map(key=> ({ key: key, ...result[1][key] }));
            let allopms = Object.keys(result[2]).map(key=> ({ key: key, ...result[2][key] }));
            let allProductsImages = Object.keys(result[3]).map(key=> ({ key: key, ...result[3][key] }));
            this.promotions = allpromos;
            this.taxes = alltaxes;
            this.offres = allopms;
            this.productimages= allProductsImages;
            if (showDebug) { console.log ('mmmmmm'+JSON.stringify(this.productsImages)); }
            cartItemsLocal.forEach(function(cartItem){
                const cItem = { ...cartItem };

                let promo = allpromos.find(item => item.Produit__c === cartItem.cartItemResult.cartItem.productId);
           //     let taxes = alltaxes.filter(item => item.CartItemId === cartItem.cartItemResult.cartItem.cartItemId);
                let opm = allopms.find(item => item.Produit__c === cartItem.cartItemResult.cartItem.productId);
                let productImages = allProductsImages.find(item => item.ProductId__c === cartItem.cartItemResult.cartItem.productId);
                let tva = alltaxes.find(item => item.key === cartItem.cartItemResult.cartItem.cartItemId + ',' + 'TVA');
                let ecotax = alltaxes.find(item => item.key === cartItem.cartItemResult.cartItem.cartItemId + ',' + 'Ecotaxe');
                let consigne = alltaxes.find(item => item.key === cartItem.cartItemResult.cartItem.cartItemId + ',' + 'Consigne');
                let vignette =  alltaxes.find(item => item.key === cartItem.cartItemResult.cartItem.cartItemId + ',' + 'Taxe Vignette Alcool');
                if (showDebug) { console.log ('yyyyyy'+JSON.stringify(productImages)); }
                if(promo !== undefined){
                    cItem.promo = promo;
                }

                if(tva !== undefined){
                    cItem.tva = tva;
                }
                if(ecotax !== undefined){
                    cItem.ecotax = ecotax;
                }
                if(consigne !== undefined){
                    cItem.consigne = consigne;
                }

                if(vignette !== undefined){
                    cItem.vignette = vignette;
                }

                if(opm !== undefined){
                    cItem.opm = opm;
                }

                if(productImages != undefined){
                    cItem.productImages = productImages;
                }

                cartItem = cItem;
                cartItemsT.push(cItem);
                return cItem;
            });

        }).then(() => {
            if (showDebug) { console.log ('getCartItemExtraInfos then'); }
            this.cartItems = cartItemsT;
        })
        .catch((error) => {
            if (showDebug) { console.log ('error'); }
            if (showDebug) { console.log (error); }
        });
    }

    markCartItemsQuantities() {

        if (showDebug) { console.log ('debut markCartItemsQuantities'); }
        this.quantitiesMap = [];
        let qM = [];
        let cItems = this.cartItems;

        try {
            cItems.forEach(function(cartItem){
                let quantityObj = {
                    "cartItemId": cartItem.cartItemResult.cartItem.cartItemId,
                    "productId": cartItem.cartItemResult.cartItem.productId,
                    "availablequantity": cartItem.availableQuantity,
                    "isSplit": cartItem.split,
                    "quantity": cartItem.quantity,
                    "productImageUrl": resolve(cartItem.cartItemResult.cartItem.productDetails.thumbnailImage.url),
                    "productImageAlternativeText": cartItem.cartItemResult.cartItem.productDetails.thumbnailImage.alternateText || ''
                };
                qM.push(quantityObj);
            });
        } catch(error) {
            if (showDebug) { console.log ('Catch error block');}
        }

        this.quantitiesMap = qM;

        // Call the 'getCartItems' apex method imperatively
        updateSplitQuantities({
            cartItemsInfo: this.quantitiesMap
        })
        .then((changedItemss) => {
            if (showDebug) { console.log ('updateSplitQuantities then');}

            changedItemss.forEach(function(changedItem){
                // Create a copy of the item that we can safely mutate.
                const cItem = { ...changedItem };
                cItem.productUrl = '';
                cItem.productImageURL = '';
                let cartItem = cItems.find(item => item.cartItemResult.cartItem.cartItemId === changedItem.cartItemId);
                // Get URL of the product image.
                cItem.productImageUrl = resolve(
                    cartItem.cartItemResult.cartItem.productDetails.thumbnailImage.url
                );
                // Set the alternative text of the image(if provided).
                // If not, set the null all text (alt='') for images.
                cItem.productImageAlternativeText = cartItem.cartItemResult.cartItem.productDetails.thumbnailImage.alternateText || '';
                // Get URL for the product, which is asynchronous and can only happen after the component is connected to the DOM (NavigationMixin dependency).
                changedItem = cItem;
                return cItem;
            });

            this.changedItems = changedItemss;

            if(this.changedItems.length > 0){
                this.openStockChangedModal();
            }

        })
        .catch((error) => {
            if (showDebug) { console.log ('error');}
            if (showDebug) { console.log (error);}
        });
        this.changesSaved = true;
        if (showDebug) { console.log ('heeeeeeeeeer');}
    }

    /**
     * Get a list of cart items from the server via imperative apex call
     */
    async updateCartItems() {
        try {
        // Call the 'getCartItems' apex method imperatively
            let result = await getCartItemsPromo({
                communityId: communityId,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                activeCartOrId: this.recordId,
                pageParam: this.pageParam,
                sortParam: this.sortParam
            });
            if(this.rayonSort === 'RayonDesc'){
                result.promoCartItems.sort((a, b) => (a.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c > b.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c) ? 1 : -1);
                this.cartItems = result.promoCartItems;
                if (showDebug) { console.log ('&&&&&&&&&'+ JSON.stringify(this.cartItems));}

            }
            else if(this.rayonSort === 'RayonAsc'){
                result.promoCartItems.sort((a, b) => (a.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c > b.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c) ? -1 : 1);
                this.cartItems = result.promoCartItems;
                if (showDebug) { console.log ('&&&&&&&&&'+ JSON.stringify(this.cartItems));}

            }else{
                this.cartItems = result.promoCartItems;
                if (showDebug) { console.log ('&&&&&&&&&'+ JSON.stringify(this.cartItems));}
                if (showDebug) { console.log ('2222222communityId'+ communityId);}
                if (showDebug) { console.log ('2222222effectiveAccountId'+ this.resolvedEffectiveAccountId);}
                if (showDebug) { console.log ('2222222activeCartOrId'+ this.recordId);}
                if (showDebug) { console.log ('2222222pageParam'+ this.pageParam);}
                if (showDebug) { console.log ('2222222sortParam'+ this.sortParam);}
            }
            this.splitCartItemsInGroups();

            // PROMO: split cartItems in two  distinct groups: inStock and outOfStock
            this._cartItemCount = Number(
                result.cartItemCollection.cartSummary.totalProductCount
            );
            this.currencyCode = result.cartItemCollection.cartSummary.currencyIsoCode;
            this.cartDescription = result.cartDescription;
            if(this.doInit){
                this.doInit = false;
                executeCancelCartAsyncAction({cartId: this.recordId}).then(result => {
                    if (showDebug) { console.log ('SUCCESS');}
                    const cartId = this.recordId;
                    if (showDebug) { console.log ('this.resolvedEffectiveAccountId'+this.resolvedEffectiveAccountId);}
                    deleteDraftOrder({accId: this.resolvedEffectiveAccountId}).then(result => {
                    this.dispatchEvent(
                        new CustomEvent('cartunlockevent', {
                            bubbles: true,
                            composed: true,
                            cancelable: false,
                            detail: {
                                cartId
                            }
                        })
                    );
                    });
                })
            }
            else{
                this.isCartDisabled = LOCKED_CART_STATUSES.has(
                    result.cartItemCollection.cartSummary.status
                );
            }
            if (showDebug) { console.log ('result.cartItemCollection.cartSummary.status===='+result.cartItemCollection.cartSummary.status);}
        }catch(error) {
            if (showDebug) { console.log ('EDEC got item promos errors ');}
            if (showDebug) { console.log (error);}
            const errorMessage = error.body.message;
            if(error.body.message.includes('No Cart Items were found')){
                this.cartItems = [];
            } else {
                this.cartItems = undefined;
            }
            this.isCartClosed = isCartClosed(errorMessage);
        }

    }

    /**
     * Handles a "click" event on the sort menu.
     *
     * @param {Event} event the click event
     * @private
     */
    handleChangeSortSelection(event) {
        if(event.target.value == 'RayonDesc'){
            this.inStockCartItems.sort((a, b) => (a.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c > b.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c) ? 1 : -1);
            this.outOfStockCartItems.sort((a, b) => (a.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c > b.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c) ? 1 : -1);
            this.sortParam = null;
            this.rayonSort = event.target.value;
        }
        else if(event.target.value == 'RayonAsc'){
            this.inStockCartItems.sort((a, b) => (a.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c > b.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c) ? -1 : 1);
            this.outOfStockCartItems.sort((a, b) => (a.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c > b.cartItemResult.cartItem.ProductDetails.Libelle_Rayon__c) ? -1 : 1);
            this.sortParam = null;
            this.rayonSort = event.target.value;
        }
        else{
            this.sortParam = event.target.value;
            this.rayonSort = '';

        }
        // After the sort order has changed, we get a refreshed list
        this.updateCartItems();
    }

    /**
     * Helper method to handle updates to cart contents by firing
     *  'cartchanged' - To update the cart badge
     *  'cartitemsupdated' - To notify any listeners for cart item updates (Eg. Cart Totals)
     *
     * As of the Winter 21 release, Lightning Message Service (LMS) is not available in B2B Commerce for Lightning.
     * These samples make use of the [pubsub module](https://github.com/developerforce/pubsub).
     * In the future, when LMS is supported in the B2B Commerce for Lightning, we will update these samples to make use of LMS.
     *
     * @fires CartContents#cartchanged
     * @fires CartContents#cartitemsupdated
     *
     * @private
     */
    handleCartUpdate() {
        // Update Cart Badge
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
        // Notify any other listeners that the cart items have updated
        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
    }

    /**
     * Handler for the 'quantitychanged' event fired from cartItems component.
     *
     * @param {Event} evt
     *  A 'quanitychanged' event fire from the Cart Items component
     *
     * @private
     */
    handleQuantityChanged(evt) {
        const { cartItemId, quantity } = evt.detail;
        updateCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId,
            cartItem: { quantity }
        })
            .then((cartItem) => {
                this.updateCartItems();
                // Update the cart badge and notify any components interested with this change
                this.handleCartUpdate();
            })
            .catch((e) => {
                // Handle quantity update error properly
                // For this sample, we can just log the error
                if (showDebug) { console.log (e); }
            });
    }

    /**
     * Handler for the 'singlecartitemdelete' event fired from cartItems component.
     *
     * @param {Event} evt
     *  A 'singlecartitemdelete' event fire from the Cart Items component
     *
     * @private
     */
    handleCartItemDelete(evt) {
        const { cartItemId } = evt.detail;
        deleteCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId
        })
            .then(() => {
                this.removeCartItem(cartItemId);
            })
            .catch((e) => {
                // Handle cart item delete error properly
                // For this sample, we can just log the error
                if (showDebug) { console.log (e);}
            });
    }

    /**
     * Handler for the 'click' event fired from 'Clear Cart' button
     * We want to delete the current cart, create a new one,
     * and navigate to the newly created cart.
     *
     * @private
     */
    handleClearCartButtonClicked() {
        // Step 1: Delete the current cart
        deleteCart({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId
        })
            .then(() => {
                // Step 2: If the delete operation was successful,
                // set cartItems to undefined and update the cart header
                this.cartItems = undefined;
                this._cartItemCount = 0;
                console.log('debug 1');
            })
            .then(() => {
                // Step 3: Create a new cart
                console.log('debug 2');
                return createCart({
                    communityId,
                    effectiveAccountId: this.effectiveAccountId
                });
            })
            .then((result) => {
                console.log('debug 3');
                console.log(result);
                // Step 4: If create cart was successful, navigate to the new cart
                this.navigateToCart(result.cartId);
                this.handleCartUpdateEvent();
            })
            .catch((e) => {
                // Handle quantity any errors properly
                // For this sample, we can just log the error
                if (showDebug) { console.log (e);}
            });
    }

    handleCartUpdateEvent() {
        // Update Cart Badge
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
    }

    /**
     * Given a cart id, navigate to the record page
     *
     * @private
     * @param{string} cartId - The id of the cart we want to navigate to
     */
    navigateToCart(cartId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cartId,
                objectApiName: 'WebCart',
                actionName: 'view'
            }
        });
    }

    /**
     * Given a cartItem id, remove it from the current list of cart items.
     *
     * @private
     * @param{string} cartItemId - The id of the cart we want to navigate to
     */
    removeCartItem(cartItemId) {
        const removedItem = (this.cartItems || []).filter(
            (item) => item.cartItemResult.cartItem.cartItemId === cartItemId
        )[0];
        const quantityOfRemovedItem = removedItem
            ? removedItem.cartItemResult.cartItem.quantity
            : 0;
        const updatedCartItems = (this.cartItems || []).filter(
            (item) => item.cartItemResult.cartItem.cartItemId !== cartItemId
        );
        // Update the cartItems with the change
        this.cartItems = updatedCartItems;
        // PROMO: make sure the two lists (inStock and outOfStock) are also updated
        this.splitCartItemsInGroups();
        // Update the Cart Header with the new count
        this._cartItemCount -= Number(quantityOfRemovedItem);
        // Update the cart badge and notify any other components interested in this change
        this.handleCartUpdate();
    }

    /**
     * Given a cartItem id, update it from the current list of cart items.
     *
     * @private
     * @param{CartItem} cartItem - An updated cart item
     */
    /*
    updateCartItemInformation(cartItem) {
        // Get the item to update the product quantity correctly.
        let count = 0;
        const updatedCartItems = (this.cartItems || []).map((item) => {
            // Make a copy of the cart item so that we can mutate it
            let updatedItem = { ...item };
            if (updatedItem.cartItemResult.cartItem.cartItemId === cartItem.cartItemId) {
                updatedItem.cartItemResult.cartItem = cartItem;
            }
            count += Number(updatedItem.cartItemResult.cartItem.quantity);
            return updatedItem;
        });
        // Update the cartItems List with the change
        this.cartItems = updatedCartItems;
        // PROMO: make sure the two lists (inStock and outOfStock) are also updated
        this.splitCartItemsInGroups();
        // Update the Cart Header with the new count
        this._cartItemCount = count;
        // Update the cart badge and notify any components interested with this change
        this.handleCartUpdate();
    }*/



    /**
     * EDEC - Promocash changes below
     *
     *
     */


    /**
     * A list of inStock cartItems.
     *
     * @type {CartItem[]}
     */
    inStockCartItems;

    /**
     * A list of outOfStock cartItems.
     *
     * @type {CartItem[]}
     */
    outOfStockCartItems;

    showInStock = false;
    showOutOfStock = false;

    splitCartItemsInGroups(){
        this.inStockCartItems = [];
        this.outOfStockCartItems = [];

        this.cartItems.forEach(function(cartItem){
          if(cartItem.inStock){
            this.inStockCartItems.push(cartItem);
            }
           else{
            this.outOfStockCartItems.push(cartItem);
            }
        },this);
        if (showDebug) { console.log ('1111111'+ JSON.stringify(this.inStockCartItems ));}
        this.showInStock = (this.inStockCartItems.length>0) ? true:false;
        this.showOutOfStock = (this.outOfStockCartItems.length>0) ? true:false;
    }


    @track quantity = 1;
    lastCategoryName = 'Ma nouvelle liste';

    openlistmodal() {
        this.template.querySelector('c-list-add-itemsor-create-custom').initDefaultValues(this.lastCategoryName);
        this.isWLModalOpen = true;
    }
    handleclosemodal() {
        this.isWLModalOpen = false;
    }

    openStockChangedModal() {
        this.isStockChangedModalOpen = true;
    }
    handleCloseStockChangedModal() {
        this.isStockChangedModalOpen = false;
    }

    @track isCartDisabled = false;

    handleCartUnlock(){
        this.isCartDisabled = false;
    }
}