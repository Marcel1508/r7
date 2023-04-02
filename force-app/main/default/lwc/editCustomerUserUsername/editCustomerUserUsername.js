import { LightningElement, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import ID_FIELD from "@salesforce/schema/Contact.Id";
import FIRSTNAME_FIELD from "@salesforce/schema/Contact.FirstName";
import LASTNAME_FIELD from "@salesforce/schema/Contact.LastName";
import EMAIL_FIELD from "@salesforce/schema/Contact.Email";

import isCustomerUserEnabled from "@salesforce/apex/ActivateCustomerUserService.isCustomerUserEnabled";
import getCustomerUser from "@salesforce/apex/ActivateCustomerUserService.getCustomerUser";
import changeUsername from "@salesforce/apex/ActivateCustomerUserService.changeUsername";

import { CurrentPageReference } from "lightning/navigation";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

const fields = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD];

export default class EditCustomerUserUsername extends LightningElement {
  email;
  user;
  state = "edit";
  errorMessage = "";
  successMessage = "";
  showSpinner = false;
  saveLabel = "Valider";

  handleClick() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSave() {
    if (this.saveLabel == "Terminer") {
      this.dispatchEvent(new CloseActionScreenEvent());
    } else if (this.validateFields()) {
      this.changeEmail();
    }
  }

  recordId;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.recordId;
      this.getUser();
    }
  }

  getUser() {
    getCustomerUser({ contactId: this.recordId })
      .then(res => {
        if (showDebug) { console.log ("getCustomerUser Res : " + JSON.stringify(res));}
        this.showSpinner = false;
        if (res == null) {
          this.state = "error";
          this.saveLabel = "Terminer";
          this.errorMessage = "Le contact n'est pas active";
        } else {
          this.user = res;
          this.email = res.Username;
        }
      })
      .catch(err => {
        if (showDebug) { console.log ("getAllMagasinsFromZoneDeChalandise err: ");}
        if (showDebug) { console.log (err);}
        this.showSpinner = false;
      });
  }

  checkIsCustomerUserEnabled() {
    this.showSpinner = true;
    isCustomerUserEnabled({ contactId: this.recordId })
      .then(res => {
        if (showDebug) { console.log ("Res : " + res);}
        this.showSpinner = false;
        if (res == true) {
          this.state = "error";
          this.saveLabel = "Terminer";
          this.errorMessage = "L'utilisateur est déja active";
        }
      })
      .catch(err => {
        if (showDebug) { console.log ("getAllMagasinsFromZoneDeChalandise err: ");}
        if (showDebug) { console.log (err);}
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

  changeEmail() {
    this.showSpinner = true;
    changeUsername({
      userId: this.user.Id,
      email: this.email
    })
      .then(res => {
        if (res.isSuccess == false) {
          this.errorMessage =
            "Erreur lors de la mise à jour de l'utilisateur. Veuillez contacter un administrateur.";
          this.state = "error";
          this.saveLabel = "Terminer";
        } else {
          this.successMessage = "L'utilisateur a bien été mise à jour.";
          this.state = "success";
          this.saveLabel = "Terminer";
        }
        this.showSpinner = false;
      })
      .catch(error => {
        if (showDebug) { console.log ("changeUsername catch Error ");}
        if (showDebug) { console.log (error);}
        this.errorMessage =
          "Erreur lors de la mise à jour de l'utilisateur. Veuillez contacter un administrateur.";
        this.state = "error";
        this.saveLabel = "Terminer";
        this.showSpinner = false;
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