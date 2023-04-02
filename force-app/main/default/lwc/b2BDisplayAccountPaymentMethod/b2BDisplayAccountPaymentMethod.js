import { LightningElement } from 'lwc';
import { track, wire, api } from "lwc";
import getAccountDataInfos from "@salesforce/apex/B2BGetInfoCustom.getAccountDataInfos";

export default class B2BDisplayAccountPaymentMethod extends LightningElement {
    @api effectiveAccountId;
    @track delaiPaiement;
    @track modeReglement;
    @track soldeClient;
    @track noInformation ='-'
  
  
    connectedCallback() {
        if(this.effectiveAccountId == '000000000000000' || this.effectiveAccountId == undefined) {
        } else {
            getAccountDataInfos({
                effectiveAccountId: this.effectiveAccountId
            })
            .then(res => {
                this.delaiPaiement = res[0].Echeance__c == undefined ? this.noInformation : res[0].Echeance__c;
                this.modeReglement = res[0].Mode_de_reglement__c == undefined ? this.noInformation : res[0].Mode_de_reglement__c;
                this.soldeClient = res[0].Solde_client__c == undefined ? this.noInformation : res[0].Solde_client__c;
            })
            .catch(err => {
                console.log('B2BDisplayAccountPaymentMethod err: ', err);
            })
        } 
    }
}