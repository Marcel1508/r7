import LightningDataTable from "lightning/datatable";
import linkPreview from "./linkPreview.html";
import { LightningElement, api, wire } from 'lwc';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class CustomDatatable extends LightningDataTable {
  static customTypes = {
    filePreview: {
      template: linkPreview,
      typeAttributes: ["anchorText", "versionId"]
    }
  };


  showPreview = false;
  @api label = "";
  @api versionId = "";
  @api fileId = "";

  navigateToFile(event) {
    if (showDebug) { console.log ('Nvigate to file');}
    event.preventDefault();
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        recordIds: this.fileId,
        selectedRecordId: this.fileId
      }
    });
  }

  get fileOrVersionId() {
    return this.versionId || this.fileId;
  }

  handleMouseOver() {
    this.showPreview = true;
  }

  handleMouseOut() {
    this.showPreview = false;
  }
}