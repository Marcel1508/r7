import { wire, LightningElement, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsubCustom'

import getOffreProduitMagasin from "@salesforce/apex/B2BGetInfoCustom.getOffreProduitMagasin";
import checkStockAndEnCours from "@salesforce/apex/B2BGetInfoCustom.checkStockAndEnCours";
import checkProductIsPFT from "@salesforce/apex/B2BGetInfoCustom.checkProductIsPFT";
import addToCartPromocashQuantity from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity";
import getCartSummaryPromo from '@salesforce/apex/B2BCartControllerCustom.getCartSummaryPromo';
import getCartSummary from '@salesforce/apex/B2BGetInfoCustom.getCartSummary';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

// Event name constants
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class AddToCartWithModalChoice extends LightningElement {
	@api productid;
	@api communityid;
	@api effectiveaccountid;
	@api quantity = 1;
	@api disabled;
    @api ifProductStatutOrange = false;
    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

	@api
	opm;

	@api
	isPFT;

    @api
    stockAndEnCours;

	get parent() {return this.modallaounchedby;}

	get hasOpmStatusAndPFT(){
		if(this.opm !== undefined && this.isPFT !== undefined){
			return this.opm.Statut__c !== undefined;
		}
		else{
			return false;
		}
	}
	get isDisabled(){
		return this.opm.Statut__c  == '4'|| this.opm.Statut__c  == '5'|| this.isPFT == true;
	}

	@api
	setQuantity(qty) {
		this.quantity = qty;
	}

    /** MODAL CHOIX **/

    @track showModal = false;
    openModal(){
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
    }

	addToCartPromocashQuantity() {
		if (showDebug) { console.log ('started'); }
		this.getCartContent()
		.then((result) => {
			let alreadyInCart;
			if (result && result.promoCartItems){
				alreadyInCart = result.promoCartItems.find((item) => item.cartItemResult.cartItem.productId == this.productid);
			}
			if (!alreadyInCart) {
				alreadyInCart = { quantity: 0 };
			}
			
			this.getInStockCount(this.opm.Produit__r.Id).then((instockCount) => {
				
			this.stockAndEnCours= {data : instockCount};
            
			if (((parseInt(this.quantity) + parseInt(alreadyInCart.quantity)) > instockCount) && !this.ifProductStatutOrange) {
				this.openModal();
			}
			else {
				addToCartPromocashQuantity({
					communityId: this.communityid,
					productId: this.productid,
					quantity: this.quantity,
					effectiveAccountId: this.effectiveaccountid
				})
					.then(result => {
						let stringMsg = 'Le produit a été ajouté au panier.';
						this.dispatchEvent(
							new ShowToastEvent({
								title: 'Succès',
								message: stringMsg,
								variant: "success"
							})
						);
						this.handleCartUpdate();
					})
					.catch(error => {
                        this.error = error;
						if (showDebug) { console.log ('errors'); }
						if (showDebug) { console.log (error); }
						let stringMsg = 'Erreur lors de l\'ajout du produit au panier. Veuillez contacter un administrateur Salesforce';
						this.dispatchEvent(
							new ShowToastEvent({
								title: 'Erreur',
								message: stringMsg,
								variant: "error"
							})
						);
					});
			}});
		}).catch((err) => {
			if (showDebug) { console.log ('Error:', err); }
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

	/**
	 * Get cart summary from the server via imperative apex call
	 */
	getCartContent() {
		return new Promise((resolve, reject) => {
			getCartSummary({
				communityId: this.communityid,
				effectiveAccountId: this.effectiveaccountid
			})
			.then((response) => {
				if (showDebug) { console.log (response); }
				return getCartSummaryPromo({
					communityId: this.communityid,
					activeCartOrId: response.cartId,
					effectiveAccountId: this.effectiveaccountid
				});
			})
			.then((result) => {
				resolve(result);
			})
			.catch((err)=> {
				reject(err);
			});
		});
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

}