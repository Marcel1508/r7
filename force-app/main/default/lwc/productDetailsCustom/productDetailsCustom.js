import { LightningElement, wire, api } from "lwc";

import communityId from '@salesforce/community/Id';
import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import checkStockAndEnCours from "@salesforce/apex/B2BGetInfoCustom.checkStockAndEnCours";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import { resolve } from "c/cmsResourceResolverCustom";
import Id from '@salesforce/user/Id';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class ProductDetailsCustom extends LightningElement {
    //cmtId = communityid;
    userId = Id;

    connectedCallback(){
		if (showDebug) { console.log ('ProductDetailsCustom recordId: ' + this.recordId);}
	    if (showDebug) { console.log (this.userId);}
    }
    
    /**
     * Gets or sers the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    /**
     *  Gets or sets the unique identifier of a product.
     * 
     * @type {string}
     */
    @api
    recordId;

    /**
     * The stock status of the product, i.e. whether it is "in stock."
     *
     * @type {Boolean}
     * @private
     */
    @wire(checkStockAndEnCours, {
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    stockAndEnCours;

    get inStock() {
		return this.stockAndEnCours.data > 0;
	}
    /**
     * The full product information retrieved.
     *
     * @type {ConnectApi.ProductDetail}
     * @private
     */
    @wire(getProduct, {
        communityId: communityId,
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    product;

    /**
     * The price of the product for the user, if any.
     *
     * @type {ConnectApi.ProductPrice}
     * @private
     */
    @wire(getProductPrice, {
        communityId: communityId,
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    productPrice;

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        //return "001T1000001nGYQIA2";
        const effectiveAcocuntId = this.effectiveAccountId || "";
        let resolved = null;

        if (effectiveAcocuntId.length > 0 && effectiveAcocuntId !== "000000000000000") {
            resolved = effectiveAcocuntId;
        }
        if (showDebug) { console.log ('===> resolved: ' + resolved);}
        return resolved;
    }

    /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasProduct() {
        if (showDebug) { console.log ('Product: ' + JSON.stringify(this.product));}
        if (showDebug) { console.log ('stockAndEnCours: ' + JSON.stringify(this.stockAndEnCours));}
        return this.product.data !== undefined && this.stockAndEnCours.data !== undefined;
    }

    /**
     * Gets the normalized, displayable product information for use by the display components.
     *
     * @readonly
     */
    get displayableProduct() {
        //if (showDebug) { console.log ('this.product.data ' + JSON.stringify(this.product.data));
        // if (showDebug) { console.log ('this.product.data in displayable product');
        // if (showDebug) { console.log (this.product.data);
        if (showDebug) { console.log ('#######mediaGroups: ' + JSON.stringify(this.product.data.mediaGroups));}
        return {
            categoryPath: this.product.data.primaryProductCategoryPath.path.map(category => ({
                id: category.id,
                name: category.name
            })),
            description: this.product.data.fields.Description,
            image: {
                alternativeText: this.product.data.defaultImage.alternativeText,
                url: resolve(this.product.data.defaultImage.url)
            },
            picto: this.product.data.Pictogramme_Rayon__c,
            medias: this.product.data.mediaGroups,
            inStock: this.inStock,
            quantityInStock: this.stockAndEnCours.data,
            name: this.product.data.fields.Libell_Final_TA__c,
            price: {
                currency: (this.productPrice.data || {}).currencyIsoCode,
                negotiated: (this.productPrice.data || {}).unitPrice
            },
            sku: this.product.data.fields.StockKeepingUnit
        };
    }

    // renderedCallback(){
    //     if (showDebug) { console.log ('this.displayableProduct');
    //     if (showDebug) { console.log (this.displayableProduct);
    // }
    /**
     * Handles a user request to add the product to their active cart.
     * 
     * @private
     */
    addtoCart() {
        if (showDebug) { console.log ('add to cart');}
        // addToCart({
        //     communityId: communityId,
        //     productId: this.recordId,
        //     quantity: "1",
        //     effectiveAccountId: this.resolvedEffectiveAccountId
        // })
        //     .then(result => {
        //         if (showDebug) { console.log (result);
        //         if (showDebug) { console.log ('no errors');
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         if (showDebug) { console.log ('errors');
        //     });

    }

    /**
     * Handles a user request to add the product to their active cart.
     * 
     * @private
     */
    addtoList() {
        if (showDebug) { console.log ('add to list');}

        // addToList({
        //     communityId: communityId,
        //     productId: this.recordId,
        //     effectiveAccountId: this.resolvedEffectiveAccountId
        // })
        //     .then(result => {
        //         if (showDebug) { console.log (result);
        //         if (showDebug) { console.log ('no errors');
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         if (showDebug) { console.log ('errors');
        //     });

    }
}