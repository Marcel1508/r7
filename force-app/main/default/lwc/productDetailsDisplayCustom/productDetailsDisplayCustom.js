import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { htmlDecode } from "c/cartUtilsCustom";
import { resolve } from "c/cmsResourceResolverCustom";

import communityId from "@salesforce/community/Id";
import getOffreProduitMagasin from "@salesforce/apex/B2BGetInfoCustom.getOffreProduitMagasin";
import checkProductIsPFT from "@salesforce/apex/B2BGetInfoCustom.checkProductIsPFT";
import getPrixSpecifique from "@salesforce/apex/B2BGetInfoCustom.getPrixSpecifique";
import getCartSummary from "@salesforce/apex/B2BGetInfoCustom.getCartSummary";
import getPromotions from "@salesforce/apex/B2BPromotionsControllerCustom.getPromotions";
import getPromotionsForGuestUser from "@salesforce/apex/B2BPromotionsControllerCustom.getPromotionsForGuestUser";
import getDisplayedProductName from "@salesforce/apex/B2BGetInfoCustom.getDisplayedProductName";
import getDisplayedProductData from "@salesforce/apex/B2BGetInfoCustom.getDisplayedProductData";
import getTaxeEmballageUnitaire from "@salesforce/apex/B2BCartTaxesCustom.getTaxeEmballageUnitaire";
import getProductImagesForPDP from "@salesforce/apex/B2BBasePhotoControllerCustom.getProductImagesForPDP";
import checkStockAndEnCours from "@salesforce/apex/B2BGetInfoCustom.checkStockAndEnCours";
//images
import DEFAULT_IMAGE from "@salesforce/resourceUrl/DefaultImage";
import BANNER_PROMO from "@salesforce/resourceUrl/BannerPromo";
// labels
import URL_default_image from "@salesforce/label/c.URL_default_image";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
import isGuest from '@salesforce/user/isGuest';

// A fixed entry for the home page.
const homePage = {
  name: "Home",
  type: "standard__namedPage",
  attributes: {
    pageName: "home"
  }
};

/**
 * An organized display of product information.
 *
 * @fires ProductDetailsDisplay#addtocart
 */
/**
 * An organized display of product information.
 *
 * @fires ProductDetailsDisplay#addtolist
 */
export default class ProductDetailsDisplayCustom extends NavigationMixin(
  LightningElement
) {
  cmtyId = communityId;
  @track quantity = 1;
  quantityClient = 1;
  @track bannerPromo = BANNER_PROMO;
  @track defaultImage = DEFAULT_IMAGE;
  @track hasDefaultImage = false;
  isGuestUser = isGuest;
  /**
   * An event fired when the user indicates the product should be added to their cart.
   *
   * Properties:
   *   - Bubbles: false
   *   - Composed: false
   *
   * @event ProductDetailsDisplay#addtocart
   * @type {CustomEvent}
   *
   * @export
   */

  /**
   * An event fired when the user indicates the product should be added to their list.
   *
   * Properties:
   *   - Bubbles: false
   *   - Composed: false
   *
   * @event ProductDetailsDisplay#addtolist
   * @type {CustomEvent}
   *
   * @export
   */

  /**
   * A product image.
   * @typedef {object} Image
   *
   * @property {string} url
   *  The URL of an image.
   *
   * @property {string} alternativeText
   *  The alternative display text of the image.
   */

  /**
   * A product category.
   * @typedef {object} Category
   *
   * @property {string} id
   *  The unique identifier of a category.
   *
   * @property {string} name
   *  The localized display name of a category.
   */

  /**
   * A product price.
   * @typedef {object} Price
   *
   * @property {string} negotiated
   *  The negotiated price of a product.
   *
   * @property {string} currency
   *  The ISO 4217 currency code of the price.
   */

  /**
   * Gets or sets the name of the product.
   *
   * @type {string}
   */
  @api
  description;

  @api
  recordId;

  @api
  effectiveAccountId;

  /**
   * Gets or sets the product image.
   *
   * @type {Image}
   */
  @api
  image;

  @api
  product;

  /**
   * Gets or sets the name of the product.
   *
   * @type {string}
   */
  @api
  name;

  /**
   * Gets or sets the price - if known - of the product.
   * If this property is specified as undefined, the price is shown as being unavailable.
   *
   * @type {Price}
   */
  @api
  price;

  /**
   * Gets or sets teh stock keeping unit (or SKU) of the product.
   *
   * @type {string}
   */
  @api
  sku;
  @api
  cartId;

  stockAndEnCours;

  @api medias;

  // Poids_brut__c, Conservation__c, Allergenes__c, Labelrouge__c, AOC__c FROM Product2 where Id=:productId LIMIT 1];
  @track energieKJ;
  @track energieKcal;
  @track matieresGrasse
  @track dontAcidesGras;
  @track glucides;
  @track dontSucres;
  @track Proteines;
  @track sel;
  
  
  @track msgNoInformation = 'Pas d\'information';
  @track ingredients;
  @track conseilUtilisation;
  @track infosAvertissement;
  @track mentionsLegales;
  @track degreAlcool;
  @track couleur
  @track cuvee
  @track cepages
  @track accordMetsVins


  @track poidsBrut
  @track getConservation
  @track allergenes
  @track labelRouge
  @track getAoc

  @track conditionnement;
 // @track ecotaxe;
 // @track montantConsigne;


  @wire (getDisplayedProductName,{productId: '$recordId'}) DisplayedProductName;

  @wire (getDisplayedProductData,{productId: '$recordId'}) 
  wiredGetDisplayedProductData({ error, data }) {
    if (data) {
      console.log('$$$$ data = ' + JSON.stringify(data));

      this.conditionnement = (data[0].Conditionnement__c == undefined) ? '' : data[0].Conditionnement__c;
     // this.ecotaxe = (data[0].Ecotaxe__c == undefined) ? '0' : data[0].Ecotaxe__c;
    //  this.montantConsigne = (data[0].Consigne__c == undefined) ? '0' : data[0].Consigne__c;
    
      //Description
      this.conseilUtilisation = (data[0].Conseils_d_utilisation__c == undefined) ? this.msgNoInformation : data[0].Conseils_d_utilisation__c;
      this.infosAvertissement = (data[0].Infos_et_avertissements__c == undefined) ? this.msgNoInformation : data[0].Infos_et_avertissements__c;
      this.mentionsLegales = (data[0].Mentions_legales__c == undefined) ? this.msgNoInformation : data[0].Mentions_legales__c;
      this.degreAlcool = (data[0].Degre_alcool__c == undefined) ? this.msgNoInformation : data[0].Degre_alcool__c;
      this.couleur = (data[0].Couleur__c == undefined) ? this.msgNoInformation : data[0].Couleur__c;
      this.cuvee = (data[0].Cuvee__c == undefined) ? this.msgNoInformation : data[0].Cuvee__c;
      this.cepages = (data[0].Cepages__c == undefined) ? this.msgNoInformation : data[0].Cepages__c;
      this.accordMetsVins = (data[0].Accords_mets_vins__c == undefined) ? this.msgNoInformation : data[0].Accords_mets_vins__c;

      //Ingredients et nutrition
      this.ingredients = (data[0].Ingredients__c == undefined) ? this.msgNoInformation : data[0].Ingredients__c;
      this.energieKJ = (data[0].Energie_Kj__c == undefined) ? this.msgNoInformation : data[0].Energie_Kj__c;
      this.energieKcal = (data[0].Energie_Kcal__c == undefined) ? this.msgNoInformation : data[0].Energie_Kcal__c;
      this.matieresGrasse = (data[0].Matieres_grasses__c == undefined) ? this.msgNoInformation : data[0].Matieres_grasses__c;
      this.dontAcidesGras = (data[0].dont_acides_gras__c == undefined) ? this.msgNoInformation : data[0].dont_acides_gras__c;
      this.glucides = (data[0].Glucides__c == undefined) ? this.msgNoInformation : data[0].Glucides__c;
      this.dontSucres = (data[0].dont_sucres__c == undefined) ? this.msgNoInformation : data[0].dont_sucres__c;
      this.Proteines = (data[0].Proteines__c == undefined) ? this.msgNoInformation : data[0].Proteines__c;
      this.sel = (data[0].Sel__c == undefined) ? this.msgNoInformation : data[0].Sel__c;
  
      //Caracteristiques
      this.poidsBrut = (data[0].Poids_brut__c == undefined) ? this.msgNoInformation : data[0].Poids_brut__c;
      this.getConservation = (data[0].Conservation__c == undefined) ? this.msgNoInformation : data[0].Conservation__c;
      this.allergenes = (data[0].Allergenes__c == undefined) ? this.msgNoInformation : data[0].Allergenes__c;
      this.labelRouge = (data[0].Labelrouge__c == undefined) ? this.msgNoInformation : data[0].Labelrouge__c;
      this.getAoc = (data[0].AOC__c == undefined) ? this.msgNoInformation : data[0].AOC__c;

      this.error = undefined;
    } else if (error) {
        this.error = error;
        this.energie = undefined;
        console.log(' wiredGetDisplayedProductData error' + JSON.stringify(error));
    }
  }
  
  opm;
  statut;
  taxeemballageunitaire;
  guestUserPromo;
  hasTaxeEmballageUnitaire;
  picto;
  isPFT;
  prixSpecifique;
  @api buttonDisabledAddToCart = false;
  _categoryPath;
  _resolvedCategoryPath = [];
  lastCategoryName;
  slides1 = [];

  // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
  // which the NavigationMixin implicitly requires to function properly.
  _resolveConnected;
  _connected = new Promise(resolve => {
    this._resolveConnected = resolve;
  });
  
  redirectToCart() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/promocash/s/cart/" + this.cartId
      }
    });
  }

  connectedCallback() {
    if (showDebug) { console.log ("productDetailsDisplay this.effectiveAccountId: " + this.effectiveAccountId);}
    if (showDebug) { console.log ("productDetailsDisplay this.product: " + this.recordId);}
    
 
    getPromotions({
      productId: this.recordId,
      effectiveAccountId: this.effectiveAccountId
    })
    .then(res => {
      if (showDebug) { console.log ('getPromotions res: ', res);}
      this.promotion = {"data": res};
    })
    .catch(err => {
      this.promotion = {};
      if (showDebug) { console.log ('getPromotions err: ', err);}
    })

    getPromotionsForGuestUser({
      productId: this.recordId,
    })
    .then(res => {
      if (showDebug) { console.log ('getPromotionsForGuestUser res: ', res);}
      this.guestUserPromo = {"data": res};
    })
    .catch(err => {
      this.guestUserPromo = {};
      if (showDebug) { console.log ('getPromotionsForGuestUser err: ', err);}
    })

    getProductImagesForPDP({
      productId: this.recordId,
    })
    .then(res => {
      if (showDebug) { console.log ('??????'+JSON.stringify(res));}
      if(res!= null)
      {
        let slides=[];
        let slide;
        res.forEach(element => {
          slide={
            image: element.Product_Image_URL__c,
            heading: "Image par défaut",
            description: "Image par défaut"
          }
          slides.push(slide);
        });
        this.slides1 = slides;     
      } 
      else
      {
        let slides=[];
        let slide = {
          image: DEFAULT_IMAGE,
          heading: "Image par défaut",
          description: "Image par défaut"
        };
        slides.push(slide);
        this.slides1 = slides;
      }         
      if (showDebug) { console.log ('slides1 res: ', res.length, ' ', res, ' ', res[0]);}
    }).catch(err => {
      if (showDebug) { console.log ('slides1 err : ', err);}
    })
    
    getTaxeEmballageUnitaire({
      productId: this.recordId
    })
    .then(res => {
      if (showDebug) { console.log ('gettaxeemballageunitaire res: ', res);}
      this.taxeemballageunitaire = {"data": res};
      if(this.taxeemballageunitaire.data>0)
      {
        this.hasTaxeEmballageUnitaire=true;
      }
    })
    .catch(err => {
      if (showDebug) { console.log ('gettaxeemballageunitaire err: ', err);}
    })

    getCartSummary({
      communityId: this.cmtyId,
      effectiveAccountId: this.effectiveAccountId
    })
      .then(result => {
        this.cartId = result.cartId;
        if (showDebug) { console.log ('getCartSummary' + JSON.stringify(result));}
        if (result.status !== "Active") {
          this.buttonDisabledAddToCart = true;
        }
      })
      .catch(e => {
        if (showDebug) { console.log ("getCartSummary error : " + JSON.stringify(e));}
      });
    
      
    
      if(this.effectiveAccountId == '000000000000000' || this.effectiveAccountId == undefined) {
        this.opm = undefined;
      } else {
        getOffreProduitMagasin({
          productId: this.recordId,
          effectiveAccountId: this.effectiveAccountId
        })
          .then(result => {
            if (showDebug) { console.log ('this.recordId: ' + this.recordId);}
            if (showDebug) { console.log ('this.effectiveAccountId: ' + this.effectiveAccountId);}
            this.opm = result;
            if (showDebug) { console.log ('this.opm: ' + JSON.stringify(this.opm));}
            this.statut = this.opm.Statut__c;
            this.picto = this.opm.Produit__r.Picto_front__c;
            this.getPrixSpecifique();
          })
          .catch(e => {
            // Handle quantity update error properly
            // For this sample, we can just log the error
            if (showDebug) { console.log ("e");}
            if (showDebug) { console.log (e);}
          });

          checkStockAndEnCours({
            productId: this.recordId,
            effectiveAccountId: this.effectiveAccountId
          })
          .then(result => {
            this.stockAndEnCours = result;
          })
          .catch(e => {
            console.log('Error while getting stock en cours');
          });
      }
    

    checkProductIsPFT({
      productId: this.recordId,
      effectiveAccountId: this.effectiveAccountId
    })
      .then(resultPFT => {
        this.isPFT = resultPFT;
      })
      .catch(e => {
        if (showDebug) { console.log ("e");}
        if (showDebug) { console.log (e);}
      });
    this._resolveConnected();
  }

  getPrixSpecifique() {
    getPrixSpecifique({
      effectiveAccountId: this.effectiveAccountId,
      opmId: this.opm.Id,
      productId: this.recordId
    })
      .then(result => {
        this.prixSpecifique = result;
      })
      .catch(e => {
        // Handle quantity update error properly
        // For this sample, we can just log the error
        if (showDebug) { console.log ("e");}
        if (showDebug) { console.log (e);}
      });

    if (showDebug) { console.log ("this promotion price box : ", this.promotion);}
  }

  disconnectedCallback() {
    this._connected = new Promise(resolve => {
      this._resolveConnected = resolve;
    });
  }

  /**
   * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
   *
   * @type {Category[]}
   */
  @api
  get categoryPath() {
    return this._categoryPath;
  }

  set categoryPath(newPath) {
    this._categoryPath = newPath;
    this.resolveCategoryPath(newPath || []);
  }

  get hasPrice() {
    return ((this.price || {}).negotiated || "").length > 0;
  }
  

  /**
   * Emits a notification that the user wants to add the item to their list.
   *
   * @fires ProductDetailsDisplay#addtolist
   * @private
   */
  notifyAddToList() {
    this.template
      .querySelector("c-list-add-itemsor-create-custom")
      .initDefaultValues(this.lastCategoryName);
  }

  get hasOpmStatusAndPFT() {
    if (this.opm !== undefined && this.isPFT !== undefined) {
      return this.opm.Statut__c !== undefined;
    } else {
      return false;
    }
  }

  get isGuestUser() {
    return (
      this.effectiveAccountId == null ||
      this.effectiveAccountId == "000000000000000"
    );
  }

  get isDisabled() {
    if (this.opm == undefined) return true;
    return (
      //this.opm.Statut__c == "4" ||
      this.opm.Statut__c == "5" ||
      this.isPFT == true
    );
  }

  get hasSku() {
    return (
      this.product.data.fields.StockKeepingUnit != null &&
      this.product.data.fields.StockKeepingUnit !== undefined
    );
  }

  get getSku() {
    return this.product.data.fields.StockKeepingUnit;
  }

  get hasCodeRayon() {
    return (
      this.product.data.fields.Code_rayon__c != null &&
      this.product.data.fields.Code_rayon__c !== undefined
    );
  }

  get getCodeRayon() {
    return this.product.data.fields.Code_rayon__c;
  }

  get hasCodeIFLS() {
    return (
      this.product.data.fields.Code_IFLS__c != null &&
      this.product.data.fields.Code_IFLS__c !== undefined
    );
  }

  get getCodeIFLS() {
    return this.product.data.fields.Code_IFLS__c;
  }

  get hasVignetteAlcool() {
    return (
      this.opm != undefined &&
      this.opm.vignette_alcool__c != null &&
      this.opm.vignette_alcool__c !== undefined &&
      this.opm.vignette_alcool__c > 0
    );
  }

  get getVignetteAlcool() {
    if(this.opm == undefined)
      return undefined;
    return this.opm.vignette_alcool__c
  }

  get getPicto(){
    return htmlDecode(this.product.data.fields.Picto_front__c);
    
  }

  get hasMedias() {
    return this.medias !== undefined;
  }

  get slides() {
    let finalresult = [];
    let productDetailImages = this.medias.find(
      item => item.developerName === "productDetailImage"
    );
    productDetailImages.mediaItems.forEach(function(image) {
      if (
        "'" + image.url + "'" == URL_default_image &&
        image.title == "image"
      ) {
        let slide = {
          image: DEFAULT_IMAGE,
          heading: "Image par défaut",
          description: "Image par défaut"
        };
        finalresult.push(slide);
      } else {
        let slide = {
          image: resolve(image.url),
          heading: image.alternativeText,
          description: image.title
        };
        finalresult.push(slide);
      }
    });
    return finalresult;
  }


  get hasOpms() {
    return this.opm !== undefined;
  }

  get getProductStatut() {
    if(this.opm == undefined)
      return 'disponible';

    return this.opm.Statut__c;
  }

  get hasStatusLabel() {
    return this.statut != undefined || this.statut != null;
  }

  get hasPrixKilo() {
    return (
      this.opm != undefined &&
      this.opm.Prix_kilo__c != null &&
      this.opm.Prix_kilo__c !== undefined &&
      this.opm.Prix_kilo__c != 0
    );
  }
  get getPrixKilo() {
    if(this.opm == undefined)
      return undefined;

    return this.opm.Prix_kilo__c;
  }
  get hasPrixLitre() {
    return (
      this.opm != undefined &&
      this.opm.Prix_L__c != null &&
      this.opm.Prix_L__c !== undefined &&
      this.opm.Prix_L__c != 0
    );
  }
  get getPrixLitre() {
    if(this.opm == undefined)
      return undefined;

    return this.opm.Prix_L__c;
  }

  get hasLibelleConditionnement() {
    return (
      this.opm.Libelle_du_conditionnement_de_vente__c != undefined ||
      this.opm.Libelle_du_conditionnement_de_vente__c != null
    );
  }

  get libelleConditionnement() {
    if(this.opm == undefined)
      return undefined;
    return this.opm.Libelle_du_conditionnement_de_vente__c;
  }

  get hasPrixUnite() {
    return (
      this.opm.Prix_unite__c != undefined &&
      this.opm.Prix_unite__c != null &&
      this.opm.Prix_unite__c != 0
    );
  }
  get prixUnite() {
    if(this.opm == undefined)
      return undefined;
    return this.opm.Prix_unite__c;
  }

  get statutLabel() {
    if(this.opm == undefined)
      return undefined;

    this.statut = this.opm.Statut__c;
    if (this.statut == 1) {
      this.statut = "Disponible";
    }
    if (this.statut == 2) {
      this.statut = "Disponible sous commande";
    }
    if (this.statut == 3) {
      this.statut = "Disponible en quantité limitée";
    }
    if (this.statut == 4) {
      this.statut = "Indisponible temporairement";
    }
    if (this.statut == 5) {
      this.statut = "Indisponible";
    }
    return this.statut;
  }

  get ifProductStatutGreen() {
    if(this.opm == undefined)
      return undefined;

    return this.opm.Statut__c == "1" || this.opm.Statut__c == "3";
  }
  get ifProductStatutOrange() {
    if(this.opm == undefined)
      return undefined;

    return this.opm.Statut__c == "2";
  }
  get ifProductStatutRed() {
    if(this.opm == undefined)
      return undefined;

    return (
      this.opm.Statut__c == "4" ||
      this.opm.Statut__c == "5" ||
      this.hasOpms == false
    );
  }

  get hasPrixSpecifique() {
    return this.prixSpecifique !== undefined && this.prixSpecifique !== null;
  }

  get hasPrixUnitePS() {
    return (
      this.prixSpecifique.Prix_unite__c != undefined ||
      this.prixSpecifique.Prix_unite__c != null
    );
  }
  get prixUnitePS() {
    return this.prixSpecifique.Prix_unite__c;
  }

  get hasPrixKiloPS() {
    return (
      this.prixSpecifique.Prix_kilo__c != undefined ||
      this.prixSpecifique.Prix_kilo__c != null
    );
  }
  get prixKiloPS() {
    return this.prixSpecifique.Prix_kilo__c;
  }

  get hasPrixLitrePS() {
    return (
      this.prixSpecifique.Prix_L__c != undefined ||
      this.prixSpecifique.Prix_L__c != null
    );
  }
  get prixLitrePS() {
    return this.prixSpecifique.Prix_L__c;
  }

  get hasPic() {
    return this.picto != undefined && this.picto != null;
  }
  
  get hasPicto() {
    return (
      this.product.data.fields.Picto_front__c != null &&
      this.product.data.fields.Picto_front__c !== undefined
    );
  }
  /*zameziane*/
  get hasIndicateurBio() {
    return (
      this.product.data.fields.Indicateur_bio__c != null &&
      this.product.data.fields.Indicateur_bio__c !== undefined &&
      this.product.data.fields.Indicateur_bio__c != "false"
    );
  }

  get hasOrigines() {
    return (
      this.product.data.fields.Origines__c != null &&
      this.product.data.fields.Origines__c !== undefined
    );
  }

  get getOrigines() {
    return this.product.data.fields.Origines__c;
  }

  get hasConditionnement() {
    return (
      this.product.data.fields.Conditionnement__c != null &&
      this.product.data.fields.Conditionnement__c !== undefined
    );
  }
  get getConditionnement() {
    console.log('$$$ this.product.data.fields.Conditionnement__c ' +this.product.data.fields.Conditionnement__c);
    return this.product.data.fields.Conditionnement__c;
  } 

  get hasEcotaxe() {
    return (
      this.product.data.fields.Ecotaxe__c != null &&
      this.product.data.fields.Ecotaxe__c !== undefined && 
      this.product.data.fields.Ecotaxe__c >0
    );
  }
  get getEcotaxe() {
    return this.product.data.fields.Ecotaxe__c;
  } 

  get hasMontantConsigne() {
    return (
      this.product.data.fields.Consigne__c != null &&
      this.product.data.fields.Consigne__c !== undefined
    );
  }
  get getMontantConsigne() {
    return this.product.data.fields.Consigne__c;
  } 

  // get hasBio() {
  //   return (
  //     this.product.data.fields.ABCERTIFIEAGRIBIOvert__c != null &&
  //     this.product.data.fields.ABCERTIFIEAGRIBIOvert__c !== undefined
  //   );
  // }

  get hasLabelRouge() {
    return (
      this.product.data.fields.Labelrouge__c != null &&
      this.product.data.fields.Labelrouge__c !== undefined
    );
  }

  pftCondition () {return this.opm !== undefined && this.opm.unit_de_prix__c === 'UCT' && this.opm.Code_departement__c === '4'}

  get getKGPriceCssClass() {
    return this.pftCondition() == true? 'slds-text-heading_large product-price': 'prixKg slds-text-heading_small';
  }

  get getPriceCssClass() {
    return this.pftCondition() == false? 'slds-text-heading_large product-price': 'prixKg slds-text-heading_small';
  }
  
  /**
   * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
   *
   * @param {Category[]} newPath
   *  The new category "path" for the product.
   */
  resolveCategoryPath(newPath) {
    const path = [homePage].concat(
      newPath.map(level => ({
        name: level.name,
        type: "standard__recordPage",
        attributes: {
          actionName: "view",
          recordId: level.id
        }
      }))
    );

    this._connected
      .then(() => {
        const levelsResolved = path.map(level =>
          this[NavigationMixin.GenerateUrl]({
            type: level.type,
            attributes: level.attributes
          }).then(url => ({
            name: level.name,
            url: url
          }))
        );

        return Promise.all(levelsResolved);
      })
      .then(levels => {
        this._resolvedCategoryPath = levels;
        this.lastCategoryName = this._resolvedCategoryPath[
          this._resolvedCategoryPath.length - 1
        ].name;
      });
  }

  /** PROMOTIONS **/

  /*@wire(getPromotions, {
    productId: this.recordId,
    effectiveAccountId: this.effectiveAccountId
  })
  promotion;
*/

  get priceNotFoundMessage() {
    return (this.isGuestUser === true)? 'Pour voir le prix connectez-vous': 'Prix introuvable';
  }

  get hasPromotions() {
    if(this.promotion == undefined)
      return false;
    if(this.promotion.data == undefined || this.promotion.data == null)
      return false;
    return this.promotion.data != null && this.promotion.data != undefined;
  }

  get hasGuestUserPromotions() {
    if(this.guestUserPromo == undefined)
      return false;
    if(this.guestUserPromo.data == undefined || this.guestUserPromo.data == null)
      return false;
    return this.guestUserPromo.data != null && this.guestUserPromo.data != undefined;
  }

  /** EVENT QUANTITY + AJOUT CART  */
  handleQuanitytChange(e) {
    this.quantity = this.template.querySelector("input[data-my-id=in1]").value;
    if (
      this.quantity == "" ||
      this.quantity == null ||
      this.quantity == undefined
    ) {
      this.quantity = 1;
    }
  }

  redirectToLogin() {
    let urlString = window.location.href;
    let state = {};
    state["startURL"] = encodeURI(urlString);

    let pageReference = {
      type: "comm__loginPage",
      attributes: {
        actionName: "login"
      },
      state: state
    };
    this[NavigationMixin.Navigate](pageReference);
  }
  renderedCallback() {
    if (showDebug) { console.log ("this promotion : ", JSON.stringify(this.promotion));}
  }

  get prixPromo(){
    return this.promotion.data.Prix_de_vente_promotion__c 
}

}