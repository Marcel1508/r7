import {
	NavigationMixin,
	CurrentPageReference
} from 'lightning/navigation';
import {
	LightningElement,
	api,
	wire,
	track
} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProduct from "@salesforce/apex/B2BGetInfoCustom.getProduct";
import getProductPrice from "@salesforce/apex/B2BGetInfoCustom.getProductPrice";
import getProductExtraInfo from "@salesforce/apex/B2BGetInfoCustom.getProductExtraInfo";
import getOffreProduitMagasin from "@salesforce/apex/B2BGetInfoCustom.getOffreProduitMagasin";
import checkStockAndEnCours from "@salesforce/apex/B2BGetInfoCustom.checkStockAndEnCours";
import checkProductIsPFT from "@salesforce/apex/B2BGetInfoCustom.checkProductIsPFT";
import checkDisplayingSimilarProductLA from "@salesforce/apex/B2BGetInfoCustom.checkDisplayingSimilarProductLA";
import getSimilarProduct from "@salesforce/apex/B2BGetInfoCustom.getSimilarProduct";
import getQuantityWishlistItem from "@salesforce/apex/B2BGetInfoCustom.getQuantityWishlistItem";
import getPromotions from '@salesforce/apex/B2BPromotionsControllerCustom.getPromotions';
import addProductToList from '@salesforce/apex/B2BCartControllerCustom.addProductToList';
import getDisplayedProductName from "@salesforce/apex/B2BGetInfoCustom.getDisplayedProductName";
import getProductImageURL from '@salesforce/apex/B2BBasePhotoControllerCustom.getProductImageURL';
//images
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
import BANNER_PROMO from "@salesforce/resourceUrl/BannerPromo";
// labels
import URL_default_image from '@salesforce/label/c.URL_default_image';

import { resolve } from 'c/cmsResourceResolverCustom';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
export default class WishlistsDesktopViewItemCustom extends NavigationMixin(LightningElement) {
	@track defaultImage = DEFAULT_IMAGE;
	@track bannerPromo = BANNER_PROMO;
	@api picklistvalues;
	@api productid;
	@api thumbnailurl;
	@api name;
	@api sku;
	@api currencycode;
	@api wishlistitemid;
	@api effectiveaccountid;
	@api communityid;
	@api salesprice;
	@api wishlistid;
	@api realuserid;
	@api buttondisabledaddtocart;

	@track removed = false;
	@track selection;
	@track opmRecordTypeId;

	@wire (getDisplayedProductName,{productId: '$productid'}) DisplayedProductName;

	//type de subsitution for modal
	@api substitution;
	@track quantity;
	@track isPFT = {'data':''};
	@track isDisplayed = {'data':''};
	@track stockAndEnCours = {'data':''};
	@track product = {'data':''};
	@track extraproduct = {'data':''};
	@track opm = {'data':''};
	@track productPrice = {'data':''};
	originalQuantity;
	firstQuantity;

	//called when the component is rendered
	renderedCallback() {
		if (this.opm.data !== undefined) {
			this.opmRecordTypeId = this.opm.data.RecordTypeId;
		};
	}
	

	connectedCallback() {
		if (showDebug) { console.log ('communityid==='+this.communityid+'productId=='+this.productid+'this.effectiveaccountid==='+this.effectiveaccountid);}
		if (showDebug) { console.log ('wishlistid==in item='+this.wishlistid);}
		this.getOriginalQuantity();
		checkProductIsPFT({productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.isPFT.data = result;
		});
		checkStockAndEnCours({productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.stockAndEnCours.data = result;
		});
		getProduct({communityId:this.communityid,productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.product.data = result;
		});
		getProductImageURL({productId: this.productid}).then(result => {
			if (showDebug) { console.log ('++++++++'+result.Product_Image_URL__c);}
			if(result != null && result != undefined){
				this.image = result.Product_Image_URL__c;
				this.alternativeText = result.AlternativeText__c;
				this.imagevignette = result.Product_URL_Vignette__c;
			}
		});
		
		getProductExtraInfo({productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.extraproduct.data = result;
			console.log('$$$$ this.extraproduct.data ' + JSON.stringify(this.extraproduct.data ));
		});
		getOffreProduitMagasin({productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.opm.data = result;
		});
		getProductPrice({communityId: this.communityid,productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.productPrice.data = result;
		});
		checkDisplayingSimilarProductLA({productId : this.productid,effectiveAccountId: this.effectiveaccountid}).then(result => {
			this.isDisplayed.data = result;
		});
	}
	
	getOriginalQuantity(){
		getQuantityWishlistItem({effectiveAccountId: this.effectiveaccountid,wishlistId: this.wishlistid,wishlistItemId: this.wishlistitemid}).then((result) => {
				this.quantity = result;
				this.firstQuantity = this.quantity;
				if (showDebug) { console.log ('firstQuantity'+this.firstQuantity+'result==='+result);}
				
			})
			.catch((e) => {
				if (showDebug) { console.log ('e');}
				if (showDebug) { console.log (e);}
			});
	}

	//returns true if the product defined by the product id is 'en extension de gamme'
	/*@wire(checkProductIsPFT, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid'
	}) isPFT;
	//returns opm.Niveau_de_stock__c + opm.En_cours_de_commande 
	@wire(checkStockAndEnCours, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid'
	}) stockAndEnCours;
	//returns the product, uses Connect API
	@wire(getProduct, {
		communityId: '$communityid',
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid',
	}) product;
	//used to get extra fields 
	//TODO: replace with ConnectAPI function = custom fields to manage only 1 object
	@wire(getProductExtraInfo, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid',
	}) extraproduct;
	//returns the products' opm for this account
	@wire(getOffreProduitMagasin, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid',
	}) opm;
	//connectAPI function used to get other types of prices, prices adjustments, and other extra price information
	@wire(getProductPrice, {
		communityId: '$communityid',
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid',
	}) productPrice;
*/

	//returns a reference to the current page
	@wire(CurrentPageReference)
	pageRef;

	//** Start - Fonctions pour la suggestion produit */
	/*@wire(checkDisplayingSimilarProductLA, {
		productId: "$productid",
		effectiveAccountId: "$effectiveaccountid"
	})
	isDisplayed;*/

	get hasDisplayedData() {
		return this.isDisplayed.data !== undefined;
	}
	get statutOut() {
		if (this.isDisplayed.data == '5') {
			return true
		}
	}
	get statutIndispo() {
		if (this.isDisplayed.data == '4') {
			return true
		}
	}

	@track bShowModal = false;
	listOPMs;

	openModal() {
		// to open modal window set 'bShowModal' track value as true

		if (this.isDisplayed.data == '5') {
			this.substitution = 'permanente';
		};
		if (this.isDisplayed.data == '4') {
			this.substitution = 'temporaire';
		};
		this.bShowModal = true;

		getSimilarProduct({
			productId: this.productid,
			effectiveAccountId: this.effectiveaccountid
		})
			.then((result) => {
				if (showDebug) { console.log (result);}
				this.listOPMs = result;
			})
			.catch((e) => {
				if (showDebug) { console.log ('e');}
				if (showDebug) { console.log (e);}
			});
	}

	closeModal() {
		this.bShowModal = false;
	}

	get hasOpmsSPOverZero() {
		return this.listOPMs != null;
	}
	//** End - Fonctions pour la suggestion produit **/

	/**PROMOTIONS - start */

	@wire(getPromotions, {
		productId: '$productid',
		effectiveAccountId: '$effectiveaccountid',
	}) promotion;

	get hasPromotions() {
		console.log('$$$ promotions = '+ JSON.stringify(this.promotion.data));
		return this.promotion.data != null && this.promotion.data != undefined;
	}

	get prixVentePromotion() {
		return this.promotion.data.Prix_de_vente_promotion__c != null && this.promotion.data.Prix_de_vente_promotion__c !== undefined;
	}
	/**PROMOTIONS - end */


	/**  FUNCTIONS AND EVENTS **/

	/**Event Quantity */
	handleQuanitytChange(e) {
		this.quantity = this.template.querySelector("input[data-my-id=in1]").value;
		if (this.quantity == '' || this.quantity == null || this.quantity == undefined) {
			this.quantity = 1;
		}
	}
	updateQuantity(event){
		if (showDebug) { console.log ('Quantity==='+this.quantity+'originalQuantity==='+this.originalQuantity);}
		this.originalQuantity = this.originalQuantity?this.originalQuantity:this.firstQuantity;
		if(this.originalQuantity && this.quantity && this.quantity != this.originalQuantity){
			addProductToList({
				communityId: this.communityid,
				productId: this.productid,
				wishlistId: this.wishlistid,
				effectiveAccountId: this.effectiveaccountid,
				realUserId: this.realuserid,
				quantity: this.quantity
			}).then(() => {
				this.getOriginalQuantity();
				this.originalQuantity = this.quantity;
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Succès',
						message: 'Ajout à la liste',
						variant: 'success',
						mode: 'dismissable'
					}),
				);
			}).catch(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Erreur',
						message: "Erreur lors de l'ajout",
						variant: 'error',
						mode: 'dismissable'
					})
				);
			});            
		}
	}

	//sends an event to mywishlistscustom to remove this product from the wishlist and refresh the list
	removewishlistitem() {
		//create an array to send with dispatch event to mywishlistcustom
		let itemToRemove = {
			wishlistItemId: this.wishlistitemid,
			eventType: 'removewishlistitem'
		};
		const removeEvent = new CustomEvent('removefromwishlist', {
			detail: itemToRemove
		});
		this.dispatchEvent(removeEvent);
		//hides the tab until the component is refreshed
		this.removed = true;
		/*setTimeout(function() {
			eval("$A.get('e.force:refreshView').fire();");
		},1000);*/
		/*setTimeout(function() {
		window.location.reload();
		}, 1000);*/
		
	}

	//if a product is selected (checkbox), an event is sent with its id to mywishlistscustom to be added or removed to the list of selected products
	multipleselectevent(event) {
		//event.target.id has the folliwing type: id-XXX
		//so we remove everything on the right starting from the "-"
		let productIdX = event.target.id.split('-')[0];

		let multipleSelectIdChecked = [];
		//depending on whether the checkbox is checked or not, sends a different event type
		if (event.target.checked == true) {
			multipleSelectIdChecked = {
				productId: productIdX,
				quantity: this.quantity,
				eventType: 'multipleselectadd'
			};
		} else if (event.target.checked == false) {
			multipleSelectIdChecked = {
				productId: productIdX,
				quantity: this.quantity,
				eventType: 'multipleselectremove'
			};
		}
		const multipleSelectEvent = new CustomEvent('multipleselect', {
			detail: multipleSelectIdChecked
		});
		this.dispatchEvent(multipleSelectEvent);
		
	}

	//NavigationMixin.Navigate: navigate to another page in the application
	//here to the product record page
	navigateToCart(productId) {
		//TODO:  USE BELOW TEMPLATE TO REDIRECT TO CART
	}


	//NavigationMixin.Navigate: navigate to another page in the application
	//activated on click to navigate to current component product using the productid
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

	//serie of gets, pretty explicit

	//check eof for displayable product

	get hasStatusLabel() {
		return this.picklistvalues !== undefined && this.opm.data.Statut__c !== undefined;
	}
	get statutLabel() {
		//here we find the label of the status value using the picklist values array we got from parent component
		let statut = this.picklistvalues.find(item => item.value == this.opm.data.Statut__c).label;

		//client want display other status only for the website
		if (statut == 'out') {
			statut = 'Indisponible';
		}
		if (statut == 'quantité limitée') {
			statut = 'Disponible en quantité limitée';
		}
		//then format the string to uppercase the first letter and have the rest in lowercase
		return statut.charAt(0).toUpperCase() + statut.substring(1).toLowerCase();
	}
	//connect api getproduct returns a default image and it is not null
	get hasProductDefaultImage() {
		//return this.product.data.defaultImage !== undefined && this.product.data.defaultImage != null && this.product.data.defaultImage.url != URL_default_image && this.product.data.defaultImage.title != 'image';
		return this.image !== null && this.image !== undefined && this.image !== '';
	}
	get hasNotProductDefaultImage() {
		return this.product.data.defaultImage.Id;
	}
	get productDefaultImageUrl() {
		//see cmsresourceresolver 
		//return resolve(this.product.data.defaultImage.url);
		return this.image;
	}
	get productDefaultImageAlt() {
		//return this.product.data.defaultImage.alternativeText;
		return this.image.alternativeText;
	}
	get hasProductDefaultImageUrl() {
		//return this.product.data.defaultImage.url !== undefined && this.product.data.defaultImage.url != URL_default_image && this.product.data.defaultImage.title != 'image';
	    return this.image !== null && this.image !== undefined && this.image !== '';
	}
	get hasNullThumbnail() {
		//return this.thumbnailurl.url == null;
		return this.imagevignette == null || this.imagevignette == undefined || this.imagevignette == '';
		
	}
	get hasThumbnail() {
		//return this.thumbnailurl !== undefined && this.thumbnailurl != null && this.product.data.defaultImage.url != URL_default_image && this.product.data.defaultImage.title != 'image';
		return (this.imagevignette !== null && this.imagevignette !== undefined && this.imagevignette !== '');
	}
	get resolvedThumbnailUrl() {
		return resolve(this.thumbnailurl.url);
	}
	get urlIsNull() {
		//return this.product.data.defaultImage.url == null;
		return this.image == null;
	}
	get hasSku() {
		return this.sku != null && this.sku !== undefined;
	}
	get hasSalesPrice() {
		return this.salesprice !== undefined;
	}
	get hasProduct() {
		return this.product !== undefined;
	}
	get hasProductPrice() {
		return this.productPrice !== undefined;
	}
	get hasListPrice() {
		return this.productPrice.listprice !== undefined;
	}
	get hasUnitPrice() {
		return this.productPrice.unitprice !== undefined;
	}
	get hasRefTarifMagasin() {
		return this.opm.data.Ref_tarifaire_magasin__c !== undefined;
	}
	get inStock() {
		return this.stockAndEnCours.data > 0;
	}
	get hasStock() {
		return this.stockAndEnCours.data !== undefined;
	}
	get hasPFT() {
		return this.isPFT.data !== undefined;
	}
	get hasPFTAndStatutOut() {
		return this.isPFT.data == true || this.isDisplayed.data == '5';
	}
	get hasOPM() {
		return this.opm.data !== undefined;
	}
	get isDisabled() {
		return this.opm.data.Statut__c == '1' || this.isPFT.data == true;
	}
	get ifProductStatutGreen() {
		return this.opm.data.Statut__c == '1' || this.opm.data.Statut__c == '3';
	}
	get ifProductStatutOrange() {
		return this.opm.data.Statut__c == '2';
	}
	get ifProductStatutRed() {
		return this.opm.Statut__c == 4 || this.opm.Statut__c == 5 || this.statutLabel == 'Indisponible' || this.statutLabel == 'Indisponible temporairement';
	}
	get hasCodeIFLS() {
		return this.extraproduct.data.Code_IFLS__c != null && this.extraproduct.data.Code_IFLS__c !== undefined;
	}
	get hasOrigines() {
		return this.extraproduct.data.Origines__c != null && this.extraproduct.data.Origines__c !== undefined;
	}
	get hasConditionnement() {
		return this.extraproduct.data.Conditionnement__c != null && this.extraproduct.data.Conditionnement__c !== undefined;
	}
	get hasLabelRouge() {
		return this.extraproduct.data.Labelrouge__c != null && this.extraproduct.data.Labelrouge__c !== undefined;
	}
	get hasABCERTIFIEAGRIBIOvert() {
		return this.extraproduct.data.ABCERTIFIEAGRIBIOvert__c != null && this.extraproduct.data.ABCERTIFIEAGRIBIOvert__c !== undefined;
	}
	get hasEcotaxe() {
		return this.extraproduct.data.Ecotaxe__c != null && this.extraproduct.data.Ecotaxe__c !== undefined && this.extraproduct.data.Ecotaxe__c >0;
	}
	get hasOpms() {
		return this.opm.data != null && this.opm.data != undefined;
	}
	get hasPrixLitre() {
		return this.opm.data.Prix_L__c !== undefined && this.opm.data.Prix_L__c !== null && this.opm.data.Prix_L__c != 0;
	}
	get getPrixLitre() {
		if(this.opm.data == undefined)
		  return undefined;
		return this.opm.data.Prix_L__c;
	}
	get hasPrixKilo() {
		return this.opm.data.Prix_kilo__c !== undefined && this.opm.data.Prix_kilo__c !== null && this.opm.data.Prix_kilo__c != 0;
	}
	get getPrixKilo() {
		if(this.opm.data == undefined)
		  return undefined;
		return this.opm.data.Prix_kilo__c;
	}
	get hasPrixUnite() {
		return this.opm.data.Prix_unite__c !== undefined && this.opm.data.Prix_unite__c !== null && this.opm.data.Prix_unite__c != 0;
	}
	get prixUnite() {
		if(this.opm.data == undefined)
		  return undefined;
		return this.opm.data.Prix_unite__c;
	}
	

	//TODO: ultimately it would be better to us this object to display every information on the product
	//to do that, make sure that variables aren't undefined (or null for some fields) or the whole get won't work properly
	//would be an improvement because it could barry all of the product, prices, and opm fields in a single object
	get displayableProduct() {
		return {
			categoryPath: this.product.data.primaryProductCategoryPath.path.map(
				(category) => ({
					id: category.id,
					name: category.name
				})
			),
			description: this.product.data.fields.Description,
			image: {
				alternativeText: this.product.data.defaultImage.alternativeText,
				url: resolve(this.product.data.defaultImage.url)
			},
			inStock: this.inStock.data === true,
			name: this.product.data.fields.Name,
			price: {
				currency: ((this.productPrice || {}).data || {})
					.currencyIsoCode,
				negotiated: ((this.productPrice || {}).data || {}).unitPrice
			},
			codeIfls: this.product.data.fields.Code_IFLS__c,
			pictos: this.product.data.fields.Picto_front__c,
			codeRayon: this.product.data.fields.Code_Rayon__c,
			libelleRayon: this.product.data.fields.Libelle_Rayon__c,
			customFields: Object.entries(
				this.product.data.fields || Object.create(null)
			)
				.filter(([key]) =>
					(this.customDisplayFields || '').includes(key)
				)
				.map(([key, value]) => ({ name: key, value }))
		};
	}
	//integrate in displayableProduct
	// get displayableOpm() {
	// 	return {
	// 		codeDepartement: this.opm.data.Code_departement__c,
	// 		niveauStock: this.opm.data.Niveau_de_stock__c,
	// 		encours: this.opm.data.En_cours_de_commande__c
	// 	};
	// }
	/*connectedCallback() {
		
	}*/

}