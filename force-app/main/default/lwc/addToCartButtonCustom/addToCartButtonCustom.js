import {
	wire,
	LightningElement,
	api
} from 'lwc';

import getOffreProduitMagasin from "@salesforce/apex/B2BGetInfoCustom.getOffreProduitMagasin";
import addToCartPromocashUnique from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashUnique";
import checkProductIsPFT from "@salesforce/apex/B2BGetInfoCustom.checkProductIsPFT";
import {CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsubCustom';
import addToCartPromocashQuantity from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity";

import {
	ShowToastEvent
} from 'lightning/platformShowToastEvent'
// Event name constants
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class AddToCartButtonCustom extends LightningElement {
	@api productid;
	@api communityid;
	@api effectiveaccountid;
	@api quantity = 1;
	@api disabled;

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;


	@wire(getOffreProduitMagasin, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid',
	}) opm;

	@wire(checkProductIsPFT, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid'
	}) isPFT;

	get hasOpmStatusAndPFT(){
		if(this.opm.data !== undefined && this.isPFT.data !== undefined){
			return this.opm.data.Statut__c !== undefined;
		}
		else{
			return false;
		}
	}
	get isDisabled(){
		return this.opm.data.Statut__c  == '4'|| this.opm.data.Statut__c  == '5'|| this.isPFT.data == true;
	}

	@api
	setQuantity(qty) {
		this.quantity = qty;
	}
	/*get disabledMessage(){
		if(this.opm.data.Statut__c  == '4'|| this.opm.data.Statut__c  == '5'){
			return '';
		}
		else if(this.isPFT.data == true){
			return 'Produit en Extension de Gamme: ';
		}
		return this.opm.data.Statut__c  == '5'|| this.isPFT.data == true;
	}*/

	addToCartPromocashQuantity() {
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
				let stringMsg = 'Erreur lors de l\'ajout du produit au panier. Veuillez contacter un administrateur Salesforce';
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Erreur',
						message: stringMsg,
						variant: "error"
					})
				);

			});
	}

	addToCartPromocashUnique() {
		addToCartPromocashUnique({
				productId: this.productid,
				effectiveAccountId: this.effectiveaccountid,
				communityId: this.communityid
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
				let stringMsg = 'Erreur lors de l\'ajout du produit au panier. Veuillez contacter un administrateur Salesforce';
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