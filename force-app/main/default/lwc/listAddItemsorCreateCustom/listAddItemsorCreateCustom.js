import { LightningElement, api, wire,track } from 'lwc';
import UserId from '@salesforce/user/Id';
import CommunityId from '@salesforce/community/Id';
//import getUserinfo from "@salesforce/apex/ListController.getUserinfo";
import getListWhislist from "@salesforce/apex/B2BCartControllerCustom.getListWhislist";
//import AddToList from '@salesforce/apex/B2BGetInfo.addItemToWishlist';
import createsAndAddProductToList from '@salesforce/apex/B2BCartControllerCustom.createsAndAddProductToList';
import addProductToList from '@salesforce/apex/B2BCartControllerCustom.addProductToList';
import createsAndAddToList from '@salesforce/apex/B2BCartControllerCustom.createsAndAddToList';
import addCartToList from '@salesforce/apex/B2BCartControllerCustom.addCartToList';
import getLoggedAsDetails from '@salesforce/apex/B2BGetInfoCustom.getLoggedAsDetails';
import getUserInfo from '@salesforce/apex/B2BCartControllerCustom.getUserInfo';
import USER_ID from "@salesforce/user/Id";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ListAddItemsOrCreate extends LightningElement {
    newListChecked = true;
    existingListChecked = false;
    @api userId = UserId;
    @api communityId = CommunityId;
    accountId;
    @api productId;
    wishlistId;
    error;
    namenewlist;
    @api productList = [];
    @api optionList = [];
    @api quantity;

    showModal = false;

    @api accountId;

    @api cartId;
    userId = USER_ID;

    realname;
    realuserid;
    mode;
    name;
    oneRendered = false;

    renderedCallback(){
        if(this.showModal == true && this.oneRendered == false){
            this.oneRendered = true;
            this.getWishlist();
        }
    }

    setloggedinAs(result2) {
        if (showDebug) { console.log ('result2==in Add Item='+JSON.stringify(result2));}
        this.RRetURL = this.getCookie('RRetURL');
        if (this.RRetURL != null) {
            result2.forEach(line => {
                if (line.Display.includes(name)) {
                    this.realname = line.Field2;
                    if (showDebug) { console.log ('line.Field2 : '+line.Field2);}
                    if (showDebug) { console.log ('realname : '+this.realname);}
                    this.realuserid = line.CreatedById;
                    if (showDebug) { console.log ('realname : '+this.realuserid);}
                }
            });
        } else {
            if (showDebug) { console.log ('Regular session WISHLIST');}
            this.realname = 'Regular Session';
        }
    }

    getLoggedAsDetails() {
        let loggedinAsvalue = sessionStorage.getItem('loggedinAsData');
        if(loggedinAsvalue) {
            let data = JSON.parse(loggedinAsvalue);
            this.setloggedinAs(data);
        } else {
            getLoggedAsDetails({externalUserName:"$name"}).then((data) => {
                if(data) {
                    this.setloggedinAs(data);
                    sessionStorage.setItem('loggedinAsData', JSON.stringify(data));
                }
            }).catch((error) => {
                window.console.group('%c IsLoggedInAs Error', 'background: #ff0000; color: #ffffff');
                window.console.log('status:'+error.status);
                window.console.log('exceptionType:'+error.body.exceptionType);
                window.console.log('message:'+error.body.message);
                window.console.log('stackTrace:'+error.body.stackTrace);
                window.console.groupEnd();
                this.error = error;
                this.show = undefined;
            });
        }
    }

	connectedCallback() {
		if (showDebug) { console.log ('Quantity===='+this.quantity);}
		if (showDebug) { console.log ('USER_ID==='+USER_ID);}

        let loggedinAsName = sessionStorage.getItem('loggedinAsName');
        if(loggedinAsName) {
            this.name = loggedinAsName;
            this.getLoggedAsDetails();
        } else {
            getUserInfo({userId: USER_ID}).then(res => {
                if(res) {
                    this.name = res.Name;
                    sessionStorage.setItem('loggedinAsName', this.name);
                    this.getLoggedAsDetails();
                }
            });
        }
	}
    
    getCookie(name) {
        var cookieString = "; " + document.cookie;
        var parts = cookieString.split("; " + name + "=");
        if (parts.length === 2) {
            return parts.pop().split(";").shift();
        }
        return null;
    }
    
    optionsWishlist = [];
  
    getWishlist(){
        console.log ('result get  this.accountId ',  this.accountId );
        getListWhislist({
            accountId: this.accountId 
        }).then((result)=>{
            if (showDebug) { console.log ('result get list', result);}
            var returnOptions = [];
            if(result){
                result.forEach(ele =>{
                returnOptions.push({label:ele.Name , value:ele.Id});
                });
            this.optionsWishlist = returnOptions;
            }
        }).catch((error)=>{
            if (showDebug) { console.log ('Erreur lors de la récupération des listes');}
            if (showDebug) { console.log (error);}
        });
    } 

    set showModal(value) {
        this.setAttribute('showModal', value);
    }

    get hasResults() {
        return (this.listwishlist.data.length > 0);
    }    

    get disableContinueButton(){
        if(this.mode==="new" && this.namenewlist != undefined && this.namenewlist != "")
            return false;
        if(this.mode==="existing" && this.wishlistId != undefined)
            return false;
       return true;
    }

    handleWishListChange(event) {
        this.wishlistId = event.target.value;
        this.newListChecked = false;
        this.existingListChecked = true;
        this.mode = 'existing';
    }
    handleNomNewList(event) {
        this.namenewlist = event.target.value;
        this.newListChecked = true;
        this.existingListChecked = false;
        this.mode = 'new';
    }

    selectRadio(event) {
        this.mode=event.target.value;
        this.newListChecked = this.mode === 'new';
        this.existingListChecked = this.mode === 'existing';
    }

    @api
    initDefaultValues(lastCategoryName) {
        this.getWishlist();
        this.mode = 'new';
        this.namenewlist = lastCategoryName;
        this.newListChecked = true;
        this.existingListChecked = false;
        this.wishlistId = undefined;
        this.showModal = true;
    }

    onclickClose(event) {
        this.showModal = false;
    }

    handlePositive(){
		if (showDebug) { console.log ('this.quantity in handlePositive==='+this.quantity+'this.mode===='+this.mode);}
        if(this.mode==="new"){
            if(this.cartId == undefined || this.cartId == null){
                createsAndAddProductToList({
                    communityId: this.communityId,
                    productId: this.productId,
                    wishlistName: this.namenewlist,
                    effectiveAccountId: this.accountId,
                    realUserId: this.realuserid,
                    quantity: this.quantity
                }).then(() => {;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Succès',
                            message: 'Création de la nouvelle liste',
                            variant: 'success',
                            mode: 'dismissable'
                        }),
                    );
                    this.onclickClose();
                    this.dispatchEvent(new CustomEvent('closemodal'));
					if (showDebug) { console.log ('this.realuserid===='+this.realuserid);}
					/*setTimeout(function() {
						window.location.reload();
					}, 1000);*/
                }).catch(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erreur',
                            message: "Erreur lors de la création. Contactez votre administrateur Salesforce ou vérifiez que vous n'avez pas atteint la limite de 10 listes",
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                });
            } else {
                //Add cart to new list
                createsAndAddToList({
                    communityId: this.communityId,
                    cartId: this.cartId,
                    wishlistName: this.namenewlist,
                    effectiveAccountId: this.accountId,
                    realUserId: this.realuserid
                }).then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Succès',
                            message: 'Tous vos produits ont été ajoutés à la liste',
                            variant: 'success',
                            mode: 'dismissable'
                        }),
                    );
                    this.onclickClose();
                    this.dispatchEvent(new CustomEvent('closemodal'));
					if (showDebug) { console.log ('this.realuserid===='+this.realuserid);}
                }).catch(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erreur',
                            message: "Erreur lors de la création. Contactez votre administrateur Salesforce ou vérifiez que vous n'avez pas atteint la limite de 10 listes",
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                });
            }
        }
        else if(this.mode==="existing"){
            if(this.cartId == undefined || this.cartId == null){
                addProductToList({
                    communityId: this.communityId,
                    productId: this.productId,
                    wishlistId: this.wishlistId,
                    effectiveAccountId: this.accountId,
                    realUserId: this.realuserid,
                    quantity: this.quantity
                }).then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Succès',
                            message: 'Ajout à la liste',
                            variant: 'success',
                            mode: 'dismissable'
                        }),
                    );
                    this.onclickClose();
                    this.dispatchEvent(new CustomEvent('closemodal'));
					if (showDebug) { console.log ('this.realuserid===='+this.realuserid);}
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
            } else {
                //Add cart to existing list
                addCartToList({
                    communityId: this.communityId,
                    cartId: this.cartId,
                    wishlistId: this.wishlistId,
                    effectiveAccountId: this.accountId,
                    realUserId: this.realuserid
                }).then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Succès',
                            message: 'Tous vos produits ont été ajoutés à la liste',
                            variant: 'success',
                            mode: 'dismissable'
                        }),
                    );
                    this.onclickClose();
                    this.dispatchEvent(new CustomEvent('closemodal'));
					if (showDebug) { console.log ('this.realuserid===='+this.realuserid);}
                }).catch(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erreur',
                            message: "Erreur lors de l'ajout - Contactez votre administateur Salesforce",
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                });
            } 
        }

        let record = {
            fields: {
                Id: this.accountId
            },
        };


    
    }      
}