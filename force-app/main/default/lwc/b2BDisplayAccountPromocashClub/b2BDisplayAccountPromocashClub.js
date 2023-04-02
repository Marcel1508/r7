import { LightningElement } from 'lwc';
import { track, wire, api } from "lwc";
import getAccountDataInfos from "@salesforce/apex/B2BGetInfoCustom.getAccountDataInfos";
import clubImg from '@salesforce/resourceUrl/PMCClub';
import cadeauxImg from '@salesforce/resourceUrl/PMCClubCadeaux';
import goldImg from '@salesforce/resourceUrl/PMCClubGold';
import platiniumClubImg from '@salesforce/resourceUrl/PMCClubPlatinium';
import silverImg from '@salesforce/resourceUrl/PMCClubSilver';
import vipImg from '@salesforce/resourceUrl/PMCClubVIP';

export default class B2BDisplayAccountPromocashClub extends LightningElement {
    @api effectiveAccountId;
    @track cadeauxImage = cadeauxImg;
    @track clubImg = clubImg;
    @track goldImg = goldImg;
    @track platiniumClubImg = platiniumClubImg;
    @track silverImg = silverImg;
    @track vipImg = vipImg;
    @track statutFideliteImg;
    @track statutFidelite;
    @track pointsAcquis;
    @track hasPointsAcquis = false;
    @track pointsArrivantsEcheance;
    @track pointsArrivantsEcheanceAu;
    @track dateEcheance;
    @track pointsAcquisAu;
   
  
    connectedCallback() {
        if(this.effectiveAccountId == '000000000000000' || this.effectiveAccountId == undefined) {
        } else {
            getAccountDataInfos({
                effectiveAccountId: this.effectiveAccountId
            })
            .then(res => {
                console.log('B2BDisplayAccountPromocashClub : ', JSON.stringify(res));
                this.statutFidelite = (res[0].Statut_fidelite__c == undefined || res[0].Statut_fidelite__c == null|| res[0].Statut_fidelite__c == '') ? '' : res[0].Statut_fidelite__c;
                if (this.statutFidelite == 'Platinum') { 
                    this.statutFideliteImg = platiniumClubImg; 
                } else if (this.statutFidelite == 'Silver') { 
                    this.statutFideliteImg = silverImg;
                } else if (this.statutFidelite == 'Gold') {  
                    this.statutFideliteImg = goldImg;
                } else if (this.statutFidelite == 'VIP') { 
                    this.statutFideliteImg = vipImg; 
                } else { 
                    this.statutFideliteImg = ''; 
                }
                this.pointsAcquis = (res[0].Fidelite__r.Points_acquis__c == undefined || res[0].Fidelite__r.Points_acquis__c == null || res[0].Fidelite__r.Points_acquis__c == '') ? '0' : res[0].Fidelite__r.Points_acquis__c;
                this.pointsArrivantsEcheance = (res[0].Fidelite__r.Points_arrivant_echeance__c == undefined || res[0].Fidelite__r.Points_arrivant_echeance__c == null || res[0].Fidelite__r.Points_arrivant_echeance__c == '') ? '0' : res[0].Fidelite__r.Points_arrivant_echeance__c;
                this.pointsArrivantsEcheanceAu = (res[0].Fidelite__r.Points_arrivant_echeance_au__c == undefined || res[0].Fidelite__r.Points_arrivant_echeance_au__c == null || res[0].Fidelite__r.Points_arrivant_echeance_au__c == '') ? '-' : res[0].Fidelite__r.Points_arrivant_echeance_au__c;
                this.pointsAcquisAu = (res[0].Fidelite__r.Points_acquis_au__c == undefined || res[0].Fidelite__r.Points_acquis_au__c == null || res[0].Fidelite__r.Points_acquis_au__c == '') ? '-' : res[0].Fidelite__r.Points_acquis_au__c;
            })
            .catch(err => {
                console.log('B2BDisplayAccountPromocashClub err: ', err);
            })
        } 
    }

    jenProfite(){
        document.location.href='https://mon.promocash.com/';
    }
       

}