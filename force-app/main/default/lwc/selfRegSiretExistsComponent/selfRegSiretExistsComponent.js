import { LightningElement, track, api } from 'lwc';
import getAllMagasinsFromZoneDeChalandise from "@salesforce/apex/selfRegService.getAllMagasinsFromZoneDeChalandise";
import getZoneChalandise from "@salesforce/apex/selfRegService.getZoneChalandise";
import { NavigationMixin } from 'lightning/navigation';
import enablePortalUserForContact from "@salesforce/apex/selfRegService.enablePortalUserForContact";
import enablePortalUserForContactWithoutEmail from "@salesforce/apex/selfRegService.enablePortalUserForContactWithoutEmail";
import updateContactEmail from "@salesforce/apex/selfRegService.updateContactEmail";
import updateAccountMagasin from "@salesforce/apex/selfRegService.updateAccountMagasin";
import activeExistingLead from '@salesforce/apex/selfRegService.activeExistingLead';
import getUserByUsername from "@salesforce/apex/selfRegService.getUserByUsername";

//contact ContactPointAddress fields
import ContactPointAddress_Id_FIELD from '@salesforce/schema/ContactPointAddress.Id';
import ContactPointAddress_City_FIELD from '@salesforce/schema/ContactPointAddress.City';
import ContactPointAddress_NumeroDeVoie_FIELD from '@salesforce/schema/ContactPointAddress.Numero_de_voie__c';
import ContactPointAddress_TypeDeVoie_FIELD from '@salesforce/schema/ContactPointAddress.Type_de_voie__c';
import ContactPointAddress_NomDeVoie_FIELD from '@salesforce/schema/ContactPointAddress.Nom_de_voie__c';
import ContactPointAddress_Country_FIELD from '@salesforce/schema/ContactPointAddress.Country';
import ContactPointAddress_PostalCode_FIELD from '@salesforce/schema/ContactPointAddress.PostalCode';
import ContactPointAddress_codesPostaux_FIELD from "@salesforce/schema/ContactPointAddress.Codes_Postaux__c";
import ContactPointAddress_State_FIELD from '@salesforce/schema/ContactPointAddress.State';
import ContactPointAddress_Street_FIELD from '@salesforce/schema/ContactPointAddress.Street';
import ContactPointAddress_Name_FIELD from '@salesforce/schema/ContactPointAddress.Name';
import ContactPointAddress_AddressType_FIELD from '@salesforce/schema/ContactPointAddress.AddressType';
import ContactPointAddress_IsDefault_FIELD from '@salesforce/schema/ContactPointAddress.IsDefault';
import ContactPointAddress_ParentId_FIELD from '@salesforce/schema/ContactPointAddress.ParentId';
import ContactPointAddress_Pays_FIELD from "@salesforce/schema/ContactPointAddress.Pays__c";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class SelfRegSiretExistsComponent extends NavigationMixin(LightningElement) {
    @track selectedStep;
    @api account;
    @api street;
    @api city;
    @api state;
    @api country;
    @api countryLabel;
    @api postalCode;
    @api selectedPostalCodeId;
    @track showSpinner = false;
    //New Address fields
    @api numVoie;
    @api typeVoie;
    @api nomVoie;

    //STEP 1
    mySelectedMagasin;
    selectedMagasinFromAllZones;
    selectedMyZoneId;
    selectedMyZone;
    selectedAllZoneId;
    selectedAllZone;
    myMagasins = [];
    loadedMyMagasins = [];
    allMagasins = [];
    loadedAllMagasins = [];
    chooseMagasinFromMyPostalCode = true;
    isMagasinError = false;
    magasinSelectErrorMessage = "";

    //STEP 2
    codeChaine = "";
    codeChaineunknown = false;
    isCodeChaineError = false;
    codeChaineErrorMessage = "";
    ecommerceEmail = "";

    //STEP3
    sousStep = "";
        //SOUS STEP CLIENT 1
        codeCarte = "";
        isCodeCarteError = false;
        codeCarteunknown = false;
        //SOUS STEP PASSWORD
        username = "";
        password = "";
        reapetPassword = "";
        isCredentialError = false;
        credentialErrorMessage = "";
        isUsernameError = false;
        usernameErrorMessage = "";

    //ErrorPage
    errorPage = false;
    errorPageMessage = "";


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
        AddressType: 'Billing',
        IsDefault: true,
        ParentId: ContactPointAddress_ParentId_FIELD
    }

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
        AddressType: 'Shipping',
        IsDefault: true,
        ParentId: ContactPointAddress_ParentId_FIELD
    }

    connectedCallback() {
        this.showSpinner = true;
        if (showDebug) { console.log ('account: ' + JSON.stringify(this.account));}

        if(this.account.Client_grand_compte__c == true) {
            this.selectedStep = "Step2";
        } else {
            this.selectedStep = "Step2NotKeyAccount";
        }

        getZoneChalandise({postalCode: this.postalCode, city: this.city})
            .then(res => {
                if(res != null) {
                    res.forEach(element => {
                        if (this.myMagasins.find(item => item.magasinName === element.Magasin__r.Name) === undefined) {
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
                    if(res.length > 0) { //Init 
                        this.selectedMyZoneId = res[0].Id;
                    }
                }
                this.showSpinner = false;
            })
            .catch(err => {
                if (showDebug) { console.log ('getZoneChalandise err: ' + err);}
                this.showSpinner = false;
        })

        getAllMagasinsFromZoneDeChalandise()
            .then(res=> {
                if(res != null) {
                    res.forEach(element => {
                        if (this.allMagasins.find(item => item.magasinName === element.Magasin__r.Name) === undefined) {
                            this.allMagasins.push({
                                id: element.Id, 
                                label: element.Libelle_ville__c, 
                                value: element.Libelle_ville__c,
                                restrictif: element.Magasin__r.Restrictif__c,
                                magasinId: element.Magasin__r.Id,
                                magasinName: element.Magasin__r.Name
                            });
                        }
                        //Init all magasins without filter
                        this.loadedAllMagasins.push({
                            id: element.Id, 
                            label: element.Libelle_ville__c, 
                            value: element.Libelle_ville__c,
                            restrictif: element.Magasin__r.Restrictif__c,
                            magasinId: element.Magasin__r.Id,
                            magasinName: element.Magasin__r.Name
                        });                        
                    });
                }

                /*id: element.Id,
                            label: element.Libelle_ville__c,
                            value: element.Libelle_ville__c,
                            restrictif: element.Magasin__r.Restrictif__c,
                            magasinId: element.Magasin__r.Id,
                            magasinName: element.Magasin__r.Name    */

            })
            .catch(err => {
                if (showDebug) { console.log ('SelfRegMagasinChoiceComponent.getAllMagasinsFromZoneDeChalandise err: ' + JSON.stringify(err));}
        })
    }

    /** STEP 1 **/
    myMagasinSelectionHandler(event) {
        var selectedValue = this.myMagasins.find(item => item.magasinName === event.target.value);
        this.selectedMyZoneId = selectedValue.Id;
    }

    allMagasinSelectionChangeHandler(event) {
        var selectedValue = this.allMagasins.find(item => item.magasinName === event.target.value);
        this.selectedAllZoneId = selectedValue.Id;
        if (showDebug) { console.log ("init selectedAllZoneId" + this.selectedAllZoneId);}
    }

    handleCannotFindMyMagasinCheckbox() {
        const element = this.template.querySelector('[data-id="checkbox-cannotFindMyMagasin"]');
        this.chooseMagasinFromMyPostalCode = !element.checked;
        if (showDebug) { console.log ('checked selectedMyZoneId: ' + this.selectedMyZoneId);}
        if(this.chooseMagasinFromMyPostalCode == false) { // Init selectedAllZoneId with the first element
            this.selectedAllZoneId = this.loadedAllMagasins[0].id;
            if (showDebug) { console.log ('init selectedAllZoneId' + this.selectedAllZoneId);}
            this.isMagasinError = false;
        }
    }
    /** STEP 1 **/
    
    /** STEP 2 **/
    handleCodeChaine(event) {
        this.codeChaine = event.target.value;
    }
    handleIsCodeChaineKnown() {
        const element = this.template.querySelector('[data-id="checkbox-chaineCode"]');
        this.codeChaineunknown = element.checked;
    }
    handleEcommerceFinish() { //Redirect user to login page
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/promocash/s"
            }
        });
    }
    /** STEP 2 **/

    /** STEP 3 **/

        // SOUS STEP CLIENT 1
        handleCodeCarte(event) {
            this.codeCarte = event.target.value;
        }
        handleIsCodeCarteKnown() {
            const element = this.template.querySelector('[data-id="checkbox-codeCarte"]');
            this.codeCarteunknown = element.checked;
        }
        // SOUS STEP CLIENT 1

        // SOUS STEP PASSWORD
        handleUsernameChange(event) {
            this.username = event.target.value;
        }
        handlePasswordChange(event) {
            this.password = event.target.value;
        }
        handlerepeatPasswordChange(event) {
            this.reapetPassword = event.target.value;
        }
        handleSuccess() {
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "/promocash/s"
                }
            });
        }
         // SOUS STEP PASSWORD

    /** STEP 3 **/

    /** Error page **/
    handleFinishError() {
        const ev = new CustomEvent("previous");
        this.dispatchEvent(ev);
    }
    /** Error page **/

    handleNext() {
        //this.showSpinner = true;
        var getselectedStep = this.selectedStep;
        if(getselectedStep === 'Step1'){
            this.isMagasinError = false;
            if (showDebug) { console.log ('selectedMyZoneId: ' + this.selectedMyZoneId);}
            if (showDebug) { console.log ('chooseMagasinFromMyPostalCode: ' + this.chooseMagasinFromMyPostalCode);}

            if(this.selectedMyZoneId == undefined && this.chooseMagasinFromMyPostalCode == true) {
                this.isMagasinError = true;
                this.magasinSelectErrorMessage = 'Veuillez selectionner un magasin';
            }
            if(this.chooseMagasinFromMyPostalCode == false || (this.selectedMyZoneId != undefined && this.chooseMagasinFromMyPostalCode == true)) {
                this.initSelectedZone();
                if (showDebug) { console.log ('selected all zone id: ' + this.selectedAllZoneId);}
                this.checkEcommerceEmail();
            }
        }
        else if(getselectedStep === 'Step2'){
            if (showDebug) { console.log ('this.account.Code_Externe_Chaine_Text__c: ' + this.account.Code_Externe_Chaine_Text__c);}
            if(this.codeChaineunknown == false) {
                if(this.codeChaine == this.account.Code_Externe_Chaine_Text__c) {
                    //this.checkEcommerceEmail();
                    this.selectedStep = "Step1";
                } else {
                    this.isCodeChaineError = true;
                    this.codeChaineErrorMessage = 'Chaine code incorrect';
                }
            } else {
                this.errorPage = true;
                this.errorPageMessage = 'Veuillez contacter votre magasin';
            }
            //this.selectedStep = 'Step3';
        }
        else if(getselectedStep === 'Step2NotKeyAccount'){
            //this.checkEcommerceEmail();
            this.selectedStep = "Step1";
        }
        else if(getselectedStep === 'Step3'){
            if(this.sousStep === 'client1') {
                if(this.codeCarteunknown == false) {
                    if (showDebug) { console.log ('this.account.Numero_Client__c: ' + this.account.Numero_Client__c);}
                    if(this.account.Numero_Client__c !== this.codeCarte) {
                        this.isCodeCarteError = true;
                    } else {
                        if (showDebug) { console.log ('this.account.Numero_Client__c correct ');}
                        this.isCodeCarteError = false;
                        this.sousStep = 'sousStepPassword';
                    }
                } else {
                    this.showGenericErrorPage();
                }
                
            } else if(this.sousStep === 'sousStepPassword') { //slds-has-error
                //this.showSpinner = true;
                this.isCredentialError = false;
                this.isUsernameError = false;
                if (showDebug) { console.log ('username: ' + this.username);}
                if (showDebug) { console.log ('password: ' + this.password);}
                if (showDebug) { console.log ('reapet pass: ' + this.reapetPassword);}

                let errClass = 'slds-has-error';

                let errorUsername = this.template.querySelector('[data-id="username"]').classList.contains(errClass);
                let errorPassword = this.template.querySelector('[data-id="password"]').classList.contains(errClass);
                let errorRepeatPassword = this.template.querySelector('[data-id="repeatPassword"]').classList.contains(errClass);
                if (showDebug) { console.log ('errorUsername: ' + errorUsername + ', errorPassword: ' +errorPassword+ ', errorRepeatPassword: ' + errorRepeatPassword);}
                if(errorUsername == true || errorPassword == true || errorRepeatPassword == true) {
                    //Nothing to do, wiating for user to correct inputs
                } else {
                    if(this.username == '' || this.password == '' || this.reapetPassword == '') {
                        this.isCredentialError = true;
                        this.credentialErrorMessage = 'Tous les champs sont obligatoires';
                    } else {
                        if(this.password !== this.reapetPassword) {
                            this.isCredentialError = true;
                            this.credentialErrorMessage = 'les mots de passe saisis ne sont pas identiques';
                        } else if(this.validatePassword(this.password) == false) {
                            this.isCredentialError = true;
                            this.credentialErrorMessage = 'Le mot de passe doit contenir au moins 12 caractères dont 1 lettre, 1 chiffre et 1 caractère spécial.';
                        } else {
                            if (showDebug) { console.log ('correct');}
                            this.showSpinner = true;
                            this.ecommerceEmail = this.username;
                            
                            getUserByUsername({
                                username: this.username
                            })
                            .then(result => {
                                if(result != null){
                                    this.credentialErrorMessage = 'Ce username existe déjà, veuillez en saisir un autre.';
                                    this.isCredentialError = true;
                                    if (showDebug) { console.log ('username found');}
                                    this.showSpinner = false;
                                } else{
                                updateContactEmail({contactId: this.account.Contacts[0].Id, email: this.username})
                                .then(res => {
                                    if (showDebug) { console.log ('updateContactEmail res: ' +JSON.stringify(res));}
                                    if(res.isSuccess == true) {

                                        var selectedMagasinId;
                                        var magasinGeographique;

                                        if(this.chooseMagasinFromMyPostalCode == true) {
                                            selectedMagasinId = this.selectedMyZone.magasinId;
                                            magasinGeographique = this.selectedMyZone.magasinId;
                                        } else {
                                            selectedMagasinId = this.selectedAllZone.magasinId;
                                            if(this.selectedMyZone != undefined) {
                                                magasinGeographique = this.selectedMyZone.magasinId;
                                            }
                                        }

                                        if (showDebug) { console.log ('selectedMagasinId: ' + selectedMagasinId);}
                                        if (showDebug) { console.log ('magasinGeographique: ' + magasinGeographique);}

                                        this.setAddresses();

                                        this.billingAddressRecord = this.clearArray(this.billingAddressRecord, 'ContactPointAddress');
                                        this.shippingAddressRecord = this.clearArray(this.shippingAddressRecord, 'ContactPointAddress');

                                        //CALL
                                        updateAccountMagasin({account: this.account, magasinId: selectedMagasinId, magasinGeographique: magasinGeographique, billAddress: this.billingAddressRecord, shipAddress: this.shippingAddressRecord})
                                            .then(updateAccountMagasinRes => {
                                                if(updateAccountMagasinRes.isSuccess == true) {
                                                    //Call IsBuyer
                                                    if(this.account.IsBuyer == false) {
                                                        if (showDebug) { console.log ('not buyer account');}
                                                        activeExistingLead({accountId: this.account.Id, magasinDeRattachementId: selectedMagasinId})
                                                            .then(result => {
                                                                if (showDebug) { console.log ('activeExistingLead res: ' + JSON.stringify(result));}
                                                                if(result.isSuccess == true) {
                                                                    //CALL Active user
                                                                    enablePortalUserForContactWithoutEmail({accountid: this.account.Id, contactId: this.account.Contacts[0].Id, email: this.username, password: this.password})
                                                                    .then(response => {
                                                                        if (showDebug) { console.log ('enablePortalUserForContactWithoutEmail response: ' + JSON.stringify(response));}
                                                                        if(response.isSuccess == false) {
                                                                            if(response.message == 'user_already_exists') {
                                                                                this.selectedStep = "ecommerceEmailStep";
                                                                            } else {
                                                                                this.errorPage = true;
                                                                                this.errorPageMessage = 'veuillez contacter votre administrateur';
                                                                            }
                                                                            this.showSpinner = false;
                                                                        } else {
                                                                            this.selectedStep = 'successStep';
                                                                            this.successMessage = 'votre compte a été créé avec succès ';
                                                                            this.showSpinner = false;
                                                                        }
                                                                    })
                                                                    .catch(err => {
                                                                        if (showDebug) { console.log ('enablePortalUserForContactWithoutEmail cath error: ' + JSON.stringify(err));}
                                                                        this.showGenericErrorPage();
                                                                        this.showSpinner = false;
                                                                    })

                                                                } else {
                                                                    if (showDebug) { console.log ('activeExistingLead error: ');}
                                                                    this.showGenericErrorPage();
                                                                    this.showSpinner = false;
                                                                }
                                                            })
                                                            .catch(err => {
                                                                if (showDebug) { console.log ('activeExistingLead catch err: ' + JSON.stringify(err));}
                                                                this.showGenericErrorPage();
                                                                this.showSpinner = false;
                                                            });
                                                    } else {
                                                        if (showDebug) { console.log ('buyer account');}
                                                        enablePortalUserForContactWithoutEmail({accountid: this.account.Id, contactId: this.account.Contacts[0].Id, email: this.username, password: this.password})
                                                            .then(response => {
                                                                if (showDebug) { console.log ('enablePortalUserForContactWithoutEmail response: ' + JSON.stringify(response));}
                                                                if(response.isSuccess == false) {
                                                                    if(response.message == 'user_already_exists') {
                                                                        this.selectedStep = "ecommerceEmailStep";
                                                                    } else {
                                                                        this.errorPage = true;
                                                                        this.errorPageMessage = 'veuillez contacter votre administrateur';
                                                                    }
                                                                    this.showSpinner = false;
                                                                } else {
                                                                    this.selectedStep = 'successStep';
                                                                    this.successMessage = 'votre compte a été créé avec succès ';
                                                                    this.showSpinner = false;
                                                                }
                                                            })
                                                            .catch(err => {
                                                                if (showDebug) { console.log ('enablePortalUserForContactWithoutEmail cath error: ' + JSON.stringify(err));}
                                                                this.showGenericErrorPage();
                                                                this.showSpinner = false;
                                                            })
                                                    }
                                                } else {
                                                    if (showDebug) { console.log ('updateAccountMagasin error: ' + JSON.stringify(updateAccountMagasinRes));}
                                                    this.showGenericErrorPage();
                                                    this.showSpinner = false;
                                                }
                                            })
                                            .catch(updateAccountMagasinResErr => {
                                                if (showDebug) { console.log ('updateAccountMagasin catch error: ' + JSON.stringify(updateAccountMagasinResErr));}
                                                this.showGenericErrorPage();
                                                this.showSpinner = false;
                                            })

                                        
                                    } else {
                                        if (showDebug) { console.log ('error update contact ');}
                                        this.showGenericErrorPage();
                                        this.showSpinner = false;
                                    }
                                })
                                .catch(err => {
                                    if (showDebug) { console.log ('updateContactEmail catch error update contact ' + JSON.stringify(err));}
                                    this.showGenericErrorPage();
                                    this.showSpinner = false;
                                });
                                }
                            })
                            .catch(error => {
                                if (showDebug) { console.log ('getUsername catch error update contact ' + JSON.stringify(error));}
                                this.error = error.message;
                                this.showSpinner = false;
                            });
                        }
                    }
                }
            }
        }
    }

    handlePreviousLeadCreation() {
        this.selectedStep = 'Step2NotKeyAccount';
    }

    initSelectedZone() {
        //this.selectedAllZone = this.allMagasins.find(item => item.id === this.selectedAllZoneId);
        if(this.chooseMagasinFromMyPostalCode == false) {
            this.selectedAllZone = this.allMagasins.find(item => item.id === this.selectedAllZoneId);
            if(this.selectedMyZoneId !== undefined) {
                this.selectedMyZone = this.loadedAllMagasins.find(item => item.id === this.selectedMyZoneId);
            }
        } else {
            this.selectedMyZone = this.loadedAllMagasins.find(item => item.id === this.selectedMyZoneId);
        }
        if (showDebug) { console.log ('**initSelectedZone: ' + JSON.stringify(this.allMagasins));}
        if (showDebug) { console.log ('**initSelectedZone: ' + JSON.stringify(this.selectedMyZone));}
        if (showDebug) { console.log ('**initSelectedZone: ' + JSON.stringify(this.selectedAllZone));}
    }

    checkEcommerceEmail() {
        if(this.account.Contacts != undefined) { // Account has a principal contact
            let loadedEcommerceEmail = this.account.Contacts[0].Email;

            if(this.account.RecordType != undefined && this.account.RecordType.Name == 'Lead') {
                this.selectedStep = 'Step3';
                this.sousStep = 'lead1';
            } else if(loadedEcommerceEmail != undefined) {
                if (showDebug) { console.log ('Email e commerce step');}

                this.ecommerceEmail = loadedEcommerceEmail;
                //Check if the principal contact has an associated portal user
                var selectedMagasinId;
                var magasinGeographique;

                if(this.chooseMagasinFromMyPostalCode == true) {
                    selectedMagasinId = this.selectedMyZone.magasinId;
                    magasinGeographique = this.selectedMyZone.magasinId;
                } else {
                    selectedMagasinId = this.selectedAllZone.magasinId;
                    if(this.selectedMyZone != undefined) {
                        magasinGeographique = this.selectedMyZone.magasinId;
                    }
                }
                this.showSpinner = true;
  
                this.setAddresses();
                this.billingAddressRecord = this.clearArray(this.billingAddressRecord, 'ContactPointAddress');
                this.shippingAddressRecord = this.clearArray(this.shippingAddressRecord, 'ContactPointAddress');

                updateAccountMagasin({account: this.account, magasinId: selectedMagasinId, magasinGeographique: magasinGeographique, billAddress: this.billingAddressRecord, shipAddress: this.shippingAddressRecord})
                    .then(updateAccountMagasinRes => {
                        if (showDebug) { console.log ('DEBUG 2');}
                        if(updateAccountMagasinRes.isSuccess == true) {
                            //Call IsBuyer
                            if(this.account.IsBuyer == false) {
                                if (showDebug) { console.log ('not buyer account');}
                                activeExistingLead({accountId: this.account.Id, magasinDeRattachementId: selectedMagasinId})
                                    .then(result => {
                                        if (showDebug) { console.log ('activeExistingLead res: ' + JSON.stringify(result));}
                                        if(result.isSuccess == true) {
                                            //CALL Active user
                                            enablePortalUserForContact({accountid: this.account.Id, contactId: this.account.Contacts[0].Id, email: loadedEcommerceEmail})
                                                .then(res => {
                                                    if (showDebug) { console.log ('enablePortalUserForContact res: ' + JSON.stringify(res));}
                                                    if(res.isSuccess == false && res.message != 'user_already_exists') {
                                                        if (showDebug) { console.log ('enablePortalUserForContact res: ' + JSON.stringify(res));}
                                                        this.errorPage = true;
                                                        this.errorPageMessage = 'veuillez contacter votre administrateur';

                                                        this.showSpinner = false;
                                                    } else {
                                                        this.selectedStep = "ecommerceEmailStep";
                                                        this.showSpinner = false;
                                                    }
                                                })
                                                .catch(err=> {
                                                    alert('catch error: ' + JSON.stringify(err));
                                                    this.showSpinner = false;
                                                });
                                        } else {
                                            if (showDebug) { console.log ('activeExistingLead error: ');}
                                            this.showGenericErrorPage();
                                            this.showSpinner = false;
                                        }
                                    })
                                    .catch(err => {
                                        if (showDebug) { console.log ('activeExistingLead catch err: ' + JSON.stringify(err));}
                                        this.showGenericErrorPage();
                                        this.showSpinner = false;
                                    });
                            } else {
                                if (showDebug) { console.log ('buyer account');}
                                enablePortalUserForContact({accountid: this.account.Id, contactId: this.account.Contacts[0].Id, email: loadedEcommerceEmail})
                                    .then(res => {
                                        if (showDebug) { console.log ('enablePortalUserForContact res: ' + JSON.stringify(res));}
                                        if(res.isSuccess == false && res.message != 'user_already_exists') {
                                            if (showDebug) { console.log ('enablePortalUserForContact res: ' + JSON.stringify(res));}
                                            this.errorPage = true;
                                            this.errorPageMessage = 'veuillez contacter votre administrateur';
                                            this.showSpinner = false;
                                        } else {
                                            this.selectedStep = "ecommerceEmailStep";
                                            this.showSpinner = false;
                                        }
                                    })
                                    .catch(err=> {
                                        if (showDebug) { console.log ('catch error: ' + JSON.stringify(err));}
                                        this.showGenericErrorPage();
                                        this.showSpinner = false;
                                    });
                            }
                        } else {
                            if (showDebug) { console.log ('updateAccountMagasin error: ' + JSON.stringify(updateAccountMagasinRes));}
                            this.showGenericErrorPage();
                            this.showSpinner = false;
                        }
                    })
                    .catch(updateAccountMagasinResErr => {
                        if (showDebug) { console.log ('updateAccountMagasin catch error: ' + JSON.stringify(updateAccountMagasinResErr));}
                        this.showGenericErrorPage();
                        this.showSpinner = false;
                    })

            } else { // Eamil not defined
                if (showDebug) { console.log ('this.account.RecordType: ' + this.account.RecordType);}
                if(this.account.RecordType == undefined) { //Record type undefined
                    if (showDebug) { console.log ('Error recordType not defined')}
                    this.errorPage = true;
                    this.errorPageMessage = 'veuillez contacter votre administrateur';
                } else {
                    if(this.account.RecordType.Name == 'Client') {
                        this.selectedStep = 'Step3';
                        this.sousStep = 'client1';
                    } else if(this.account.RecordType.Name == 'Prospect') {
                        this.selectedStep = 'Step3';
                        this.isCodeCarteError = false;
                        this.sousStep = 'sousStepPassword';
                    } else {
                        if (showDebug) { console.log ('Error recordType unkown')}
                        this.errorPage = true;
                        this.errorPageMessage = 'veuillez contacter votre administrateur';
                    }
                }
            }
        } else {
            if (showDebug) { console.log ('LOOOOOOOOG');}
            //alert('Error! compte n\'a pas de contact principale');
            this.selectedStep = 'Step3';
            this.sousStep = 'lead1';
        }
    }

    showGenericErrorPage() {
        this.errorPage = true;
        this.errorPageMessage = 'Veuillez contacter votre magasin';
    }

    makeProperiesWritable() {
        Object.defineProperties(this.account, {
            'Magasin_de_rattachement__c': {
              writable: true
            },
            'Magasin_actif_en_cours__c': {
                writable: true
            },
            'Etablissement_geographique__c': {
                writable: true
            }
          });
    }

    setAddresses() {
        this.billingAddressRecord['Numero_de_voie__c'] = this.numVoie;
        this.billingAddressRecord['Type_de_voie__c'] = this.typeVoie;
        this.billingAddressRecord['Nom_de_voie__c'] = this.nomVoie;
        this.billingAddressRecord['City'] = this.city;
        this.billingAddressRecord["Pays__c"] = this.country;
        this.billingAddressRecord['PostalCode'] = this.postalCode;
        this.billingAddressRecord["Codes_Postaux__c"] = this.selectedPostalCodeId;
        this.billingAddressRecord['Name'] = 'Facturation :' + this.numVoie + ' ' + this.typeVoie + ' ' + this.nomVoie;
        this.billingAddressRecord['ParentId'] = this.account.Id;

        this.shippingAddressRecord['Numero_de_voie__c'] = this.numVoie;
        this.shippingAddressRecord['Type_de_voie__c'] = this.typeVoie;
        this.shippingAddressRecord['Nom_de_voie__c'] = this.nomVoie;
        this.shippingAddressRecord['City'] = this.city;
        this.shippingAddressRecord["Pays__c"] = this.country;
        this.shippingAddressRecord['PostalCode'] = this.postalCode;
        this.shippingAddressRecord["Codes_Postaux__c"] = this.selectedPostalCodeId;
        this.shippingAddressRecord['Name'] = 'Expédition :' + this.numVoie + ' ' + this.typeVoie + ' ' + this.nomVoie;
        this.shippingAddressRecord['ParentId'] = this.account.Id;
    }

    clearArray(dirtyArray, sObjectType) {
        let keys = Object.keys(dirtyArray);
        let cleanArray = {
            'sobjectType': sObjectType
        };
        keys.forEach(field => {
            if (typeof dirtyArray[field] == 'object') {
                if (showDebug) { console.log ('object if');}
            } else {
                if (showDebug) { console.log ('object else');}
                cleanArray[field] = dirtyArray[field];
            }
        });
        return cleanArray;
    }

    handlePrev() {
        var getselectedStep = this.selectedStep;
        if(getselectedStep === 'Step1'){
            const ev = new CustomEvent("previous");
            this.dispatchEvent(ev);
        }
        else if(getselectedStep === 'Step2' || getselectedStep === 'Step2NotKeyAccount'){
            this.selectedStep = 'Step1';
        }
        else if(getselectedStep === 'Step3'){
            this.selectedStep = 'Step2';
        }
    }
      
    handleFinish() {
        alert('Finished...');
        this.selectedStep = 'Step1';
    }
      
    selectStep1() {
        this.selectedStep = 'Step1';
    }
 
    selectStep2() {
        this.selectedStep = 'Step2';
    }
 
    selectStep3() {
        this.selectedStep = 'Step3';
    }

    get isSelectStep1() {
        return this.selectedStep === "Step1";
    }

    get isSelectStep2() {
        return this.selectedStep === "Step2";
    }

    get isSelectStep2NotKeyAccount() {
        return this.selectedStep === "Step2NotKeyAccount";
    }

    get isSelectStep3() {
        return this.selectedStep === "Step3";
    }

    get isSelectSousStepClient1() {
        return this.sousStep === "client1";
    }
    
    get isSelectSousStepLead1() {
        return this.sousStep === "lead1";
    }
    
    get isSuccessPage() {
        return this.selectedStep === "successStep";
    }

    get isEcommerceEmailStep() {
        return this.selectedStep === "ecommerceEmailStep";
    }

    get isSelectSousStepPassword() {
        return this.sousStep === "sousStepPassword";
    }
      
    get notFinalScreen() {
        return this.selectedStep !== "ecommerceEmailStep" && this.selectedStep !== "successStep" && this.selectedStep !== "Step2NotKeyAccount" && this.sousStep !== 'lead1';
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