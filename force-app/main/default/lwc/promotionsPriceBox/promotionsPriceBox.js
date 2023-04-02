import { LightningElement, api, track } from 'lwc';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class PromotionsPriceBox extends LightningElement {
    /**
     * Gets or sers the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    /**
     *  Gets or sets the unique identifier of a product.
     * 
     * @type {string}
     */
    @api
    recordId;

    @api promotion;
    renderedCallback(){
        if (showDebug) { console.log('this promotion price box : ', this.promotion);  }
    }

    get hasPromotionData(){
        return this.promotion.data != null && this.promotion.data != undefined
    }

    //Parameter of Promotion
    get isNotPromotionStandard(){
        return this.promotion.data.Mecanique_Promotion_TECH__c == true && this.promotion.data.Mecanique_Promotion_TECH__c != undefined
    }
    get isBRI(){
        return this.promotion.data.Type_de_promotion__c == 'BRI'
    }
    get isLVHO(){
        return this.promotion.data.Type_de_promotion__c == 'LVHO'
    }

    get hasProductLibelleCondionnement() {
        return this.promotion.data.Produit__r != undefined && this.promotion.data.Produit__r.Libelle_du_conditionnement_vente__c;
    }

    //type of offer
    get isOfferM(){
        return this.promotion.data.Type_d_offre__c == 'M'
    }
    get isOfferP(){
        return this.promotion.data.Type_d_offre__c == 'P'
    }
    get isOfferQ(){
        return this.promotion.data.Type_d_offre__c == 'Q'
    }
/*
    //quantity
    get hasMinQuantity(){
        return this.promotion.data.Quantite_minimum_de_commande__c != null
    }
    get hasPaidQuantity(){
        return this.promotion.data.Quantite_payee__c != null
    }

    //price
    get hasPricePromotion(){
        return this.promotion.data.Prix_de_vente_promotion__c != null
    }
    get hasRemise(){
        return this.promotion.data.Remise_en_e__c != null
    }
    get hasRemiseP(){
        return this.promotion.data.Remise_en_p__c != null
    }
    get hasPrixSousMecanique(){
        return this.promotion.data.Prix_sous_mecanique__c != null
    }

    //Phrase
    get hasPhrase(){
        return this.promotion.data.Phrase_offre__c != null
    }
    get hasLibelleConditionnement(){
        return this.promotion.data.Produit__r.Libelle_du_conditionnement_vente__c != null
    }
    get hasLibellePeriode(){
        return this.promotion.data.Libelle_periode_de_promotion__c != null
    }*/

}