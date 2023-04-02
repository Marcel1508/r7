import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getUserByUsername from "@salesforce/apex/selfRegService.getUserByUsername";
import getCodesAPE from "@salesforce/apex/selfRegService.getCodesAPE";
import getCodesAPEBis from "@salesforce/apex/selfRegService.getCodesAPEBis";
import getPickListValues from "@salesforce/apex/selfRegService.getPickListValues";
import updateAccountInfo from "@salesforce/apex/selfRegService.updateAccountInfo";
import enablePortalUserForContactWithoutEmail from "@salesforce/apex/selfRegService.enablePortalUserForContactWithoutEmail";
import updatePieceJustificatifFields from "@salesforce/apex/selfRegService.updatePieceJustificatifFields";
import activeExistingLead from "@salesforce/apex/selfRegService.activeExistingLead";

// importing to get the object info
import { getObjectInfo } from "lightning/uiObjectInfoApi";
// importing Object schemas
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import CONTACTPOINTADDRESS_OBJECT from "@salesforce/schema/ContactPointAddress";

// Account fields
import Account_Id_FIELD from "@salesforce/schema/Account.Id";
import Account_RecordType_FIELD from "@salesforce/schema/Account.RecordTypeId";
import Account_SiretText__c_FIELD from "@salesforce/schema/Account.SiretText__c";
import Account_Name_FIELD from "@salesforce/schema/Account.Name";
import Account_Enseigne_commerciale__c_FIELD from "@salesforce/schema/Account.Enseigne_commerciale__c";
import Account_Date_creation_etablissement__c_FIELD from "@salesforce/schema/Account.Date_creation_etablissement__c";
import Account_Code_APE__c_FIELD from "@salesforce/schema/Account.Code_APE__c";
import Account_Theme__c_FIELD from "@salesforce/schema/Account.Theme__c";
import Account_Forme_juridique__c_FIELD from "@salesforce/schema/Account.Forme_juridique__c";
import Account_Magasin_de_rattachement__c_FIELD from "@salesforce/schema/Account.Magasin_de_rattachement__c";
import Account_Etablissement_geographique__c_FIELD from "@salesforce/schema/Account.Etablissement_geographique__c";
import Account_N_association__c_FIELD from "@salesforce/schema/Account.N_association__c";
import Account_Email__c_FIELD from "@salesforce/schema/Account.Email__c";
import Account_Telephone_Siret__c_FIELD from "@salesforce/schema/Account.Telephone_Siret__c";
import Account_Fax_FIELD from "@salesforce/schema/Account.Fax";
//account shipping fields
import Account_ShippingCity_FIELD from "@salesforce/schema/Account.ShippingCity";
import Account_ShippingCountry_FIELD from "@salesforce/schema/Account.ShippingCountry";
// import Account_ShippingCountryCode_FIELD from '@salesforce/schema/Account.ShippingCountryCode';
import Account_ShippingPostalCode_FIELD from "@salesforce/schema/Account.ShippingPostalCode";
import Account_ShippingState_FIELD from "@salesforce/schema/Account.ShippingState";
// import Account_ShippingStateCode_FIELD from '@salesforce/schema/Account.ShippingStateCode';
import Account_ShippingStreet_FIELD from "@salesforce/schema/Account.ShippingStreet";

//account billing fields
import Account_BillingCity_FIELD from "@salesforce/schema/Account.BillingCity";
import Account_BillingCountry_FIELD from "@salesforce/schema/Account.BillingCountry";
// import Account_BillingCountryCode_FIELD from '@salesforce/schema/Account.Name';
import Account_BillingPostalCode_FIELD from "@salesforce/schema/Account.BillingPostalCode";
import Account_BillingState_FIELD from "@salesforce/schema/Account.BillingState";
// import Account_BillingStateCode_FIELD from '@salesforce/schema/Account.Name';
import Account_BillingStreet_FIELD from "@salesforce/schema/Account.BillingStreet";
import Account_Specialisation_FIELD from "@salesforce/schema/Account.Specialisation__c";

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
import Contact_AccountId_FIELD from "@salesforce/schema/Contact.AccountId";

//contact Mailing fields
import Contact_MailingCity_FIELD from "@salesforce/schema/Contact.MailingCity";
import Contact_MailingCountry_FIELD from "@salesforce/schema/Contact.MailingCountry";
// import Contact_MailingCountry_FIELD_MailingCountryCode_FIELD from '@salesforce/schema/Contact.MailingCountryCode';
import Contact_MailingPostalCode_FIELD from "@salesforce/schema/Contact.MailingPostalCode";
import Contact_MailingState_FIELD from "@salesforce/schema/Contact.MailingState";
// import Contact_MailingCountry_FIELD_MailingStateCode_FIELD from '@salesforce/schema/Contact.MailingStateCode';
import Contact_MailingStreet_FIELD from "@salesforce/schema/Contact.MailingStreet";

//contact ContactPointAddress fields
import ContactPointAddress_NumeroDeVoie_FIELD from "@salesforce/schema/ContactPointAddress.Numero_de_voie__c";
import ContactPointAddress_TypeDeVoie_FIELD from "@salesforce/schema/ContactPointAddress.Type_de_voie__c";
import ContactPointAddress_NomDeVoie_FIELD from "@salesforce/schema/ContactPointAddress.Nom_de_voie__c";
import ContactPointAddress_Id_FIELD from "@salesforce/schema/ContactPointAddress.Id";
import ContactPointAddress_City_FIELD from "@salesforce/schema/ContactPointAddress.City";
import ContactPointAddress_Country_FIELD from "@salesforce/schema/ContactPointAddress.Country";
// import Contact_Country_FIELD_CountryCode_FIELD from '@salesforce/schema/ContactPointAddress.CountryCode';
import ContactPointAddress_PostalCode_FIELD from "@salesforce/schema/ContactPointAddress.PostalCode";
import ContactPointAddress_codesPostaux_FIELD from "@salesforce/schema/ContactPointAddress.Codes_Postaux__c";
import ContactPointAddress_State_FIELD from "@salesforce/schema/ContactPointAddress.State";
// import Contact_Country_FIELD_StateCode_FIELD from '@salesforce/schema/Contact.StateCode';
import ContactPointAddress_Street_FIELD from "@salesforce/schema/ContactPointAddress.Street";
import ContactPointAddress_Pays_FIELD from "@salesforce/schema/ContactPointAddress.Pays__c";
import ContactPointAddress_Name_FIELD from "@salesforce/schema/ContactPointAddress.Name";
import ContactPointAddress_AddressType_FIELD from "@salesforce/schema/ContactPointAddress.AddressType";
import ContactPointAddress_IsDefault_FIELD from "@salesforce/schema/ContactPointAddress.IsDefault";
import ContactPointAddress_ParentId_FIELD from "@salesforce/schema/ContactPointAddress.ParentId";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class SelfRegSiretExistsLeadCreationComponent extends NavigationMixin(
  LightningElement
) {
  @track selectedStep = "Step2";
  showSpinner = false;
  @api account;
  @api street;
  @api city;
  @api state;
  @api country;
  @api countryLabel;
  @api postalCode;
  @api selectedPostalCodeId;
  @api selectedMyZone;
  @api selectedAllZone;
  @api chooseMagasinFromMyPostalCode;
  //New Address fields
  @api numVoie;
  @api typeVoie;
  @api nomVoie;
  selectedMagasinId;
  selectedMagasin;
  @track recordTypes = [];
  magasinIsRestrictif;
  magasinName;
  successMessage;
  errorPageMessage;

  isKbisError = false;
  kbisErrorMessage = "";

  @track agreedCGV = false;
  @track agreedPromoCGU = false;

  @track selectedOption;
  @track openModalCGUCGV = false;
  @track openModalpromotionaloffers = false;
  @track optionsAPE;
  @track optionsTheme;
  @track codeAPE;
  @track accountRecord = {
    sobjectType: "Account",
    RecordTypeId: Account_RecordType_FIELD,
    SiretText__c: Account_SiretText__c_FIELD,
    Name: Account_Name_FIELD,
    Enseigne_commerciale__c: Account_Enseigne_commerciale__c_FIELD,
    Date_creation_etablissement__c: Account_Date_creation_etablissement__c_FIELD,
    Code_APE__c: Account_Code_APE__c_FIELD,
    Theme__c: Account_Theme__c_FIELD,
    Forme_juridique__c: Account_Forme_juridique__c_FIELD,
    Magasin_de_rattachement__c: Account_Magasin_de_rattachement__c_FIELD,
    Etablissement_geographique__c: Account_Etablissement_geographique__c_FIELD,
    N_association__c: Account_N_association__c_FIELD,
    Email__c: Account_Email__c_FIELD,
    Telephone_Siret__c: Account_Telephone_Siret__c_FIELD,
    Fax: Account_Fax_FIELD,
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
    AccountId: Contact_AccountId_FIELD,
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
    // MailingCountryCode: Contact_MailingCountryCode_FIELD,
    MailingPostalCode: Contact_MailingPostalCode_FIELD,
    MailingState: Contact_MailingState_FIELD,
    // MailingStateCode: Contact_MailingStateCode_FIELD,
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

  //SOUS STEP PASSWORD
  username = "";
  password = "";
  repeatPassword = "";
  isCredentialError = false;
  credentialErrorMessage = "";
  isUsernameError = false;
  usernameErrorMessage = "";

  @track optionsRole;
  @track optionsFormeJuridique;
  @track disableAssociation = true;

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
      if (showDebug) { console.log ("this.recordTypes");}
      if (showDebug) { console.log (JSON.stringify(this.recordTypes));}
    } else if (error) {
      window.console.log ("Error ===> " + JSON.stringify(error));
    }
  }

  @track optionsAPEBis = [];

  connectedCallback() {

    getCodesAPEBis()
      .then(data => {
        this.optionsAPEBis = [];

        Object.keys(data).forEach(el => {
          this.optionsAPEBis.push({value: el, label: el});
        });
        this.loadedCodesAPE = data;

        this.selectedCodeAPEBis = this.optionsAPEBis[0].value; // init first selected code APE
        let firstEl = this.loadedCodesAPE[this.selectedCodeAPEBis];
        firstEl.forEach(el => {
          this.specialisationOptions.push({label: el.Specialisation__c, value: el.Id});
        });

        this.selectedSpecialisationBis = firstEl[0].Id;

        if(this.specialisationOptions.length > 1) {
          this.showSpecialisationCombobox = true;
        } else {
          this.showSpecialisationCombobox = false;
        }
        if (showDebug) { console.log ('***INIT selectedSpecialisationBis: ' + JSON.stringify(this.selectedSpecialisationBis));}
      })
      .catch(error => {
        this.displayError(error);
      });

    getPickListValues({
      objApiName: "Account",
      fieldName: "Forme_juridique__c"
    })
      .then(data => {
        this.optionsFormeJuridique = data;
      })
      .catch(error => {
        if (showDebug) { console.log ("forme juridique error");}
        if (showDebug) { console.log (error);}
        this.displayError(error);
      });

    //Init Contact fields
    if(this.account.Contacts !== undefined) {
      if (this.account.Contacts[0].FirstName !== undefined) {
        this.contactRecord.FirstName = this.account.Contacts[0].FirstName;
      }
      if (this.account.Contacts[0].LastName !== undefined) {
        this.contactRecord.LastName = this.account.Contacts[0].LastName;
      }
      if (this.account.Contacts[0].Salutation !== undefined) {
        this.contactRecord.Salutation = this.account.Contacts[0].Salutation;
      } else {
        this.contactRecord.Salutation = "";
      }
      if (this.account.Contacts[0].Roles__c !== undefined) {
        this.contactRecord.Roles__c = this.account.Contacts[0].Roles__c;
      }

      if (this.account.Contacts[0].Phone !== undefined) {
        this.contactRecord.Phone = this.account.Contacts[0].Phone;
      }
      if (this.account.Contacts[0].Telephone_portable__c !== undefined) {
        this.contactRecord.Telephone_portable__c = this.account.Contacts[0].Telephone_portable__c;
      }
    } else {
      this.contactRecord.Salutation = 'M';
    }
    
    if (showDebug) { console.log ("selectedMyZone: " + this.selectedMyZone);}
    if (showDebug) { console.log (
      "this.chooseMagasinFromMyPostalCode: " +
        this.chooseMagasinFromMyPostalCode
    );}
    //Init Account fields
    if (this.chooseMagasinFromMyPostalCode == false) {
      if (showDebug) { console.log ("1==");}
      this.accountRecord[
        "Magasin_de_rattachement__c"
      ] = this.selectedAllZone.magasinId;
      if (this.selectedMyZone !== undefined) {
        this.accountRecord[
          "Etablissement_geographique__c"
        ] = this.selectedMyZone.magasinId;
      }
      this.magasinIsRestrictif = this.selectedAllZone.restrictif;
      this.magasinName = this.selectedAllZone.magasinName;
    } else {
      if (showDebug) { console.log ("2==");}
      this.accountRecord[
        "Magasin_de_rattachement__c"
      ] = this.selectedMyZone.magasinId;
      this.accountRecord[
        "Etablissement_geographique__c"
      ] = this.selectedMyZone.magasinId;
      this.magasinIsRestrictif = this.selectedMyZone.restrictif;
      this.magasinName = this.selectedMyZone.magasinName;
    }

    if (showDebug) { console.log (
      "this.account.Enseigne_commerciale__c: " +
        this.account.Enseigne_commerciale__c
    );}

    if (showDebug) { console.log (
      "Magasin_de_rattachement__c: " +
        this.accountRecord["Magasin_de_rattachement__c"]
    );}
    if (showDebug) { console.log (
      "Magasin_geographique__c: " +
        this.accountRecord["Etablissement_geographique__c"]
    );}

    if (this.account.Name !== undefined) {
      this.accountRecord.Name = this.account.Name;
    }
    if (this.account.Enseigne_commerciale__c !== undefined) {
      this.accountRecord.Enseigne_commerciale__c = this.account.Enseigne_commerciale__c;
    } else {
      this.accountRecord.Enseigne_commerciale__c = "";
    }

    if (this.account.Date_creation_etablissement__c !== undefined) {
      this.accountRecord.Date_creation_etablissement__c = this.account.Date_creation_etablissement__c;
    }
    if (this.account.Theme__c !== undefined) {
      this.accountRecord.Theme__c = this.account.Theme__c;
    }
    if (this.account.Email__c !== undefined) {
      this.accountRecord.Email__c = this.account.Email__c;
    }
    if (this.account.Forme_juridique__c !== undefined) {
      this.accountRecord.Forme_juridique__c = this.account.Forme_juridique__c;
    }
    if (this.account.N_association__c !== undefined) {
      this.accountRecord.N_association__c = this.account.N_association__c;
    }
  }

  specialisationValues;
  nextButtonClicked = false;
  initialized = false;
  selectedSpec;
  spec;
  isSpecError = false;
  specErrorMessage = "";
  isCodeAPEError = false;
  codeAPEErrorMessage = "";
  agreedCGVErrorMessage = "";

  renderedCallback() {
    if (showDebug) { console.log ("renderedCallback donotexists rendredcallback");}
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
          this.nextButtonClicked = true;
          this.initialized = true;
          if (this.template.querySelector("datalist") !== null) {
            let listId = this.template.querySelector("datalist").id;
            if (showDebug) { console.log ("listId: " + JSON.stringify(listId));
            //this.template.querySelector("input[data-id=inputVoie]").setAttribute("list", listId);
            this.template
              .querySelector("input[name=inputSpec]")
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
      item => item.label === selectedVoieVar
    );
    if (showDebug) { console.log ("selectedVoieVar; " + JSON.stringify(this.selectedSpec));}

    if (this.selectedSpec == undefined) {
      this.showSpecError();
    } else {
      this.spec = this.selectedSpec.value;
      //this.typeVoieTypingValue = this.typeVoie;
      this.resetSpecErrorMessages();
    }
  }

  showSpecError() {
    this.template
      .querySelector('[data-id="specElement"]')
      .classList.add("slds-has-error");
    this.isSpecError = true;
    this.specErrorMessage = "Valuer incorrecte";
  }

  resetSpecErrorMessages() {
    this.isSpecError = false;
    this.template
      .querySelector('[data-id="specElement"]')
      .classList.remove("slds-has-error");
  }

  ifAgreedCGV() {
    if(this.agreedCGV == false) {
      this.showAgreedCGVErrorMessages();
      return false;
    }
    this.resetAgreedCGVErrorMessages();
    return true;
  }

  showAgreedCGVErrorMessages() {
    this.template
      .querySelector('[data-id="agreedCGVElement"]')
      .classList.add("slds-has-error");

    if (showDebug) { console.log ('erroooooooor');}
    this.isAgreedCGVError = true;
    this.agreedCGVErrorMessage = "Vous devez lire et accepter les conditions générales de vente";
  }

  resetAgreedCGVErrorMessages() {
    this.isAgreedCGVError = false;
    this.template
      .querySelector('[data-id="agreedCGVElement"]')
      .classList.remove("slds-has-error");
  }

  validateSpecInput() {
    if (this.selectedSpec == undefined) {
      this.showSpecError();
      return false;
    } else {
      this.resetSpecErrorMessages();
      return true;
    }
  }

  validateCodeAPEInput() {
    if (typeof this.accountRecord["Code_APE__c"] == "object") {
      this.showCodeAPEError();
      return false;
    }
    this.resetCodeAPEErrorMessages();
    return true;
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

  registreFileComponent;
  kbisFileComponent;
  ribFileComponent;
  pieceFileComponent;

  handleNext() {
    var getselectedStep = this.selectedStep;
    this.isCredentialError = false;
    this.isKbisError = false;

    if (!this.validateFields()) {
      if (showDebug) { console.log ("Error");}
    } else if (getselectedStep === "Step3") {
      this.isCredentialError = false;
      this.isUsernameError = false;
      if (showDebug) { console.log ("username: " + this.username);}
      if (showDebug) { console.log ("password: " + this.password);}
      if (showDebug) { console.log ("repeat pass: " + this.repeatPassword);}

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
      if (showDebug) { console.log (
        "errorUsername: " +
          errorUsername +
          ", errorPassword: " +
          errorPassword +
          ", errorRepeatPassword: " +
          errorRepeatPassword
      );}
      if (
        errorUsername == true ||
        errorPassword == true ||
        errorRepeatPassword == true
      ) {
        //Nothing to do, wiating for user to correct inputs
      } else {
        if (this.checkTelephonesFields() == false) {
          this.isCredentialError = true;
          this.credentialErrorMessage =
            "Veuillez saisir un Téléphone fixe ou bien un Téléphone mobile";
        } else if (
          this.username == "" ||
          this.password == "" ||
          this.repeatPassword == ""
        ) {
          this.isCredentialError = true;
          this.credentialErrorMessage =
            "Veuillez saisir un email de connexion et mot de passe";
        } else {
          if (this.password !== this.repeatPassword) {
            this.isCredentialError = true;
            this.credentialErrorMessage =
              "Les mots de passe saisis ne sont pas identiques";
          } else if (this.validatePassword(this.password) == false) {
            this.isCredentialError = true;
            this.credentialErrorMessage =
            "Le mot de passe doit contenir au moins 12 caractères dont 1 lettre, 1 chiffre et 1 caractère spécial.";
          } else {
            if (showDebug) { console.log ("correct");}
            getUserByUsername({
              username: this.username
            })
              .then(result => {
                if (result != null) {
                  this.credentialErrorMessage =
                    "Ce username existe déjà, veuillez en saisir un autre.";
                  this.isCredentialError = true;
                  if (showDebug) { console.log ("username found");}
                } else {
                  //this.selectedStep = 'Step3';
                  //this.userNameOk = true;
                  if (showDebug) { console.log ("username OK");}
                  // const fields = this.template.querySelectorAll('lightning-input-field');
                  // if (showDebug) { console.log ('fields');
                  // if (showDebug) { console.log (fields);

                  if (showDebug) { console.log ("this.contactRecord");}
                  if (showDebug) { console.log (this.contactRecord);}
                  if (showDebug) { console.log ("this.accountRecord");}
                  if (showDebug) { console.log (this.accountRecord);}

                  this.showSpinner = true;
                  //Content
                  this.setAddresses();
                  //var registreUploaded = false;
                  var ribUploaded = false;
                  var pieceIdentiteUploaded = false;

                  if (showDebug) { console.log ("isRIBUploaded(): " + this.isRIBUploaded());}
                  if (showDebug) { console.log (
                    "isPieceIdentiteUploaded(): " +
                      this.isPieceIdentiteUploaded()
                  );}

                  /*if (this.isRegistreCommercUploaded() == true) {
                    registreUploaded = true;
                  }*/
                  if (this.isRIBUploaded() == true) {
                    ribUploaded = true;
                  }
                  if (this.isPieceIdentiteUploaded() == true) {
                    pieceIdentiteUploaded = true;
                  }

                  this.accountRecord = this.clearArray(
                    this.accountRecord,
                    "Account"
                  );
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
                  //TODO
                  if (showDebug) { console.log (
                    "accountRecord to Update : " +
                      JSON.stringify(this.accountRecord)
                  );}
                  let createAccountB = true;
                  if(this.account.Contacts !== undefined) {
                    createAccountB = false;
                  }
                  if (showDebug) { console.log ('createAccountB == ' + createAccountB);}
                  updateAccountInfo({
                    objAcc: this.accountRecord,
                    billAddress: this.billingAddressRecord,
                    shipAddress: this.shippingAddressRecord,
                    contact: this.contactRecord,
                    createContact: createAccountB
                  })
                    .then(res => {
                      if (showDebug) { console.log (
                        "updateAccountInfo res: " + JSON.stringify(res)
                      );}
                      if (res.isSuccess == true) {
                        let contactObjId = null;
                        if(this.account.Contacts !== undefined) {
                          contactObjId = this.account.Contacts[0].Id;
                        }
                        enablePortalUserForContactWithoutEmail({
                          accountid: this.account.Id,
                          contactId: contactObjId,
                          email: this.username,
                          password: this.password
                        })
                          .then(resEnable => {
                            if (showDebug) { console.log (
                              "enablePortalUserForContactWithoutEmail res: " +
                                JSON.stringify(resEnable)
                            );}
                            //Save files

                            if (resEnable.isSuccess == false) {
                              this.selectedStep = "errorPage";
                              this.errorPageMessage = resEnable.message;
                            } else {
                              this.kbisFileComponent.handleSave();

                              /*if (registreUploaded == true) {
                                this.registreFileComponent.handleSave();
                              }*/
                              if (ribUploaded == true) {
                                this.ribFileComponent.handleSave();
                              }
                              if (pieceIdentiteUploaded == true) {
                                this.pieceFileComponent.handleSave();
                              }

                              if (this.magasinIsRestrictif === false) {
                                //Enable account
                                updatePieceJustificatifFields({
                                  accountId: this.account.Id,
                                  registreCommerce: false,
                                  kbis: true,
                                  rib: ribUploaded,
                                  pieceIdentite: pieceIdentiteUploaded
                                })
                                  .then(res => {
                                    if (showDebug) { console.log (
                                      "updatePieceJustificatifFields res: " +
                                        JSON.stringify(res)
                                    );}
                                  })
                                  .catch(err => {
                                    this.selectedStep = "errorPage";
                                    this.errorPageMessage =
                                      "veuillez contacter votre administrateur";
                                  });

                                activeExistingLead({
                                  accountId: this.account.Id,
                                  magasinDeRattachementId: this.accountRecord[
                                    "Magasin_de_rattachement__c"
                                  ]
                                })
                                  .then(result => {
                                    if (showDebug) { console.log (
                                      "activeExistingLead res: " +
                                        JSON.stringify(result)
                                    );}
                                    if (result.isSuccess == true) {
                                      this.selectedStep = "successPage";
                                      this.successMessage =
                                        "votre compte a été créé avec succès";
                                    } else {
                                      this.selectedStep = "errorPage";
                                      this.errorPageMessage =
                                        "veuillez contacter votre administrateur";
                                    }
                                  })
                                  .catch(err => {
                                    if (showDebug) { console.log (
                                      "activeExistingLead err: " +
                                        JSON.stringify(err)
                                    );}
                                    this.selectedStep = "errorPage";
                                    this.errorPageMessage =
                                      "veuillez contacter votre administrateur";
                                  });
                              } else {
                                updatePieceJustificatifFields({
                                  accountId: this.account.Id,
                                  registreCommerce: false,
                                  kbis: true,
                                  rib: ribUploaded,
                                  pieceIdentite: pieceIdentiteUploaded
                                })
                                  .then(res => {
                                    if (showDebug) { console.log (
                                      "updatePieceJustificatifFields res: " +
                                        JSON.stringify(res)
                                    );}
                                    this.selectedStep = "successPage";
                                    this.successMessage =
                                      "votre compte a été créé avec succès";
                                  })
                                  .catch(err => {
                                    this.selectedStep = "errorPage";
                                    this.errorPageMessage =
                                      "veuillez contacter votre administrateur";
                                  });
                              }
                            }
                            this.showSpinner = false;
                          })
                          .catch(err => {
                            if (showDebug) { console.log ("SUCESS: " + JSON.stringify(err));}
                            this.showSpinner = false;
                          });
                      } else {
                        if (showDebug) { console.log ("updateAccountInfo error update : " + JSON.stringify(res));}
                        this.selectedStep = "errorPage";
                        this.errorPageMessage = "veuillez contacter votre administrateur";
                        this.showSpinner = false;
                      }
                    })
                    .catch(err => {
                      if (showDebug) { console.log ("error: " + JSON.stringify(err));}
                      this.showSpinner = false;
                    });
                }
              })
              .catch(error => {
                this.error = error.message;
              });
          }
        }
      }
    } else if (getselectedStep === "Step2") {
      //STEP 2
      //var specInputValidation = this.validateSpecInput();
      //var apeVlidation = this.validateCodeAPEInput();

      this.kbisFileComponent = this.template.querySelector(
        '[data-id="KBISFileUpload"]'
      );

      if (this.isKBISUploaded() == false) {
        this.isKbisError = true;
        this.kbisErrorMessage = "Veuillez télécharger un fichier KBIS";
      } else if (this.ifAgreedCGV() == true) {
        if (showDebug) { console.log ("pas d erreur kbis");}
        /*this.registreFileComponent = this.template.querySelector(
          '[data-id="registreFileUpload"]'
        );*/
        this.kbisFileComponent = this.template.querySelector(
          '[data-id="KBISFileUpload"]'
        );
        this.ribFileComponent = this.template.querySelector(
          '[data-id="RIBFileUpload"]'
        );
        this.pieceFileComponent = this.template.querySelector(
          '[data-id="PieceIdentiteFileUpload"]'
        );

        this.selectedStep = "Step3";
      }
    }
  }

  handleLireCGV(evt) {
    const element = this.template.querySelector('[data-id="dataID-lireCGV"]');
    this.agreedCGV = element.checked;
    if (showDebug) { console.log ("checkbox clicked" + JSON.stringify(this.agreedCGV));}
  }

  redirectToCGV() {
    if (showDebug) { console.log ("link clicked");}

    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s/selfreg-conditions-generales-de-vente"
      }
    }).then(url => {
      window.open(url, "_blank");
    });
  }

  handleLirePromoCGU(evt) {
    const element = this.template.querySelector(
      '[data-id="dataID-lirePromoCGU"]'
    );
    this.agreedPromoCGU = element.checked;
    if (showDebug) { console.log ("checkbox clicked" + JSON.stringify(this.agreedPromoCGU));}
  }

  redirectToPromoCGU() {
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s/selfreg-promotions"
      }
    }).then(url => {
      window.open(url, "_blank");
    });
  }

  checkTelephonesFields() {
    if (showDebug) { console.log ("phone: " + this.contactRecord["Phone"]);}
    if (showDebug) { console.log (
      "Telephone_portable__c: " + this.contactRecord["Telephone_portable__c"]
    );}

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

  /*isRegistreCommercUploaded() {
    //return this.template.querySelector('[data-id="registreFileUpload"]').hasFile();
    return (
      this.registreFileComponent !== undefined &&
      this.registreFileComponent.hasFile()
    );
  }*/
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

  setAddresses() {
    //needs to be done dynamically if possible
    if (this.magasinIsRestrictif === false) {
      if (showDebug) { console.log ("magasinNonRestrictif");}
      this.accountRecord["RecordTypeId"] = this.recordTypes.find(
        item => item.label === "Prospect"
      ).value;
      this.accountRecord["Magasin_actif_en_cours__c"] = this.accountRecord[
        "Magasin_de_rattachement__c"
      ];
      this.accountRecord["Statut_Fiche_client__c"] = "Prospect";
      this.accountRecord["IsBuyer"] = true;
    }
    if (showDebug) { console.log ('countryLabel: ' + this.countryLabel);}
    if (showDebug) { console.log ('country: ' + this.country);}

    this.accountRecord["Id"] = this.account.Id;
    this.accountRecord["BillingCity"] = this.city;
    this.accountRecord["BillingCountry"] = this.countryLabel;
    this.accountRecord["BillingPostalCode"] = this.postalCode;
    this.accountRecord["BillingState"] = this.state;
    this.accountRecord["BillingStreet"] =
      this.numVoie + " " + this.typeVoie + " " + this.nomVoie;
    this.accountRecord["ShippingCity"] = this.city;
    this.accountRecord["ShippingCountry"] = this.countryLabel;
    this.accountRecord["ShippingPostalCode"] = this.postalCode;
    this.accountRecord["ShippingState"] = this.state;
    this.accountRecord["ShippingStreet"] =
      this.numVoie + " " + this.typeVoie + " " + this.nomVoie;
    this.accountRecord["Email__c"] = this.username;
    this.accountRecord["Specialisation__c"] = this.spec;
    this.accountRecord["Code_APE__c"] = this.getSelecetedCodeApeObject().Id;

    if (this.getContactMobile() !== undefined) {
      this.accountRecord["Telephone_Siret__c"] = this.getContactMobile();
    }
    /*if (this.getContactMobilePhone() !== undefined) {
      this.accountRecord["Telephone_Siret__c"] = this.getContactMobilePhone();
    }*/

    if(this.account.Contacts !== undefined) {
      this.contactRecord["Id"] = this.account.Contacts[0].Id;
    }
    this.contactRecord["MailingCity"] = this.city;
    this.contactRecord["MailingCountry"] = this.countryLabel;
    this.contactRecord["MailingPostalCode"] = this.postalCode;
    this.contactRecord["MailingState"] = this.state;
    this.contactRecord["MailingStreet"] =
      this.numVoie + " " + this.typeVoie + " " + this.nomVoie;
    this.contactRecord["AccountId"] = this.account.Id;
    this.contactRecord["Email"] = this.username;

    this.contactRecord["Accepte_courrier__c"] = true;
    this.contactRecord["Accepte_fax__c"] = true;
    this.contactRecord["Accepte_eMail__c"] = true;
    this.contactRecord["Accepte_telephone__c"] = true;
    this.contactRecord["Accepte_SMS__c"] = true;

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
    this.billingAddressRecord["ParentId"] = this.account.Id;

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
    this.shippingAddressRecord["ParentId"] = this.account.Id;
  }

  handleSuccess() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s"
      }
    });
  }

  handleAPEChange(e) {
    this.accountRecord["Code_APE__c"] = e.target.value;
    //this.resetCodeAPEErrorMessages();
  }

  clearArray(dirtyArray, sObjectType) {
    let keys = Object.keys(dirtyArray);
    let cleanArray = {
      sobjectType: sObjectType
    };
    keys.forEach(field => {
      if (typeof dirtyArray[field] == "object") {
        if (showDebug) { console.log ("object if");}
      } else {
        if (showDebug) { console.log ("object else");}
        cleanArray[field] = dirtyArray[field];
      }
    });
    return cleanArray;
  }

  handleAPEChangeBis(e) {
    //this.accountRecord["Code_APE__c"] = e.target.value;
    this.selectedCodeAPEBis = e.target.value;
    let selectedApe = this.loadedCodesAPE[this.selectedCodeAPEBis];
    this.specialisationOptions = [];
    selectedApe.forEach(el => {
      this.specialisationOptions.push({label: el.Specialisation__c, value: el.Id});
    });
    this.selectedSpecialisationBis = this.specialisationOptions[0].value;

    if(this.specialisationOptions.length > 1) {
      this.showSpecialisationCombobox = true;
    } else {
      this.showSpecialisationCombobox = false;
    }

    if (showDebug) { console.log ('SELECTED code object : ' + this.getSelecetedCodeApeObject());}
  }

  handleChangeSpecBis(event) {
    this.selectedSpecialisationBis = event.detail.value;
    if (showDebug) { console.log ('SELECED SPEC : ' + JSON.stringify(this.selectedSpecialisationBis));}
    if (showDebug) { console.log ('SELECTED code object : ' + this.getSelecetedCodeApeObject());}
  }


  @track specialisationOptions = [];
  @track selectedSpecialisationBis;
  @track selectedCodeAPEBis;
  showSpecialisationCombobox=true;
  @track specialisationValuesBis;
  @track loadedCodesAPE;


  getSelecetedCodeApeObject() {
    let selectedApe = this.loadedCodesAPE[this.selectedCodeAPEBis];
    let sel = selectedApe.find(item => item.Id === this.selectedSpecialisationBis);
    return sel;
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

  selectionAPEChangeHandler(event) {
    if (showDebug) { console.log ("code ape choisi");}
    if (showDebug) { console.log (event.target.value);}
    this.codeAPE = event.target.value;
  }

  handlePrev() {
    var getselectedStep = this.selectedStep;
    if (getselectedStep === "Step2") {
      const ev = new CustomEvent("previous");
      this.dispatchEvent(ev);
    }
    if (getselectedStep === "Step3") {
      this.selectedStep = "Step2";
      this.nextButtonClicked = true;
    }
  }

  handleUsernameChange(event) {
    this.username = event.target.value;
  }
  handlePasswordChange(event) {
    this.password = event.target.value;
  }
  handlerepeatPasswordChange(event) {
    this.repeatPassword = event.target.value;
  }

  @track formFields;

  @track recordTypes = [];

  handleContactFieldChange(e) {
    this.contactRecord[e.currentTarget.fieldName] = e.target.value;
    if (showDebug) { console.log (
      e.currentTarget.fieldName + " was changed to " + e.target.value
    );}
  }

  handleAccountFieldChange(e) {
    this.accountRecord[e.currentTarget.fieldName] = e.target.value;
    if (showDebug) { console.log (
      "handleAccountFieldChange: " +
        e.currentTarget.fieldName +
        " was changed to " +
        e.target.value
    );}
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

  get isMainPage() {
    return (
      this.selectedStep !== "errorPage" && this.selectedStep !== "successPage"
    );
  }

  get isSuccessPage() {
    return this.selectedStep == "successPage";
  }

  get isErrorPage() {
    return this.selectedStep === "errorPage";
  }

  get isSelectStep2() {
    return this.selectedStep === "Step2";
  }

  get isSelectStep3() {
    return this.selectedStep === "Step3";
  }

  get fileRequired() {
    return true;
  }
  showModalCGUCGV() {
    this.openModalCGUCGV = true;
  }
  closeModalCGUCGV() {
    this.openModalCGUCGV = false;
  }
  showModaloffers() {
    this.openModalpromotionaloffers = true;
  }
  closeModaloffers() {
    this.openModalpromotionaloffers = false;
  }

  get selectedFormeJuridique() {
    if (showDebug) { console.log (
      "optionsFormeJuridique: " + JSON.stringify(this.optionsFormeJuridique)
    );}
    return this.optionsFormeJuridique.find(
      item => item.value === this.accountRecord["Forme_juridique__c"]
    );
  }
  handleOkCourrierChange(e) {
    this.contactRecord["Accepte_courrier__c"] = e.target.checked;
    if (showDebug) { console.log ("Accepte_courrier__c" + " was changed to " + e.target.checked);}
    if (showDebug) { console.log ("e.target.checked");}
    if (showDebug) { console.log (e.target.checked);}
  }
  handleOkMailChange(e) {
    this.contactRecord["Accepte_eMail__c"] = e.target.checked;
    if (showDebug) { console.log ("Accepte_eMail__c" + " was changed to " + e.target.checked);}
    if (showDebug) { console.log ("e.target.checked");}
    if (showDebug) { console.log (e.target.checked);}
  }
  handleOkTelChange(e) {
    this.contactRecord["Accepte_telephone__c"] = e.target.checked;
    if (showDebug) { console.log ("Accepte_telephone__c" + " was changed to " + e.target.checked);}
    if (showDebug) { console.log ("e.target.checked");}
    if (showDebug) { console.log (e.target.checked);}
  }
  handleOkSMSChange(e) {
    this.contactRecord["Accepte_SMS__c"] = e.target.checked;
    if (showDebug) { console.log ("Accepte_SMS__c" + " was changed to " + e.target.checked);}
    if (showDebug) { console.log ("e.target.checked");}
    if (showDebug) { console.log (e.target.checked);}
  }
  handleOkFaxChange(e) {
    this.contactRecord["Accepte_fax__c"] = e.target.checked;
    if (showDebug) { console.log ("Accepte_fax__c" + " was changed to " + e.target.checked);}
    if (showDebug) { console.log ("e.target.value");}
    if (showDebug) { console.log (e.target);}
  }

  validatePassword(password) {
    var patt1 = /[a-z]/;
    var patt2 = /[A-Z]/;// /[^a-zA-Z\d]/g
    var patt3 = /[0-9]/;
    var patt4 = /[^a-zA-Z\d]/;

    var result1 = password.match(patt1);
    var result2 = password.match(patt2);
    var result3 = password.match(patt3);
    var result4 = password.match(patt4);

    if (showDebug) { console.log (
      "result1: " + result1 + ", result2: " + result2 + ", result3: " + result3
    );}
    if (result1 == null && result2 == null) return false;
    if (result3 == null) return false;
    if (result4 == null) return false;

    var len = password.length;
    if (len < 12) return false;
    return true;
  }
}