import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';

import getWishlistSummaries from "@salesforce/apex/B2BGetInfoCustom.getWishlistSummaries";
//import resolveCommunityIdToWebstoreIdPromocash from "@salesforce/apex/B2BGetInfoCustom.resolveCommunityIdToWebstoreIdPromocash";
import {
    refreshApex
} from '@salesforce/apex';

export default class WishlistsDesktopViewContents extends LightningElement {
    @api effectiveaccountid;
    @api communityid;
  //  @track wishlistSummariesUns;
    @track wishlistCountS;
    @track selectedTab;

    @track refreshAfterAction = false;
    @track refreshed = false;
  //  @api refreshwishlists;

  @api removed;

       @api
       get refreshwishlists() {
           return this._refreshwishlists;
       }
       set refreshwishlists(value) {
        this.setAttribute('refreshwishlists', value);
            this._refreshwishlists = value;
            console.log('wishlistDesktopViewContents end set refreshwishlists');
       }

    
    //  connectedCallback() {
    //     console.log('connectedCallback view');
    // }
    // renderedCallback() {
    //     console.log('renderedCallback view');
    // }
          /*
    if(this.refreshwishlists == true){
      //  this.refreshSummaries();

    getWishlistSummaries({
        effectiveAccountId: this.resolvedEffectiveAccountId,
        communityId: this.community
    })
    .then(result => {
        console.log(result);
        console.log('refreshed wishlists no errors');
        const selectedEvent = new CustomEvent('refreshedapex', {
            detail: false
        });
        this.wishlistSummariesUns = data;

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    })
    .catch(error => {
        this.error = error;
        console.log('refreshed wishlists errors');
        console.log(error);
    });
}

}*/


    refreshSummaries() {
        // console.log('wishlistDesktopViewContents refreshSummaries start');
        // console.log('wishlistDesktopViewContents this.refreshwishlists');
        // console.log(this.refreshwishlists);
        // console.log(this.wishlistSummariesUns);
      //  refreshApex(this.wishlistSummariesUns);

      eval("$A.get('e.force:refreshView').fire();");

        // //  refreshApex(this.wishlistSummariesUns);
        // getWishlistSummaries({
        //         effectiveaccountid: this.effectiveaccountid,
        //         communityid: this.communityid
        //     })
        //     .then(result => {
        //         // console.log('wishlistDesktopViewContents refreshed (recalled apex fct) result');
        //         // console.log(result);
        //         this.wishlistSummariesUns = undefined;
        //         // console.log('wishlistDesktopViewContents wishlistSummariesUns set undefined');
        //         this.wishlistSummariesUns = result;
        //         // console.log('wishlistDesktopViewContents wishlistSummariesUns set result');
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         // console.log('wishlistDesktopViewContents wishlistSummariesUns apex error(s)');
        //         console.log(error);
        //     });
            // console.log('wishlistDesktopViewContents wishlistSummariesUns set result before selectevent');

        //     const selectedEvent = new CustomEvent('refreshedapex', {
        //         detail: false
        //     });

        //     // Dispatches the event.
        //     this.dispatchEvent(selectedEvent);
        //     // console.log('wishlistDesktopViewContents wishlistSummariesUns selectevent dispatched');
    }

    refreshSummaries2() {
        // console.log(' wishlistDesktopViewContents refreshSummaries2 start');
        if (this.wishlistSummariesUns.data || this.refreshAfterAction) {
            refreshApex(this.wishlistSummariesUns.data);
        }
        this.refreshwishlists = false;
        // console.log(' wishlistDesktopViewContents refreshSummaries2 end');
    }

/*

    refreshapex(event){
        console.log('wishlistid');
        console.log(event.target.id);
    }

*/

    @wire(getWishlistSummaries, {
        effectiveaccountid: '$effectiveaccountid',
        communityid: '$communityid'
    })
    wishlistSummariesUns;
//     ({
//         error,
//         data
//     }) {
//         if (data) {
//             // console.log('wishlistDesktopViewContents wired wishlistSummariesUns start');
            
//             // console.log('wishlistDesktopViewContents wired wishlistSummariesUns data:');
//             console.log(data);
//        //     let tempArray = [];

//             this.wishlistSummariesUns = data;
//             //    this.webstoreid = resolveCommunityIdToWebstoreIdPromocash();
//             // this.wishlistSummariesUns.summaries.forEach(element => element.handleSave());
//    /*         data.summaries.forEach(function(t) {
//                 let summary = [{
//                     label: t.name,
//                     value: t.name + ' (' + tempArray.productcount + ')',
//                     id: t.id
//                 }];
//                 tempArray.push(summary);

//             });
//             this.wishlistCountS = tempArray;
//             console.log('this.wishlistCountS');
//             console.log(this.wishlistCountS);
// */
//             this.error = undefined;
//         } else if (error) {
//             // console.log('wishlistDesktopViewContents wired wishlistSummariesUns error:');
//             console.log(error);
//             this.error = error;
//             this.wishlistSummariesUns = undefined;
//         }
//         // console.log('wishlistDesktopViewContents wired wishlistSummariesUns data');
//     }

    /*
         resolveCommunityIdToWebstoreIdPromocash() {
            resolveCommunityIdToWebstoreIdPromocash({
                communityid: this.communityid,
            })
                .then(result => {
                    this.webstoreid = result;
                    console.log(result);
                    console.log('no errors');
                })
                .catch(error => {
                    this.error = error;
                    console.log('errors');
                });
        }
    */
    /*
    getNameCount(evt){
        console.log('evt');
        console.log(evt);
        
     //   const found = this.wishlistCountS.find(element => element.id = SummaryId);
     //   return this.wishlistCountS.find(element => element.id = SummaryId);
    }
    */
    get retrievedWishlistSummaries() {
        return this.wishlistSummariesUns.data !== undefined;
    }

    get hasWishlistSummaries() {
        return this.wishlistSummariesUns.data.wishlistCount > 0;
    }

    tabselect(event) {
        console.log('wishlistDesktopViewContents tabselect start');
        console.log('wishlistDesktopViewContents selectedTab:');
        let actualTabId = event.target.id.split('-')[0];

        let tabInfo = {
            oldWishlistTab: this.selectedTab,
            newWishlistTab: actualTabId,
            eventType: 'tabselect'
		};

        console.log('this.selectedTab');
        console.log(this.selectedTab);
        console.log('actualTabId');
        console.log(actualTabId);
        this.selectedTab = actualTabId;
        // Creates the event with the data.
        const tabChangeEvent = new CustomEvent("tabchange", {
            detail: tabInfo
        });

        // Dispatches the event.
        this.dispatchEvent(tabChangeEvent);
        console.log('wishlistDesktopViewContents tabselect end');
    }

    addfullwishlisttocart(event) {
        let wishlistToAdd = event.target.id.split('-')[0];
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('selectedwishlist', {
            detail: wishlistToAdd
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.timeout = setTimeout(function() {
            refreshApex(this.wishlistSummariesUns);        
        }.bind(this), 300);
        this.refreshSummaries();

    }


    addselecteditemstocart(event) {
        /*
        //let wishlistToAdd = event.target.id.slice(0, -2);
        let wishlistToAdd = event.target.id.split('-')[0];
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('selectedwishlist', {
            detail: wishlistToAdd
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        */
            // Creates the event with the data.
        const multipleAddEvent = new CustomEvent("multipleadd", {
            detail: 'Add selected items to cart event recieved'
        });

        // Dispatches the event.
        this.dispatchEvent(multipleAddEvent);
        this.timeout = setTimeout(function() {
            refreshApex(this.wishlistSummariesUns);        
        }.bind(this), 300);
        this.refreshSummaries();

    }

    showListNameUpdateModal(event) {
        // Creates the event with the data.
        const updateEvent = new CustomEvent("updatelistname", {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(updateEvent);
        this.refreshSummaries();

    }
    handlemultipleselect(event){
        // Creates the event with the data.
        const multipleEvent = new CustomEvent("multipleselect", {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(multipleEvent);
        //refreshApex(this.wishlistSummariesUns);                
    }

    handleremovefromwishlist(event){
        // Creates the event with the data.
        const removeEvent = new CustomEvent("removefromwishlist", {
            detail: event.detail
        });

        // Dispatches the event.
        this.dispatchEvent(removeEvent);
        this.timeout = setTimeout(function() {
            refreshApex(this.wishlistSummariesUns);        
        }.bind(this), 300);
        this.refreshSummaries();

    }

}