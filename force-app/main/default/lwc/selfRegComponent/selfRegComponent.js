import { LightningElement, track, wire } from "lwc";
import getAccountbySiret from "@salesforce/apex/selfRegService.getAccountbySiret";
import checkSiret from "@salesforce/apex/SirenService.checkSiret";
import getPostalCode from "@salesforce/apex/selfRegService.getPostalCode";
import getCodePostalById from "@salesforce/apex/selfRegService.getCodePostalById";
import getPickListValues from "@salesforce/apex/selfRegService.getPickListValues";

export default class SelfRegComponent extends LightningElement {
  registreCommerceChecked = false;
  requiredFieldsMissing = false;
  street = "";
  city = "";
  state = "";
  postalCode = "";
  country = "";
  countryLabel = "";
  selectedPostalCodeCountry="";
  @track siret = "";
  isSiretError = false;
  isRegistreCommerceError = false;
  isPostalCodeError = false;
  isCityError = false;
  isAddressError = false;
  isCountryAddressError = false;
  siretErrorMessage = "";
  registreCommerceErrorMessage = "";
  postalCodeErrorMessage = "";
  cityErrorMessage = "";
  addressErrorMessage = "";
  isNewAccount = false;

  loadedAccount;

  step0 = true;
  stepSiretExists = false;
  stepSiretDoesntExist = false;

  showSpinner = false;

  typeVoieValues;
  selectedVoie = undefined;

  numVoie = "";
  typeVoie = "";
  nomVoie = "";
  initialized = false;
  typeVoieTypingValue = "";
  nextButtonClicked = false;
  picklistValues;
  selectedCountry;
  codes_postaux;
  selectedPostalCode;
  selectedPostalCodeId;

  connectedCallback() {
    console.log("Debut connected callback");
    getPickListValues({
      objApiName: "ContactPointAddress",
      fieldName: "Pays__c"
    })
      .then(data => {
        this.picklistValues = data;
        //Init default value
        this.country = 'FR';
        this.countryLabel = 'FRANCE';
        this.selectedCountry = this.picklistValues.find(
          el => el.value == this.country
        );
        console.log("FIN getPickListValues");
      })
      .catch(error => {
        console.log("role error");
        console.log(error);
        this.displayError(error);
      });
  }

  renderedCallback() {
    console.log("rendered callbak");
    if (this.typeVoieValues !== undefined) {
      if (this.nextButtonClicked == true) {
        this.initialized = true;
        if (this.template.querySelector("datalist") !== null) {
          let listId = this.template.querySelector("datalist").id;
          this.template
            .querySelector("input[name=input]")
            .setAttribute("list", listId);
          this.nextButtonClicked = false;
        }
      }
    } else {
      getPickListValues({
        objApiName: "ContactPointAddress",
        fieldName: "Type_de_voie__c"
      })
        .then(data => {
          console.log("=====> res");
          this.typeVoieValues = data;
          if (this.initialized) {
            return;
          }
          this.initialized = true;
          let listId = this.template.querySelector("datalist").id;
          console.log("listId: " + JSON.stringify(listId));
          //this.template.querySelector("input[data-id=inputVoie]").setAttribute("list", listId);
          this.template
            .querySelector("input[name=input]")
            .setAttribute("list", listId);
        })
        .catch(error => {
          console.log("role error");
          console.log(error);
          this.displayError(error);
        });
    }
  }

  handleChange(evt) {
    var selectedVoieVar = evt.target.value;
    this.typeVoieTypingValue = selectedVoieVar;
    console.log(this.typeVoieTypingValue);

    this.selectedVoie = this.typeVoieValues.find(
      item => item.label === selectedVoieVar
    );
    console.log("selectedVoieVar; " + JSON.stringify(this.selectedVoie));

    if (this.selectedVoie == undefined) {
      this.showTypeVoieError();
    } else {
      this.typeVoie = this.selectedVoie.value;
      this.typeVoieTypingValue = this.typeVoie;
      this.resetTypeVoieErrorMessages();
    }
  }

  get selectedLabel() {
    if (this.selectedVoie == undefined) return "";
    return this.selectedVoie.label;
  }

  typeVoieKeydown(evt) {
    const element = this.template.querySelector('[data-id="inputVoie"]');

    console.log("typeVoieKeydown: " + element.value);
    var selectedVoieVar = evt.target.value;
    console.log("selectedVoieVar: " + selectedVoieVar);
    this.typeVoieTypingValue = selectedVoieVar;
    console.log("typeVoieKeydown");
  }

  handleRegistreCommerceInputChange() {
    const element = this.template.querySelector(
      '[data-id="checkbox-dataRegistreCommerce"]'
    );
    this.registreCommerceChecked = element.checked;
    if(this.registreCommerceChecked === true) {
      this.siret = '';
    }
    this.resetRegistreCommerceErrorMessages();
    this.resetSiretErrorMessages();
  }

  async handleSubmitClick() {
    this.showSpinner = true;
    this.resetErrorMessages();

    console.log("numVoie: " + this.numVoie);
    console.log("selectedVoie: " + JSON.stringify(this.selectedVoie));
    console.log("nomVoie: " + this.nomVoie);
    console.log("-------------");
    console.log("siret: " + this.siret);
    console.log("code postale: " + this.postalCode);
    console.log("city: " + this.city);
    console.log("country: " + this.country);

    console.log("-------------");
    console.log("registreCommerceChecked: " + this.registreCommerceChecked);

    let isInputsValid = this.checkInputs();

    if (
      this.registreCommerceChecked == true &&
      this.siret == "" &&
      isInputsValid
    ) {
      this.isNewAccount = true;
      this.checkPostalCodeAndCity();
    }
    // CHECK SIRET Field
    if (this.registreCommerceChecked == false && this.siret == "") {
      this.showRegistreCommerceError(
        "Veuillez entrer un SIRET ou bien confirmer l'inscription au registre de commerce en cours"
      );
    }

    if (
      this.registreCommerceChecked == false &&
      this.siret != "" &&
      isInputsValid
    ) {
      if (this.selectedPostalCodeCountry !== this.countryLabel) {
        //Postalcode and city are not correct
        this.showCountryError();
        this.showAddressError("Pays choisi incorrect, le code postal choisi correspond à : " + this.selectedPostalCodeCountry);
        this.isCountryAddressError = true;
      } else {
        await getAccountbySiret({ siret: this.siret })
          .then(res => {
            if (res == null) {
              // SIRET doesn't exist, we need to check if the SIRET is correct
              console.log("res is null");
              checkSiret({ siret: this.siret })
                .then(result => {
                  if (result == true) {
                    // SIRET CODE IS CORRECT,  we need to check if the postal code and city exist (CALL getPostalCode)
                    console.log("new account checkSiret SIRET IS CORRECT: ");
                    this.isNewAccount = true;
                    this.checkPostalCodeAndCity();
                  } else {
                    // SIRET CODE IS NOT CORRECT
                    console.log("checkSiret SIRET IS not CORRECT: ");
                    this.showSiretError("Code SIRET incorrect");
                  }
                })
                .catch(error => {
                  console.log("checkSiret error: " + JSON.stringify(error));
                });
            } else {
              // SIRET Code exists, we need to check if the postal code and city exist (CALL getPostalCode)
              this.loadedAccount = res;
              console.log("siret exists res: " + JSON.stringify(res));

              //pour ce que tu fais juste en bas @marouane tu peux utiliser this.checkPostalCodeAndCity(), j'ai regroupé tous les cas de figure dedans
              //j'ai pas voulu  toucher le code directement, dis moi si c'est bon
              //je pensais faire en gros :
              // if(res == null) { checkSiret() puis this.isNewAccount = true; } else {this.loadedAccount = res;}
              //et ensuite apres le if this.checkPostalCodeAndCity(); pour les deux

              getPostalCode({ postalCode: this.postalCode, city: this.city })
                .then(result => {
                  if (result == null) {
                    //Postalcode and city are not correct
                    this.showPostalCodeError();
                    this.showCityError();
                    this.showAddressError(
                      "Code postal ou bien ville sont incorrects"
                    );
                  } else {
                    ////Postalcode and city are correct, check if Client is "grand compte"
                    this.step0 = false;
                    this.stepSiretExists = true; //Client_grand_compte__c
                    this.nextButtonClicked = true;
                  }
                  console.log("getPostalCode res: " + JSON.stringify(result));
                })
                .catch(err => {
                  console.log("getPostalCode Error: ");
                  console.log(err);
                });
            }
          })
          .catch(err => {
            console.log("err: " + JSON.stringify(err));
          });
      }
    }
    this.showSpinner = false;
    console.log("La suite");
  }

  handlePrevious() {
    this.step0 = true;
    this.stepSiretExists = false;
    this.stepSiretDoesntExist = false;
  }

  handleCountryChange(event) {
    this.country = event.target.value;
    this.selectedCountry = this.picklistValues.find(
      el => el.value == this.country
    );
    this.countryLabel = this.selectedCountry.label;
    console.log("countryLabel: ", this.countryLabel);
    console.log("country: ", this.country);
  }

  genericOnChange(event) {
    this[event.target.name] = event.target.value;
  }

  checkPostalCodeAndCity() {
      if (this.selectedPostalCodeCountry !== this.countryLabel) {
        //Postalcode and city are not correct
        this.showCountryError();
        this.showAddressError("Pays choisi incorrect, le code postal choisi correspond à : " + this.selectedPostalCodeCountry);
        this.isCountryAddressError = true;
      } else {
        ////Postalcode and city are correct, check if client if new, then check if Client is "grand compte"
        if (this.isNewAccount == true) {
          this.step0 = false;
          this.stepSiretDoesntExist = true;
          console.log("selectd country: " + this.country);
        } else if (this.loadedAccount.Client_grand_compte__c == true) {
          //***** Show selRegSiretExistsComponenet STEP (Key account)
          this.step0 = false;
          this.stepSiretExists = true;
        } else {
          //***** Show STEP (not Key account)
          this.step0 = false;
          this.stepSiretExistsNoKeyAccount = true;
        }
      }
      this.nextButtonClicked = true;

    console.log('end: ');
  }

  handleCodesPostauxCHange(event) {
    console.log(event.target.value);

    this.selectedPostalCodeId = event.target.value;
    getCodePostalById({idCodePostal: this.selectedPostalCodeId})
    .then(data => {
      if(data != null) {
        this.selectedPostalCode = data;
        this.city = this.selectedPostalCode.Commune__c;
        this.postalCode = this.selectedPostalCode.Code_postal__c;
        this.selectedPostalCodeCountry = this.selectedPostalCode.Pays__c;
        console.log("city: ", this.city);
        console.log("postalCode: ", this.postalCode);
        console.log("selectedPostalCodeCountry: ", this.selectedPostalCodeCountry);
      }
    })
    .catch(error => {
      console.log("getCodePostalById error");
      console.log(error);
    });
  }

  checkInputs() {
    let validInputs = true;

    if (this.city == "") {
      validInputs = false;
      this.showCityError();
    }
    if (this.numVoie == "") {
      validInputs = false;
      this.showNumVoieError();
    }
    if (this.nomVoie == "") {
      validInputs = false;
      this.showNomVoieError();
    }
    if (!validInputs)
      this.showAddressError("Toutes les valeurs sont obligatoires");
    if (this.selectedVoie == undefined) this.showTypeVoieError();

    if (this.selectedVoie == undefined && validInputs == true) {
      validInputs = false;
      this.showTypeVoieError();
      this.showAddressError("Type de voie incorrect");
    }

    return validInputs;
  }

  handleFileUploadStep() {
    this.step0 = false;
    this.stepTestFileUpload = true;
  }

  showNumVoieError(message) {
    this.template
      .querySelector('[data-id="numVoieElement"]')
      .classList.add("slds-has-error");
  }

  showNomVoieError(message) {
    this.template
      .querySelector('[data-id="nomVoieElement"]')
      .classList.add("slds-has-error");
  }

  showTypeVoieError() {
    this.template
      .querySelector('[data-id="typeVoieElement"]')
      .classList.add("slds-has-error");
  }

  showSiretError(message) {
    this.siretErrorMessage = message;
    this.isSiretError = true;
    this.template
      .querySelector('[data-id="siretElement"]')
      .classList.add("slds-has-error");
  }

  showRegistreCommerceError(message) {
    this.registreCommerceErrorMessage = message;
    this.isRegistreCommerceError = true;
    this.template
      .querySelector('[data-id="registreCommerceElement"]')
      .classList.add("slds-has-error");
  }

  showAddressError(message) {
    this.addressErrorMessage = message;
    this.isAddressError = true;
  }

  showCityError() {
    this.template
      .querySelector('[data-id="cityElement"]')
      .classList.add("slds-has-error");
  }

  showPostalCodeError() {
    this.template
      .querySelector('[data-id="postalCodeElement"]')
      .classList.add("slds-has-error");
  }

  showCountryError() {
    this.template
      .querySelector('[data-id="countryElement"]')
      .classList.add("slds-has-error");
  }

  resetErrorMessages() {
    this.resetSiretErrorMessages();
    this.resetRegistreCommerceErrorMessages();
    this.resetAddress();
  }

  resetSiretErrorMessages() {
    if (this.registreCommerceChecked == false) {
      this.isSiretError = false;
      this.siretErrorMessage = "";
      this.template
        .querySelector('[data-id="siretElement"]')
        .classList.remove("slds-has-error");
    }
  }

  resetRegistreCommerceErrorMessages() {
    this.isRegistreCommerceError = false;
    this.template
      .querySelector('[data-id="registreCommerceElement"]')
      .classList.remove("slds-has-error");
  }

  resetTypeVoieErrorMessages() {
    this.template
      .querySelector('[data-id="typeVoieElement"]')
      .classList.remove("slds-has-error");
  }

  resetAddress() {
    this.isAddressError = false;
    this.isCountryAddressError = false
    this.template
      .querySelector('[data-id="cityElement"]')
      .classList.remove("slds-has-error");
    this.template
      .querySelector('[data-id="postalCodeElement"]')
      .classList.remove("slds-has-error");
    this.template
      .querySelector('[data-id="countryElement"]')
      .classList.remove("slds-has-error");
    this.template
      .querySelector('[data-id="numVoieElement"]')
      .classList.remove("slds-has-error");
    this.template
      .querySelector('[data-id="typeVoieElement"]')
      .classList.remove("slds-has-error");
    this.template
      .querySelector('[data-id="nomVoieElement"]')
      .classList.remove("slds-has-error");
  }
}