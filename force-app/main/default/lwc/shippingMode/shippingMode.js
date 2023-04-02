import { LightningElement,wire,api,track } from 'lwc';
import modeLivraison1 from '@salesforce/resourceUrl/ModeLivraison1';
import modeLivraison2 from '@salesforce/resourceUrl/ModeLivraison2';
import modeLivraison3 from '@salesforce/resourceUrl/ModeLivraison3';
import modeLivraisonGrey1 from '@salesforce/resourceUrl/ModeLivraisonGrey1';
import modeLivraisonGrey2 from '@salesforce/resourceUrl/ModeLivraisonGrey2';
import modeLivraisonGrey3 from '@salesforce/resourceUrl/ModeLivraisonGrey3';
import checkOK from '@salesforce/resourceUrl/checkOK';

export default class ShippingMode extends LightningElement {
    @api montantminimum;
    @api canalname;
    @api currency;
    @api prices;
    @track modeLivr1 = modeLivraison1;
    @track modeLivr2 = modeLivraison2;
    @track modeLivr3 = modeLivraison3;
   @track modeLivrGrey1 = modeLivraisonGrey1;
    @track modeLivrGrey2 = modeLivraisonGrey2;
    @track modeLivrGrey3 = modeLivraisonGrey3;
    @track checkOK = checkOK;

   /* get disponibiliteMessage(){
        let selectMessage = '';
        if(!this.canSelect){
            selectMessage += 'Your cart total must be equal or over ';
            selectMessage += this.montantminimum + ' ' + this.currency;
            selectMessage += ' minimum to select this shipping mode.';

        }else{
            selectMessage += 'You can select this shipping mode';
        }
        return selectMessage;
    }*/


   /* get disponibiliteStatut(){
        let selectMessage = this.canalname;
        if(this.canSelect){
            selectMessage += ' : Disponible';

        }else{
            selectMessage += ' : Non disponible ';
        }
        return selectMessage;
    } */


    get disponibiliteStatut(){
        //let selectMessage = this.canalname;
        let status =''; 
        if(this.canSelect){
            status = 'Disponible ';
        }else{
            status = 'Non disponible ';
        }
        return status;
    }

    // Add Zakia 
    get canalName(){
        let modeLivraison = this.canalname;
        if(this.canSelect){
            modeLivraison ;
        }else{
            modeLivraison;
        }
        return modeLivraison;
    }
 
    /*get iconMode(){
        let iconCanal ;
        if(this.canSelect && this.canalName =='Drive'){
            iconCanal = this.modeLivr1;
        }else if(this.canSelect && this.canalName =='Drive déporté') {
            iconCanal = this.modeLivr2;
        }else{
            iconCanal = this.modeLivr3;
        } 
        return iconCanal;
    }*/
    get iconMode(){
        let iconCanal ;
        if(this.canalName =='Drive'){
            if(this.canSelect){
                iconCanal = this.modeLivr1;
            }else{
                iconCanal = this.modeLivrGrey1;
            }
        }else if(this.canalName =='Drive déporté') {
            if(this.canSelect){
                iconCanal = this.modeLivr2;
            }else{
                iconCanal = this.modeLivrGrey2;
            }
        }else{
            if(this.canSelect){
                iconCanal = this.modeLivr3;
            }else{
                iconCanal = this.modeLivrGrey3;
            }

        } 
        return iconCanal;
    }
    
    //End Zakia

    get finalprice(){
        return this.prices.finalPrice;
    }

    get originalprice(){
        return this.prices.originalPrice;
    }

    get canSelect() {
        return this.montantminimum < this.finalprice;
    }
    get noMontant() {
        return this.montantminimum == 0;
    }

    get decompte() {
        console.log('this.montantminimum');
        console.log(this.montantminimum);
        return (this.montantminimum - this.finalprice).toFixed(2);
    }
}