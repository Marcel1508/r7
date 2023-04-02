import { LightningElement, api, wire, track } from 'lwc';

import {CurrentPageReference} from 'lightning/navigation';

import { fireEvent } from 'c/pubsubCustom';
import addToCartPromocashQuantity from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity";
import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {resolve} from 'c/cmsResourceResolverCustom';
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';
//images
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
// labels
import URL_default_image from '@salesforce/label/c.URL_default_image';

/**
 * An organized display of product information.
 * 
 * @fires ProductDetailsDisplay#addtocart
 */

export default class addToCartModalChoiceSimilarProduct extends LightningElement {
    
    @api productid;
    @api communityid;
    @api effectiveaccountid;
    @api quantityinstock;
    @api quantity;
    @api thumbnailurl;
    @api productreference;
    @track defaultImage = DEFAULT_IMAGE;

    
    @wire(CurrentPageReference)
        pageRef;
            
    @wire(getProduct, {
        communityId: '$communityid',
        productId: '$productid',
        effectiveAccountId: '$effectiveaccountid',
    }) product;
    
    @wire(getProductPrice, {
        communityId: '$communityid',
        productId: '$productid',
        effectiveAccountId: '$effectiveaccountid',
    }) productPrice;
    
    get hasProduct() {
        return this.product.data !== undefined;
    }
    get hasProductPrice() {
        return this.productPrice.data !== undefined;
    }
    get hasListPrice() {
        return this.productPrice.listPrice !== undefined;
    }
    get hasUnitPrice() {
        return this.productPrice.unitPrice !== undefined;
    }
    get hasProductDefaultImage() {
        return this.product.data.defaultImage !== undefined;
    }
    get productDefaultImageUrl() {
        return resolve(this.product.data.defaultImage.url);
    }
    get productDefaultImageAlt() {
        return this.product.data.defaultImage.alternativeText;
    }
    get hasProductDefaultImageUrl() {
        return this.product.data.defaultImage.url !== undefined && this.product.data.defaultImage.url != URL_default_image && this.product.data.defaultImage.title != 'image';
    }
    get hasNullThumbnail() {
        return this.thumbnailurl.url == null;
    }
    get resolvedThumbnailUrl() {
        return resolve(this.thumbnailurl.url);
    }
    get urlIsNull() {
        return this.product.data.defaultImage.url == null;
    }

    /**
     * An event fired when the user indicates the product should be added to their cart.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *
     * @event ProductDetailsDisplay#addtocart
     * @type {CustomEvent}
     *
     * @export
     */

    quantitySubstitution;

    addQuantitySubstitutionCart(){
        this.quantitySubstitution = this.quantity - this.quantityinstock;
        addToCartPromocashQuantity({
			communityId: this.communityid,
			productId: this.productreference,
			quantity: this.quantityinstock,
			effectiveAccountId: this.effectiveaccountid
		});
        addToCartPromocashQuantity({
			communityId: this.communityid,
			productId: this.productid,
			quantity: this.quantitySubstitution,
			effectiveAccountId: this.effectiveaccountid
		})
		.then(result => {
			let stringMsg = 'Tous les produits ont été ajoutés au panier.';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Succès',
					message: stringMsg,
					variant: "success"
				})
			);
			this.handleCartUpdate();
            this.closeModalSubstitution();
		})
		.catch(error => {
			this.error = error;
			let stringMsg = 'Erreur lors de l\'ajout du produit au panier. Veuillez contacter un administrateur Salesforce';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Erreur',
					message: stringMsg,
					variant: "error"
				})
			);
            this.closeModalSubstitution();
		});   
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
        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
    }
    
	@api showModalSubstitution;

	constructor() {
		super();
		this.showModalSubstitution = false;
	}

	closeModalSubstitution(){
		this.dispatchEvent(new CustomEvent('close'));
	}
}