import { LightningElement, track, wire, api } from 'lwc';
import PDPchoice from '@salesforce/resourceUrl/PDPChoice';
import { fireEvent } from 'c/pubsubCustom';
import addToCartPromocashQuantity from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity";
import getSimilarProduct from "@salesforce/apex/B2BGetInfoCustom.getSimilarProduct";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

/**
 * An organized display of product information.
 * 
 * @fires ProductDetailsDisplay#addtocart
 */

export default class addToCartModalChoice extends LightningElement {

    choice1 = PDPchoice + '/PDPchoice/Choice1.svg';
    choice2 = PDPchoice + '/PDPchoice/Choice2.svg';
    choice3 = PDPchoice + '/PDPchoice/Choice3.svg';
    
    @api productid;
    @api communityid;
    @api effectiveaccountid;
    @api quantityinstock;
    @api quantity;
    @api thumbnailurl;     
	@api state;
    @api parentis;

    hasOpmsSPOverZero = false;

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


    listOPMs;

	@api showModal;

	constructor() {
		super();
		this.showModal = false;
		}

	closeModalChoice(){
		this.dispatchEvent(new CustomEvent('close'));
	    }

	get getRest(){
		if(this.parentis != 'cart'){console.log('parentis '+this.parentis);
		    console.log(this.quantityinstock);
			return `${parseInt(this.quantity) - parseInt(this.quantityinstock)}` ;
			
		}else{
			return this.quantity ;
		}
		
	}
	@track modalSubstitution = false;

	openModalSubstitution(){
		this.modalSubstitution = true;
	}

    closeModalSubstitution(){
        this.modalSubstitution = false;
		this.closeModalChoice();
    }

	closeOnlyModalSubstitution(){
        this.modalSubstitution = false;
    }

	showModalSubstitution(){
        getSimilarProduct({
			productId: this.productid,
			effectiveAccountId: this.effectiveaccountid
        })
		.then((result) => {
			this.listOPMs = result;
            this.hasOpmsSPOverZero = true;
		})
		.catch((e) => {
			if (showDebug) { console.log ('e '+ e); }
		});
		this.openModalSubstitution();
    }

    addAllCart(){
        addToCartPromocashQuantity({
			communityId: this.communityid,
			productId: this.productid,
			quantity: this.quantity,
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
		})
		.finally(() => {
			this.closeModalChoice();
		});

    }

    addQuantityAvailableCart(){
        addToCartPromocashQuantity({
			communityId: this.communityid,
			productId: this.productid,
			quantity: this.quantityinstock,
			effectiveAccountId: this.effectiveaccountid
		})
		.then(result => {
			let stringMsg = 'Tous les produits disponibles ont été ajoutés au panier.';
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
			let stringMsg = 'Erreur lors de l\'ajout du produit au panier. Veuillez contacter un administrateur Salesforce';
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Erreur',
					message: stringMsg,
					variant: "error"
				})
			);
		})
		.finally(()=> {
			this.closeModalChoice();
		});
    }

    handleCartUpdate() {
		if (showDebug) { console.log ('state', this.state); }
        // Update Cart Badge
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
				detail: {state: this.state},
                bubbles: true,
                composed: true
            })
        );
        // Notify any other listeners that the cart items have updated
		if (this.pageRef){
			fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
		}
    }    
}