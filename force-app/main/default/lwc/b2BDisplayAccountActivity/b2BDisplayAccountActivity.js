import { LightningElement } from 'lwc';
import { track, wire, api } from "lwc";
import getAccountDataInfos from "@salesforce/apex/B2BGetInfoCustom.getAccountDataInfos";

export default class B2BDisplayAccountActivity extends LightningElement {
    @api effectiveAccountId;
    @api recordId;
    @track activite;
    @track categorieClient;
    @track codeAPE;
    @track libelleCodeAPE;
    @track enseigneCommerciale;
    @track numeroSiret;
    @track noInformation = '-';
  
    connectedCallback() {
        if(this.effectiveAccountId == '000000000000000' || this.effectiveAccountId == undefined) {
            this.activite = '';
        } else {
            getAccountDataInfos({
                effectiveAccountId: this.effectiveAccountId
            })
            .then(res => {
                this.activite = res[0].Activite__c == undefined ? this.noInformation : res[0].Activite__c;
                this.categorieClient = res[0].Categorie__c == undefined ? this.noInformation : res[0].Categorie__c;
                this.codeAPE = res[0].Code_APE__c == undefined ? this.noInformation : res[0].Code_APE__r.Name;
                this.libelleCodeAPE = res[0].Libell_code_APE__c == undefined ? this.noInformation : res[0].Libell_code_APE__c;
                this.enseigneCommerciale = res[0].Enseigne_commerciale__c == undefined ? this.noInformation : res[0].Enseigne_commerciale__c;
                this.numeroSiret = res[0].Numero_Siret__c == undefined ? this.noInformation : res[0].Numero_Siret__c;

            })
            .catch(err => {
                this.activite = '';
                console.log('B2BDisplayAccountActivity err: ', err);
            })
        } 
    }
}