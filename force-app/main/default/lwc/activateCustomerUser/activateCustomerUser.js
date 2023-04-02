import { LightningElement, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import ID_FIELD from "@salesforce/schema/Contact.Id";
import FIRSTNAME_FIELD from "@salesforce/schema/Contact.FirstName";
import LASTNAME_FIELD from "@salesforce/schema/Contact.LastName";
import EMAIL_FIELD from "@salesforce/schema/Contact.Email";

import isCustomerUserEnabled from "@salesforce/apex/ActivateCustomerUserService.isCustomerUserEnabled";
import enablePortalUser from "@salesforce/apex/ActivateCustomerUserService.enablePortalUserForContact";
import { CurrentPageReference } from "lightning/navigation";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

const fields = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD];
export default class ActivateCustomerUser extends LightningElement {
  //@api recordId;
  firstname;
  lastname;
  email;
  state = "edit";
  errorMessage = "";
  successMessage = "";
  showSpinner = false;
  saveLabel = "Valider";

  handleClick() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSave() {
    if(this.saveLabel == "Terminer") {
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    else if (this.validateFields()) {
      this.enableUser();
    }
  }

  /*@wire(getRecord, {
    recordId: "$recordId",
    fields
  })
  contact;*/

  recordId;
  contact;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.recordId;
    }
  }

  executed = false;
  //Call this before init to get recordId
  @wire(getRecord, {
    recordId: "$recordId",
    //Add whatever fields that you may need or just use Id
    fields: fields
  })
  wiredRecord({ error, data }) {
    if (data) {
      this.contact = data;
      this.checkIsCustomerUserEnabled();
      this.firstname = getFieldValue(this.contact, FIRSTNAME_FIELD);
      this.lastname = getFieldValue(this.contact, LASTNAME_FIELD);
      this.email = getFieldValue(this.contact, EMAIL_FIELD);
      
      if (!this.executed) {
        this.executed = true;
      }
    } else if (error) {
      if (showDebug) { console.log ("error : " + error); }
    }
  }

  checkIsCustomerUserEnabled() {
    this.showSpinner = true;
    isCustomerUserEnabled({ contactId: this.recordId })
      .then(res => {
        if (showDebug) { console.log ("Res : " + res); }
        this.showSpinner = false;
        if (res == true) {
          this.state = "error";
          this.saveLabel = "Terminer";
          this.errorMessage = "L'utilisateur est déja active";
        }
      })
      .catch(err => {
        if (showDebug) {
          if (showDebug) { console.log ("getAllMagasinsFromZoneDeChalandise err: ");}
          if (showDebug) { console.log (err); }
        }
        this.showSpinner = false;
      });
  }

  handleLastNameChange(e) {
    this.lastname = e.target.value;
  }

  handleFirstNameChange(e) {
    this.firstname = e.target.value;
  }

  handleEmailChange(e) {
    this.email = e.target.value;
  }

  enableUser() {
    this.showSpinner = true;
    if (showDebug) { console.log ('email : ' + this.email);}
    enablePortalUser({
      contactId: this.recordId,
      email: this.email,
      firstName: this.firstname,
      lastName: this.lastname
    })
      .then(res => {
        if (showDebug) { console.log ("enablePortalUserForContactWithoutEmail result r: ");}
        if (showDebug) { console.log (res);}
        if (res.isSuccess == false) {
          this.errorMessage =
            "Erreur lors de la création de votre utilisateur. Veuillez contacter un administrateur.";
          this.state = "error";
          this.saveLabel = "Terminer"
        } else {
          if (showDebug) { console.log ('Success');}
          this.successMessage = "Le contact a bien été activé.";
          this.state = "success";
          this.saveLabel = "Terminer"
        }
        this.showSpinner = false;
      })
      .catch(err => {
        this.showSpinner = false;
        if (showDebug) { console.log (err);}
        if (showDebug) { console.log (err.body.message) + " enableuser";}
      });
  }

  isUsernameExists() {
    getUserByUsername({
      username: this.username
    })
      .then(result => {
        if (result != null) {
          return true;
        } else {
          return false;
        }
      })
      .catch(error => {
        if (showDebug) { console.log ("Error getUserByUsername");}
        if (showDebug) { console.log (error);}
      });
  }

  get idContact() {
    return this.contact.data.id;
  }

  get successScreen() {
    return this.state == "success";
  }

  get errorScreen() {
    return this.state == "error";
  }

  get editScreen() {
    return this.state == "edit";
  }

  validateFields() {
    return [...this.template.querySelectorAll("lightning-input")].reduce(
      (validSoFar, field) => {
        // Return whether all fields up to this point are valid and whether current field is valid
        // reportValidity returns validity and also displays/clear message on element based on validity
        return validSoFar && field.reportValidity();
      },
      true
    );
  }
}