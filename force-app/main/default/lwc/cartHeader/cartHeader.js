import { LightningElement,track} from 'lwc';
import executeCancelCartAsyncAction from '@salesforce/apex/B2BCartControllerCustom.executeCancelCartAsyncAction';
import getUserDetails from '@salesforce/apex/B2BCartControllerCustom.getUserDetails';
import deleteDraftOrder from '@salesforce/apex/B2BCartControllerCustom.deleteOrder';
import USER_ID from '@salesforce/user/Id';
import Key from '@salesforce/resourceUrl/Key';
import MonPanier from '@salesforce/resourceUrl/MonPanier';
import PromocashFlowHeader from '@salesforce/resourceUrl/PromocashFlowHeader';




export default class CartHeader extends LightningElement {
	@track Key=Key;
	@track MonPanier = MonPanier;
	@track PromocashFlowHeader=PromocashFlowHeader;
    currentURL;
	baseURL;
	cartURL;
	cartId;
	userId = USER_ID;
	effectiveAccountId;
	@track imageURL;
	connectedCallback(){
		let url = window.location.href;
		if(url){
			let urls = url.split('checkout/');
			this.baseURL = urls[0];
			this.cartId = urls[1];
			this.cartURL = this.baseURL+'cart/'+this.cartId;
		}
		getUserDetails({userId: this.userId}).then((result) => {
			if(result){
				const userRec = result.userRecord;
				const imgURL = result.imageURL;
				if(userRec){
					this.effectiveAccountId = userRec.Contact.AccountId;
				}
				if(imgURL){
					this.imageURL = imgURL;
				}
			}
		});
	}
	navigateToCart(event){
		window.open(this.cartURL, "_self");
	}
	navigateToHome(event){
		executeCancelCartAsyncAction({cartId: this.cartId}).then(result => {
			console.log('SUCCESS');
			deleteDraftOrder({accId: this.effectiveAccountId}).then(result => {
				const cartId = this.cartId;
				this.dispatchEvent(
					new CustomEvent('cartunlockevent', {
						bubbles: true,
						composed: true,
						cancelable: false,
						detail: {
							cartId
						}
					})
				);
				window.open(this.baseURL, "_self");
			});
		});
		
	}
}