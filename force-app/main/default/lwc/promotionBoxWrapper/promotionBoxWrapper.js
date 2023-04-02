import { api, wire,track, LightningElement } from 'lwc';

import getPromotions from '@salesforce/apex/B2BPromotionsControllerCustom.getPromotions';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class CustomCarouselWrapper extends LightningElement {

    @api productId;
    @api effectiveAccountId;
    @api promo;
   
    get hasPromotionData(){
        return this.promo !== null;
    }
    //Parameter of Promotion
    get isNotPromotionStandard(){
        return this.promo.Mecanique_Promotion_TECH__c == true && this.promo.Mecanique_Promotion_TECH__c != undefined
    }
    get isBRI(){
        return this.promo.Type_de_promotion__c == 'BRI'
    }
    get isLVHO(){
        return this.promo.Type_de_promotion__c == 'LVHO'
    }
    //type of offer
    get isOfferM(){
        return this.promo.Type_d_offre__c == 'M'
    }
    get isOfferP(){
        return this.promo.Type_d_offre__c == 'P'
    }
    get isOfferQ(){
        return this.promo.Type_d_offre__c == 'Q'
    }

    connectedCallback(){
        if (showDebug) { console.log ('this.promo ' +this.promo);}
    }

}