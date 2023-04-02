import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { resolve } from 'c/cmsResourceResolverCustom';

//substitution produit
import getSimilarProduct from "@salesforce/apex/B2BGetInfoCustom.getSimilarProduct";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
export default class CartItemsCustomModal extends LightningElement {
    @api productid;
    @api effectiveaccountid;
	@api disabled;
	@api communityid;
	@api cartitemid;
	@api cartid;
	@track listOPMs =[];
	@api subquantity;

    //substitution produit
    //** Start - Fonctions pour la suggestion produit*/	
	@api showModal;
    openModal(){
        this.showModal = true;
    }

    closeModal(){
		this.dispatchEvent(new CustomEvent('close'));
        this.showModal = false;
    }

	renderedCallback(){
		if(this.showModal == true){
			getSimilarProduct({
				productId: this.productid,
				effectiveAccountId: this.effectiveaccountid
			})
			.then((result) => {
				if (showDebug) { console.log ('this.productid', this.productid);}
				if (showDebug) { console.log ('result modal : ', result);}
				this.listOPMs = result;
			})
			.catch((e) => {
				if (showDebug) { console.log ('e');}
				if (showDebug) { console.log (e);}
			});
		}
    }

    get hasOPMs() {
        return this.listOPMs !== undefined;
	}

	get hasOpmsSPOverZero() {
		return this.listOPMs.length > 0;
    }
	//** End - Fonctions pour la suggestion produit **/
    
}