import { LightningElement, api, wire, track } from 'lwc';
import { fireEvent } from 'c/pubsubCustom';
import deleteCartItem from '@salesforce/apex/B2BCartControllerCustom.deleteCartItem';
import updateQty from '@salesforce/apex/B2BCartControllerCustom.updateQuantity';
import addToCartPromocashQuantity from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity";
import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {resolve} from 'c/cmsResourceResolverCustom';
import {CurrentPageReference} from 'lightning/navigation';
import closeModalChoice from 'c/productDetailsDisplayChoiceCustom';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class CartItemsCustomModalSimilarProduct extends LightningElement {
/**
 * An organized display of product information.
 * 
 * @fires ProductDetailsDisplay#addtocart
 */
    
    @api productid;
    @api communityid;
    @api effectiveaccountid;
    @api thumbnailurl;
    @api cartitemid;
    @api cartid;
    @api subquantity;
    
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
        return this.product.data.defaultImage.url !== undefined;
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
    addQuantitySubstitutionCart(){
      /*  deleteCartItem({
            communityId: this.communityid,
            effectiveAccountId: this.effectiveaccountid,
            activeCartOrId: this.cartid,
            cartItemId: this.cartitemid
        }).catch(error => {
            if (showDebug) { console.log ('error', error);
			this.error = error;
			let stringMsg = 'Erreur lors du remplacement de votre produit. Veuillez contacter un administrateur Salesforce';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error',
					message: stringMsg,
					variant: "error"
				})
			);
        });*/

        updateQty({
            communityId: this.communityid,
            effectiveAccountId: this.effectiveaccountid,
            activeCartOrId: this.cartid,
            cartItemId: this.cartitemid,
            quantity:this.subquantity?this.subquantity:1
        }).catch(error => {
            if (showDebug) { console.log ('error', error); }
			this.error = error;
			let stringMsg = 'Erreur lors du remplacement de votre produit. Veuillez contacter un administrateur Salesforce';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error',
					message: stringMsg,
					variant: "error"
				})
			);
        });

        addToCartPromocashQuantity({
			communityId: this.communityid,
			productId: this.productid,
			quantity: this.subquantity?this.subquantity:1,
			effectiveAccountId: this.effectiveaccountid
		})
		.then(result => {
			let stringMsg = 'Votre produit a été remplacé dans votre panier, merci de patienter quelques instants.';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Succès',
					message: stringMsg,
					variant: "success"
				})
			);
			this.handleCartUpdate();
            setTimeout(function(){ 
                location.reload(); 
             }, 3000);
		})
		.catch(error => {
			this.error = error;
			let stringMsg = 'Erreur lors du remplacement de votre produit. Veuillez contacter un administrateur Salesforce';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Erreur',
					message: stringMsg,
					variant: "error"
				})
			);
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
}