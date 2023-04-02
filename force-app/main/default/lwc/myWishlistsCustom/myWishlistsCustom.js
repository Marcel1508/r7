import {
    LightningElement,
    wire,
    api,
    track
} from "lwc";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import {
    getRecord
} from "lightning/uiRecordApi";
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsubCustom';

import { isCartClosed } from 'c/cartUtilsCustom';
import closedCartLabel from '@salesforce/label/c.B2B_Cart_closed_cart';
import createWishlist from "@salesforce/apex/B2BGetInfoCustom.createWishlist";
import updateWishlist from "@salesforce/apex/B2BGetInfoCustom.updateWishlist";
import addWishlistToCartPromocash from "@salesforce/apex/B2BGetInfoCustom.addWishlistToCartPromocash";
import addWishlistToCartPromocash1 from "@salesforce/apex/B2BGetInfoCustom.addWishlistToCartPromocash1";
import addToCartPromocashUnique from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashUnique";
import addToCartPromocashQuantity from "@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity";
import removeWishlistItem from "@salesforce/apex/B2BGetInfoCustom.removeWishlistItem";
import deleteWishlist from "@salesforce/apex/B2BGetInfoCustom.deleteWishlist";
import getLoggedAsDetails from '@salesforce/apex/B2BGetInfoCustom.getLoggedAsDetails';
import getFavWishlistId from '@salesforce/apex/B2BGetInfoCustom.getFavWishlistId';
import getUserInfo from '@salesforce/apex/B2BCartControllerCustom.getUserInfo';
import communityId from '@salesforce/community/Id';
import USER_ID from "@salesforce/user/Id";
import USERNAME from "@salesforce/schema/User.Username";
import NAME from "@salesforce/schema/User.Name";
import PROFILENAME from "@salesforce/schema/User.ProfileName__c";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class MyWishlistsCustom extends LightningElement {

    @track refreshwishlists;
    @track creationName;
    @track oldTab;
    @track newTab;
    @track refreshTab = '';
    @track showSpinner = false;
    @track productsToAdd = [];
    @track username;
    @track name;
    @track realusername;
    @track realname;
    @track realuserid;
    @track listCreationModal = false;
    @track newListName;
    @track selectedwishlistid;
	@track favWire = {'data':''};

    /**
     * Is the cart currently disabled.
     * This is useful to prevent any cart operation for certain cases -
     * For example when checkout is in progress.
     * @type {boolean}
     */
    isCartClosed = false;

    userId = USER_ID;
    /**
     * Gets or sers the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    community = communityId;
	connectedCallback() {
       //Here we explicitly call our Apex method(Imperative call)
	   if (showDebug) { console.log ('effectiveAcocuntId==='+this.effectiveAcocuntId);}
	   if (showDebug) { console.log ('$resolvedEffectiveAccountId==='+this.resolvedEffectiveAccountId);}
	   getFavWishlistId({effectiveAccountId: this.resolvedEffectiveAccountId}).then(result => {
			this.favWire.data = result;
			if (showDebug) { console.log ('this.favWire.data'+JSON.stringify(this.favWire.data));}

            let loggedinAsName = sessionStorage.getItem('loggedinAsName');
            if(loggedinAsName) {
                this.name = loggedinAsName;
                this.getLoggedAsDetails();
            } else {
                getUserInfo({'userId': this.userId}).then(result1 => {
                    if (showDebug) { console.log ('result1==='+JSON.stringify(result1));}
                    if(result1){
                        this.name = result1.Name;
                        sessionStorage.setItem('loggedinAsName', this.name);
                        this.getLoggedAsDetails();
                    }
                });
            }
	   });
	   
   }

    getLoggedAsDetails() {
        let loggedinAsvalue = sessionStorage.getItem('loggedinAsData');
        if(loggedinAsvalue) {
            let data = JSON.parse(loggedinAsvalue);
            this.setloggedinAs(data);
        } else {
            getLoggedAsDetails().then(result2 => {
                if (showDebug) { console.log ('result2==='+JSON.stringify(result2));}
                this.setloggedinAs(result2);
                sessionStorage.setItem('loggedinAsData', JSON.stringify(result2));
            })
        }
    }

    setloggedinAs(result2) {
        this.RRetURL = this.getCookie('RRetURL');
        if (this.RRetURL != null) {
            result2.forEach(line => {
                if (line.Display.includes(this.name)) {
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
            this.realuserid = result1.Id;
        }
    }

    /*@wire(getFavWishlistId, {
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    favWire;*/

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

    //get info on the user
   /* @wire(getRecord, {
        recordId: USER_ID,
        fields: [USERNAME, NAME, PROFILENAME]
    })
    wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (showDebug) { console.log ('logged in user data');
            if (showDebug) { console.log (data);
            this.username = data.fields.Username.value;
            this.name = data.fields.Name.value;
        }
    }*/

    //get info on who is really logged in
    //stolen from isloggedinasbannercustom
    /*@wire(getLoggedAsDetails, {
    })
    prepareData({
        error,
        data
    }) {
        if (data) {
            if (showDebug) { console.log ('data get logged');
            if (showDebug) { console.log (data);
            this.RRetURL = this.getCookie('RRetURL');
            if (this.RRetURL != null) {
                data.forEach(line => {
                    if (line.Display.includes(this.name)) {
                        // this.createdById = line.CreatedById;
                        this.realname = line.Field2;
                        if (showDebug) { console.log ('line.Field2 : '+line.Field2);
                        if (showDebug) { console.log ('realname : '+this.realname);
                        // this.display = line.Display;
                        /*if (showDebug) { console.log ('line');
                        if (showDebug) { console.log (line);
                        if (showDebug) { console.log ('this.realuserid');
                        if (showDebug) { console.log (line.CreatedById);*/
                        /*this.realuserid = line.CreatedById;
                        if (showDebug) { console.log ('realname : '+this.realuserid);
                    }
                });
            } else {
                if (showDebug) { console.log ('Regular session WISHLIST');
                this.realname = 'Regular Session';
            }
        }
        if (error) {
            window.console.log ('WISHLISTstatus:' + error.status);
            window.console.log ('WISHLISTexceptionType:' + error.body.exceptionType);
            window.console.log ('WISHLISTmessage:' + error.body.message);
            window.console.log ('WISHLISTstackTrace:' + error.body.stackTrace);
        }
        if (showDebug) { console.log ('out');
    }*/

    //stolen from isloggedinasbannercustom
    //used for previous function
    getCookie(name) {
        var cookieString = "; " + document.cookie;
        var parts = cookieString.split("; " + name + "=");
        if (parts.length === 2) {
            return parts.pop().split(";").shift();
        }
        return null;
    }

    //refreshes children component 
    refreshChild() {
        //this.refreshTab = this.newTab;
        //calls noth functions from child
        this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
    }

    showListCreationModal(event) {
        this.openModal();
    }

    openModal() {
        this.listCreationModal = true;
    }
    closeModal() {
        this.listCreationModal = false;
    }

    handlenewnamechange(event) {
        if (showDebug) { console.log ('event.target.value');}
        if (showDebug) { console.log (event.target.value);}
        this.creationName = event.target.value;
    }

    //changes the name of a list when event is recieved from child
    handlelistnamechange(event) {
        updateWishlist({
            effectiveAccountId: event.detail.effectiveAccountId,
            wishlistId: event.detail.wishlistId,
            communityId: event.detail.communityId,
            newName: event.detail.newName,
            realUserName: this.realname
        }).then(result => {
            this.error = undefined;
            let stringMsg = 'Le nom de la liste a été mis à jour.';
            this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
            this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: stringMsg,
                    variant: "success"
                })
            );
            eval("$A.get('e.force:refreshView').fire();");

        }).catch(error => {
            let stringMsg = '';
            if (error.body.message !== undefined) {
                stringMsg = error.body.message;
            } else {
                stringMsg = 'Erreur lors de la mise à jour du nom de cette liste. Veuillez contacter un administrateur.';
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: stringMsg,
                    variant: "error"
                })
            );
            this.error = error;
        });
    }
    //deletes a list when event is recieved from child
    handledeletelist(event) {
        deleteWishlist({
            wishlistId: event.detail.wishlistId,
            communityId: event.detail.communityId
        }).then(result => {
            if (showDebug) { console.log ('no error');}
            if (showDebug) { console.log ('result');}
            if (showDebug) { console.log (result);}
            this.error = undefined;
            let stringMsg = 'La liste a été supprimée.';
            this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
            this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: stringMsg,
                    variant: "success"
                })
            );
        }).catch(error => {
            if (showDebug) { console.log ('error');}
            if (showDebug) { console.log (error);}
            let stringMsg = 'Une erreur est survenue lors de la suppression de cette liste. Veuillez contacter un administrateur.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: stringMsg,
                    variant: "error"
                })
            );
            this.error = error;
        });
        this.refreshTab = event.detail.wishlistId;


    }
    //adds a full list to cart when event is recieved from child
    /*handleselectedwishlist(event) {
        this.selectedwishlistid = event.detail;
        if (showDebug) { console.log ('contenu variable event.detail'+event.detail);
        addWishlistToCartPromocash({
                wishlistid: this.selectedwishlistid,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                communityId: this.resolvedCommunityId
            })
            .then(result => {
                if (showDebug) { console.log ('no errors : addwishlisttocart');
                let stringMsg = 'La liste a été ajoutée au panier.';
                this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
                this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: stringMsg,
                        variant: "success"
                    })
                );
                this.handleCartUpdate();
                //window.location.reload();
                eval("$A.get('e.force:refreshView').fire();");

            })
            .catch(error => {
                this.error = error;
                if (showDebug) { console.log ('errors');
                if (showDebug) { console.log (error);
                let stringMsg = 'Erreur lors de l\'ajout des produits de la liste au panier';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: stringMsg,
                        variant: "error"
                    })
                );
            });
            setTimeout(function() {
                this.handleCartUpdate();
            }.bind(this), 300);
    }*/

    handleselectedwishlist(event) {
        this.selectedwishlistid = event.detail;
        if (showDebug) { console.log ('contenu variable event.detail'+event.detail);}
        addWishlistToCartPromocash1({
                wishlistid: this.selectedwishlistid,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                communityId: this.resolvedCommunityId
            })
            .then(result => {
                if (showDebug) { console.log ('no errors : addwishlisttocart');}
                let stringMsg = 'La liste a été ajoutée au panier.';
                this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
                this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: stringMsg,
                        variant: "success"
                    })
                );
                this.handleCartUpdate();
                //window.location.reload();
                eval("$A.get('e.force:refreshView').fire();");

            })
            .catch(error => {
                this.error = error;
                if (showDebug) { console.log ('errors');}
                if (showDebug) { console.log (error);}
                let stringMsg = 'Erreur lors de l\'ajout des produits de la liste au panier';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: stringMsg,
                        variant: "error"
                    })
                );
            });
            setTimeout(function() {
                this.handleCartUpdate();
            }.bind(this), 300);
    }
    
    //creates a list when event is recieved from child
    createWishlist(event) {
        if (showDebug) { console.log ('create list : this.creationName '+this.creationName);}
        if (showDebug) { console.log ('create list : this.resolvedEffective '+this.resolvedEffectiveAccountId);}
        if (showDebug) { console.log ('create list : this.realname '+this.realname);}
        if (showDebug) { console.log ('create list : this.community '+this.resolvedCommunityId);}
        if (showDebug) { console.log ('create list : this.realuserid '+this.realuserid);}
        let createdwishlistid = '';
        createWishlist({
                listname: this.creationName,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                communityId: this.resolvedCommunityId,
                realUserId: this.realuserid?this.realuserid:null,
            })
            .then(result => {
                createdwishlistid = result.Id;
                if (showDebug) { console.log ('result==='+JSON.stringify(result));}
                let stringMsg = 'La liste ' + this.creationName + ' a été créée.';
                this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: stringMsg,
                        variant: "success"
                    })
                );
                this.closeModal();
                eval("$A.get('e.force:refreshView').fire();");

            })
            .catch(error => {
                this.error = error;
                if (showDebug) { console.log ('errors');}
                if (showDebug) { console.log (error);}
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur',
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
        }
    //add a wishlit item id to selected item list when event is recieved from child
    handlemultipleselect(event) {
        if (event.detail.eventType == 'multipleselectadd') {
            let multipleSelectDetails = {
                effectiveAccountId: event.detail.effectiveAccountId,
                wishlistId: event.detail.wishlistId,
                communityId: event.detail.communityId,
                quantity: event.detail.quantity,
                productId: event.detail.productId
            };
            this.productsToAdd.push(multipleSelectDetails);
        } else if (event.detail.eventType == 'multipleselectremove') {
            for (var i = this.productsToAdd.length - 1; i >= 0; i--) {
                if (this.productsToAdd[i].productId === event.detail.productId) {
                    this.productsToAdd.splice(i, 1);
                }
            }
        }
    }
    //adds multiple items to list when event is recieved from child
    handlemultipleadd() {
        let errors = []; 
        for (var i = this.productsToAdd.length - 1; i >= 0; i--) {
            /*addToCartPromocashUnique({
                    productId: this.productsToAdd[i].productId,
                    effectiveAccountId: this.productsToAdd[i].effectiveAccountId,
                    communityId: this.productsToAdd[i].communityId
                })
                .then(result => {
                    if (showDebug) { console.log ('cart item creation result');
                    if (showDebug) { console.log (result);
                    if (showDebug) { console.log ('no errors');
                    let stringMsg = 'Les produits ont été ajoutés au panier.';
                    this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: stringMsg,
                            variant: "success"
                        })
                    );
                    this.handleCartUpdate();
                })
                .catch(error => {
                    this.error = error;
                    if (showDebug) { console.log ('errors');
                    if (showDebug) { console.log (error);
                    errors.add(error);
                });
                */
                addToCartPromocashQuantity({
                communityId: this.productsToAdd[i].communityId,
                productId: this.productsToAdd[i].productId,
                quantity: this.productsToAdd[i].quantity,
                effectiveAccountId: this.productsToAdd[i].effectiveAccountId    
            })
            .then(result => {
                if (showDebug) { console.log ('cart item creation result');}
                if (showDebug) { console.log (result);}
                if (showDebug) { console.log ('no errors');}
                let stringMsg = 'Les produits ont été ajoutés au panier.';
                this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();

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
                if (showDebug) { console.log ('errors');}
                if (showDebug) { console.log (error);}
                errors.add(error);
            });
            
        }
        if(this.error.length > 0){
            let stringMsg = 'Erreur lors de l\'ajout d\'un produit au panier. Veuillez contacter un administrateur Salesforce';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: stringMsg,
                    variant: "error"
                })
            );    
        }
        setTimeout(function() {
            this.handleCartUpdate();
        }.bind(this), 300); 
    }

    handletabselect(event) {
        this.productsToAdd = [];
        this.oldTab = event.detail.oldWishlistTab;
        this.newTab = event.detail.newWishlistTab;
        this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();

    }
    //removes item from list when event is recieved from child
    handleremovefromwishlist(event) {
		if (showDebug) { console.log ('realuserid in myWishlistsCustom'+this.realuserid);}
		if (showDebug) { console.log ('realuser in myWishlistsCustom'+this.realuser);}
       /* removeWishlistItem({
                effectiveAccountId: event.detail.effectiveAccountId,
                wishlistId: event.detail.wishlistId,
                communityId: event.detail.communityId,
                wishlistItemId: event.detail.wishlistItemId,
				realUserId : this.realuserid
            })
            .then(result => {
                if (showDebug) { console.log (result);
                if (showDebug) { console.log ('no errors');
                let stringMsg = 'Le produit a été retiré de la liste.';
                //this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: stringMsg,
                        variant: "success"
                    })
                );
				/*setTimeout(function() {
					eval("$A.get('e.force:refreshView').fire();");
				},3000);*/
				//this.oldTab = event.detail.oldWishlistTab;
				/*this.newTab = event.detail.wishlistId;
				this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();
            })
            .catch(error => {
                this.error = error;
                if (showDebug) { console.log ('errors');
                if (showDebug) { console.log (error);
                let stringMsg = 'Erreur lors du retrait du produit de la liste. Veuillez contacter un administrateur Salesforce';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: stringMsg,
                        variant: "error"
                    })
                );
            });*/
    }
    /**
     * Helper method to handle updates to cart contents by firing
     *  'cartchanged' - To update the cart badge
     *  'cartitemsupdated' - To notify any listeners for cart item updates (Eg. Cart Totals)
     *
     * As of the Winter 21 release, Lightning Message Service (LMS) is not available in B2B Commerce for Lightning.
     * These samples make use of the [pubsub module](https://github.com/developerforce/pubsub).
     * In the future, when LMS is supported in the B2B Commerce for Lightning, we will update these samples to make use of LMS.
     *
     * @fires CartContents#cartchanged
     * @fires CartContents#cartitemsupdated
     *
     * @private
     */
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

    get realNameExists() {
        this.realname !== undefined;
    }

    get hasFavWireData() {
        this.favWire.data !== undefined;
    }

    get favWishlist() {
        if (this.favWire.data !== undefined) {
            this.refreshTab = this.favWire.data;
            return this.favWire.data;
        }
        else{
            return '';
        }
    }
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
    get resolvedCommunityId() {
        //return "001T1000001nGYQIA2";
        const cmomunity = this.community || "";
        let resolved = null;

        if (cmomunity.length > 0 && cmomunity !== "000000000000000") {
            resolved = cmomunity;
        }
        return resolved;
    }

    get labels() {
        return {
            closedCartLabel
        };
    }

}