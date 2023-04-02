import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';


import { resolve } from 'c/cmsResourceResolverCustom';
import { getLabelForOriginalPrice, displayOriginalPrice, formatLabel,htmlDecode } from 'c/cartUtilsCustom';
import cartItemQuantityWarningLabel from '@salesforce/label/c.B2B_Cart_Item_quantity_warning';

import updateCartItemQuantities from "@salesforce/apex/B2BCartControllerCustom.updateCartItemQuantities";

import checkStockAndEnCours from "@salesforce/apex/B2BGetInfoCustom.checkStockAndEnCours";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";

import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import getDisplayedProductData from "@salesforce/apex/B2BGetInfoCustom.getDisplayedProductData";

// Labels
import labelQuantity from '@salesforce/label/c.B2B_Cart_Item_Quantity';
import pricePerUnit from '@salesforce/label/c.B2B_Cart_Item_PricePerUnit';
import ifls from '@salesforce/label/c.B2B_Cart_Item_ifls';
import rayon from '@salesforce/label/c.B2B_Cart_Item_Rayon';
import URL_default_image from '@salesforce/label/c.URL_default_image';

//images
import BANNER_PROMO from "@salesforce/resourceUrl/BannerPromo";
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

const QUANTITY_CHANGED_EVT = 'quantitychanged';
const SINGLE_CART_ITEM_DELETE = 'singlecartitemdelete';

//Substitution produits
//import checkSimilarProductButtonCart from "@salesforce/apex/B2BCartControllerCustom.checkSimilarProductButtonCart";



/**
 * A non-exposed component to display cart items.
 *
 * @fires Items#quantitychanged
 * @fires Items#singlecartitemdelete
 */
export default class Items extends NavigationMixin(LightningElement) {
    @track bannerPromo = BANNER_PROMO;
    @track defaultImage = DEFAULT_IMAGE;
    @track popupConfig = { showModal: false };
    @track prodID;

    /**
     * An event fired when the quantity of an item has been changed.
     *
     * Properties:
     *   - Bubbles: true
     *   - Cancelable: false
     *   - Composed: true
     *
     * @event Items#quantitychanged
     * @type {CustomEvent}
     *
     * @property {string} detail.itemId
     *   The unique identifier of an item.
     *
     * @property {number} detail.quantity
     *   The new quantity of the item.
     *
     * @export
     */

    /**
     * An event fired when the user triggers the removal of an item from the cart.
     *
     * Properties:
     *   - Bubbles: true
     *   - Cancelable: false
     *   - Composed: true
     *
     * @event Items#singlecartitemdelete
     * @type {CustomEvent}
     *
     * @property {string} detail.cartItemId
     *   The unique identifier of the item to remove from the cart.
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
     * @property {string} originalPrice
     *   The original price of a cart item.
     *
     * @property {number} quantity
     *   The quantity of the cart item.
     *
     * @property {string} totalPrice
     *   The total sales price of a cart item.
     *
     * @property {string} totalListPrice
     *   The total original (list) price of a cart item.
     *
     * @property {string} unitAdjustedPrice
     *   The cart item price per unit based on tiered adjustments.
     * 
     * @property {boolean} inStock
     *   EDEC: the inStock boolean
     * 
     * @property {Promotion} promo
     *   EDEC: the inStock boolean
     * @property {Tax} tva
     *   the tva rate
     * @property {Tax} ecotax
     *   the ecotax rate
     * @property {Tax} consigne
     *   the consigne rate
     * @property {OffreProduitMagasin} opm
     *   the consigne rate
     *   
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
     * @property {string} Libelle_fournisseur__c
     * 
     * @property {string} Libelle_commercial__c
     * 
     * @property {string} Name
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
     * @typedef {Object} ProductDetails
     *
     * @property {string} productId
     *   The unique identifier of the item.
     *   *
     * @property {string} Origines__c
     *   The origine product of the item.
	 *
     *  * @property {string} Conditionnement__c
     *   The conditionnement product identifier of the item.
     *
     * @property {string} sku
     *  Product SKU number.
     *
     * @property {string} name
     *   The name of the item.
     *
     * @property {ThumbnailImage} thumbnailImage
     *   The image of the cart line item
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
     * @property {string} title
     *   The title of the image.
     *
     * @property {string} url
     *   The url of the image.
     */

    /**
     * Image information for a product.
     *
     * @typedef {Object} OffreProduitMagasin
     *
     * @property {string} Statut
     *  Statut of OffreProduitMagasin ('0','1','2','3','4','5')
     * 
     */
    
    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {string}
     */
    @api
    currencyCode;
    @api effectiveaccountid;
    @api showtaxes;
    @api showpromos;
    @api promos;
    @api taxes;
    @api offres;
    @api productimages;
    @track hasPromos = false;
    @track hasTaxes = false;
    @api typearticle;
    @api communityid;
    @api cartid;
    /**
     * Whether or not the cart is in a locked state
     *
     * @type {Boolean}
     */
    @api
    isCartDisabled = false;

    /** The icon name to show in header section */
    @api headerIconName;
    @api headerIconVariant

    /**
     * A list of CartItems
     *
     * @type {CartItem[]}
     */
    @api
    get cartItems() {
        return this._providedItems;
    }

    set cartItems(items) {
        this._providedItems = items;
        const generatedUrls = [];
        this._items = (items || []).map((item) => {
            // Create a copy of the item that we can safely mutate.
            const newItem = { ...item };
            // Set default value for productUrl
            newItem.productUrl = '';
 
            // check  for error items first
            if (item.cartItemResult.cartItem.messagesSummary.hasErrors){
                if (showDebug) { console.log ('EDEC: Error item');}
                if (showDebug) { console.log (item.cartItemResult.cartItem.messagesSummary);}
                return newItem;
            }
            // Get URL of the product image.
            /*if(("'"+item.cartItemResult.cartItem.productDetails.thumbnailImage.url+"'" == URL_default_image) || item.cartItemResult.cartItem.productDetails.thumbnailImage.url == null){
                newItem.productImageUrl = DEFAULT_IMAGE;
            } else {
                newItem.productImageUrl = resolve(
                    item.cartItemResult.cartItem.productDetails.thumbnailImage.url
                );
            }*/
            if (showDebug) { console.log ('ssssssssssnewItem'+JSON.stringify(newItem));}
            
            // Set the alternative text of the image(if provided).
            // If not, set the null all text (alt='') for images.
            newItem.productImageAlternativeText =
                item.cartItemResult.cartItem.productDetails.thumbnailImage.alternateText || '';

            // Get URL for the product, which is asynchronous and can only happen after the component is connected to the DOM (NavigationMixin dependency).
            const urlGenerated = this._canResolveUrls
                .then(() =>
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: newItem.cartItemResult.cartItem.productId,
                            objectApiName: 'Product2',
                            actionName: 'view'
                        }
                    })
                )
                .then((url) => {
                    newItem.productUrl = url;
                });
            generatedUrls.push(urlGenerated);

            
            return newItem;
        });

        // When we've generated all our navigation item URLs, update the list once more.
        Promise.all(generatedUrls).then(() => {
            this._items = Array.from(this._items);
        });
    }

    /**
     * A normalized collection of items suitable for display.
     *
     * @private
     */
    _items = [];

    /**
     * A list of provided cart items
     *
     * @private
     */
    _providedItems;

    /**
     * A Promise-resolver to invoke when the component is a part of the DOM.
     *
     * @type {Function}
     * @private
     */
    _connectedResolver;

    /**
     * A Promise that is resolved when the component is connected to the DOM.
     *
     * @type {Promise}
     * @private
     */
    _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     */
    connectedCallback() {
        // Once connected, resolve the associated Promise.
        this._connectedResolver();
        //if (showDebug) { console.log ('this._items '+ this._items);

    }
    renderedCallback() {
        if(this.showpromos == 'true' && this.promos){
            this.hasPromos = true;
        }
        if(this.showtaxes == 'true' && this.taxes){
            this.hastaxes = true;
        }
    }

    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        // We've beeen disconnected, so reset our Promise that reflects this state.
        this._canResolveUrls = new Promise((resolved) => {
            this._connectedResolver = resolved;
        });
    }


    @track orig;

    /**
     * Gets the sequence of cart items for display.
     * This getter allows us to incorporate properties that are dependent upon
     * other component properties, like price displays.
     *
     * @private
     */
    get displayItems() {
        return this._items.map((item) => {
            // Create a copy of the item that we can safely mutate.
            const newItem = { ...item };

            /* this.getInfoProduct(newItem.cartItemResult.cartItem.productId)
          .then((t) => {

            console.log('gggg 333 = '+JSON.stringify( t));
            this.orig = t.fields.Origines__c;


            console.log('gggg 333 this.orig = '+this.orig);
          }	)
          .catch((err)=> {
              console.log('Error:'+err);
          });*/

            if(this.showpromos !== undefined){
                if(this.showpromos == 'true'){
                    if(this.promos){
                        let promo = this.promos.find(item => item.Produit__c === newItem.cartItemResult.cartItem.productId);
                        newItem.promo = promo;   
                    }
                    console.log('$$$ new promo ' + newItem.promo);
                }
            }

            if(this.offres !== undefined){
                if(this.offres) {
                    let opm = this.offres.find(item => item.Produit__c === newItem.cartItemResult.cartItem.productId);
                    newItem.opm = opm;  

                    /*if (newItem.omp.vignette_alcool__c != null && newItem.omp.vignette_alcool__c != undefined && newItem.omp.vignette_alcool__c > 0){
                        newItem.hasVignetteAlcool = true;
                        newItem.montantVignetteAlcool = newItem.omp.vignette_alcool__c;
                    }
                    else{
                        newItem.hasVignetteAlcool = false;
                    }*/

                    if(newItem.opm == undefined || newItem.opm == null) {
                        newItem.statutOPM = '';
                    }
                    if(newItem.opm.Statut__c == '1'){
                        newItem.statutOPM = 'Disponible';
                        newItem.statutIsGreen = true;
                    } else if(newItem.opm.Statut__c == '2'){
                        newItem.statutOPM = 'Disponible sous commande';
                        newItem.statutIsOrange = true;
                    } else if(newItem.opm.Statut__c == '3'){
                        newItem.statutOPM = 'Disponible en quantité limitée';
                        newItem.statutIsGreen = true;
                    } else if(newItem.opm.Statut__c == '4'){
                        newItem.statutOPM = 'Indisponible temporairement';
                        newItem.statutIsRed = true;
                    } else if(newItem.opm.Statut__c == '5'){
                        newItem.statutOPM = 'Indisponible';
                        newItem.statutIsRed = true;
                    }else {
                        newItem.statutOPM = '';
                    }
                }    
            }

            if(this.showtaxes !== undefined){
                if(this.showtaxes == 'true'){
                    if(this.taxes){
                        let tva = this.taxes.find(item => item.key === newItem.cartItemResult.cartItem.cartItemId + ',' + 'TVA');
                        let ecotax = this.taxes.find(item => item.key === newItem.cartItemResult.cartItem.cartItemId + ',' + 'Ecotaxe');
                        let consigne = this.taxes.find(item => item.key === newItem.cartItemResult.cartItem.cartItemId + ',' + 'Consigne');
                        newItem.tva = tva;   
                        newItem.ecotax = ecotax;   
                        newItem.consigne = consigne;
                        newItem.montantTaxes= newItem.tva.Amount;
                        console.log('$$$$  tva ====> ====> ' + JSON.stringify(tva));
                    }

                }
            }

            if(this.productimages){
                newItem.productImages = this.productimages.find(item => item.ProductId__c === newItem.cartItemResult.cartItem.productId);
            }
            newItem.totalPrice = (newItem.cartItemResult.cartItem.totalPrice / newItem.quantity) * newItem.splitQuantity;
            
            // Get URL of the product image.
            if( newItem.productImages !== undefined  && newItem.productImages !== null && newItem.productImages.Product_Image_URL__c !== undefined &&  newItem.productImages.Product_Image_URL__c !== null){
                
                newItem.productImageUrl = newItem.productImages.Product_Image_URL__c;
                    
            } else {
                newItem.productImageUrl = DEFAULT_IMAGE;
            }
            if(newItem.inStock == true){
                newItem.totalListPrice = (newItem.cartItemResult.cartItem.totalListPrice / newItem.quantity) * newItem.splitQuantity;
            }
            else if(newItem.inStock == false){
                newItem.totalListPrice = newItem.cartItemResult.cartItem.unitAdjustedPrice * newItem.splitQuantity; 
            }

            // Set whether or not to display negotiated price
            newItem.showNegotiatedPrice =
                this.showNegotiatedPrice &&
                (newItem.totalPrice || '').length > 0;

            newItem.showNegotiatedPrice =
                this.showOriginalPrice &&
                (newItem.totalListPrice || '').length > 0;

            // Set whether or not to display original price
            newItem.showOriginalPrice = displayOriginalPrice(
                this.showNegotiatedPrice,
                this.showOriginalPrice,
                newItem.totalPrice,
                newItem.totalListPrice
            );            
            

            // get the label for original price to provide to the aria-label attr for screen readers
            newItem.originalPriceLabel = getLabelForOriginalPrice(
                this.currencyCode,
                newItem.totalListPrice
            );

            newItem.warningText=formatLabel(cartItemQuantityWarningLabel,newItem.availableQuantity,newItem.quantity);
            
            if(newItem.cartItemResult.cartItem.productDetails.fields.Picto_front__c)
                newItem.pictos=htmlDecode(newItem.cartItemResult.cartItem.productDetails.fields.Picto_front__c);

            newItem.displayedName = newItem.cartItemResult.cartItem.productDetails.fields.Libell_Final_TA__c;

            if(newItem.cartItemResult.cartItem.productDetails.fields.Libelle_rayon__c){
                newItem.libRayon = newItem.cartItemResult.cartItem.productDetails.fields.Libelle_rayon__c;
            }
            // if(newItem.cartItemResult.cartItem.productDetails.fields.Origines__c){
            // newItem.origine = newItem.cartItemResult.cartItem.productDetails.fields.Origines__c;
            //   }

            newItem.origine = this.orig;

            console.log('$$$$ ====> ====> ' + JSON.stringify(newItem));

            return newItem;
        });
        
    }



    /**
     * Gets the available labels.
     *
     * @type {Object}
     *
     * @readonly
     * @private
     */
    get labels() {
        return {
            labelQuantity,
            pricePerUnit,
            ifls,
            rayon
        };
    }

    /**
     * Handler for the 'click' event fired from 'contents'
     *
     * @param {Object} evt the event object
     */
    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                actionName: 'view'
            }
        });
    }

    /**
     * Fires an event to delete a single cart item
     * @private
     * @param {ClickEvent} clickEvt A click event.
     * @fires Items#singlecartitemdelete
     */
    handleDeleteCartItem(clickEvt) {
        const cartItemId = clickEvt.target.dataset.cartitemid;

        // PROMO: we need to account for split lines; when delete a split line ((the out of stock one)), we only want to decrease by the corresponding qty,
        // and not actually delete the whole line
        if(clickEvt.target.dataset.split === 'true' && clickEvt.target.dataset.inStock === 'false'){
            // if (showDebug) { console.log ("in split");
            const quantity = Number(clickEvt.target.dataset.totalQuantity) - Number(clickEvt.target.dataset.originalQuantity);
            // if (showDebug) { console.log ("in split quantity "+quantity);
            this.dispatchEvent(
                new CustomEvent(QUANTITY_CHANGED_EVT, {
                    bubbles: true,
                    composed: true,
                    cancelable: false,
                    detail: {
                        cartItemId,
                        quantity
                    }
                })
            );
            return;           
        }


        this.dispatchEvent(
            new CustomEvent(SINGLE_CART_ITEM_DELETE, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId
                }
            })
        );
    }

    /**
     * Fires an event to update the cart item quantity
     * @private
     * @param {FocusEvent} blurEvent A blur event.
     * @fires Items#quantitychanged
     */
    handleQuantitySelectorBlur(blurEvent) {
        if (showDebug) { console.log ('blurEvent.target.dataset');}
        // if (showDebug) { console.log (blurEvent.target.dataset);

        //Stop the original event since we're replacing it.
        blurEvent.stopPropagation();
		const eventDataSet = blurEvent.target.dataset;
        // Get the item ID off this item so that we can add it to a new event.
        const cartItemId = blurEvent.target.dataset.itemId;
        // Get the quantity off the control, which exposes it.
        var quantity = blurEvent.target.value;
        var quantityVariation = quantity - Number(blurEvent.target.dataset.originalQuantity);
        if (showDebug) { console.log ('quantity'+ quantity + quantityVariation);}
        // PROMO: we need to account for split lines; figure out what is the total quantity on the line
        if(blurEvent.target.dataset.split === 'true'){
            quantity = Number(blurEvent.target.dataset.totalQuantity) + Number(quantityVariation);
        }

        let cartItem = this.displayItems.find(item => item.cartItemResult.cartItem.cartItemId === blurEvent.target.dataset.itemId);
        console.log('tttt === '+  JSON.stringify(this.getInStockCount(cartItem.cartItemResult.cartItem.productId)));
		this.getInStockCount(cartItem.cartItemResult.cartItem.productId)
		.then((inStockCount) => {
			if ((quantity <= inStockCount) || quantityVariation <= 0) {
				updateCartItemQuantities({
					cartItemId: eventDataSet.itemId,
					split: eventDataSet.split,
					maxQuantity: cartItem.availableQuantity,
					quantity: quantity,
                    splitQuantity: Number(eventDataSet.totalQuantity) + Number(quantity - Number(eventDataSet.originalQuantity))
                    
				})
				.then((result) => {
                    this.cartItems = result.promoCartItems;
                    if (showDebug) { console.log ('xxxxxx'+this.cartItems);}
                    window.reload();
				})
				.catch((error) => {
					if (showDebug) { console.log ('updateCartItemQuantities available split errors ' + error.body.message);}
					alert(error.body.message);
				});



				// Fire a new event with extra data.
				this.dispatchEvent(
					new CustomEvent(QUANTITY_CHANGED_EVT, {
						bubbles: true,
						composed: true,
						cancelable: false,
						detail: {
							cartItemId,
							quantity
						}
					})
				);
			}
			else {
				// show popup
				this.popupConfig = {
					productId : cartItem.cartItemResult.cartItem.productId,
					quantity: quantityVariation,
					stockQuantity: inStockCount,
					showModal: true,
					state: {
						cartItemId,
						quantity
					}
				}
            }
            
		})
		.catch((err)=> {
			if (showDebug) { console.log ('Error:'+err);}
		});
    }

	handleCloseModal(event){
		this.popupConfig = { showModal: false };
	}

	handleUpdateOnModal(event){
		// Fire a new event with extra data.
		this.dispatchEvent(
			new CustomEvent(QUANTITY_CHANGED_EVT, {
				bubbles: true,
				composed: true,
				cancelable: false,
				detail: {
					cartItemId: event.detail.state.cartItemId,
					quantity: event.detail.state.quantity
				}
			})
		);
	}

    /**
     * Handles a click event on the input element.
     *
     * @param {ClickEvent} clickEvent
     *  A click event.
     */
    handleQuantitySelectorClick(clickEvent) {
        /*
      Firefox is an oddity in that if the user clicks the "spin" dial on the number
      control, the input control does not gain focus. This means that users clicking the
      up or down arrows won't trigger our change events.

      To keep the user interactions smooth and prevent a notification on every up / down arrow click
      we simply pull the focus explicitly to the input control so that our normal event handling takes care of things properly.
    */
        clickEvent.target.focus();
        if (showDebug) { console.log ('clickEvent');}
        if (showDebug) { console.log (clickEvent);}
    }

    @api
    sectionTitle="Undefined";

    @api
    quantityLabel="Undefined";

    get articleDispo(){
        return this.typearticle == 'dispo';
    }

    get articleIndispo(){
        return this.typearticle == 'indispo';
    }
    
    //Substitution produit 

    @track substitutionButton = false;
    @track showModalSubstitution = false;
    @track substitutionCartItemId;
    @track substitutionProductId;
    @track subqty;

    openModalSubstitution(clickEvt){
        const cartItemIdT = clickEvt.target.dataset.cartitemid;
        const productIdT = clickEvt.target.dataset.productid;
        this.substitutionCartItemId = cartItemIdT;
        this.substitutionProductId = productIdT;
        this.showModalSubstitution = true;
        this.subqty = clickEvt.target.dataset.subquantity;

    }

    closeModal(){
        this.showModalSubstitution = false;
    }

	getInStockCount(productId) {
		return new Promise((resolve, reject) => {
			checkStockAndEnCours({
				productId: productId,
				effectiveAccountId: this.effectiveaccountid
			})
			.then((result) => {
				resolve(result);
			})
			.catch((err) => {
				reject(err);
			});
        });  
    
    }

    @track msgNoInformation = '-';
    @track conditionnement;
    @track origine;



    getInfoProduct(prId) {


        return new Promise((resolve, reject) => {
			getProduct({
                communityId: this.communityid,
                productId: prId,
                effectiveAccountId: this.effectiveaccountid
			})
			.then((result) => {
				resolve(result);
			})
			.catch((err) => {
				reject(err);
			});
        });





			/*getDisplayedProductData({
				productId: prId
			})
			.then((result) => {
		//	this.origine = result[0].Origines__c;
            	console.log('$$$$ g'+ JSON.stringify(result));


			})
			.catch((err) => {
				reject(err);
			});*/


    }
   /* @wire (getDisplayedProductData,{productId: '$prodID'})
    wiredGetDisplayedProductData({ error, data }) {
        if (data) {
        console.log('$$$$ cartItemsCustom data = ' + JSON.stringify(data));

        this.conditionnement = (data[0].Conditionnement__c == undefined) ? this.msgNoInformation : data[0].Conditionnement__c;
        this.origine = (data[0].Origines__c == undefined) ? this.msgNoInformation  : data[0].Origines__c;

        this.error = undefined;
        } else if (error) {
            this.error = error;
            this.energie = undefined;
            console.log('cartItemsCustom wiredGetDisplayedProductData error' + JSON.stringify(error));
        }
    } */

    get isIconSuccess () {
        return this.headerIconName === "utility:success" ? true : false;
    }

    get isIconWarning () {
        return this.headerIconName === "utility:warning" ? true : false;
    }

}