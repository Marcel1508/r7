import { LightningElement } from 'lwc';
import { track, wire, api } from "lwc";
import getAccountDataInfos from "@salesforce/apex/B2BGetInfoCustom.getAccountDataInfos";

export default class B2BDisplayAccountInfos extends LightningElement {
    @api effectiveAccountId;
    @api recordId;
    @track acctName;
    @track numeroClient;
    @track contactPrincipal;
    @track email;
    @track telSiret;
    @track webSite;
    @track fax;
    @track adresseSiegeSocial;
    @track codeEtablissement;
    @track etablissementMaitre;
    @track noInformation = '-';
  
    connectedCallback() {
        if(this.effectiveAccountId == '000000000000000' || this.effectiveAccountId == undefined) {
            this.acctName = '';
        } else {
            getAccountDataInfos({
                effectiveAccountId: this.effectiveAccountId
            })
            .then(res => {
                this.acctName = res[0].Name == undefined ? this.noInformation : res[0].Name;
                this.numeroClient = res[0].Numero_Client__c == undefined ? this.noInformation : res[0].Numero_Client__c;
                this.contactPrincipal = res[0].Contact_principal_la_creation__c == undefined ? this.noInformation : res[0].Contact_principal_la_creation__c;
                this.email = res[0].Email__c == undefined ? this.noInformation : res[0].Email__c;
                this.telSiret = res[0].Telephone_Siret__c == undefined ? this.noInformation : res[0].Telephone_Siret__c;
                this.webSite = res[0].Website == undefined ? this.noInformation : res[0].Website;
                this.fax = res[0].Fax == undefined ? this.noInformation : res[0].Fax; 
                this.adresseSiegeSocial = res[0].Adresse_siege_social__c == undefined ? this.noInformation : res[0].Adresse_siege_social__c;
                this.codeEtablissement = res[0].Code_etablissement__c == undefined ? this.noInformation : res[0].Code_etablissement__c; 
                this.etablissementMaitre = res[0].Magasin_de_rattachement__c == undefined ? this.noInformation : res[0].Magasin_de_rattachement__r.Name; 
            })
            .catch(err => {
                this.acctName = '';
                console.log('B2BDisplayAccountInfos error : ', err);
            })
        } 
    }
}