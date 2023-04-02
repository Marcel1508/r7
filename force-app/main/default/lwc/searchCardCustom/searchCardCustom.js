import { LightningElement, api, track, wire } from 'lwc';
import { htmlDecode,capitalizeAllWords } from 'c/cartUtilsCustom';
import opmSearch from '@salesforce/apex/B2BSearchControllerCustom.opmSearch';
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import checkProductIsPFT from "@salesforce/apex/B2BGetInfoCustom.checkProductIsPFT";
import getPrixSpecifiqueProduct from "@salesforce/apex/B2BGetInfoCustom.getPrixSpecifiqueProduct";
import getPromotions from '@salesforce/apex/B2BPromotionsControllerCustom.getPromotions';
import getDisplayedProductName from "@salesforce/apex/B2BGetInfoCustom.getDisplayedProductName";
//images
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
import BANNER_PROMO from "@salesforce/resourceUrl/BannerPromo";
// labels
import URL_default_image from '@salesforce/label/c.URL_default_image';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
import isGuest from '@salesforce/user/isGuest';

/**
 * An organized display of a single product card.
 *
 * @fires SearchCardCustom#calltoaction
 * @fires SearchCardCustom#showdetail
 * @fires ProductDetailsDisplay#addtolist
 */
export default class SearchCardCustom extends LightningElement {
    @track defaultImage = DEFAULT_IMAGE;
	@track bannerPromo = BANNER_PROMO;
    @api effectiveaccountid;
    @api cartid;
    lastCategoryName;
    @track productId;
    @api communityid;
    @track currencyEuro ='€';
    @track showModal = false;
    @wire (getDisplayedProductName,{productId: '$productId'}) DisplayedProductName;
    isGuestUser = isGuest;
    /**
     * An event fired when the user clicked on the action button. Here in this
     *  this is an add to cart button.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *
     * @event SearchLayoutCustom#calltoaction
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
     *
     * @export
     */

    /**
     * An event fired when the user indicates a desire to view the details of a product.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *
     * @event SearchLayoutCustom#showdetail
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
     *
     * @export
     */

    /**
     * An event fired when the user indicates the product should be added to their list.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *
     * @event ProductDetailsDisplay#addtolist
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * A result set to be displayed in a layout.
     * @typedef {object} Product
     *
     * @property {string} id
     *  The id of the product
     *
     * @property {string} name
     *  Product name
     *
     * @property {Image} image
     *  Product Image Representation
     *
     * @property {object.<string, object>} fields
     *  Map containing field name as the key and it's field value inside an object.
     *
     * @property {Prices} prices
     *  Negotiated and listed price info
     */

    /**
     * A product image.
     * @typedef {object} Image
     *
     * @property {string} url
     *  The URL of an image.
     *
     * @property {string} title
     *  The title of the image.
     *
     * @property {string} alternativeText
     *  The alternative display text of the image.
     */

    /**
     * Prices associated to a product.
     *
     * @typedef {Object} Pricing
     *
     * @property {string} listingPrice
     *  Original price for a product.
     *
     * @property {string} negotiatedPrice
     *  Final price for a product after all discounts and/or entitlements are applied
     *  Format is a raw string without currency symbol
     *
     * @property {string} currencyIsoCode
     *  The ISO 4217 currency code for the product card prices listed
     */

    /**
     * Card layout configuration.
     * @typedef {object} CardConfig
     *
     * @property {Boolean} showImage
     *  Whether or not to show the product image.
     *
     * @property {string} resultsLayout
     *  Products layout. This is the same property available in it's parent
     *  {@see LayoutConfig}
     *
     * @property {Boolean} actionDisabled
     *  Whether or not to disable the action button.
     */

    /**
     * Gets or sets the display data for card.
     *
     * @type {Product}
     */
    @api displayData;
    @track displayDataTest = this.displayData;
    @api imagesData;
    @api fieldsData;
    @track loadedProduit;
    @track promotion;
    @track imageResult;
    @track opmResult;
    @track productPrice;

    @track isPFT;
    @track prixSpecifique;
    //@wire (getDisplayedProductName,{productId: '$Id'}) DisplayedProductName;
    /*
    /**INFO PRODUITS 
    @wire(opmSearch,{
		productId: '$productId',
		effectiveAccountId: '$effectiveaccountid',
	}) opmResult;

    @wire(getProductPrice, {
		communityId: '$communityid',
		productId: '$productId',
		effectiveAccountId: '$effectiveaccountid',
	}) productPrice;

    	//returns true if the product defined by the product id is 'en extension de gamme'
	@wire(checkProductIsPFT, {
		productId: '$productId',
		effectiveAccountId: '$effectiveaccountid'
	}) isPFT;

    @wire(getPrixSpecifiqueProduct,{
        productId: '$productId',
		effectiveAccountId: '$effectiveaccountid'
    }) prixSpecifique;

    /**PROMOTIONS 
    
    @wire(getPromotions,{
        productId: '$productId',
		effectiveAccountId: '$effectiveaccountid',
    }) promotion;*/
    loadedStock;

    connectedCallback(){

        if (showDebug) { console.log ('**********displayData: ' + JSON.stringify(this.displayData));}

        if (showDebug) { console.log ('********** (Search Card) found images: ' + JSON.stringify(this.productImages));}
        if (showDebug) { console.log ('********** (Search Card) found fields: ' + JSON.stringify(this.productFields));}
        
        this.productId = this.displayData.id;

        this.loadedProduit = this.displayData.produit

        var loadedOpm = this.displayData.opm;
        this.opmResult = {"data": loadedOpm};

        var loadedImage = this.displayData.image;
        this.imageResult = {"data": loadedImage};


        var loadedProductPrice = this.displayData.prices;
        this.productPrice = {"data": loadedProductPrice};

        var loadedPFT = this.displayData.pft;
        this.isPFT = {"data": loadedPFT};
        
        this.loadedStock = {"data": this.displayData.stock};
        this.opmResult = {"data": loadedOpm};
        
        var loadedPromo = this.displayData.promo;
        this.promotion = {"data": loadedPromo};
        
        var loadedPrixSpe = this.displayData.prixSpe;
        this.prixSpecifique = {"data": loadedPrixSpe};
        
        if (showDebug) { console.log ('**********this.loadedProduit: ' + JSON.stringify(this.loadedProduit));}
        if (showDebug) { console.log ('**********loadedOpm: ' + JSON.stringify(loadedOpm));}
        if (showDebug) { console.log ('**********loadedProductPrice: ' + JSON.stringify(loadedProductPrice));}
        if (showDebug) { console.log ('**********loadedPFT: ' + JSON.stringify(loadedPFT));}
        if (showDebug) { console.log ('**********loadedStock: ' + JSON.stringify(this.loadedStock));}
        if (showDebug) { console.log ('**********loadedPromo: ' + JSON.stringify(loadedPromo));}
        if (showDebug) { console.log ('**********loadedPrixSpe: ' + JSON.stringify(loadedPrixSpe));}

    }

    get productImages() {
        var res = this.imagesData.find(item => item.id == this.displayData.id);
        return res.image;
    }
    
    get productFields() {
        if(this.fieldsData == undefined)
            return undefined;
        var res = this.fieldsData.find(item => item.id == this.displayData.id);
        if(res == undefined)
            return undefined;
        return res.fields;    
    }

    get hasOrigines() {
        return this.loadedProduit !== undefined && this.loadedProduit.Origines__c !== undefined;
    }

    get productOrigines() {
        return this.loadedProduit.Origines__c;
    }

    get hasProductCodeIFS() {
        return this.loadedProduit !== undefined && this.loadedProduit.Code_IFLS__c !== undefined;
    }

    get productCodeIFS() {
        return this.loadedProduit.Code_IFLS__c;
    }
    get productConditionnement() {
        return this.loadedProduit.Conditionnement__c;
    }

    get hasOpm(){
        return this.opmResult.data !== undefined; 
    }
    get hasopmStatut(){
        return this.hasOpm == true && this.opmResult.data.Statut__c !== undefined;
    }
    get opmStatut(){
        return this.opmResult.data.Statut__c;
    }
    get hasPrixUniteOPM(){
        return this.hasOpm == true && this.opmResult.data.Prix_unite__c != null || this.opmResult.data.Prix_unite__c != undefined;
    }
    get hasIFLSOPM(){
        return this.hasOpm == true && (this.opmResult.data.Produit__r.Code_IFLS__c != null || this.opmResult.data.Produit__r.Code_IFLS__c != undefined);
    }
    get hasMarqueOPM(){
        return this.hasOpm == true && (this.opmResult.data.Produit__r.Marque_text__c != null || this.opmResult.data.Produit__r.Marque_text__c != undefined);
    }
    get hasConditionnement(){
        return this.hasOpm == true && (this.opmResult.data.Produit__r.Conditionnement__c != null || this.opmResult.data.Produit__r.Conditionnement__c != undefined);
    }
    get hasConditionnementOPM(){
        return this.hasOpm == true && (this.opmResult.data.Libelle_du_conditionnement_de_vente__c != null || this.opmResult.data.Libelle_du_conditionnement_de_vente__c != undefined);
    }
    get hasPrixSpecifique(){
		return this.prixSpecifique.data != undefined || this.prixSpecifique.data != null;
    }
    get hasPrixUnitePS(){
        return this.prixSpecifique.data.Prix_unite__c != undefined || this.prixSpecifique.data.Prix_unite__c != null;
    }
    get prixUnitePS(){
        return this.prixSpecifique.data.Prix_unite__c;
    }
    get hasPrixKiloPS(){
        return this.prixSpecifique.data.Prix_kilo__c != undefined || this.prixSpecifique.data.Prix_kilo__c != null;
    }
    get prixKiloPS(){
        return this.prixSpecifique.data.Prix_kilo__c;
    }
    get hasPrixLitrePS(){
        return this.prixSpecifique.data.Prix_L__c != null || this.prixSpecifique.data.Prix_L__c != null;
    }
    get prixLitrePS(){
        return this.prixSpecifique.data.Prix_L__c;
    }
    get hasPrixKilo() {
        return this.opmResult.data != undefined && this.opmResult.data.Prix_kilo__c !== null && this.opmResult.data.Prix_kilo__c !== undefined && this.opmResult.data.Prix_kilo__c != 0;
    }
    get getPrixKilo() {
        return this.opmResult.data.Prix_kilo__c;
    }
    get hasPrixLitre() {
        return this.opmResult.data != undefined && this.opmResult.data.Prix_L__c !== null && this.opmResult.data.Prix_L__c !== undefined && this.opmResult.data.Prix_L__c !== 0;
    }
    get getPrixLitre() {
        return this.opmResult.data.Prix_L__c;
    }
    get hasPrixUnite() {
        return this.opmResult.data != undefined && this.opmResult.data.Prix_unite__c !== null && this.opmResult.data.Prix_unite__c !== undefined && this.opmResult.data.Prix_unite__c !== 0;
    }
    get getPrixUnite() {
        return this.opmResult.data.Prix_unite__c;
    }
    get ifProductStatutGreen(){
        return this.hasOpm == true && (this.opmResult.data.Statut__c == '1' || this.opmResult.data.Statut__c == '3');
    }
    get ifProductStatutOrange(){
        return this.hasOpm == true && this.opmResult.data.Statut__c == '2';
    }
	get ifProductStatutRed(){
        return this.hasOpm == true && (this.opmResult.data.Statut__c == '4' || this.opmResult.data.Statut__c == '5');
    }
    get hasProductPrice(){
		return this.productPrice.data !== undefined;
	}
	get hasListPrice(){
		return this.productPrice.data.listprice !== undefined;
	}
	get hasUnitPrice(){
		return this.productPrice.data.unitprice !== undefined;
	}
    get hasPFTAndStatutOut(){
		return this.isPFT.data == true || (this.hasOpm == true && this.opmResult.data.Statut__c == '4') || (this.hasOpm == true && this.opmResult.data.Statut__c =='5')
	}
    
    get getStatutLabel(){
        var statutLabel = '';
        if(this.hasOpm == false)
            return statutLabel;
        if(this.opmResult.data.Statut__c == '1'){
            statutLabel = 'Disponible';
        } 
        else if(this.opmResult.data.Statut__c == '2'){
            statutLabel = 'Disponible sous commande';
        }
        else if(this.opmResult.data.Statut__c == '3'){
            statutLabel = 'Disponible en quantité limitée';
        }
        else if(this.opmResult.data.Statut__c == '4'){
            statutLabel = 'Indisponible temporairement';
        }
        else if(this.opmResult.data.Statut__c == '5'){
            statutLabel = 'Indisponible';
        }
        return statutLabel;
    }

    
    get hasPromotions(){
        if (showDebug) { console.log ('****this.promotion' + JSON.stringify(this.promotion));}
        return this.promotion != null && this.promotion.data != null && this.promotion.data != undefined;
    }

    get prixPromo(){
        return this.promotion.data.Prix_de_vente_promotion__c
    }
    

    /**
     * Gets or sets the card layout configurations.
     *
     * @type {CardConfig}
     */
    @api
    config;

    /**
     * Gets the product image.
     *
     * @type {Image}
     * @readonly
     * @private
     */
    get image() {
        return this.displayData.image || {};
    }

    /*get hasNotDefaultImage(){
        return this.displayData != undefined && this.displayData.image != null && this.displayData.image.url != URL_default_image && this.displayData.image.title != 'image';
    }*/

    get hasNotDefaultImage(){		
	return (this.imageResult != undefined && this.imageResult != null && this.imageResult.data != null && this.imageResult.data != undefined && this.imageResult.data.Product_Image_URL__c != null && this.imageResult.data.Product_Image_URL__c != undefined );		
	}

    /**
     * Gets the product fields.
     *
     * @type {object.<string, object>[]}
     * @readonly
     * @private
     */
    get fields() {
            var newFieldsArray = this.productFields;
            return (newFieldsArray || []).map(({ name, value }, id) => ({
                id: id + 1,
                tabIndex: id === 0 ? 0 : -1,
                // making the first field bit larger
                class: id
                   // ? 'slds-truncate slds-text-heading_small'
                   // : 'slds-truncate slds-text-heading_medium',
                   ? 'product-name slds-text-heading_small'
                   : 'product-name slds-text-heading_medium',
                // making Name and Description shows up without label
                // Note that these fields are showing with apiName. When builder
                // can save custom JSON, there we can save the display name.
                value:
                    name === 'Name' || name === 'Description'
                        ? value //capitalizeAllWords(value)
                        : `${name}: ${value}`
                        // : `${name}: ${capitalizeAllWords(value)}`
            }));
    }


    /**
     * Whether or not the product image to be shown on card.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get showImage() {
        return !!(this.config || {}).showImage;
    }

    /**
     * Whether or not disable the action button.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get actionDisabled() {
        return !!(this.config || {}).actionDisabled;
    }

    /**
     * Gets the product price.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get price() {
        const prices = this.displayData.prices;
        if(prices == undefined) return undefined;

        return prices.negotiatedPrice || prices.listingPrice;
    }

    /**
     * Whether or not the product has price.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasPrice() {
        return !!this.price;
    }

    get priceNotFoundMessage() {
        return (this.isGuestUser === true)? 'Pour voir le prix connectez-vous': 'Prix introuvable';
    }

    /**
     * Gets the original price for a product, before any discounts or entitlements are applied.
     *
     * @type {string}
     */
    get listingPrice() {
        if(this.displayData.prices == undefined) return undefined;
        return this.displayData.prices.listingPrice;
    }

    /**
     * Gets whether or not the listing price can be shown
     * @returns {Boolean}
     * @private
     */
    get canShowListingPrice() {
        const prices = this.displayData.prices;
        if(prices == undefined) return false;
        return (
            prices.negotiatedPrice &&
            prices.listingPrice &&
            // don't show listing price if it's less than or equal to the negotiated price.
            Number(prices.listingPrice) > Number(prices.negotiatedPrice)
        );
    }

    /**
     * Gets the currency for the price to be displayed.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get currency() {
        if(this.displayData.prices == undefined) return undefined;
        return this.displayData.prices.currencyIsoCode;
    }

    /**
     * Gets the container class which decide the innter element styles.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get cardContainerClass() {
        return this.config.resultsLayout === 'grid'
            ? 'slds-box card-layout-grid'
            : 'card-layout-list';
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires SearchCardCustom#calltoaction
     * @private
     */
    notifyAction() {
        this.dispatchEvent(
            new CustomEvent('calltoaction', {
                bubbles: true,
                composed: true,
                detail: {
                    productId: this.displayData.id,
                    productName: this.displayData.name
                }
            })
        );
    }

    /**
     * Emits a notification that the user indicates a desire to view the details of a product.
     *
     * @fires SearchCardCustom#showdetail
     * @private
     */
    notifyShowDetail(evt) {
        evt.preventDefault();
        this.dispatchEvent(
            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.id }
            })
        );
    }

   /**
     * Emits a notification that the user wants to add the item to their list.
     * 
     * @fires ProductDetailsDisplay#addtolist
     * @private
     */
    notifyAddToList() {
        this.template.querySelector('c-list-add-itemsor-create-custom').initDefaultValues(this.lastCategoryName);
        this.showModal = true;
    }    

    @track quantity = 1;

    handleQuanitytChange(e) {
        this.quantity = this.template.querySelector("input[data-my-id=in1]").value;
        if(this.quantity == '' || this.quantity == null || this.quantity == undefined) {
            this.quantity = 1;
        }
    }

    get getPic() {
        //return this.hasOpm == true? this.opmResult.data.Produit__r.Picto_front__c: '';
        if(this.loadedProduit == undefined)
            return undefined;
        return this.loadedProduit.Picto_front__c;
    }
}