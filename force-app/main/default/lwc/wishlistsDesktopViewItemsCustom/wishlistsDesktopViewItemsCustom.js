import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import {
    getRecord
} from "lightning/uiRecordApi";
import {
    getPicklistValuesByRecordType,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import OPM_OBJECT from '@salesforce/schema/Offre_Produit_Magasin__c';
import getWishlistItems from "@salesforce/apex/B2BGetInfoCustom.getWishlistItems";
import updateWishlist from "@salesforce/apex/B2BGetInfoCustom.updateWishlist";
import deleteWishlist from "@salesforce/apex/B2BGetInfoCustom.deleteWishlist";
import setFavWishlistId from "@salesforce/apex/B2BSetInfoCustom.setFavWishlistId";
import getPickListValuesCustom from '@salesforce/apex/B2BGetInfoCustom.getPickListValues';
import findRecords from '@salesforce/apex/B2BGetInfoCustom.findRecords';
import findRecords2 from '@salesforce/apex/CustomLookupController.findRecords2';
import isGerantOrCommercial from '@salesforce/apex/CustomLookupController.isGerantOrCommercial';
import getCartSummary from '@salesforce/apex/B2BGetInfoCustom.getCartSummary';
//added by ajay for partage la liste button funtionality
import getCurrentMagasinActif from '@salesforce/apex/B2BGetInfoCustom.getCurrentMagasinActif';

import getAccessibleAccountsCount from '@salesforce/apex/B2BGetInfoCustom.getAccessibleAccountsCount';
/*commented by ajay-create a new without sharing for share the wishlist*/
//import shareWishlistsWithAccounts from '@salesforce/apex/B2BGetInfoCustom.shareWishlistsWithAccounts';
//import shareWishlistsWithAccounts from '@salesforce/apex/B2BShareWishList.shareWishlistsWithAccounts';    
// import getCurrentSessionInfos from '@salesforce/apex/B2BGetInfoCustom.getCurrentSessionInfos';
import USERNAME from "@salesforce/schema/User.Username";
import NAME from "@salesforce/schema/User.Name";
import PROFILENAME from "@salesforce/schema/User.ProfileName__c";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
export default class WishlistsDesktopViewItemsCustom extends LightningElement {
    @api createdby;
    @api lastmodifiedby;
    @api effectiveaccountid;
    @api wishlistid;
    @api buttonDisabledAddToCart;
    @api communityid;
    @api productcount;
    @api name;
    @api realuser;
    @api realuserid;
    @api magasinactif;
    //used to get labels from picklistvalues
    @track values;
    @track specialisations;
    @track specialisationChoisie;
    @track comptesSpecialisationChoisie;
    @track pickListvaluesByRecordType;
    @track opmDefaultRecordTypeId;
    //used for text inputs
    @track searchTerm = '';
    @track newName = '';
    @track profilename = '';
    @track showShare;
    //used to open and close modals
    @track nameChangeModal = false;
    @track deleteModal = false;
    @track shareModal = false;
    @track selectedTarget = false;
    @track beforeNext = true;
    //list of wishlist items used for display and in the child component
    @track wishlistItems;

    // added by ajay . if we don't get data in findRecords2 then we show error message 
    @track noData=false;

    @track lookupSelectedRecordId; //store the record id of the selected 
    @track shareTypeSelected = 'Compte';
    //get information on the opm object, here we need info on the status field in order to retrieve the default record type id
    @wire(getAccessibleAccountsCount, {})
    accessibleAccountsCount;

    // @wire(getCurrentSessionInfos, {})
    // getCurrentSessionInfos;
    //get info on the user
    // @wire(isGerantOrCommercial, {
    //     userId: this.realuserid
    // })
    // wiredObject({
    //     data,
    //     error
    // }) {
    //     if (data) {
    //         if (showDebug) { console.log ('isgerantstuff');
    //         if (showDebug) { console.log (data);
    //         this.profilename = data;
    //     }
    //     if (error) {
    //         if (showDebug) { console.log ('error.body');
    //         if (showDebug) { console.log (error.body);
    //     }
    // }

    @wire(getObjectInfo, {
        objectApiName: OPM_OBJECT
    })
    wiredObject({
        data,
        error
    }) {
        if (data) {
            this.opmDefaultRecordTypeId = data.defaultRecordTypeId;
        }
        if (error) {
            if (showDebug) { console.log ('Did not find offre_produit_magasin_c default record type id value.'); }
            if (showDebug) { console.log (error.body); }
        }
    }

    //get all picklist values and api names for the child item to use to identify the status label from its value
    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$opmDefaultRecordTypeId',
        objectApiName: OPM_OBJECT
    })
    wiredRecordtypeValues({
        data,
        error
    }) {
        if (data) {
            this.pickListvaluesByRecordType = data.picklistFieldValues.Statut__c.values;
        }
        if (error) {
            if (showDebug) { console.log ('error 2'); }
            if (showDebug) { console.log (error);}
        }
    }
    
    connectedCallback() {
        getPickListValuesCustom({
                objApiName: 'Account',
                fieldName: 'Specialisation__c'
            })
            .then(data => {
                if (showDebug) { console.log ('specialisations');}
                if (showDebug) { console.log (data);}
                this.specialisations = data;
                this.specialisations.sort(this.dynamicSort("label"));
                // Display data with new order
                if (showDebug) { console.log (this.specialisations);}
            })
            .catch(error => {
                if (showDebug) { console.log ('getPickListValues error');}
                if (showDebug) { console.log (error);}
            });
        getCartSummary({
            communityId: this.communityid,
            effectiveAccountId: this.effectiveaccountid
        }).then((result) => {
            if(result.status !=='Active'){
                this.buttonDisabledAddToCart = true;
            }
        })
        .catch((e) => {
            if (showDebug) { console.log ('getCartSummary error ITEMS: ' + JSON.stringify(e));}
        });
        // added by ajay, for partage la liste button to get cureent magsin actif encours
        getCurrentMagasinActif({
            effectiveAccountId: this.effectiveaccountid
        }).then((result) => {
            if(result !==null){
                this.magasinactif = result;
            }
        })
        .catch((e) => {
            if (showDebug) { console.log ('getCurrentMagasinActif error ITEMS: ' + JSON.stringify(e));}
        });
		this.handleWishlistItems();
    }

    renderedCallback(){
        if (showDebug) { console.log ('community id : '+ this.communityid)}
        if (showDebug) { console.log ('this.profilename');}
        if (showDebug) { console.log (this.profilename);}
        if (showDebug) { console.log ('this.realuserid');}
        if (showDebug) { console.log (this.realuserid);}
        isGerantOrCommercial({
            userId: this.realuserid
        })
        .then(data => {
            if (showDebug) { console.log ('data profile name');}
            if (showDebug) { console.log (data);}
            if(data == 'PT1' ||data.includes('Gérant') ||data.includes('Commerciaux') ||data.includes('Directeur(rice) Cash and Carry')||data.includes('Responsable commercial et administratif') ||data.includes('Commercial')){

                if (showDebug) { console.log ('got in');}
                this.profilename = data;
                this.showShare = false;
            }else{
                if (showDebug) { console.log ('got else');}
                this.showShare = true;
            }
            if (showDebug) { console.log ('this.showShare');}
            if (showDebug) { console.log (this.showShare);}
            if (showDebug) { console.log ('this.profilename');}
            if (showDebug) { console.log (this.profilename);}
    
        })
        .catch(error => {
            if (showDebug) { console.log ('data profile error');}
            if (showDebug) { console.log (error);}
            this.showShare = true;
            if (showDebug) { console.log ('this.showShare');}
            if (showDebug) { console.log (this.showShare);}
            if (showDebug) { console.log ('this.profilename');}
            if (showDebug) { console.log (this.profilename);}
    
        });
    }

    get hasShowShare(){
        return this.showShare !== undefined;
    }

    dynamicSort(property) {
        var sortOrder = 1;

        if (property[0] === "-") {
            sortOrder = -1;
            property = property.substr(1);
        }

        return function(a, b) {
            if (sortOrder == -1) {
                return b[property].localeCompare(a[property]);
            } else {
                return a[property].localeCompare(b[property]);
            }
        }
    }

    //get wishlist items and assign them to this.wishlistItem
    /*@wire(getWishlistItems, {
        effectiveAccountId: '$effectiveaccountid',
        wishlistId: '$wishlistid',
        communityId: '$communityid'
    })
    wishlistItemsResult({
        error,
        data
    }) {
        if (data) {
            if (showDebug) { console.log ('ViewItemsCustom: Retrieved Wishlist Items');
            if (showDebug) { console.log (data);
            this.wishlistItems = data;
            this.error = undefined;
        } else if (error) {
            if (showDebug) { console.log ('ViewItemsCustom: Error while retrieving wishlist items.');
            if (showDebug) { console.log (error.body);
            // if (showDebug) { console.log (this.webstoreid);
            this.error = error;
            this.wishlistItems = undefined;
        }
    }*/

    //force get of all updated wishlist items
	handleWishlistItems(){
		getWishlistItems({
            effectiveAccountId: this.effectiveaccountid,
            wishlistId: this.wishlistid,
            communityId: this.communityid
        }).then(result => {
            if (showDebug) { console.log ('ViewItemsCustom refreshed items: ');}
            if (showDebug) { console.log (result);}
			if(result){
				this.error = undefined;
				this.wishlistItems = result;
			}
        }).catch(error => {
            if (showDebug) { console.log ('ViewItemsCustom: error while refreshing items');}
            if (showDebug) { console.log (error);}
			this.wishlistItems = undefined;
            let stringMsg = 'Erreur lors de la mise à jour des items.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: stringMsg + error.body.message,
                    variant: "error"
                })
            );
            this.error = error;
        });
	}
    @api
    refreshItems() {
		this.handleWishlistItems();
        if (showDebug) { console.log ('ViewItemsCustom: got in refresh items');}
        /*getWishlistItems({
            effectiveAccountId: this.effectiveaccountid,
            wishlistId: this.wishlistid,
            communityId: this.communityid
        }).then(result => {
            if (showDebug) { console.log ('ViewItemsCustom refreshed items: ');
            if (showDebug) { console.log (result);
            this.error = undefined;
            this.wishlistItems = undefined;
            this.wishlistItems = result;
        }).catch(error => {
            if (showDebug) { console.log ('ViewItemsCustom: error while refreshing items');
            if (showDebug) { console.log (error);
            let stringMsg = 'Erreur lors de la mise à jour des items.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: stringMsg + error.body.message,
                    variant: "error"
                })
            );
            this.error = error;
        });*/

    }

    addAsFavorite() {
        if (showDebug) { console.log ('this.effectiveaccountid==='+this.effectiveaccountid+'this.wishlistid=='+this.wishlistid);}
        setFavWishlistId({
            effectiveAccountId: this.effectiveaccountid,
            wishlistId: this.wishlistid
        }).then(result => {
            if (showDebug) { console.log ('ViewItemsCustom new fav wishlist success ');}
            if (showDebug) { console.log (result);}
            let stringMsg = 'Liste ajoutée en tant que favorite';
            this.dispatchEvent(new CustomEvent('fav'));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: stringMsg,
                    variant: "success"
                })
            );
            eval("$A.get('e.force:refreshView').fire();");
        }).catch(error => {
            if (showDebug) { console.log ('ViewItemsCustom: error while fav wishlist change');}
            if (showDebug) { console.log (error);}
            let stringMsg = 'Erreur lors de la mise à jour de la liste favorite. Veuillez contacter un administrateur';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: stringMsg + error.body.message,
                    variant: "error"
                })
            );
            this.error = error;
        });
    }

    //TODO: use to sort the array of items
    getGroupedByProperty(data, key) {
        return data.reduce(function(storage, item) {
            let group = item[key];
            storage[group] = storage[group] || [];
            storage[group].push(item);
            return storage;
        }, {});
    }

    //is called when the search term changes in the search bar
    handlesearchinputchange(event) {
        this.searchTerm = event.target.value;
    }

    //is called when the new name unput is updated in the case of a list name change
    handlenamechange(event) {
        this.newName = event.target.value;
    }

    handleValueSelectedLookup(event) {
        if (showDebug) { console.log (event.detail);}
        if (showDebug) { console.log (event.detail.recordId);}
        this.lookupSelectedRecordId = event.detail.recordId;
    }

    handleOnShareTypeChange(event) {
        if (showDebug) { console.log ('event.detail.value');}
        if (showDebug) { console.log ( event.detail.value);}
        if(event.detail.value='Metier'){
            if(this.lookupSelectedRecordId !='' || this.lookupSelectedRecordId!=null){
                this.lookupSelectedRecordId='';
            }
        }
        this.shareTypeSelected = event.detail.value;
        if (showDebug) { console.log ( this.shareTypeSelected); }    
    }

    handleSpecialisationChange(event) {
        if (showDebug) { console.log ('spécialisation choisie');}
        if (showDebug) { console.log (event.target.value);}
        this.specialisationChoisie = event.target.value;
    }     

    /** MODAL MANIPULATIONS **/


    //opens the list sharing modal window
    openShareModal() {
        this.shareModal = true;
    }

    //closes the list sharing modal window
    closeShareModal() {
        this.shareModal = false;
        this.selectedTarget = false;
        this.beforeNext = true;
    }

    //opens the name change modal window
    openNameChangeModal() {
        this.nameChangeModal = true;
    }

    //opens the list deletion modal window
    openDeleteModal() {
        this.deleteModal = true;
    }

    //closes the name change modal window
    closeModal() {
        this.nameChangeModal = false;
    }

    //opens the list deletion modal window
    closeDeleteModal() {
        this.deleteModal = false;
    }

    /** DIRECT FUNCTIONS */

    getCol(matrix, col){
        var column = [];
        for(var i=0; i<matrix.length; i++){
           column.push(matrix[i][col]);
        }
        return column;
     }
    //OBSOLETE FOR NOW, updates the wishlist directly from this component
    //this works, but it is a better practice to call it from mywishlistscustom
    wishlistupdate() {
        updateWishlist({
            effectiveAccountId: this.effectiveaccountid,
            wishlistId: this.wishlistid,
            communityId: this.communityid,
            newName: this.newName
        }).then(result => {
            if (showDebug) { console.log ('ViewItemsCustom direct update successful: ');}
            if (showDebug) { console.log (result);}
            this.error = undefined;
            let stringMsg = 'Le nom de la liste a été mis à jour.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: stringMsg,
                    variant: "success"
                })
            );
        }).catch(error => {
            if (showDebug) { console.log ('ViewItemsCustom: direct update error');}
            if (showDebug) { console.log (error);}
            let stringMsg = 'Erreur lors de la mise à jour du nom de cette liste. Veuillez contacter un administrateur.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: stringMsg,
                    variant: "error"
                })
            );
            this.error = error;
        });
        this.closeModal();
    }

    //OBSOLETE FOR NOW, deletes the wishlist directly from this component
    //this works, but it is a better practice to call it from mywishlistscustom
    deletecurrentwishlist() {
        deleteWishlist({
            wishlistId: this.wishlistid,
            communityId: this.communityid
        }).then(result => {
            if (showDebug) { console.log ('ViewItemsCustom direct delete successful: ');}
            if (showDebug) { console.log (result);}
            this.error = undefined;
            let stringMsg = 'La liste a été supprimée.';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: stringMsg,
                    variant: "success"
                })
            );
        }).catch(error => {
            if (showDebug) { console.log ('ViewItemsCustom: direct delete error');}
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
    }

    //OBSOLETE: check child item checked items
    //TODO: REPLACE WITH PUBSUB SYSTEM
    handlesaddselecteditemstocart(event) {
        // Query the DOM
        const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            )
            // Filter down to checked items
            .filter(element => element.label == "wishlistProduct")
            // Map checked items to their labels
            .map(element => element.id);
        this.selection = id.join(', ');
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('selectedwishlistproducts', {
            detail: selection
        });
    if (showDebug) { console.log ('check selected products  : '+ selection);}
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    //dispatches from child to parent
    //TODO: REPLACE WITH PUBSUB SYSTEM
    handlemultipleselect(event) {
        let multipleSelectDetails = {
            effectiveAccountId: this.effectiveaccountid,
            wishlistId: this.wishlistid,
            communityId: this.communityid,
            productId: event.detail.productId,
            quantity:event.detail.quantity,
            eventType: event.detail.eventType
        };
        const multipleSelectEvent = new CustomEvent('multipleselect', {
            detail: multipleSelectDetails
        });
        this.dispatchEvent(multipleSelectEvent);

    }
    //dispatches from child to parent
    //TODO: REPLACE WITH PUBSUB SYSTEM
    handleremovefromwishlist(event) {
        let itemToRemove = {
            effectiveAccountId: this.effectiveaccountid,
            wishlistId: this.wishlistid,
            communityId: this.communityid,
            wishlistItemId: event.detail.wishlistItemId,
            eventType: 'removewishlistitem'
        };
        const removeEvent = new CustomEvent('removefromwishlist', {
            detail: itemToRemove
        });
        this.dispatchEvent(removeEvent);

    }
    //TODO: REPLACE WITH PUBSUB SYSTEM
    //sends an event to mywishlistscustom to update the current list name
    sendUpdateEvent() {
        if (this.newName != '') {
            let updateDetails = {
                effectiveAccountId: this.effectiveaccountid,
                wishlistId: this.wishlistid,
                communityId: this.communityid,
                newName: this.newName,
                eventType: 'update'
            };
            // Creates the event with the data.
            const modalEvent = new CustomEvent("updatelistname", {
                detail: updateDetails
            });
            // Dispatches the event.
            this.dispatchEvent(modalEvent);
            this.nameChangeModal = false;

        } else {
            alert('Le nouveau nom de la liste ne peut être vide.');
        }
    }

    //TODO: REPLACE WITH PUBSUB SYSTEM
    //sends an event to mywishlistscustom to delete the current list
    sendDeleteEvent() {
        let deleteDetails = {
            wishlistId: this.wishlistid,
            communityId: this.communityid,
            eventType: 'delete'
        };
        // Creates the event with the data.
        const deleteEvent = new CustomEvent("deletelist", {
            detail: deleteDetails
        });
        // Dispatches the event.
        this.dispatchEvent(deleteEvent);
        this.deleteModal = false;
        eval("$A.get('e.force:refreshView').fire();");

    }

    handleNextShare() {
        if (showDebug) { console.log ('beforeNext');}
        if (showDebug) { console.log (this.beforeNext);}
        if (showDebug) { console.log ('this.specialisationChoisieeee');}
        if (showDebug) { console.log (this.specialisationChoisie);}
        if (showDebug) { console.log ('this.shareTypeSelectedeeee');}
        if (showDebug) { console.log (this.shareTypeSelected);}

        if(this.shareTypeSelected!='Compte'){
            findRecords2({
                searchKey: this.specialisationChoisie,
                objectname: 'Account',
                searchInputField: 'Name',
                searchOutputField: 'Specialisation_new__c',
                magaisnActifEnCours: this.magasinactif
            })
            .then(result => {
                this.noData=false;
                if (showDebug) { console.log ('result');}
                if (showDebug) { console.log (result);}
                if(result!=null && result!='')
                this.comptesSpecialisationChoisie = result;
                else
                this.noData=true;
            })
            .catch(error => {
                if (showDebug) { console.log (error);}
            });
        }
        this.beforeNext = false;
        this.selectedTarget = true;
    }

    handlePreviousShare() {
        this.beforeNext = true;
        this.selectedTarget = false;
        if(this.comptesSpecialisationChoisie!=null || this.comptesSpecialisationChoisie!='')
        this.comptesSpecialisationChoisie='';
        if(this.hasLookupSelectedRecordId)
        this.lookupSelectedRecordId='';
        if(this.noData){
            this.noData=false;
        }
    }

    get hasLookupSelectedRecordId() {
        return this.lookupSelectedRecordId !== undefined;
    }

    get hasComptesSpecialisationChoisie() {
        return this.comptesSpecialisationChoisie !== undefined;
    }

    sendShareEvent() {
        if (showDebug) { console.log ('this.specialisationChoisi');}
        if (showDebug) { console.log (this.specialisationChoisie);}
        if (showDebug) { console.log ('this.shareTypeSelected');}
        if (showDebug) { console.log (this.shareTypeSelected);}
        if (showDebug) { console.log ('this.comptesSpecialisationChoisie');}
        if (showDebug) { console.log (this.comptesSpecialisationChoisie);}

        let comptes = []; 
        if(this.shareTypeSelected=='Metier'){
        if (showDebug) { console.log (this.comptesSpecialisationChoisie);}
        this.comptesSpecialisationChoisie.forEach(compte => {
            comptes.push(compte.Id);
        });
        }else if(this.shareTypeSelected=='Compte'){
            comptes.push(this.lookupSelectedRecordId);
        }

        if (showDebug) { console.log ('comptes');}
        if (showDebug) { console.log (comptes);}
        if (showDebug) { console.log ('this.wishlistid');}
        if (showDebug) { console.log (this.wishlistid);}
        if (showDebug) { console.log ('this.realuser');}
        if (showDebug) { console.log (this.realuserid);}
        if (showDebug) { console.log ('this.communityid');}
        if (showDebug) { console.log (this.communityid);}
        if (showDebug) { console.log ('this.effectiveaccountid');}
        if (showDebug) { console.log (this.effectiveaccountid);}

        shareWishlistsWithAccounts({
            wishlistId: this.wishlistid,
            accountIds: comptes,
            realuserId: this.realuserid,
            communityId: this.communityid,
            effectiveAccountId: this.effectiveaccountid
        })
        .then(result => {
            if (showDebug) { console.log ('result');}
            if (showDebug) { console.log (result);}
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Succès',
                    message: 'La liste a été partagée avec le compte choisi',
                    variant: "success"
                })
            );
        })
        .catch(error => {
            if (showDebug) { console.log (error);}
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message: 'Un problème est survenu lors du partage de votre liste. Veuillez contacter un administrateur.',
                    variant: "error"
                })
            );
        });
        this.closeShareModal();
    }

    //TODO: use to manipulate the array of items
    //not functional as is needs some work
    get wishlistItemsGrouped() {
        //TODO: SORT BY NAME OR SMTH ELSE
        // let wishlistItemsGrouped1 = this.getGroupedByProperty(this.wishlistItemsFiltered,'productSummary.name'); 			
        // let wishlistItemsGrouped2 = this.getGroupedByProperty(this.wishlistItems.items,'productSummary.name'); 			
        // let wishlistItemsGrouped3 = this.getGroupedByProperty(this.wishlistItems,'items.productSummary.name'); 			
        // if (showDebug) { console.log ('wishlistItemsGouped'); 
        // if (showDebug) { console.log (JSON.stringify(wishlistItemsGrouped1)); 
        // if (showDebug) { console.log ('wishlistItemsGrouped'); 
        // if (showDebug) { console.log (JSON.stringify(wishlistItemsGrouped2)); 
        // if (showDebug) { console.log ('wishlistItemsGroupedd'); 
        // if (showDebug) { console.log (JSON.stringify(wishlistItemsGrouped3)); 
    }

    //returns the wishlist items filtered b y search term
    //TODO: add other searchable fields 
    get wishlistItemsFiltered() {
        if (this.wishlistItems !== undefined) {
            //put the filtered list in a temp variable 
            //we use directly this.wishlist.items, so that we just need to refresh this.wishlistItems and this stays dynamic
            let filteredList = this.wishlistItems.items.filter((element) => element.productSummary.name.toLowerCase().includes(this.searchTerm.toLowerCase()));

            if (filteredList.length > 0) {
                //if list is not empty, return list
                return this.wishlistItems.items.filter((element) => element.productSummary.name.toLowerCase().includes(this.searchTerm.toLowerCase()));
            } else if (filteredList.length > 0 && this.searchTerm == '') {
                //if list is not empty and the search term is empty, always return the full unfiltered list
                return this.wishlistItems.items;
            }
        } else {
            return undefined;
        }
    }

    get retrievedWishlistItemsFiltered() {
        return this.wishlistItemsFiltered !== undefined;
    }

    get retrievedWishlistItems() {
        return this.wishlistItems !== undefined;
    }

    get hasWishlistItems() {
        return this.wishlistItems.items.length > 0;
    }

    get hasWishlistItemsFiltered() {
        return this.wishlistItemsFiltered.length > 0;
    }

    get concatNameCount() {
        return this.name + ' (' + this.productcount + ')';
    }

    get radioptions() {
        // if (this.accessibleAccountsCount.data == 1) {
        //     return [{
        //         label: 'Partager avec un compte',
        //         value: 'Compte'
        //     }, ];
        // } else {
            return [{
                    label: 'Partager avec un compte',
                    value: 'Compte'
                },
                {
                    label: 'Partager avec une spécialisation métier',
                    value: 'Metier'
                },
            ];
        // }
    }
    get sharewithcompte() {
        return this.shareTypeSelected == 'Compte';
    }

    get sharewithmetier() {
        return this.shareTypeSelected == 'Metier';
    }

    get hasAccessToOtherAccounts() {
        return this.accessibleAccountsCount !== undefined;
    }

    get hasAccessibleAccountsCount() {
        return this.accessibleAccountsCount !== undefined;
    }

    get hasAccessToOtherAccounts() {
        return this.accessibleAccountsCount > 0;
    }

    // get noSpecialisationsFound(){
    //     return this.specialisations.length <= 0;
    // }

    /*
	TODO: fully implement pubsub library
*/

}