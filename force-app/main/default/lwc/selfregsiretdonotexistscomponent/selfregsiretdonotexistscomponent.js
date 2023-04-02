import { api, LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// Importing Apex Class method
import saveAccountApex from "@salesforce/apex/selfRegService.saveAccountRecord";
import saveRecordsApex from "@salesforce/apex/selfRegService.saveRecords";
import insertAddress from "@salesforce/apex/selfRegService.insertAddress";
import saveContactApex from "@salesforce/apex/selfRegService.saveContactRecord";
import saveContactPointAddressApex from "@salesforce/apex/selfRegService.saveContactPointAddressRecord";
import enablePortalUserForSingleNewContact from "@salesforce/apex/selfRegService.enablePortalUserForSingleNewContact";
import enablePortalUserForContactWithoutEmail from "@salesforce/apex/selfRegService.enablePortalUserForContactWithoutEmail";
import getPickListValues from "@salesforce/apex/selfRegService.getPickListValues";
import getCodesAPEBis from "@salesforce/apex/selfRegService.getCodesAPEBis";
import getUserByUsername from "@salesforce/apex/selfRegService.getUserByUsername";
import getAllMagasinsFromZoneDeChalandise from "@salesforce/apex/selfRegService.getAllMagasinsFromZoneDeChalandise";
import getZoneChalandise from "@salesforce/apex/selfRegService.getZoneChalandise";
import updatePieceJustificatifFields from "@salesforce/apex/selfRegService.updatePieceJustificatifFields";

// importing to get the object info
import { getObjectInfo } from "lightning/uiObjectInfoApi";
// importing Object schemas
import ACCOUNT_OBJECT from "@salesforce/schema/Account";

// Account fields
import Account_RecordType_FIELD from "@salesforce/schema/Account.RecordTypeId";
import Account_SiretText__c_FIELD from "@salesforce/schema/Account.SiretText__c";
import Account_Name_FIELD from "@salesforce/schema/Account.Name";
import Account_Enseigne_commerciale__c_FIELD from "@salesforce/schema/Account.Enseigne_commerciale__c";
import Account_Date_creation_etablissement__c_FIELD from "@salesforce/schema/Account.Date_creation_etablissement__c";
import Account_Code_APE__c_FIELD from "@salesforce/schema/Account.Code_APE__c";
import Account_En_cours_de_creation__c_FIELD from "@salesforce/schema/Account.En_cours_de_creation_au_reg_du_commerce__c";
import Account_Theme__c_FIELD from "@salesforce/schema/Account.Theme__c";
import Account_Forme_juridique__c_FIELD from "@salesforce/schema/Account.Forme_juridique__c";
import Account_Magasin_de_rattachement__c_FIELD from "@salesforce/schema/Account.Magasin_de_rattachement__c";
import Account_Etablissement_geographique__c_FIELD from "@salesforce/schema/Account.Etablissement_geographique__c";
import Account_N_association__c_FIELD from "@salesforce/schema/Account.N_association__c";
import Account_Email__c_FIELD from "@salesforce/schema/Account.Email__c";
import Account_Telephone_Siret__c_FIELD from "@salesforce/schema/Account.Telephone_Siret__c";
import Account_Origine__c_FIELD from "@salesforce/schema/Account.Origine__c";
import Account_Fax_FIELD from "@salesforce/schema/Account.Fax";
import Account_IsBuyer_FIELD from "@salesforce/schema/Account.IsBuyer";
import Account_Specialisation_FIELD from "@salesforce/schema/Account.Specialisation__c";
//account shipping fields
import Account_ShippingCity_FIELD from "@salesforce/schema/Account.ShippingCity";
import Account_ShippingCountry_FIELD from "@salesforce/schema/Account.ShippingCountry";
import Account_ShippingPostalCode_FIELD from "@salesforce/schema/Account.ShippingPostalCode";
import Account_ShippingState_FIELD from "@salesforce/schema/Account.ShippingState";
import Account_ShippingStreet_FIELD from "@salesforce/schema/Account.ShippingStreet";

//account billing fields
import Account_BillingCity_FIELD from "@salesforce/schema/Account.BillingCity";
import Account_BillingCountry_FIELD from "@salesforce/schema/Account.BillingCountry";
import Account_BillingPostalCode_FIELD from "@salesforce/schema/Account.BillingPostalCode";
import Account_BillingState_FIELD from "@salesforce/schema/Account.BillingState";
import Account_BillingStreet_FIELD from "@salesforce/schema/Account.BillingStreet";

//contact fields
import Contact_Id_FIELD from "@salesforce/schema/Contact.Id";
import Contact_FirstName_FIELD from "@salesforce/schema/Contact.FirstName";
import Contact_LastName_FIELD from "@salesforce/schema/Contact.LastName";
import Contact_Salutation_FIELD from "@salesforce/schema/Contact.Salutation";
import Contact_Roles__c_FIELD from "@salesforce/schema/Contact.Roles__c";
import Contact_Email_FIELD from "@salesforce/schema/Contact.Email";
import Contact_Phone_FIELD from "@salesforce/schema/Contact.Phone";
import Contact_MobilePhone_FIELD from "@salesforce/schema/Contact.MobilePhone";
import Contact_Telephone_portable__c from "@salesforce/schema/Contact.Telephone_portable__c";
import Contact_Fax_FIELD from "@salesforce/schema/Contact.Fax";
import Contact_Accepte_courrier__c_FIELD from "@salesforce/schema/Contact.Accepte_courrier__c";
import Contact_Accepte_fax__c_FIELD from "@salesforce/schema/Contact.Accepte_fax__c";
import Contact_Accepte_eMail__c_FIELD from "@salesforce/schema/Contact.Accepte_eMail__c";
import Contact_Accepte_telephone__c_FIELD from "@salesforce/schema/Contact.Accepte_telephone__c";
import Contact_Accepte_SMS__c_FIELD from "@salesforce/schema/Contact.Accepte_SMS__c";

//contact Mailing fields
import Contact_MailingCity_FIELD from "@salesforce/schema/Contact.MailingCity";
import Contact_MailingCountry_FIELD from "@salesforce/schema/Contact.MailingCountry";
import Contact_MailingPostalCode_FIELD from "@salesforce/schema/Contact.MailingPostalCode";
import Contact_MailingState_FIELD from "@salesforce/schema/Contact.MailingState";
import Contact_MailingStreet_FIELD from "@salesforce/schema/Contact.MailingStreet";

//contact ContactPointAddress fields
import ContactPointAddress_City_FIELD from "@salesforce/schema/ContactPointAddress.City";
import ContactPointAddress_NumeroDeVoie_FIELD from "@salesforce/schema/ContactPointAddress.Numero_de_voie__c";
import ContactPointAddress_TypeDeVoie_FIELD from "@salesforce/schema/ContactPointAddress.Type_de_voie__c";
import ContactPointAddress_NomDeVoie_FIELD from "@salesforce/schema/ContactPointAddress.Nom_de_voie__c";
import ContactPointAddress_Country_FIELD from "@salesforce/schema/ContactPointAddress.Country";
import ContactPointAddress_Pays_FIELD from "@salesforce/schema/ContactPointAddress.Pays__c";
import ContactPointAddress_PostalCode_FIELD from "@salesforce/schema/ContactPointAddress.PostalCode";
import ContactPointAddress_codesPostaux_FIELD from "@salesforce/schema/ContactPointAddress.Codes_Postaux__c";
import ContactPointAddress_State_FIELD from "@salesforce/schema/ContactPointAddress.State";
import ContactPointAddress_Street_FIELD from "@salesforce/schema/ContactPointAddress.Street";
import ContactPointAddress_Name_FIELD from "@salesforce/schema/ContactPointAddress.Name";
import ContactPointAddress_ParentId_FIELD from "@salesforce/schema/ContactPointAddress.ParentId";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class Selfregsiretdonotexistscomponent extends NavigationMixin(
  LightningElement
) {
  @api street;
  @api postalCode;
  @api selectedPostalCodeId;
  @api city;
  @api country;
  @api countryLabel;
  @api state;
  @api siret;
  @api registrecommercechecked;
  @track agreedCGV = false;
  @track agreedPromoCGU = false;

  //New Address fields
  @api numVoie;
  @api typeVoie;
  @api nomVoie;

  @track selectedStep = "Step1";
  @track selectedOption;
  @track openModalCGUCGV = false;
  @track openModalpromotionaloffers = false;
  @track accountRecord = {
    RecordTypeId: Account_RecordType_FIELD,
    SiretText__c: Account_SiretText__c_FIELD,
    Name: Account_Name_FIELD,
    Enseigne_commerciale__c: Account_Enseigne_commerciale__c_FIELD,
    Date_creation_etablissement__c:
      Account_Date_creation_etablissement__c_FIELD,
    Code_APE__c: Account_Code_APE__c_FIELD,
    En_cours_de_creation_au_reg_du_commerce__c:
      Account_En_cours_de_creation__c_FIELD,
    Theme__c: Account_Theme__c_FIELD,
    Forme_juridique__c: Account_Forme_juridique__c_FIELD,
    Magasin_de_rattachement__c: Account_Magasin_de_rattachement__c_FIELD,
    Etablissement_geographique__c: Account_Etablissement_geographique__c_FIELD,
    N_association__c: Account_N_association__c_FIELD,
    Email__c: Account_Email__c_FIELD,
    Origine__c: Account_Origine__c_FIELD,
    Telephone_Siret__c: Account_Telephone_Siret__c_FIELD,
    Fax: Account_Fax_FIELD,
    IsBuyer: Account_IsBuyer_FIELD,
    BillingCity: Account_BillingCity_FIELD,
    BillingCountry: Account_BillingCountry_FIELD,
    BillingPostalCode: Account_BillingPostalCode_FIELD,
    BillingState: Account_BillingState_FIELD,
    BillingStreet: Account_BillingStreet_FIELD,
    ShippingCity: Account_ShippingCity_FIELD,
    ShippingCountry: Account_ShippingCountry_FIELD,
    ShippingPostalCode: Account_ShippingPostalCode_FIELD,
    ShippingState: Account_ShippingState_FIELD,
    ShippingStreet: Account_ShippingStreet_FIELD,
    Specialisation__c: Account_Specialisation_FIELD
  };
  @track contactRecord = {
    FirstName: Contact_FirstName_FIELD,
    LastName: Contact_LastName_FIELD,
    Salutation: Contact_Salutation_FIELD,
    Roles__c: Contact_Roles__c_FIELD,
    Email: Contact_Email_FIELD,
    Phone: Contact_Phone_FIELD,
    MobilePhone: Contact_MobilePhone_FIELD,
    Telephone_portable__c: Contact_Telephone_portable__c,
    Fax: Contact_Fax_FIELD,
    MailingCity: Contact_MailingCity_FIELD,
    MailingCountry: Contact_MailingCountry_FIELD,
    MailingPostalCode: Contact_MailingPostalCode_FIELD,
    MailingState: Contact_MailingState_FIELD,
    MailingStreet: Contact_MailingStreet_FIELD,
    Accepte_courrier__c: Contact_Accepte_courrier__c_FIELD,
    Accepte_fax__c: Contact_Accepte_fax__c_FIELD,
    Accepte_eMail__c: Contact_Accepte_eMail__c_FIELD,
    Accepte_telephone__c: Contact_Accepte_telephone__c_FIELD,
    Accepte_SMS__c: Contact_Accepte_SMS__c_FIELD
  };

  @track billingAddressRecord = {
    Numero_de_voie__c: ContactPointAddress_NumeroDeVoie_FIELD,
    Type_de_voie__c: ContactPointAddress_TypeDeVoie_FIELD,
    Nom_de_voie__c: ContactPointAddress_NomDeVoie_FIELD,

    City: ContactPointAddress_City_FIELD,
    Country: ContactPointAddress_Country_FIELD,
    Pays__c: ContactPointAddress_Pays_FIELD,
    PostalCode: ContactPointAddress_PostalCode_FIELD,
    Codes_Postaux__c: ContactPointAddress_codesPostaux_FIELD,
    State: ContactPointAddress_State_FIELD,
    Street: ContactPointAddress_Street_FIELD,
    Name: ContactPointAddress_Name_FIELD,
    AddressType: "Billing",
    IsDefault: true,
    ParentId: ContactPointAddress_ParentId_FIELD
  };

  @track shippingAddressRecord = {
    Numero_de_voie__c: ContactPointAddress_NumeroDeVoie_FIELD,
    Type_de_voie__c: ContactPointAddress_TypeDeVoie_FIELD,
    Nom_de_voie__c: ContactPointAddress_NomDeVoie_FIELD,

    City: ContactPointAddress_City_FIELD,
    Country: ContactPointAddress_Country_FIELD,
    Pays__c: ContactPointAddress_Pays_FIELD,
    PostalCode: ContactPointAddress_PostalCode_FIELD,
    Codes_Postaux__c: ContactPointAddress_codesPostaux_FIELD,
    State: ContactPointAddress_State_FIELD,
    Street: ContactPointAddress_Street_FIELD,
    Name: ContactPointAddress_Name_FIELD,
    AddressType: "Shipping",
    IsDefault: true,
    ParentId: ContactPointAddress_ParentId_FIELD
  };

  @track formFields;

  @track recordTypes = [];
  //STEP 1
  selectedMagasin;
  selectedMyZoneId;
  selectedAllZoneId;
  selectedMyZone;
  selectedAllZone;
  magasinIsRestrictif;
  selectedMagasinName;
  myMagasins = [];
  loadedMyMagasins = [];
  allMagasins = [];
  loadedAllMagasins = [];
  chooseMagasinFromMyPostalCode = true;
  showAllMagasins = false;
  isMagasinError = false;
  magasinSelectErrorMessage = "";

  originalMagasinId;
  zoneDisabled = false;
  //ErrorPage
  @track errorPage = false;
  @track errorPageMessage = "";

  successMessage = "";
  @track optionsRole;
  @track optionsFormeJuridique;
  @track optionsAPE;
  @track optionsAPEBis = [];
  @track loadedCodesAPE;

  @track disableAssociation = true;

  @track isAttributeRequired = false;
  @track isAttributeRequiredRole = false;
  @track isAttributeRequiredAPE = false;

  /* STEP 2 Aymen */
  @track name;
  @track surname;
  userNameOk;
  @track civilite;
  @track email;
  @track role;
  @track phone;
  @track mobile;
  @track fax;
  @track codeAPE;
  //SOUS STEP PASSWORD
  username = "";
  password = "";
  repeatPassword = "";
  @track isCredentialError = false;
  @track credentialErrorMessage = "";
  @track isPhoneError = false;
  @track phoneErrorMessage = "";
  @track isUsernameError = false;
  @track usernameErrorMessage = "";

  @wire(getObjectInfo, {
    objectApiName: ACCOUNT_OBJECT
  })
  accObjectInfo({ data, error }) {
    if (data) {
      let optionsValues = [];
      // map of record type Info
      const rtInfos = data.recordTypeInfos;

      // getting map values
      let rtValues = Object.values(rtInfos);

      for (let i = 0; i < rtValues.length; i++) {
        if (rtValues[i].name !== "Master") {
          optionsValues.push({
            label: rtValues[i].name,
            value: rtValues[i].recordTypeId
          });
        }
      }

      this.recordTypes = optionsValues;
      if (showDebug) {
        console.log("this.recordTypes");
      }
      if (showDebug) {
        console.log(this.recordTypes);
      }
    } else if (error) {
      window.console.log("Error ===> " + JSON.stringify(error));
    }
  }

  displayError(error) {
    this.error = "Unknown error";
    if (Array.isArray(error.body)) {
      this.error = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      this.error = error.body.message;
    }
  }

  // for now forcing false
  get isPicklistDisabledRole() {
    // return (this.optionsRole &&
    // this.contrFieldValue !== 'Select') ? false : true;
    return false;
  }
  get askForInscriptionRegistre() {
    // return (this.optionsRole &&
    // this.contrFieldValue !== 'Select') ? false : true;
    return !this.registrecommercechecked;
  }

  get isPicklistDisabledAPE() {
    // return (this.optionsAPE &&
    // this.contrFieldValue !== 'Select') ? false : true;
    return false;
  }

  specialisationValues;
  @track specialisationValuesBis;
  nextButtonClicked = false;
  initialized = false;
  selectedSpec;
  spec;
  isSpecError = false;
  specErrorMessage = "";
  isCodeAPEError = false;
  codeAPEErrorMessage = "";
  isFileError = false;
  fileErrorMessage = "";
  isAgreedCGVError = false;
  agreedCGVErrorMessage = "";

  renderedCallback() {
    if (showDebug) {
      console.log("renderedCallback donotexists rendredcallback");
    }
    if (this.selectedStep == "Step2") {
      if (typeof this.accountRecord.Forme_juridique__c == "object") {
        this.accountRecord.Forme_juridique__c = "";
      }
    }
    /*if (this.specialisationValues !== undefined) {
      if (this.nextButtonClicked == true) {
        this.initialized = true;
        if (this.template.querySelector("datalist") !== null) {
          let listId = this.template.querySelector("datalist").id;
          this.template
            .querySelector("input[name=inputSpec]")
            .setAttribute("list", listId);
          this.nextButtonClicked = false;
        }
      }
    } else {
      getPickListValues({
        objApiName: "Account",
        fieldName: "Specialisation__c"
      })
        .then(data => {
          if (showDebug) { console.log ("=====> res");
          this.specialisationValues = data;
          if (showDebug) { console.log (
            "specialisationValues : " +
              JSON.stringify(this.specialisationValues)
          );

          if (this.initialized) {
            return;
          }
          this.initialized = true;
          if (this.template.querySelector("datalist") !== null) {
            let listId = this.template.querySelector("datalist").id;
            if (showDebug) { console.log ("listId: " + JSON.stringify(listId));
            //this.template.querySelector("input[data-id=inputVoie]").setAttribute("list", listId);
            this.template
              .querySelector("input[name=input]")
              .setAttribute("list", listId);
          }
        })
        .catch(error => {
          if (showDebug) { console.log ("role error");
          if (showDebug) { console.log (error);
          this.displayError(error);
        });
    }*/
  }

  get selectedSpecialisation() {
    if (this.selectedSpec == undefined) return "";
    return this.selectedSpec.label;
  }

  handleSpecChange(evt) {
    var selectedVoieVar = evt.target.value;
    //this.typeVoieTypingValue = selectedVoieVar;
    //if (showDebug) { console.log (this.typeVoieTypingValue);

    this.selectedSpec = this.specialisationValues.find(
      (item) => item.label === selectedVoieVar
    );
    if (showDebug) {
      console.log("selectedVoieVar; " + JSON.stringify(this.selectedSpec));
    }

    if (this.selectedSpec == undefined) {
      this.showSpecError();
    } else {
      this.spec = this.selectedSpec.value;
      //this.typeVoieTypingValue = this.typeVoie;
      this.resetSpecErrorMessages();
    }
  }

  connectedCallback() {
    this.showSpinner = true;
    if (showDebug) {
      console.log("after spinner");
    }
    if (showDebug) {
      console.log(this.registrecommercechecked);
    }
    if (showDebug) {
      console.log(this.askForInscriptionRegistre);
    }
    getPickListValues({
      objApiName: "Contact",
      fieldName: "Role__c"
    })
      .then((data) => {
        this.optionsRole = data;
      })
      .catch((error) => {
        if (showDebug) {
          console.log("role error");
        }
        if (showDebug) {
          console.log(error);
        }
        this.displayError(error);
      });
    getPickListValues({
      objApiName: "Account",
      fieldName: "Forme_juridique__c"
    })
      .then((data) => {
        this.optionsFormeJuridique = data;
      })
      .catch((error) => {
        if (showDebug) {
          console.log("forme juridique error");
        }
        if (showDebug) {
          console.log(error);
        }
        this.displayError(error);
      });
    if (showDebug) {
      console.log("after getPicklistValues");
    }
    if (
      this.accountRecord.Enseigne_commerciale__c == undefined ||
      typeof this.accountRecord.Enseigne_commerciale__c == "object"
    ) {
      this.accountRecord.Enseigne_commerciale__c = "";
    }

    getCodesAPEBis()
      .then((data) => {
        Object.keys(data).forEach((el) => {
          this.optionsAPEBis.push({ label: el, value: el });
        });
        this.loadedCodesAPE = data;
        if (showDebug) {
          console.log("loadedCodesAPE: ");
        }
        if (showDebug) {
          console.log(JSON.stringify(this.loadedCodesAPE));
        }

        this.selectedCodeAPEBis = this.optionsAPEBis[0].value; // init first selected code APE
        let firstEl = this.loadedCodesAPE[this.selectedCodeAPEBis];
        firstEl.forEach((el) => {
          this.specialisationOptions.push({
            label: el.Specialisation__c,
            value: el.Id
          });
        });

        this.selectedSpecialisationBis = firstEl[0].Id;

        if (this.specialisationOptions.length > 1) {
          this.showSpecialisationCombobox = true;
        } else {
          this.showSpecialisationCombobox = false;
        }
        if (showDebug) {
          console.log(
            "***INIT selectedSpecialisationBis: " +
              JSON.stringify(this.selectedSpecialisationBis)
          );
        }
      })
      .catch((error) => {
        this.displayError(error);
      });

    if (showDebug) {
      console.log("after APEs");
    }

    getZoneChalandise({
      postalCode: this.postalCode,
      city: this.city
    })
      .then((res) => {
        if (res != null) {
          if (showDebug) {
            console.log("into getZoneChalandise res not null: ");
          }
          if (showDebug) {
            console.log(JSON.stringify(res));
          }
          res.forEach((element) => {
            if (
              this.myMagasins.find(
                (item) => item.magasinName === element.Magasin__r.Name
              ) === undefined
            ) {
              this.myMagasins.push({
                Id: element.Id,
                label: element.Libelle_ville__c,
                value: element.Libelle_ville__c,
                restrictif: element.Magasin__r.Restrictif__c,
                magasinId: element.Magasin__r.Id,
                magasinName: element.Magasin__r.Name
              });
            }
          });
          if (showDebug) {
            console.log("myMagasins:  " + JSON.stringify(this.myMagasins));
          }
          if (res.length > 0) {
            //Init
            this.selectedMyZoneId = res[0].Id;
          }
          /*in order to show the first magasin of the list we should do this:*/
          this.chooseMagasinFromMyPostalCode = false;
          this.chooseMagasinFromMyPostalCode = true;
        } else {
          this.zoneDisabled = true;
          this.showAllMagasins = true;
        }
      })
      .catch((err) => {
        if (showDebug) {
          console.log("getZoneChalandise err: ");
        }
        if (showDebug) {
          console.log(err);
        }
        this.errorPageMessage = "Error : getZoneChalandise";
        this.errorPage = true;
      });
    if (showDebug) {
      console.log("after getZoneChalandise");
    }
    getAllMagasinsFromZoneDeChalandise()
      .then((res) => {
        if (res != null) {
          if (showDebug) {
            console.log(
              "into getAllMagasinsFromZoneDeChalandise res not null: "
            );
          }
          if (showDebug) {
            console.log(res);
          }

          res.forEach((element) => {
            if (
              this.allMagasins.find(
                (item) => item.magasinName === element.Magasin__r.Name
              ) === undefined
            ) {
              this.allMagasins.push({
                Id: element.Id,
                label: element.Libelle_ville__c,
                value: element.Libelle_ville__c,
                restrictif: element.Magasin__r.Restrictif__c,
                magasinId: element.Magasin__r.Id,
                magasinName: element.Magasin__r.Name
              });
            }
            this.loadedAllMagasins.push({
              Id: element.Id,
              label: element.Libelle_ville__c,
              value: element.Libelle_ville__c,
              restrictif: element.Magasin__r.Restrictif__c,
              magasinId: element.Magasin__r.Id,
              magasinName: element.Magasin__r.Name
            });
          });
          if (res.length > 0) {
            this.selectedAllZoneId = res[0].Id;
          }
          if (this.showAllMagasins == true) {
            this.chooseMagasinFromMyPostalCode = false;
            const element = this.template.querySelector(
              '[data-id="checkbox-cannotFindMyMagasin"]'
            );
            element.checked = true;
          }
        } else {
          if (showDebug) {
            console.log("into getAllMagasinsFromZoneDeChalandise res null: ");
          }
          if (showDebug) {
            console.log(res);
          }
        }
      })
      .catch((err) => {
        if (showDebug) {
          console.log(
            "SelfRegMagasinChoiceComponent.getAllMagasinsFromZoneDeChalandise err: "
          );
        }
        if (showDebug) {
          console.log(err);
        }
        this.errorPageMessage = "Error : getAllMagasinsFromZoneDeChalandise";
        this.errorPage = true;
      });

    if (showDebug) {
      console.log("after getAllMagasinsFromZoneDeChalandise");
    }

    this.showSpinner = false;
  }

  /** STEP 1 **/
  myMagasinSelectionHandler(event) {
    var selectedValue = this.myMagasins.find(
      (item) => item.magasinName === event.target.value
    );
    this.selectedMyZoneId = selectedValue.Id;
  }

  allMagasinSelectionChangeHandler(event) {
    //this.selectedAllZoneId = event.target.value;
    var selectedValue = this.allMagasins.find(
      (item) => item.magasinName === event.target.value
    );
    this.selectedAllZoneId = selectedValue.Id;
    if (showDebug) {
      console.log("init selectedAllZoneId" + this.selectedAllZoneId);
    }
  }

  // selectedMagasin;

  handleCannotFindMyMagasinCheckbox() {
    const element = this.template.querySelector(
      '[data-id="checkbox-cannotFindMyMagasin"]'
    );
    this.chooseMagasinFromMyPostalCode = !element.checked;
    if (this.chooseMagasinFromMyPostalCode == false) {
      // Init selectedAllZoneId with the first element
      this.selectedAllZoneId = this.loadedAllMagasins[0].Id;
      //this.selectedMagasinId = this.loadedAllMagasins[0].Id;
      if (showDebug) {
        console.log("init selectedAllZoneId" + this.selectedAllZoneId);
      }
      if (showDebug) {
        console.log("init selectedMagasinId" + this.selectedMagasinId);
      }
      this.isMagasinError = false;
    }
  }
  /** STEP 1 **/

  handleUsernameChange(event) {
    this.username = event.target.value;
  }
  handlePasswordChange(event) {
    this.password = event.target.value;
  }
  handlerepeatPasswordChange(event) {
    this.repeatPassword = event.target.value;
  }

  selectStep1() {
    this.selectedStep = "Step1";
  }

  selectStep2() {
    this.selectedStep = "Step2";
  }

  selectStep3() {
    this.selectedStep = "Step3";
  }

  saveRecord(record, objectType) {
    insertRecord({
      obj: record,
      objtype: objectType
    })
      .then(result => {
        let newrecord = result;

        if (showDebug) { console.log ("created" + objectType + " result:");}
        if (showDebug) { console.log (newrecord);}
        // Show success messsage
        // this.dispatchEvent(new ShowToastEvent({
        // title: 'Success!!',
        // message: 'Contact Created Successfully!!',
        // variant: 'success'
        // }), );
        return newrecord;
      })
      .catch(error => {
        if (showDebug) { console.log (error);}
        if (showDebug) { console.log (error.body.message);}

        this.error = error.body.message;
      });
  }
  saveContact(contactArray) {
    saveContactApex({
      objCont: contactArray
    })
      .then((result) => {
        // Clear the user enter values
        //this.accountRecord = {};
        contactArray = result;

        if (showDebug) {
          console.log("created contact result");
        }
        if (showDebug) {
          console.log(result);
        }
        // Show success messsage
        // this.dispatchEvent(new ShowToastEvent({
        // title: 'Success!!',
        // message: 'Contact Created Successfully!!',
        // variant: 'success'
        // }), );
        return contactArray;
      })
      .catch((error) => {
        if (showDebug) {
          console.log(error);
        }
        if (showDebug) {
          console.log(error.body.message);
        }

        this.error = error.body.message;
      });
  }
  saveContactPointAddress(contactPointAddressArray) {
    saveContactPointAddressApex({
      objCPA: contactPointAddressArray
    })
      .then((result) => {
        // Clear the user enter values
        //this.accountRecord = {};
        contactPointAddressArray = result;

        if (showDebug) {
          console.log("created contact point address result");
        }
        if (showDebug) {
          console.log(result);
        }
        // Show success messsage
        // this.dispatchEvent(new ShowToastEvent({
        // title: 'Success!!',
        // message: 'contact point address Created Successfully!!',
        // variant: 'success'
        // }), );
        return contactPointAddressArray;
      })
      .catch((error) => {
        if (showDebug) {
          console.log(error);
        }
        if (showDebug) {
          console.log(error.body.message);
        }

        this.error = error.body.message;
        return error;
      });
  }
  enableUser() {
    enablePortalUserForContactWithoutEmail({
      accountid: this.accountRecord["Id"],
      contactId: this.contactRecord["Id"],
      email: this.username,
      password: this.password
      // includePassword: true
    })
      .then((res) => {
        if (showDebug) {
          console.log("enablePortalUserForContactWithoutEmail result r: ");
        }
        if (showDebug) {
          console.log(res);
        }
        if (res.isSuccess == false) {
          // if (showDebug) { console.log ('enablePortalUserForSingleNewContact result: ');
          // if (showDebug) { console.log (res);
          this.errorPageMessage =
            "Erreur lors de la création de votre utilisateur. Veuillez contacter un administrateur.";
          this.errorPage = true;
        } else {
          this.successMessage = "Votre compte a bien été créé.";
          this.selectedStep = "successStep";
        }
        if (showDebug) {
          console.log("enablePortalUserForContactWithoutEmail result r: ");
        }
        if (showDebug) {
          console.log(res);
        }
        this.showSpinner = false;
        return res;
      })
      .catch((err) => {
        this.showSpinner = false;
        if (showDebug) {
          console.log(err);
        }
        if (showDebug) {
          console.log(err.body.message) + " enableuser";
        }
        return err;
      });
  }
  enableUserFuture() {
    enablePortalUserForSingleNewContact({
      accountid: this.accountRecord["Id"],
      contactId: this.contactRecord["Id"],
      email: this.username,
      password: this.password,
      includePassword: true
    })
      .then((res) => {
        if (showDebug) {
          console.log("enablePortalUserForSingleNewContact result: ");
        }
        if (showDebug) {
          console.log(res);
        }
        if (res.isSuccess == false) {
          if (showDebug) {
            console.log("enablePortalUserForSingleNewContact result: ");
          }
          if (showDebug) {
            console.log(res);
          }
          this.errorPageMessage =
            "Erreur lors de la création de votre utilisateur. Veuillez contacter un administrateur.future";
          this.errorPage = true;
        } else {
          this.successMessage = "Votre compte a bien été créé.";
          this.selectedStep = "successStep";
        }
        this.showSpinner = false;
        return res;
      })
      .catch((err) => {
        if (showDebug) {
          console.log(err);
        }
        if (showDebug) {
          console.log(err.body.message) + " enableuser";
        }
        this.showSpinner = false;
        return err;
      });
  }

  //enablePortalUserForContactWithoutEmail({accountid: this.account.Id, contactId: this.account.Contacts[0].Id, email: this.username, password: this.password})

  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    if (showDebug) {
      console.log(uploadedFiles);
    }
    alert("No. of files uploaded : " + uploadedFiles.length);
  }

  showModalCGUCGV() {
    this.openModalCGUCGV = true;
  }
  closeModalCGUCGV() {
    this.openModalCGUCGV = false;
  }
  agreeModalCGUCGV() {
    this.agreedCGV = !this.agreedCGV;
    this.openModalCGUCGV = false;
  }
  showModaloffers() {
    this.openModalpromotionaloffers = true;
  }
  closeModaloffers() {
    this.openModalpromotionaloffers = false;
  }

  get isSelectStep1() {
    return this.selectedStep === "Step1";
  }

  get isSelectStep2() {
    return this.selectedStep === "Step2";
  }

  get isSelectStep3() {
    return this.selectedStep === "Step3";
  }
  // get showPrevious() {
  //     return this.selectedStep === "Step2"||this.selectedStep === "Step3"||this.errorPage == true;
  // }
  get isSuccessPage() {
    return this.selectedStep === "successStep";
  }
  get notFinalScreen() {
    return this.selectedStep !== "Step3" && this.selectedStep !== "successStep";
  }

  get notFinalScreenRetour() {
    return this.selectedStep !== "successStep";
  }

  get isEcommerceEmailStep() {
    return this.selectedStep === "ecommerceEmailStep";
  }

  get selectedFormeJuridique() {
    return this.optionsFormeJuridique.find(
      (item) => item.value === this.accountRecord["Forme_juridique__c"]
    );
  }

  checkTelephonesFields() {
    if (showDebug) {
      console.log("phone: " + this.contactRecord["Phone"]);
    }
    if (showDebug) {
      console.log(
        "Telephone_portable__c: " + this.contactRecord["Telephone_portable__c"]
      );
    }
    if (
      (typeof this.contactRecord["Phone"] == "object" &&
        typeof this.contactRecord["Telephone_portable__c"] == "object") ||
      (this.contactRecord["Phone"] == "" &&
        this.contactRecord["Telephone_portable__c"] == "")
    ) {
      return false;
    }
    return true;
  }

  get encryptedToken() {
    //use apex to get
  }

  get acceptedFormats() {
    return [".pdf", ".png"];
  }

  showGenericErrorPage() {
    this.errorPageMessage = "Veuillez contacter votre magasin";
    this.errorPage = true;
  }

  registreFileComponent;
  kbisFileComponent;
  ribFileComponent;
  pieceFileComponent;

  handleNext() {
    if (showDebug) {
      console.log("this.validateFields()");
    }
    if (showDebug) {
      console.log(this.validateFields());
    }
    //  if(this.validateFields()){

    this.showSpinner = true;
    var getselectedStep = this.selectedStep;
    if (showDebug) {
      console.log("getselectedStep ===>" + getselectedStep);
    }

    if (getselectedStep === "Step1") {
      this.isMagasinError = false;

      if (
        this.selectedMyZoneId == undefined &&
        this.chooseMagasinFromMyPostalCode == true
      ) {
        this.isMagasinError = true;
        this.magasinSelectErrorMessage = "Veuillez selectionner un magasin";
      }

      if (this.isMagasinError == false) {
        var selectedMagasinId;
        var magasinGeographique;
        var isRestrictif;
        this.initSelectedZone();

        if (this.chooseMagasinFromMyPostalCode == true) {
          selectedMagasinId = this.selectedMyZone.magasinId;
          magasinGeographique = this.selectedMyZone.magasinId;
          isRestrictif = this.selectedMyZone.restrictif;
          this.selectedMagasinName = this.selectedMyZone.magasinName;
        } else {
          selectedMagasinId = this.selectedAllZone.magasinId;
          isRestrictif = this.selectedAllZone.restrictif;
          this.selectedMagasinName = this.selectedAllZone.magasinName;

          if (this.selectedMyZone != undefined) {
            magasinGeographique = this.selectedMyZone.magasinId;
          }
        }
        if (showDebug) {
          console.log("magasinGeographique: " + magasinGeographique);
        }
        //if (showDebug) { console.log ('selectedMagasinId: ' + selectedMagasinId);

        this.accountRecord["Magasin_de_rattachement__c"] = selectedMagasinId;
        this.accountRecord["Etablissement_geographique__c"] =
          magasinGeographique;

        this.magasinIsRestrictif = isRestrictif;

        this.selectedStep = "Step2";
        this.nextButtonClicked = true;
      }
      if (showDebug) {
        console.log(
          "chooseMagasinFromMyPostalCode: " + this.chooseMagasinFromMyPostalCode
        );
      }
    } else if (getselectedStep === "Step2") {
      if (
        this.validateFields() &&
        //this.validateCodeAPEInput() &&
        //this.validateSpecInput() &&
        this.filesUploaded() &&
        this.ifAgreedCGV()
      ) {
        if (showDebug) {
          console.log("Vlidation OK");
        }
        this.registreFileComponent = this.template.querySelector(
          '[data-id="registreFileUpload"]'
        );
        this.kbisFileComponent = this.template.querySelector(
          '[data-id="KBISFileUpload"]'
        );
        this.ribFileComponent = this.template.querySelector(
          '[data-id="RIBFileUpload"]'
        );
        this.pieceFileComponent = this.template.querySelector(
          '[data-id="IDFileUpload"]'
        );

        this.selectedStep = "Step3";
        this.userNameOk = true;
      }
    }
    this.showSpinner = false;

    //}
  }

  handleLireCGV(evt) {
    const element = this.template.querySelector('[data-id="dataID-lireCGV"]');
    this.agreedCGV = element.checked;
    if (showDebug) {
      console.log("link clicked" + JSON.stringify(this.agreedCGV));
    }
  }

  redirectToCGV() {
    if (showDebug) {
      console.log("link clicked");
    }

    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s/selfreg-conditions-generales-de-vente"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  handleLirePromoCGU(evt) {
    const element = this.template.querySelector(
      '[data-id="dataID-lirePromoCGU"]'
    );
    this.agreedPromoCGU = element.checked;
    if (showDebug) {
      console.log("link clicked" + JSON.stringify(this.agreedPromoCGU));
    }
  }

  redirectToPromoCGU() {
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s/selfreg-promotions"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  initSelectedZone() {
    //this.selectedAllZone = this.allMagasins.find(item => item.id === this.selectedAllZoneId);
    if (this.chooseMagasinFromMyPostalCode == false) {
      this.selectedAllZone = this.loadedAllMagasins.find(
        (item) => item.Id === this.selectedAllZoneId
      );
      if (this.selectedMyZoneId !== undefined) {
        this.selectedMyZone = this.loadedAllMagasins.find(
          (item) => item.Id === this.selectedMyZoneId
        );
      }
    } else {
      this.selectedMyZone = this.loadedAllMagasins.find(
        (item) => item.Id === this.selectedMyZoneId
      );
    }
    if (showDebug) {
      console.log(
        "**initSelectedZone selectedMyZone: " +
          JSON.stringify(this.selectedMyZone)
      );
    }
    if (showDebug) {
      console.log(
        "**initSelectedZone selectedAllZone: " +
          JSON.stringify(this.selectedAllZone)
      );
    }
  }

  filesUploaded() {
    if (showDebug) {
      console.log("registrecommercechecked : " + this.registrecommercechecked);
    }
    if (this.registrecommercechecked == true) {
      var res = this.template
        .querySelector('[data-id="registreFileUpload"]')
        .hasFile();
      if (res == true) {
        this.resetFileError();
      } else {
        this.showFileError("attestation d'inscription au registre de commerce");
      }
      return res;
    } else {
      var res = this.template
        .querySelector('[data-id="KBISFileUpload"]')
        .hasFile();
      if (res == true) {
        this.resetFileError();
      } else {
        this.showFileError("KBIS");
      }
      return res;
    }
  }

  ifAgreedCGV() {
    if (this.agreedCGV == false) {
      this.showAgreedCGVErrorMessages();
      return false;
    }
    this.resetAgreedCGVErrorMessages();
    return true;
  }

  validateSpecInput() {
    if (this.selectedSpec == undefined) {
      this.showSpecError();
      return false;
    }
    this.resetSpecErrorMessages();
    return true;
  }

  validateCodeAPEInput() {
    if (typeof this.accountRecord["Code_APE__c"] == "object") {
      this.showCodeAPEError();
      return false;
    }
    this.resetCodeAPEErrorMessages();
    return true;
  }

  showFileError(fileName) {
    this.isFileError = true;
    this.fileErrorMessage = "Veuillez uploader votre " + fileName;
  }
  resetFileError() {
    this.isFileError = false;
  }

  showCodeAPEError() {
    this.template
      .querySelector('[data-id="codeAPEElement"]')
      .classList.add("slds-has-error");
    this.isCodeAPEError = true;
    this.codeAPEErrorMessage = "Remplissez ce champ.";
  }

  resetCodeAPEErrorMessages() {
    this.isCodeAPEError = false;
    this.template
      .querySelector('[data-id="codeAPEElement"]')
      .classList.remove("slds-has-error");
  }

  showAgreedCGVErrorMessages() {
    this.template
      .querySelector('[data-id="agreedCGVElement"]')
      .classList.add("slds-has-error");

    this.isAgreedCGVError = true;
    this.agreedCGVErrorMessage =
      "vous devez lire et accepter les conditions générales de vente";
  }

  resetAgreedCGVErrorMessages() {
    this.isAgreedCGVError = false;
    this.template
      .querySelector('[data-id="agreedCGVElement"]')
      .classList.remove("slds-has-error");
  }

  showSpecError() {
    this.template
      .querySelector('[data-id="specElement"]')
      .classList.add("slds-has-error");
    this.isSpecError = true;
    this.specErrorMessage = "Valeur incorrecte";
  }

  resetSpecErrorMessages() {
    this.isSpecError = false;
    this.template
      .querySelector('[data-id="specElement"]')
      .classList.remove("slds-has-error");
  }

  handleFinish() {
    console.log("Handle finish");
    this.showSpinner = true;
    if (this.validateFields()) {
      this.isCredentialError = false;
      this.isUsernameError = false;
      this.isPhoneError = false;
      if (showDebug) {
        console.log("username: " + this.username);
      }
      if (showDebug) {
        console.log("password: " + this.password);
      }
      if (showDebug) {
        console.log("repeat pass: " + this.repeatPassword);
      }

      let errClass = "slds-has-error";
      let errorUsername = this.template
        .querySelector('[data-id="username"]')
        .classList.contains(errClass);
      let errorPassword = this.template
        .querySelector('[data-id="password"]')
        .classList.contains(errClass);
      let errorRepeatPassword = this.template
        .querySelector('[data-id="repeatPassword"]')
        .classList.contains(errClass);
      if (showDebug) {
        console.log(
          "errorUsername: " +
            errorUsername +
            ", errorPassword: " +
            errorPassword +
            ", errorRepeatPassword: " +
            errorRepeatPassword
        );
      }
      if (this.checkTelephonesFields() == false) {
        this.isPhoneError = true;
        this.phoneErrorMessage =
          "Veuillez saisir un Téléphone fixe ou bien un Téléphone mobile";
      } else if (
        errorUsername == true ||
        errorPassword == true ||
        errorRepeatPassword == true
      ) {
        //Nothing to do, wiating for user to correct inputs
      } else {
        if (
          this.username == "" ||
          this.password == "" ||
          this.repeatPassword == ""
        ) {
          this.showSpinner = false;
          this.isCredentialError = true;
          this.credentialErrorMessage =
            "Veuillez saisir un emil de connexion et un mot de passe";
        } else {
          if (this.password !== this.repeatPassword) {
            this.showSpinner = false;
            this.isCredentialError = true;
            this.credentialErrorMessage =
              "Les mots de passe saisis ne sont pas identiques";
          } else if (this.validatePassword(this.password) == false) {
            this.isCredentialError = true;
            this.showSpinner = false;
            this.credentialErrorMessage =
              "Le mot de passe doit contenir au moins 12 caractères dont 1 lettre, 1 chiffre et 1 caractère spécial.";
          } else {
            if (showDebug) {
              console.log("correct");
            }
            getUserByUsername({
              username: this.username
            })
              .then((result) => {
                if (result != null) {
                  this.errorPageMessage =
                    "Cet username existe déjà, veuillez en sélectionner un autre.";
                  this.errorPage = true;
                  if (showDebug) {
                    console.log("username found");
                  }
                  this.showSpinner = false;
                } else {
                  this.setAddresses();
                  if (showDebug) {
                    console.log("this.recordTypes");
                    console.log(this.recordTypes);
                    console.log("this.city");
                    console.log("this.magasinIsRestrictif");
                    console.log(this.city);
                    console.log(this.magasinIsRestrictif);
                  }

                  if (this.magasinIsRestrictif === true) {
                    if (showDebug) {
                      console.log("magasinRestrictif");
                    }
                    this.accountRecord["RecordTypeId"] = this.recordTypes.find(
                      (item) => item.label === "Lead"
                    ).value;
                    this.accountRecord["Statut_Fiche_client__c"] = "Lead";
                  } else if (this.magasinIsRestrictif === false) {
                    if (showDebug) {
                      console.log("magasinNonRestrictif");
                    }
                    this.accountRecord["RecordTypeId"] = this.recordTypes.find(
                      (item) => item.label === "Prospect"
                    ).value;
                    this.accountRecord["Magasin_actif_en_cours__c"] = this.accountRecord["Magasin_de_rattachement__c"];
                    this.accountRecord["Statut_Fiche_client__c"] = "Prospect";
                    this.accountRecord["IsBuyer"] = true;
                  }

                  this.accountRecord["Specialisation__c"] = this.spec;
                  this.accountRecord["Email__c"] = this.username;
                  this.accountRecord["Numero_Siret__c"] = this.siret;
                  this.accountRecord["Origine__c"] = "7";
                  this.accountRecord["Code_APE__c"] =
                    this.getSelecetedCodeApeObject().Id;
                  this.accountRecord[
                    "En_cours_de_creation_au_reg_du_commerce__c"
                  ] = this.registrecommercechecked;

                  this.contactRecord["Accepte_courrier__c"] = true;
                  this.contactRecord["Accepte_fax__c"] = true;
                  this.contactRecord["Accepte_eMail__c"] = true;
                  this.contactRecord["Accepte_telephone__c"] = true;
                  this.contactRecord["Accepte_SMS__c"] = true;

                  this.contactRecord["Email"] = this.username;
                  if (showDebug) {
                    console.log("this.accountRecord.keys");
                  }
                  if (showDebug) {
                    console.log(Object.keys(this.accountRecord));
                  }
                  this.accountRecord = this.clearArray(
                    this.accountRecord,
                    "Account"
                  );

                  //Set Fileupload
                  var kbisUploaded = false;
                  var registreUploaded = false;
                  var ribUploaded = false;
                  var pieceIdentiteUploaded = false;
                  if (this.isKBISUploaded() == true) {
                    kbisUploaded = true;
                  }
                  if (this.registrecommercechecked == true) {
                    if (this.isRegistreCommercUploaded() == true) {
                      registreUploaded = true;
                    }
                  }
                  if (this.isRIBUploaded() == true) {
                    ribUploaded = true;
                  }
                  if (this.isPieceIdentiteUploaded() == true) {
                    pieceIdentiteUploaded = true;
                  }

                  saveAccountApex({
                    objAcc: this.accountRecord
                  })
                    .then((result) => {
                      if (showDebug) {
                        console.log(
                          "saveAccountApex result: " + JSON.stringify(result)
                        );
                      }
                      // this.accountRecord['Id'] = account.id;
                      this.accountRecord = result;
                      this.contactRecord["AccountId"] = result.Id;
                      this.billingAddressRecord["ParentId"] = result.Id;
                      this.shippingAddressRecord["ParentId"] = result.Id;
                      if (this.registrecommercechecked) {
                        this.registreFileComponent.setParentRecordId(result.Id);
                        this.registreFileComponent.handleSave();

                        //this.template.querySelector('[data-id="registreFileUpload"]').setParentRecordId(result.Id);
                        //this.template.querySelector('[data-id="registreFileUpload"]').handleSave();
                      }
                      if (kbisUploaded == true) {
                        this.kbisFileComponent.setParentRecordId(result.Id);
                        this.kbisFileComponent.handleSave();

                        //this.template.querySelector('[data-id="KBISFileUpload"]').setParentRecordId(result.Id);
                        //this.template.querySelector('[data-id="KBISFileUpload"]').handleSave();
                      }
                      if (ribUploaded == true) {
                        this.ribFileComponent.setParentRecordId(result.Id);
                        this.ribFileComponent.handleSave();

                        //this.template.querySelector('[data-id="RIBFileUpload"]').setParentRecordId(result.Id);
                        //this.template.querySelector('[data-id="RIBFileUpload"]').handleSave();
                      }
                      if (pieceIdentiteUploaded == true) {
                        this.pieceFileComponent.setParentRecordId(result.Id);
                        this.pieceFileComponent.handleSave();

                        //this.template.querySelector('[data-id="IDFileUpload"]').setParentRecordId(result.Id);
                        //this.template.querySelector('[data-id="IDFileUpload"]').handleSave();
                      }
                      updatePieceJustificatifFields({
                        accountId: result.Id,
                        registreCommerce: registreUploaded,
                        kbis: kbisUploaded,
                        rib: ribUploaded,
                        pieceIdentite: pieceIdentiteUploaded
                      })
                        .then((resUpload) => {
                          if (showDebug) {
                            console.log(
                              "updatePieceJustificatifFields res: " +
                                JSON.stringify(resUpload)
                            );
                          }
                        })
                        .catch((errUpload) => {
                          if (showDebug) {
                            console.log(
                              "updatePieceJustificatifFields err: " +
                                JSON.stringify(errUpload)
                            );
                          }
                        });

                      this.contactRecord = this.clearArray(
                        this.contactRecord,
                        "Contact"
                      );
                      this.billingAddressRecord = this.clearArray(
                        this.billingAddressRecord,
                        "ContactPointAddress"
                      );
                      this.shippingAddressRecord = this.clearArray(
                        this.shippingAddressRecord,
                        "ContactPointAddress"
                      );

                      if (showDebug) {
                        console.log(
                          "billingAddressRecord: " +
                            JSON.stringify(this.billingAddressRecord)
                        );
                      }
                      if (showDebug) {
                        console.log(
                          "shippingAddressRecord: " +
                            JSON.stringify(this.shippingAddressRecord)
                        );
                      }

                      console.log("contactRecord: " + JSON.stringify(this.contactRecord));

                      // public static ServiceResponse saveRecords(Account account, Contact contact, ContactPointAddress billingAddress, ContactPointAddress shippingAddress,
                      //     Boolean isMagasinRestrictif, String username, String password){

                      saveRecordsApex({
                        account: this.accountRecord,
                        contact: this.contactRecord,
                        billingAddress: this.billingAddressRecord,
                        shippingAddress: this.shippingAddressRecord,
                        isMagasinRestrictif: this.magasinIsRestrictif,
                        magasinName: this.selectedMagasinName,
                        username: this.username,
                        password: this.password
                      })
                        .then((res) => {
                          if (showDebug) {
                            console.log(
                              "saveRecordsApex res: " + JSON.stringify(res)
                            );
                          }
                          if (showDebug) {
                            console.log(res);
                          }

                          if (res.isSuccess == true) {
                            if (showDebug) {
                              console.log("success");
                            }

                            insertAddress({
                              billingAddress: this.billingAddressRecord,
                              shippingAddress: this.shippingAddressRecord
                            })
                              .then((resInsert) => {
                                if (showDebug) {
                                  console.log("Insert address success: ");
                                }
                              })
                              .catch((er) => {
                                if (showDebug) {
                                  console.log("Insert address error: ", er);
                                }
                              });

                            if (this.magasinIsRestrictif == false) {
                              if (showDebug) {
                                console.log("isMagasinRestrictif == false");
                              }
                              if (showDebug) {
                                console.log(res.errorType);
                              }
                              if (showDebug) {
                                console.log(res);
                              }
                              this.contactRecord["Id"] = res.errorType;
                              if (showDebug) {
                                console.log("this.contactRecord");
                              }
                              if (showDebug) {
                                console.log(this.contactRecord);
                              }
                              if (showDebug) {
                                console.log("this.accountRecord");
                              }
                              if (showDebug) {
                                console.log(this.accountRecord);
                              }
                              if (showDebug) {
                                console.log("this.username");
                              }
                              if (showDebug) {
                                console.log(this.username);
                              }
                              if (showDebug) {
                                console.log("this.password");
                              }
                              if (showDebug) {
                                console.log(this.password);
                              }

                              //this.enableUserFuture();
                              if (showDebug) {
                                console.log(this.enableUser());
                              }
                            } else {
                              this.successMessage =
                                "Votre compte a bien été créé. Vous pourrez vous connecter dés que votre requête aura été acceptée par le magasin.";
                              this.selectedStep = "successStep";
                              this.showSpinner = false;
                            }

                            // this.successMessage = 'Votre compte a bien été créé.';
                            // this.selectedStep = "successStep";
                            //this.handleSuccess();
                          } else {
                            //
                            this.errorPageMessage = res.message;
                            if (showDebug) {
                              console.log(
                                "saveRecordsApex Error : " +
                                  res.message +
                                  " Type: " +
                                  res.errorType
                              );
                            }
                            this.errorPage = true;
                            this.showSpinner = false;
                          }
                        })
                        .catch((error) => {
                          if (showDebug) {
                            console.log(
                              "saveRecordsApex catch error: " + error
                            );
                          }
                          if (showDebug) {
                            console.log(
                              "saveRecordsApex catch error: " +
                                JSON.stringify(error)
                            );
                          }
                          //if (showDebug) { console.log (error.body.message);
                          this.showSpinner = false;
                        });
                    })
                    .catch((error) => {
                      if (showDebug) {
                        console.log("saveAccountApex catch error: " + error);
                      }
                      if (showDebug) {
                        console.log(
                          "saveAccountApex catch error: " +
                            JSON.stringify(error)
                        );
                      }
                      //this.errorPageMessage = error.body.message;

                      // this.error = error.body.message;
                      this.errorPage = true;
                      this.showSpinner = false;
                    });
                }
              })
              .catch((error) => {
                this.error = error.message;
              });
          }
        }
      }
    } else {
      this.showSpinner = false;
    }
  }

  isRegistreCommercUploaded() {
    //return this.template.querySelector('[data-id="registreFileUpload"]').hasFile();
    return (
      this.registreFileComponent !== undefined &&
      this.registreFileComponent.hasFile()
    );
  }
  isKBISUploaded() {
    //return this.template.querySelector('[data-id="KBISFileUpload"]').hasFile();
    return (
      this.kbisFileComponent !== undefined && this.kbisFileComponent.hasFile()
    );
  }
  isRIBUploaded() {
    //return this.template.querySelector('[data-id="RIBFileUpload"]').hasFile();
    return (
      this.ribFileComponent !== undefined && this.ribFileComponent.hasFile()
    );
  }
  isPieceIdentiteUploaded() {
    //return this.template.querySelector('[data-id="IDFileUpload"]').hasFile();
    return (
      this.pieceFileComponent !== undefined && this.pieceFileComponent.hasFile()
    );
  }

  clearArray(dirtyArray, sObjectType) {
    let keys = Object.keys(dirtyArray);
    let cleanArray = {
      sobjectType: sObjectType
    };
    keys.forEach((field) => {
      if (typeof dirtyArray[field] == "object") {
        if (showDebug) {
          console.log("object if");
        }
      } else {
        if (showDebug) {
          console.log("object else");
        }
        cleanArray[field] = dirtyArray[field];
      }
    });
    return cleanArray;
  }

  handlePrev() {
    var getselectedStep = this.selectedStep;
    if (getselectedStep === "Step1") {
      this.handleReset();
      const ev = new CustomEvent("previous");
      this.dispatchEvent(ev);
    } else if (getselectedStep === "Step2") {
      //this.handleReset();
      this.selectedStep = "Step1";
    } else if (getselectedStep === "Step3") {
      this.selectedStep = "Step2";
      this.nextButtonClicked = true;
    }
  }

  validateFields() {
    return [...this.template.querySelectorAll("lightning-input-field")].reduce(
      (validSoFar, field) => {
        // Return whether all fields up to this point are valid and whether current field is valid
        // reportValidity returns validity and also displays/clear message on element based on validity
        return validSoFar && field.reportValidity();
      },
      true
    );
  }

  handleSuccess() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s"
      }
    });
  }
  handleFinishError() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s"
      }
    });
  }

  handleContactFieldChange(e) {
    this.contactRecord[e.currentTarget.fieldName] = e.target.value;
    if (showDebug) {
      console.log(
        e.currentTarget.fieldName + " was changed to " + e.target.value
      );
    }
  }

  handleOkCourrierChange(e) {
    this.contactRecord["Accepte_courrier__c"] = e.target.checked;
    if (showDebug) {
      console.log(
        "Accepte_courrier__c" + " was changed to " + e.target.checked
      );
    }
    if (showDebug) {
      console.log("e.target.checked");
    }
    if (showDebug) {
      console.log(e.target.checked);
    }
  }
  handleOkMailChange(e) {
    this.contactRecord["Accepte_eMail__c"] = e.target.checked;
    if (showDebug) {
      console.log("Accepte_eMail__c" + " was changed to " + e.target.checked);
    }
    if (showDebug) {
      console.log("e.target.checked");
    }
    if (showDebug) {
      console.log(e.target.checked);
    }
  }
  handleOkTelChange(e) {
    this.contactRecord["Accepte_telephone__c"] = e.target.checked;
    if (showDebug) {
      console.log(
        "Accepte_telephone__c" + " was changed to " + e.target.checked
      );
    }
    if (showDebug) {
      console.log("e.target.checked");
    }
    if (showDebug) {
      console.log(e.target.checked);
    }
  }
  handleOkSMSChange(e) {
    this.contactRecord["Accepte_SMS__c"] = e.target.checked;
    if (showDebug) {
      console.log("Accepte_SMS__c" + " was changed to " + e.target.checked);
    }
    if (showDebug) {
      console.log("e.target.checked");
    }
    if (showDebug) {
      console.log(e.target.checked);
    }
  }
  handleOkFaxChange(e) {
    this.contactRecord["Accepte_fax__c"] = e.target.checked;
    if (showDebug) {
      console.log("Accepte_fax__c" + " was changed to " + e.target.checked);
    }
    if (showDebug) {
      console.log("e.target.value");
    }
    if (showDebug) {
      console.log(e.target);
    }
  }

  accountDenominationSociale = "";
  accountEnseigneCommerciale = "";
  accountNumeroAssociation = "";

  handleDenominationChange(e) {
    this.accountDenominationSociale = e.target.value;
    this.accountRecord["Name"] = this.accountDenominationSociale;
    if (showDebug) {
      console.log("===> " + this.accountRecord["Name"]);
    }
  }

  handleEnseigneCommercialeChange(e) {
    this.accountEnseigneCommerciale = e.target.value;
    this.accountRecord["Enseigne_commerciale__c"] =
      this.accountEnseigneCommerciale;
  }

  handleNumeroAssociationChange(e) {
    this.accountNumeroAssociation = e.target.value;
    this.accountRecord["N_association__c"] = this.accountNumeroAssociation;
  }

  handleAccountFieldChange(e) {
    this.accountRecord[e.currentTarget.fieldName] = e.target.value;
    if (showDebug) {
      console.log(
        e.currentTarget.fieldName + " was changed to " + e.target.value
      );
    }
    if (showDebug) {
      console.log(this.selectedFormeJuridique);
    }
    if (
      e.currentTarget.fieldName == "Forme_juridique__c" &&
      this.selectedFormeJuridique.label.includes("ASSOCIATION")
    ) {
      this.disableAssociation = false;
    } else if (
      e.currentTarget.fieldName == "Forme_juridique__c" &&
      !this.selectedFormeJuridique.label.includes("ASSOCIATION")
    ) {
      this.disableAssociation = true;
      this.accountRecord["N_association__c"] = Account_N_association__c_FIELD;
    }
  }
  handleAPEChange(e) {
    this.accountRecord["Code_APE__c"] = e.target.value;
    this.resetCodeAPEErrorMessages();
  }

  handleAPEChangeBis(e) {
    //this.accountRecord["Code_APE__c"] = e.target.value;
    this.selectedCodeAPEBis = e.target.value;
    let selectedApe = this.loadedCodesAPE[this.selectedCodeAPEBis];
    this.specialisationOptions = [];
    selectedApe.forEach((el) => {
      this.specialisationOptions.push({
        label: el.Specialisation__c,
        value: el.Id
      });
    });
    this.selectedSpecialisationBis = this.specialisationOptions[0].value;

    if (this.specialisationOptions.length > 1) {
      this.showSpecialisationCombobox = true;
    } else {
      this.showSpecialisationCombobox = false;
    }

    if (showDebug) {
      console.log("SELECTED code object : " + this.getSelecetedCodeApeObject());
    }
  }

  handleSpecialisationChangeBis(e) {
    if (showDebug) {
      console.log(
        "SELCTED spec : " + JSON.stringify(e.target.value.Regroupement__c)
      );
    }
  }

  handleChangeSpecBis(event) {
    this.selectedSpecialisationBis = event.detail.value;
    if (showDebug) {
      console.log(
        "SELECED SPEC : " + JSON.stringify(this.selectedSpecialisationBis)
      );
    }
    if (showDebug) {
      console.log("SELECTED code object : " + this.getSelecetedCodeApeObject());
    }
  }

  getSelecetedCodeApeObject() {
    let selectedApe = this.loadedCodesAPE[this.selectedCodeAPEBis];
    let sel = selectedApe.find(
      (item) => item.Id === this.selectedSpecialisationBis
    );
    return sel;
  }

  @track specialisationOptions = [];
  @track selectedSpecialisationBis;
  @track selectedCodeAPEBis;
  showSpecialisationCombobox = true;
  //value = 'inProgress';

  /*get options() {
    return [
        { label: 'New', value: 'new' },
        { label: 'In Progress', value: 'inProgress' },
        { label: 'Finished', value: 'finished' },
    ];
  }*/

  handleContactSubmit(event) {
    if (showDebug) {
      console.log("Fields");
    }
    if (showDebug) {
      console.log(event.detail.fields);
    }
    if (showDebug) {
      console.log("username");
    }
    if (showDebug) {
      console.log(this.username);
    }

    event.preventDefault(); // stop the form from submitting
    const fields = event.detail.fields;
    if (showDebug) {
      console.log("Fields");
    }
    if (showDebug) {
      console.log(fields);
    }
    if (showDebug) {
      console.log("username");
    }
    if (showDebug) {
      console.log(this.username);
    }

    getUserByUsername({
      username: this.username
    })
      .then((result) => {
        if (result != null) {
          this.errorPageMessage =
            "Cet username existe déjà, veuillez en sélectionner un autre.";
          this.errorPage = true;
          if (showDebug) {
            console.log("username found");
          }
        } else {
          this.userNameOk = true;
          if (showDebug) {
            console.log("username not found");
          }
        }
      })
      .catch((error) => {
        this.error = error.message;
      });

    //this.template.querySelector('lightning-record-edit-form').submit(fields);
  }
  handleContactFormSuccess(event) {
    const payload = event.detail;
    if (showDebug) {
      console.log(JSON.stringify(payload));
    }

    const updatedRecord = event.detail.id;
    if (showDebug) {
      console.log("onsuccess: ", updatedRecord);
    }
  }
  handleReset() {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
  }

  validatePassword(password) {
    var patt1 = /[a-z]/;
    var patt2 = /[A-Z]/; // /[^a-zA-Z\d]/g
    var patt3 = /[0-9]/;
    var patt4 = /[^a-zA-Z\d]/;

    var result1 = password.match(patt1);
    var result2 = password.match(patt2);
    var result3 = password.match(patt3);
    var result4 = password.match(patt4);

    if (showDebug) {
      console.log(
        "result1: " +
          result1 +
          ", result2: " +
          result2 +
          ", result3: " +
          result3
      );
    }
    if (result1 == null && result2 == null) return false;
    if (result3 == null) return false;
    if (result4 == null) return false;

    var len = password.length;
    if (len < 12) return false;
    return true;
  }

  setAddresses() {
    //needs to be done dynamically if possible
    this.accountRecord["BillingCity"] = this.city;
    this.accountRecord["BillingCountry"] = this.countryLabel;
    this.accountRecord["BillingPostalCode"] = this.postalCode;
    this.accountRecord["BillingStreet"] =
      this.numVoie + " " + this.typeVoie + " " + this.nomVoie;
    this.accountRecord["ShippingCity"] = this.city;
    this.accountRecord["ShippingCountry"] = this.countryLabel;
    this.accountRecord["ShippingPostalCode"] = this.postalCode;
    this.accountRecord["ShippingState"] = this.state;
    this.accountRecord["ShippingStreet"] =
      this.numVoie + " " + this.typeVoie + " " + this.nomVoie;
    if (this.getContactMobile() !== undefined) {
      this.accountRecord["Telephone_Siret__c"] = this.getContactMobile();
    }
    /*if (this.getContactMobilePhone() !== undefined) {
      this.accountRecord["Telephone_Siret__c"] = this.getContactMobilePhone();
    }*/

    this.contactRecord["MailingCity"] = this.city;
    this.contactRecord["MailingCountry"] = this.countryLabel;
    this.contactRecord["MailingPostalCode"] = this.postalCode;
    this.contactRecord["MailingStreet"] =
      this.numVoie + " " + this.typeVoie + " " + this.nomVoie;

    this.billingAddressRecord["Numero_de_voie__c"] = this.numVoie;
    this.billingAddressRecord["Type_de_voie__c"] = this.typeVoie;
    this.billingAddressRecord["Nom_de_voie__c"] = this.nomVoie;
    this.billingAddressRecord["City"] = this.city;
    this.billingAddressRecord["Pays__c"] = this.country;
    this.billingAddressRecord["PostalCode"] = this.postalCode;
    this.billingAddressRecord["Codes_Postaux__c"] = this.selectedPostalCodeId;
    this.billingAddressRecord["State"] = this.state;
    this.billingAddressRecord["Name"] =
      "Facturation :" + this.numVoie + " " + this.typeVoie + " " + this.nomVoie;

    this.shippingAddressRecord["Numero_de_voie__c"] = this.numVoie;
    this.shippingAddressRecord["Type_de_voie__c"] = this.typeVoie;
    this.shippingAddressRecord["Nom_de_voie__c"] = this.nomVoie;
    this.shippingAddressRecord["City"] = this.city;
    this.shippingAddressRecord["Pays__c"] = this.country;
    this.shippingAddressRecord["PostalCode"] = this.postalCode;
    this.shippingAddressRecord["Codes_Postaux__c"] = this.selectedPostalCodeId;
    this.shippingAddressRecord["State"] = this.state;
    this.shippingAddressRecord["Name"] =
      "Expédition :" + this.numVoie + " " + this.typeVoie + " " + this.nomVoie;
  }

  getContactMobile() {
    if (typeof this.contactRecord["Phone"] == "object") {
      return undefined;
    }
    return this.contactRecord["Phone"];
  }

  getContactMobilePhone() {
    if (typeof this.contactRecord["Telephone_portable__c"] == "object") {
      return undefined;
    }
    return this.contactRecord["Telephone_portable__c"];
  }
}

// createRecord({ apiName: CONTACT_OBJECT.objectApiName, fields: this.contactRecord })
// .then(contact => {
// this.dispatchEvent(
// new ShowToastEvent({
// title: 'Success',
// message: 'Contact created from saveForm => ' + contact.id,
// variant: 'success'
// })
// );
// })
// .catch((error) => {
// this.dispatchEvent(
// new ShowToastEvent({
// title: 'Error creating record',
// message: error.body.message,
// variant: 'error'
// })
// );
// });

// createRecord({ apiName: CONTACTPOINTADDRESS_OBJECT.objectApiName, fields: this.billingAddressRecord })
// .then(billingAddress => {
// this.dispatchEvent(
// new ShowToastEvent({
// title: 'Success',
// message: 'Billing Address created from saveForm => ' + billingAddress.id,
// variant: 'success'
// })
// );
// })
// .catch((error) => {
// this.dispatchEvent(
// new ShowToastEvent({
// title: 'Error creating record',
// message: error.body.message,
// variant: 'error'
// })
// );
// });

// createRecord({ apiName: CONTACTPOINTADDRESS_OBJECT.objectApiName, fields: this.shippingAddressRecord })
// .then(shippingAddress => {
// this.dispatchEvent(
// new ShowToastEvent({
// title: 'Success',
// message: 'Shipping Address created from saveForm => ' + shippingAddress.id,
// variant: 'success'
// })
// );
// })
// .catch((error) => {
// this.dispatchEvent(
// new ShowToastEvent({
// title: 'Error creating record',
// message: error.body.message,
// variant: 'error'
// })
// );
// });