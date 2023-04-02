import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import getFavWishlistId from "@salesforce/apex/B2BGetInfoCustom.getFavWishlistId";
import getWishlistSummaries from "@salesforce/apex/B2BGetInfoCustom.getWishlistSummaries";
import getWishlistSummariesRefresh from "@salesforce/apex/B2BGetInfoCustom.getWishlistSummariesRefresh";
import removeWishlistItem from "@salesforce/apex/B2BGetInfoCustom.removeWishlistItem";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getWishlistInfosTeleSales from "@salesforce/apex/B2BGetInfoCustom.getWishlistInfosTeleSales";
import getCartSummary from '@salesforce/apex/B2BGetInfoCustom.getCartSummary';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

import {
    getRecord,updateRecord
} from "lightning/uiRecordApi";

import {
    refreshApex
} from '@salesforce/apex';
const FIELDS = ['Account.Name', 'Account.Phone'];

export default class WishlistsDesktopViewContentsCustom extends LightningElement {
    @api effectiveaccountid;
    @api communityid;
    @api realuser;
    @api realuserid;
    @api removed;
    @api refreshtab;

    @track wishlistCountS;
    @track oldSelectedTab;
    @track selectedTab;
    @track selectedTabId;
    @track tabToSelect;
    @track refreshAfterAction = false;
    @track refreshed = false;
    @track lastWishlistId = '';
    @track retrievedWishlistID = '';
    @track CBCB;
    @track LMB;
    @track gotFav = false;
    buttonDisabledAddToCart = false;
    @track wishlistSummariesUns =[];
    @track tabsData =[];
    @track defaultTab;
    @wire(getRecord, { recordId: '$effectiveaccountid', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            if (showDebug) { console.log (5)}
        } else if (data) {
            if (showDebug) { console.log (6)}

        }
    }

    //get wishlist summaries
  /*  @wire(getWishlistSummaries, {
        effectiveaccountid: '$effectiveaccountid',
        communityid: '$communityid'
    })
    wishlistSummariesUns;*/



    fletchWishListSummaries() {
        getWishlistSummariesRefresh({ 
            effectiveaccountid: this.effectiveaccountid,
            communityid: this.communityid
    
         })
            .then((result) => {
                if (showDebug) { console.log ('======result'+JSON.stringify(result))}
                this.wishlistSummariesUns = JSON.parse(JSON.stringify(result));
                this.handlefavNew(this.wishlistSummariesUns)
            })
            .catch((error) => {
            });
    }

   /* @wire(getWishlistSummaries, { 
        effectiveaccountid: '$effectiveaccountid',
        communityid: '$communityid'

     })
wiredGetActivityHistory(value) {
    // Hold on to the provisioned value so we can refresh it later.
    this.wishlistSummar = value;
    // Destructure the provisioned value 
    const { data, error } = value;
    if (data) {  
        this.wishlistSummariesUns = data;
    }
    
}*/



    //potentially called from mywishlistscustom
    //refreshess summaries and calls this.refreshSummaries after a little time to do the action
    @api refreshFromParent() {
        this.fletchWishListSummaries();
           // eval("$A.get('e.force:refreshView').fire();");
    }
    connectedCallback(){
        this.fletchWishListSummaries();
        getCartSummary({
            communityId: this.communityid,
            effectiveAccountId: this.effectiveaccountid
        }).then((result) => {
            if(result.status !=='Active'){
                this.buttonDisabledAddToCart = true;
            }
        })
        .catch((e) => {
            if (showDebug) { console.log ('getCartSummary error : ' + JSON.stringify(e));}
        });
    }

    //get fav wishlist for this account, then sets the fav list as current list if this is not rendered from an action
    //in which case the same tab which was selected before the action is now selected
    renderedCallback() {
        if(this.gotFav == false){
          //  this.handleFav();
        }
        this.gotFav = true;
        if (showDebug) { console.log ('this.realuserid');}
        if (showDebug) { console.log (this.realuserid);}
    }

handlefavNew(data){
    getFavWishlistId({
        effectiveAccountId: this.effectiveaccountid
    })
    .then(result => {
        var summaries =[];
        for(var i=0;i<data.summaries.length;i++){
            var rec ={...data.summaries[i]};
            rec.labelname = this.fromatText(rec.name);
            rec.name = this.fromatText(rec.name);
            if (result && rec.id.includes(result)) {
                rec.labelname = '* ' +rec.labelname;
                 rec.name = '* ' +rec.name;
                 this.defaultTab=rec.id;
            }
            else{
                if(rec.name.startsWith('*')){
                    rec.name = rec.name.replace('*');
                    rec.labelname = rec.labelname.replace('*','')

                }

            }
            summaries.push(rec)
        }
        if (showDebug) { console.log ('summaries==='+JSON.stringify(summaries));}
        summaries.sort((a, b) => (a.name.startsWith('*')) ? -1 : 1);
        this.tabsData=summaries;
    })
    .catch(error => {
        if (showDebug) { console.log (error);}
    });

}

    handleFav(){
        getFavWishlistId({
                effectiveAccountId: this.effectiveaccountid
            })
            .then(result => {
                if (showDebug) { console.log ('result');}
                if (showDebug) { console.log (result);}
                let res = result;
                if (showDebug) { console.log (result)}

                if (this.template.querySelectorAll('lightning-tab') != null) {
                    let lightningTabs = this.template.querySelectorAll('lightning-tab');
                    lightningTabs.forEach(tab => {
                        if (showDebug) { console.log ('tab.dataset');}
                        if (showDebug) { console.log (tab.style);}
                        tab.dataset.tabname = this.fromatText(tab.dataset.tabname);
                        tab.label = this.fromatText(tab.dataset.tabname);
                        if (result && tab.dataset.id.includes(result)) {
                            //tab.style.backgroundColor = "lightgrey";
                            let tabnamex = tab.dataset.tabname;
                            if (showDebug) { console.log ('tab');}
                            if (showDebug) { console.log (tab.dataset.tabname);}
                            tab.dataset.tabname = "* " + tabnamex;
                            tab.label = "* " + tabnamex;
                            res = 'xxx';
                            this.template.querySelector('lightning-tabset').activeTabValue = tab.dataset.id;

                            
                        }
                        else{

                            if(tab.dataset.tabname.startsWith('*')){
                                tab.dataset.tabname = tab.dataset.tabname.replace('*');
                                tab.label = tab.label.replace('*','')

                            }
                        }
                    });
                }
            })
            .catch(error => {
                if (showDebug) { console.log (error);}
            });

    }
    //can be called from parent
    //refreshed data for summaried and in child component viewitems
    @api refreshSummaries() {
        this.template.querySelector("c-wishlists-desktop-view-items-custom").refreshItems();
    }

    fromatText(text){
        var div = document.createElement("div");
        div.innerHTML = text;
        var text = div.textContent || div.innerText || "";
        return text;

    }



    //  connectedCallback() {
    //     if (showDebug) { console.log ('connectedCallback view');
    // }
    // renderedCallback() {
    //     if (showDebug) { console.log ('renderedCallback viewcontents');
    //    // if()
    //     this.tabToSelect = this.wishlistSummariesUns.data.displayedList.summary.id;

    // }

    //onactive tab event
    //under construction, sets the current tab or saves it
    //also gets the real user, in case a change is done if user is acting for another one
    tabselect(event) {
        if (showDebug) { console.log (event.target.id);}
        if (showDebug) { console.log ('wishlistDesktopViewContents selectedTab:');}
        let actualTabId = event.target.id.split('-')[0];

        let tabInfo = {
            oldWishlistTab: this.selectedTab,
            newWishlistTab: actualTabId,
            oldTabId: this.selectedTabId,
            newTabId: event.target.id,
            eventType: 'tabselect'
        };

        this.oldSelectedTab = this.selectedTab;
        this.selectedTab = event.target.id;
        this.selectedTabId = actualTabId;
        //this.CBCB = undefined;
        //this.LMB = undefined;
        if (showDebug) { console.log ('Selected Tab Id'+this.selectedTabId);}
        getWishlistInfosTeleSales({
                wishlistId: this.selectedTabId
            })
            .then(result => {
                let cblm = result;
                if (showDebug) { console.log ('cblm');}
                if (showDebug) { console.log (result);}
                this.CBCB = cblm.split(',')[0];
                this.LMB = cblm.split(',')[1];
                if (showDebug) { console.log (this.LMB+' hasLMB===='+this.hasLMB+'LMBNotNull=='+this.LMBNotNull);}
            })
            .catch(error => {
                if (showDebug) { console.log (error);}
            });
		this.fletchWishListSummaries();
        // Creates the event with the data.
        const tabChangeEvent = new CustomEvent("tabchange", {
            detail: tabInfo
        });

        // Dispatches the event.
        this.dispatchEvent(tabChangeEvent);
        if (showDebug) { console.log ('wishlistDesktopViewContents tabselect end');}
    }


    //dispatches event if user wants to add the full wishlist to the cart
    //TODO: REPLACE WITH PUBSUB SYSTEM
    addfullwishlisttocart(event) {
        //get only the id from the tab
        let wishlistToAdd = event.target.id.split('-')[0];
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('selectedwishlist', {
            detail: wishlistToAdd
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        //refresh component after some time
        // chandu
       /* setTimeout(function() {
            refreshApex(this.wishlistSummar); 
            this.refreshSummaries();
        }.bind(this), 500);*/
    }

    //dispatches event if user wants to add the only the selected items to the cart
    //TODO: REPLACE WITH PUBSUB SYSTEM
    addselecteditemstocart(event) {
        // Creates the event with the data.
        const multipleAddEvent = new CustomEvent("multipleadd", {
            detail: 'Add selected items to cart event recieved'
        });

        // Dispatches the event.
        this.dispatchEvent(multipleAddEvent);
        // chandu
      /*  setTimeout(function() {
            refreshApex(this.wishlistSummar);
            this.refreshSummaries();
        }.bind(this), 500);*/
    }

    //dispatches from child to parent
    //TODO: REPLACE WITH PUBSUB SYSTEM
    showListNameUpdateModal(event) {
        // Creates the event with the data.
        const updateEvent = new CustomEvent("updatelistname", {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(updateEvent);
        // this.refreshSummaries();
        // chandu
       /* setTimeout(function() {
            refreshApex(this.wishlistSummar);
            this.refreshSummaries();
        }.bind(this), 500);*/
    }
    //dispatches from child to parent
    //TODO: REPLACE WITH PUBSUB SYSTEM
    handledeletelist(event) {
        // Creates the event with the data.
        const deleteEvent = new CustomEvent("deletelist", {
            detail: event.detail
        });
        // Dispatches the event.
        this.dispatchEvent(deleteEvent);
        // this.refreshSummaries();
        // chandu
      /*  setTimeout(function() {
            refreshApex(this.wishlistSummar);
            this.refreshSummaries();
        }.bind(this), 500);*/
    }
    //dispatches from child to parent
    //TODO: REPLACE WITH PUBSUB SYSTEM
    handlemultipleselect(event) {
        // Creates the event with the data.
        const multipleEvent = new CustomEvent("multipleselect", {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(multipleEvent);
        //refreshApex(this.wishlistSummariesUns);    
    }
    //dispatches from child to parent
    //TODO: REPLACE WITH PUBSUB SYSTEM
    handleremovefromwishlist(event) {
		if (showDebug) { console.log ('realuserid in wishlistsDesktopViewContentsCustom'+this.realuserid);}
		if (showDebug) { console.log ('realuser in wishlistsDesktopViewContentsCustom'+this.realuser);}
        // Creates the event with the data.
		removeWishlistItem({
                effectiveAccountId: event.detail.effectiveAccountId,
                wishlistId: event.detail.wishlistId,
                communityId: event.detail.communityId,
                wishlistItemId: event.detail.wishlistItemId,
				realUserId : this.realuserid
            })
            .then(result => {
                if (showDebug) { console.log (result);}
				if(result){
					let cblm = result;
						if (showDebug) { console.log ('cblm');}
						if (showDebug) { console.log (result);}
						this.CBCB = cblm.split(',')[0];
						this.LMB = cblm.split(',')[1];
						if (showDebug) { console.log (this.LMB+' hasLMB= after==='+this.hasLMB+'LMBNotNull=='+this.LMBNotNull);}
				}
                if (showDebug) { console.log ('no errors');}
                let stringMsg = 'Le produit a été retiré de la liste.';
				this.fletchWishListSummaries();
                //this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshFromParent();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: stringMsg,
                        variant: "success"
                    })
                );
				//setTimeout(function() {
					//getWishlistInfosTeleSales({wishlistId: this.selectedTabId}).then(result => {
						
					//}).catch(error => { if (showDebug) { console.log (error); });
					//eval("$A.get('e.force:refreshView').fire();");
				//},3000);
				//this.oldTab = event.detail.oldWishlistTab;
				//this.newTab = event.detail.wishlistId;
				//this.template.querySelector("c-wishlists-desktop-view-contents-custom").refreshSummaries();
            })
            .catch(error => {
                this.error = error;
                if (showDebug) { console.log ('errors');}
                if (showDebug) { console.log (error);}
                let stringMsg = 'Erreur lors du retrait du produit de la liste. Veuillez contacter un administrateur Salesforce';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: stringMsg,
                        variant: "error"
                    })
                );
            });
        const removeEvent = new CustomEvent("removefromwishlist", {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(removeEvent);
		if (showDebug) { console.log ('this.selectedTabId in wishlistsDesktopViewContentsCustom before'+this.selectedTabId);}
		if (showDebug) { console.log ('this.this.LMB in wishlistsDesktopViewContentsCustom before'+this.LMB);}
		/*setTimeout(function() {
			
			//eval("$A.get('e.force:refreshView').fire();");
		},2000);*/
		
		
        // chandu
        /*setTimeout(function() {
            refreshApex(this.wishlistSummar);
            this.refreshSummaries();
        }.bind(this), 500);*/
    }

    get retrievedWishlistSummaries() {
        return this.wishlistSummariesUns !== undefined;
    }
    get hasWishlistSummaries() {
        return this.wishlistSummariesUns.wishlistCount > 0;
    }
    get hasDisplayedList() {
        return this.wishlistSummariesUns.displayedList !== undefined;
    }
    get hasCBCB() {
        return this.CBCB !== undefined;
    }
    get CBCBNotNull() {
        return this.CBCB != null && this.CBCB != 'null';
    }
    get hasLMB() {
        return this.LMB !== undefined;
    }
    get LMBNotNull() {
        return this.LMB != null && this.LMB != 'null';
    }

}