import { LightningElement, api, track, wire } from "lwc";

// We can get our community Id for use in the callout
import communityId from "@salesforce/community/Id";

// Get our base path for navigating to non-named pages
import communityBasePath from "@salesforce/community/basePath";

// Our Apex method will allow us to retrieve the items
//import getConnectNavigationItems from "@salesforce/apex/NavigationMenuController.getConnectNavigationItems";
import getNavigationMenuItems from "@salesforce/apex/NavigationMenuController.getNavigationMenuItems";

// Lightning Navigation Service will allow us to navigate to our target
import { NavigationMixin } from "lightning/navigation";

export default class TileNavigationMenu extends NavigationMixin(LightningElement) {
  @api myMenuName;
  @api classCSS;
  @track menuItems = [];
  @api maxWidth = "200"; // Default to 400px
  communityId = communityId;
  communityBasePath = communityBasePath;
  error;
  baseUrl;
  shortUrl; //used to compare with current URL


  connectedCallback() {
    let urlString = window.location.href;
    this.baseUrl = urlString.substring(0, urlString.indexOf("/s/"));
    this.shortUrl = urlString.substring(urlString.indexOf("/s/")+2, urlString.length+3);
  }

/*  
@wire(getConnectNavigationItems, {
    menuName: "$myMenuName",
    communityId: "$communityId"
  })
*/


  @wire(getNavigationMenuItems, { menuName: "$myMenuName" })
  wiredNavigationItems({ error, data }) {
    if (data) {
      //this.menuItems = data.menuItems;
      //this.menuItems = data;
      this.menuItems= JSON.parse(JSON.stringify(data));
      for(let item of this.menuItems){
        //NLF : on injecte à la volée un classe dans l'item si c'est l'URL courante (ou qu'elle est contenue)
        //item.itemClass='slds-col slds-p-around--small' +  (item.Target==this.shortUrl ?  ' item-active' : '');
        item.itemClass='slds-col slds-p-around--small' +  (item.Target==this.shortUrl.substring(0,item.Target.length) ?  ' item-active' : '');
      }
    } else if (error) {
      this.error = error;
    }
  }

  get contentContainer() {
    return "max-width:" + this.maxWidth + "px;";
  }

  navigateToItem(event) {
    // Get the menu item's label from the target
    let selectedLabel = event.target.label;
    console.log(selectedLabel);
    // Loop through the menu items and get the row of the selected item
    let item = this.menuItems.filter(menuItem => menuItem.Label === selectedLabel)[0];
    console.log(JSON.stringify(item));
    // Distribute the action to the relevant mechanism for navigation
    if (item.Type === "ExternalLink") {
      console.log("external");
      this.navigateToExternalPage(item);
    } else if (item.Type === "InternalLink") {
      console.log("internal");
      this.navigateToInternalPage(item);
    }
  }

  // Open the external link
  navigateToExternalPage(item) {
    const url = item.Target;
    console.log(url);
    if (item.TargetPrefs === "NewWindow") {
      window.open(url, "_blank");
    }else {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: url
        }
      });
    }
  }

  // Open an internal link
  navigateToInternalPage(item) {
    //console.log(item.Target);
    //const url = this.communityBasePath + item.Target;
    //console.log(url);
    //const url2 = this.baseUrl + "/s" + item.Target;
    //console.log(url2);

    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: item.Target
      }
    });
  }
}