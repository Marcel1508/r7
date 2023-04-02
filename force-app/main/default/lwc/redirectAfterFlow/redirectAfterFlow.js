import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { LightningElement, api, wire, track } from "lwc";
import communityId from "@salesforce/community/Id";

export default class RedirectAfterFlow extends NavigationMixin(
  LightningElement
) {
  community = communityId;
  sfdcBaseURL;
  renderedCallback() {
    this.sfdcBaseURL = window.location.origin;
        setTimeout(()=>{
          this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: "/promocash/s"
            }
          });
     },2000);
  }
}