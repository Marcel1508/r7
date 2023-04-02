import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Campaign.Name';
import ENDDATE_FIELD from '@salesforce/schema/Campaign.EndDate';
import ISOCODE_FIELD from '@salesforce/schema/Campaign.CurrencyIsoCode';
import getCampaignRecord from '@salesforce/apex/SelectionPromotionController.getCampaign';
import getShelvesByPriority from '@salesforce/apex/SelectionPromotionController.getShelvesByPriority';
import getProductsByShelf from '@salesforce/apex/SelectionPromotionController.getProductsByShelf';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";


export default class SelectionPromotion extends LightningElement{
    @api cmpId;
     data = '';
     shelves = [];
    display = false;
    /* @wire(getRecord, { recordId: this.cmpId, fields: [NAME_FIELD, ENDDATE_FIELD, ISOCODE_FIELD]})
     wiredRecord({ error, data }) {
        if (showDebug) { console.log ('Yes : ' + JSON.stringify(data));

     }*/
    connectedCallback(){
        if (showDebug) { console.log ('id cmp : ' + this.cmpId);}
        getCampaignRecord({recordId : this.cmpId}).then(result=>{
            this.data  = (result != undefined) ? result : '';
            if(result.Type !== 'Email - Promotions'){
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Toast Message',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);

                //window.open('/'+this.cmpId,"_self");


            }
            else{
                this.display = true;
                if (showDebug) { console.log ('data campaign : ' + JSON.stringify(this.data));}
                getShelvesByPriority().then(result=>{
                    if (showDebug) { console.log ('List des rayons : ' + JSON.stringify(result));}
                    this.shelves  =  result;
                })
                
                getProductsByShelf().then(res=>{
                    if (showDebug) { console.log ('List des rayons / products : ' + JSON.stringify(res));}
                    // this.shelfPrd  =  res;
                })
            }
        })
 
        
        
    }
    renderedCallback(){


    }

    navigateToCampaign(){
        window.open('/'+this.cmpId,"_self");
    }


}