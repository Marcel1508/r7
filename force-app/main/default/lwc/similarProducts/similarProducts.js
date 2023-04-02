import { LightningElement, wire, api } from "lwc";

import checkDisplayingSimilarProduct from "@salesforce/apex/B2BGetInfoCustom.checkDisplayingSimilarProduct";
import getSimilarProduct from "@salesforce/apex/B2BGetInfoCustom.getSimilarProduct";
import getCartSummary from '@salesforce/apex/B2BGetInfoCustom.getCartSummary';

import communityId from '@salesforce/community/Id';

export default class SimilarProducts extends LightningElement {
	community = communityId;
    @api buttonDisabledAddToCart = false;

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
     * Check OPM statut to display SimilarProduct Section
     *
     * @type {Boolean}
     * @private
     */
    @wire(checkDisplayingSimilarProduct, {
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    isDisplayed;

    @wire(getSimilarProduct, {
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    listOPMs;

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
        return resolved;
    }

	
    /**
     * Gets product's statut__c to display Similar Product Section
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasOpms() {
		return this.listOPMs.data !== undefined;
    }

    connectedCallback() {
        console.log('similar products this.effectiveAccountId: ' +  this.effectiveAccountId);
        console.log('similar OPM****');
        console.log(this.listOPMs);
        console.log('==> ' + this.recordId);
        getCartSummary({
            communityId: this.community,
            effectiveAccountId: this.effectiveAccountId
        })
        .then((result) => {
            if(result !== null) {
                this.cartId = result.cartId;
                if(result.status !=='Active'){
                    this.buttonDisabledAddToCart = true; 
                }
            }

        console.log('similar products this.effectiveAccountId: ELSE');
        })
        .catch((e) => {
            console.log('getCartSummary error : ' + JSON.stringify(e));
        });
    }

    get hasOpmsOverZero() {
		return this.listOPMs.data.length > 0;
    }
    get hasDisplayedData() {
        return this.isDisplayed.data !== undefined;
    }
}