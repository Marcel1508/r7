import {
	NavigationMixin,
	CurrentPageReference
} from 'lightning/navigation';

import { LightningElement, track, wire, api } from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import addToListsPromocash from "@salesforce/apex/B2BGetInfoCustom.addToListsPromocash";
import removeWishlistItem from "@salesforce/apex/B2BGetInfoCustom.removeWishlistItem";
//images
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
// labels
import URL_default_image from '@salesforce/label/c.URL_default_image';

import {resolve} from 'c/cmsResourceResolverCustom';

export default class WishlistsDesktopViewItemCustomModalSimilarProduct extends LightningElement {
    
        @api productid;
        @api communityid;
        @api effectiveaccountid;
        @api thumbnailurl;
        @api wishlistitemid;
        @api wishlistid;
        @api substitution;
        @api quantity;
        @api disabled;
        @track defaultImage = DEFAULT_IMAGE;
    
        @wire(CurrentPageReference)
        pageRef;
            
        @wire(getProduct, {
            productId: '$productid',
            effectiveAccountId: '$effectiveaccountid',
            communityId: '$communityid',
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

        get statutOut() {
            if(this.substitution =='permanente'){
                return true
            }
        }
        get statutIndispo() {
            if(this.substitution =='temporaire'){
                return true
            }
        }
        
    
        handleProductDetailNavigation(evt) {
            evt.preventDefault();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.productid,
                    actionName: 'view'
                }
            });
        }

        handleAddToListAndRemoveProduct(event){
            addToListsPromocash({
                effectiveAccountId: this.effectiveaccountid,
                wishlistId: this.wishlistid,
                communityId: this.communityid,
                productId: this.productid
            });
            removeWishlistItem({
                effectiveAccountId: this.effectiveaccountid,
                wishlistId: this.wishlistid,
                communityId: this.communityid,
                wishlistItemId: this.wishlistitemid
            }).then(result => {
                this.error = undefined;
                let stringMsg = 'Le produit a été substitué dans votre liste.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: stringMsg,
                        variant: "success"
                    })
                );
            }).catch(error => {
                let stringMsg = 'Une erreur est survenue lors de la substitution de votre produit. Veuillez contacter un administrateur.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: stringMsg,
                        variant: "error"
                    })
                );
                this.error = error;
            });
            location.reload();
        }      
}