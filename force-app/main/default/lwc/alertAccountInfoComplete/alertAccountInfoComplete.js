import { LightningElement, wire, api } from "lwc";
import getAccountInfo from "@salesforce/apex/AccountinfoService.getAccountInfo";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
export default class AlertAccountInfoComplete extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objectApiName;
  parentRecordId;

  showErrorPanel = true;
  needContact = false;
  needAddress = false;
  missingAddress = "";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: ["Account.Name"]
  })
  getaccountRecord({ data, error }) {
    if (showDebug) { console.log ("******* accountRecord => ", data, error); }
    if (data) {
      this.getAccount();
    } else if (error) {
      console.error("ERROR => ", JSON.stringify(error)); // handle error properly
    }
  }

  connectedCallback() {
    if (showDebug) { console.log ("recordId: " + this.recordId); }
    if (showDebug) { console.log ("objectApiName: " + this.objectApiName); }
    this.getAccount();
  }

  getAccount() {
    getAccountInfo({ objectId: this.recordId, objectType: this.objectApiName })
      .then(res => {
        if (showDebug) { console.log ("res: " + JSON.stringify(res)); }

        this.parentRecordId = res.Id;
        if (showDebug) { console.log ("parentRecordId: " + this.parentRecordId); }

        var hasContact = true;
        var hasShippingAddress = false;
        var hasBillingAddress = false;

        if (res.Contacts == undefined) {
          hasContact = false;
        }

        if (res.ContactPointAddresses != undefined) {
          res.ContactPointAddresses.forEach(element => {
            if (element.AddressType == "Billing") {
              hasBillingAddress = true;
            } else if (element.AddressType == "Shipping") {
              hasShippingAddress = true;
            }
          });
        }

        if (hasContact && hasShippingAddress && hasBillingAddress) {
          this.showErrorPanel = false;
          this.needContact = false;
          this.needAddress = false;
        } else {
          this.showErrorPanel = true;
          this.needContact = !hasContact;

          if (!hasShippingAddress) {
            this.needAddress = true;
            this.missingAddress = "d'expédition";
          }
          if (!hasBillingAddress) {
            this.needAddress = true;
            if (hasShippingAddress) this.missingAddress = "de facturation";
            else this.missingAddress += " et de facturation";
          }
        }
      })
      .catch(err => {
        if (showDebug) { console.log ("err: " + JSON.stringify(err)); }
      });
  }

  redirectToContactCreation() {
    if (showDebug) { console.log ("Click"); }
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Contact",
        actionName: "new"
      },
      state: {
        nooverride: "1",
        defaultFieldValues: "AccountId=" + this.parentRecordId
      }
    });
  }

  redirectToAddressCreation() {
    if (showDebug) { console.log ("Click"); }
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "ContactPointAddress",
        actionName: "new"
      },
      state: {
        nooverride: "1",
        defaultFieldValues: "ParentId=" + this.parentRecordId
      }
    });
  }
}