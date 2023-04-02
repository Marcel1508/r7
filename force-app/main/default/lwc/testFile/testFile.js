import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class TestFile extends NavigationMixin(LightningElement) {
  eea() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s/contactsupport"
      }
    });
  }
}