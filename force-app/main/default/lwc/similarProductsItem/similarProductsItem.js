import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';

import { LightningElement, track, wire, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import {resolve} from 'c/cmsResourceResolverCustom';
//images
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
// labels
import URL_default_image from '@salesforce/label/c.URL_default_image';


export default class SimilarProductsItem extends NavigationMixin(LightningElement)  {

    @api productid;
    @api communityid;
    @api effectiveaccountid;
    @api thumbnailurl;
	@api disabled;
	@track defaultImage = DEFAULT_IMAGE;


    @track isPft = false;

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

	renderedCallback(){
		console.log('$$$  productid = '+this.productid);
		console.log('communityid ='+this.communityid);
		console.log('effectiveaccountid ='+this.effectiveaccountid);
        console.log('productid url = ' +this.url);
        
		if(this.product.data !== undefined){
			console.log(' $$$$ product data ='+ JSON.stringify(this.product.data));
		}
	}
	get addcartButtonCSS(){
		if(FORM_FACTOR=='Small') return 'slds-col slds-grow slds-container_center addToCartButton';
		else return 'slds-col slds-grow slds-size_1-of-3 slds-container_center addToCartButton';
	}

	get hasConditionnement() {
		return (
			this.product.data.fields.Conditionnement__c != null &&
			this.product.data.fields.Conditionnement__c !== undefined
		);
	}

	get hasOrigines() {
		return (
			this.product.data.fields.Origines__c != null &&
			this.product.data.fields.Origines__c !== undefined
		);
	}
	


}