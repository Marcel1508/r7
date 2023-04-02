import { LightningElement, track } from "lwc";
import LoginPicture from '@salesforce/resourceUrl/LoginPicture';
import PromocashFlowHeader from '@salesforce/resourceUrl/PromocashFlowHeader';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

import doLogin from "@salesforce/apex/CommunityAuthController.doLogin";
import getAccountUsername from "@salesforce/apex/selfRegService.getAccountUsername";
import { NavigationMixin } from 'lightning/navigation';




export default class LoginCustomPage extends NavigationMixin(LightningElement) {
  username;
  password;
  codeClient;
  @track errorCheck;
  @track errorMessage;
  @track loginPicture= LoginPicture ;
  @track PromocashFlowHeader=PromocashFlowHeader;
  createAccountStep = true;
  showSpinner = false;
  isResultStep;
  usernameError = false;
  userNameFound = false;

  connectedCallback() {
    var meta = document.createElement("meta");
    meta.setAttribute("name", "viewport");
    meta.setAttribute("content", "width=device-width, initial-scale=1.0");
    document.getElementsByTagName("head")[0].appendChild(meta);
  }

  handleUserNameChange(event) {
    this.username = event.target.value;
  }

  emailOublie() {
    this.createAccountStep = false;
    if (showDebug) { console.log("createAccountStep: " + this.createAccountStep); }
  }

  redirectToContactSupport() {
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
          "url": "/promocash/s/contactsupport"
      }
    });
  }
  
  redirectToSelfReg() {
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
          "url": "/promocash/s/SelfRegister"
      }
    });
  }

  redirectToForgotPassword() {
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
          "url": "/promocash/s/ForgotPassword"
      }
    });
  }

  handlePasswordChange(event) {
    this.password = event.target.value;
  }

  createAccount() {
    if (showDebug) { console.log("Cliquee"); }
  }

  handleForgotUsername() {
    if (this.codeClient) {
      event.preventDefault();
      this.showSpinner = true;
      getAccountUsername({ codeCarte: this.codeClient })
        .then(res => {
          if (showDebug) { console.log("res: " + JSON.stringify(res)); }
          if (res.isSuccess == true) {
            this.usernameResult = res.message;
            this.usernameError = false;
            this.userNameFound = true;
          } else {
            this.usernameError = true;
            this.userNameFound = false;
            if (res.errorType == "exception") {
              this.usernameErrorMessage =
                "Erreur lors de la récupération des données";
            } else {
              this.usernameErrorMessage = res.message;
            }
          }
          this.showSpinner = false;
        })
        .catch(err => {
          if (showDebug) { console.log("res: " + JSON.stringify(err)); }
          this.showSpinner = false;
        });
    }
  }

  handleLogin(event) {
    if (this.username && this.password) {
      event.preventDefault();

      doLogin({ username: this.username, password: this.password })
        .then(result => {
          if (showDebug) { console.log("result: ", result); }
          window.location.href = result;
        })
        .catch(error => {
          if (showDebug) { console.log("error: ", error); }
          this.error = error;
          this.errorCheck = true;
          this.errorMessage = error.body.message;
        });
    }
  }

  handleCodeClientChange(event) {
    this.codeClient = event.target.value;
  }

  get isResultStep() {
    return this.step === "resultStep";
  }

  get isHomeStep() {
    return this.step === "homeStep";
  }
}