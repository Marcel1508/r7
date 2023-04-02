import { LightningElement } from "lwc";
import getAccountUsername from '@salesforce/apex/selfRegService.getAccountUsername';
import { NavigationMixin } from 'lightning/navigation';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class ForgotUsernameComponent extends NavigationMixin(LightningElement) {
  step = "homeStep";
  codeCarte = "";
  showSpinner = false;
  usernameResult;
  isUsernameError = false;
  usernameErrorMessage = '';

  handleSubmitClick() {
    this.isUsernameError = false;
      if(this.validateFields()) {
          if (showDebug) { console.log ('valid');}
          this.showSpinner = true;
          getAccountUsername({codeCarte: this.codeCarte})
            .then(res => {
                if (showDebug) { console.log ('res: ' + JSON.stringify(res));}
                if(res.isSuccess == true) {
                    this.usernameResult = res.message;
                    this.step = 'resultStep';
                } else {
                  this.isUsernameError = true;
                  if(res.errorType == 'exception') {
                    this.usernameErrorMessage = 'Erreur lors de la récupération des données';
                  } else {
                    this.usernameErrorMessage = res.message;
                  }
                }
                this.showSpinner = false;
            })
            .catch(err => {
                if (showDebug) { console.log ('res: ' + JSON.stringify(err));}
                this.showSpinner = false;
            })
      }
  }

  onChangeCodeCarte(evt) {
    this.codeCarte = evt.target.value;
  }

  get isHomeStep() {
    return this.step === "homeStep";
  }
  get isResultStep() {
    return this.step === "resultStep";
  }

  handleRetourClick() {
      this.step = 'homeStep';
  }

  handleTerminerClick() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": "/promocash/s"
        }
    });
  }

  validateFields() {
    return [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
        // Return whether all fields up to this point are valid and whether current field is valid
        // reportValidity returns validity and also displays/clear message on element based on validity
        return (validSoFar && field.reportValidity());
    }, true);
}
}