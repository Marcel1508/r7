import { LightningElement, api } from 'lwc';


/**
 * An organized display of product cards.
 *
 * @fires SearchLayout#calltoaction
 * @fires SearchLayout#showdetail
 */
export default class SearchLayoutCustom extends LightningElement {

    @api effectiveaccountid;
    @api communityid;
    @api cartid;
    /**
     * An event fired when the user clicked on the action button. Here in this
     *  this is an add to cart button.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *
     * @event SearchLayout#calltoaction
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
     * @event SearchLayout#showdetail
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
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
     * @property {object} opm
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
     * Layout configuration.
     * @typedef {object} LayoutConfig
     *
     * @property {string} resultsLayout
     *  Products layout.
     *  Supported (case-sensitive) values are:
     *  - "grid"
     *      The products will be displayed in grid column layout.
     *      The property gridMaxColumnsDisplayed defines the max no. of columns.
     *  - "list"
     *      The products will be displayed as a list.
     *
     * @property {CardConfig} cardConfig
     *   Card layout configuration.
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
     */

    /**
     * Gets or sets the display data for layout.
     *
     * @type {Product[]}
     */
    @api
    displayData;
    @api
    displayExtraData;
    @api opm;
    showStuff = false;
    hop = [];

    /**
     * Gets or sets the layout configurations.
     *
     * @type {LayoutConfig}
     */
    @api
    config;

    /**
     * Gets the container class which decide the innter element styles.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get layoutContainerClass() {
        return this.config.resultsLayout === 'grid'
            ? 'layout-grid'
            : 'layout-list';
    }
    
    get imagesData() {
        var images = [];
        if(this.displayData != undefined) {
            this.displayData.forEach(element => {
                //console.log('#### imagesDate: ' + JSON.stringify(element.image));
                images.push({"id": element.id, "image": element.image});
            });
        }
        return images;
    } 

    get fieldsData() {
        var images = [];
        if(this.displayData != undefined) {
            this.displayData.forEach(element => {
                images.push({"id": element.id, "fields": element.fields});
            });
        }
        return images;
    }

    topFunction(){
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

    renderedCallback(){
        console.log('layout : this.displayExtraData' + JSON.stringify(this.displayExtraData));
        console.log('layout : this.displayData' + JSON.stringify(this.displayData));
     }
}