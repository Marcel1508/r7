import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';
import productSearch from '@salesforce/apex/B2BSearchControllerCustom.productSearch';
import getCartSummary from '@salesforce/apex/B2BGetInfoCustom.getCartSummary';
import addToCart from '@salesforce/apex/B2BGetInfoCustom.addToCartPromocashQuantity';
import getExtraInfoPLP from '@salesforce/apex/B2BSearchControllerCustom.getExtraInfoPLP';
import { transformData, normalizedCardContentMapping } from './dataNormalizer';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

/**
 * A search resutls component that shows results of a product search or
 * category browsing.This component handles data retrieval and management, as
 * well as projection for internal display components.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Custom Search Results'
 */
export default class SearchResultsCustom extends NavigationMixin(LightningElement) {
    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    @api cartId;
    testAccountId = '';
    @track showStuff = false;
    communityid = communityId;

    /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
     connectedCallback() {
        this.testAccountId = this.effectiveAccountId;
        //this.updateCartInformation();
        this.triggerProductSearch();
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
     get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;
        if(
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ){
            resolved = effectiveAcocuntId;
        }
        return resolved;
    }
    /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
    set effectiveAccountId(newId) {
        if (showDebug) { console.log ('effectiveAccountId log');}
        this._effectiveAccountId = newId;
        this.testAccountId = newId;
        //à retester après mise en commun des méthodes apex
       this.updateCartInformation();
    }

    /**
     *  Gets or sets fields to show on a card.
     *
     * @type {string}
     */
    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    /**
     *  Gets or sets the layout of this component. Possible values are: grid, list.
     *
     * @type {string}
     */
    @api
    resultsLayout;

    /**
     *  Gets or sets whether the product image to be shown on the cards.
     *
     * @type {string}
     */
    @api
    showProductImage;

    /**
    * Triggering the search query imperatively. We can do declarative way if
       '_isLoading` is not required. It would be something like this.
     */ 
    get searchQueryx(){
        return JSON.stringify({
            searchTerm: this.term,
            categoryId: this.recordId,
            refinements: this._refinements,
            // use fields for picking only specific fields
            // using ./dataNormalizer's normalizedCardContentMapping
            fields: normalizedCardContentMapping(this._cardContentMapping),
            page: this._pageNumber - 1,
            includePrices: true
        });
    }

    @track opms;
    @track prixSpes;
    @track promotions;
    @track pfts;
    @track stocks;

     /*
     *  Note that setting the loading status while changing the parameter could
     *  work, but somtimes it gets into a weird cache state where no network
     *  call or callback (to your searchHandler where you can reset the load
     *  state) and you get into infinite UI spinning.
     *
     * @type {ConnectApi.ProductSummaryPage}
     * @private
     */
    triggerProductSearch() {
        this.testAccountId = this.effectiveAccountId;
        if (showDebug) { console.log ('recordID console: ' + this.recordId);}
        if (showDebug) { console.log ('testAccountId: ' + this.testAccountId);}
        const searchQuery = JSON.stringify({
            searchTerm: this.term,
            categoryId: this.recordId,
            refinements: this._refinements,
            // use fields for picking only specific fields
            // using ./dataNormalizer's normalizedCardContentMapping
            fields: normalizedCardContentMapping(this._cardContentMapping),
            page: this._pageNumber - 1,
            includePrices: true
        });
        if (showDebug) { console.log ('===> resolvedEffectiveAccountId: ' + JSON.stringify(this.resolvedEffectiveAccountId));}
        if (showDebug) { console.log ('===> searchQuery: ' + JSON.stringify(searchQuery));}
        // this._isLoading = true;
        productSearch({
            communityId: communityId,
            searchQuery: searchQuery,
            effectiveAccountId: this.resolvedEffectiveAccountId
        }).then((result) => {
                this.displayData = result;
                if (showDebug) { console.log ('productSearch res: ' + JSON.stringify(result));}
                
                let listProducts=[];
                let listProductsLocal = result;
                let productT=[];
                let productDisplayDataT=[];

                this.displayData.layoutData.forEach(function(product){
                        listProducts.push(product.id);
                });
        
                getExtraInfoPLP({
                    listProducts: listProducts,
                    effectiveAccountId: this.resolvedEffectiveAccountId
                }).then((res) => {
                        if (showDebug) { console.log ('XXXXXXXXX res' + JSON.stringify(res));}
                        let allProduits = undefined;
                        let allOpms = undefined;
                        let allPrixSpe = undefined;
                        let allPromos = undefined;
                        let allImages = undefined;
                        let loadedPFTs = undefined;
                        let loadedAllStocks = undefined;

                        if(this.resolvedEffectiveAccountId != null) { // Not guest user
                            allProduits = Object.keys(res[0]).map(key=> ({ key: key, ...res[0][key] }));
                            allOpms = Object.keys(res[1]).map(key=> ({ key: key, ...res[1][key] }));
                            allPrixSpe = Object.keys(res[2]).map(key=> ({ key: key, ...res[2][key] }));
                            allPromos = Object.keys(res[3]).map(key=> ({ key: key, ...res[3][key] }));
                            allImages = Object.keys(res[4]).map(key=> ({ key: key, ...res[4][key] }));
                            
                            //let allPFTs = Object.keys(res[4]).map(key=> ({ key: key, ...res[4][key] }));
                            loadedPFTs = res[5];
                            //let allStocks = Object.keys(res[5]).map(key=> ({ key: key, ...res[5][key] }));
                            loadedAllStocks = res[6];
                        } else {
                            if (showDebug) { console.log ('XXXXXXXXX res1' + JSON.stringify(res));}
                            allProduits = Object.keys(res[0]).map(key=> ({ key: key, ...res[0][key] }));
                            allPromos = Object.keys(res[1]).map(key=> ({ key: key, ...res[1][key] }));
                            allImages = Object.keys(res[2]).map(key=> ({ key: key, ...res[2][key] }));
                        }
                        if (showDebug) { console.log ('XXXXXXXXX allImages :' + JSON.stringify(allImages));}
                        listProductsLocal.productsPage.products.forEach(function(product){
                            const prodt = { ...product };
                            let customFields = [];

                            let produit = allProduits === undefined? undefined:  allProduits.find(item => item.Id === product.id);

                            let opm = allOpms === undefined? undefined: allOpms.find(item => item.Produit__c === product.id);
                            let prixSpe = allPrixSpe === undefined? undefined: allPrixSpe.find(item => item.Produit__c === product.id);
                            let promo = allPromos === undefined? undefined: allPromos.find(item => item.Produit__c === product.id);
                            let image = allImages === undefined? undefined: allImages.find(item => item.ProductId__c === product.id);
                            if (showDebug) { console.log ('XXXXXXXXX images :' + JSON.stringify(image));}
                            //let pft = allPFTs.find(item => item.key === product.id);
                            let pft = loadedPFTs === undefined? undefined: loadedPFTs[product.id];
                            //let stock = allStocks.find(item => item.key === product.id);
                            let stock = loadedAllStocks === undefined? undefined: loadedAllStocks[product.id];

                            if (showDebug) { console.log ('XXXXXXXXX produit' + JSON.stringify(produit));}

                            //customFields.push({"Origines__c": product.Origines__c});
                            /*customFields.push({"Origines__c": produit.Origines__c});
                            customFields.push({"Picto_front__c": product.Picto_front__c});
                            prodt.customFields = customFields;*/
                            
                            if(produit !== undefined){
                                prodt.produit = produit;
                            }
                            if(opm !== undefined){
                                prodt.opm = opm;
                            }
                            if(promo !== undefined){
                                prodt.promo = promo;
                            }
                            if(prixSpe !== undefined){
                                prodt.prixSpe = prixSpe;
                            }
                            if(pft !== undefined){
                                prodt.pft = pft;
                            }

                            if(image !== undefined){
                                prodt.image = image;
                            }
                            if(image !== undefined){
                                prodt.stock = stock;
                            }
                            product = prodt;
                            productT.push(prodt);
                            return prodt;
                        });
                    }).then(() => {
                            this.displayExtraData = productT;
                            let displayDataT = this.displayData.layoutData;
                            let displayExtraDataT = this.displayExtraData;
                            
                            displayDataT.forEach(function(product){
                                const prodt = { ...product };
                                let extraInfo = displayExtraDataT.find(item => item.id === product.id);
                                if(extraInfo !== undefined){
                                    prodt.extraInfo = extraInfo;
                                }
                                product = prodt;
                                productDisplayDataT.push(prodt);
                                return prodt;
                            });
                    }).then(() => {
                        this.displayExtraData = productDisplayDataT;
                        if (showDebug) { console.log ('Result ===> displayExtraData' + JSON.stringify(this.displayExtraData));}
                    }).catch((error2) => {
                    this.error = error2;
                    if (showDebug) { console.log (error2);}
                });
        }).catch((error) => {
            this.error = error;
            if (showDebug) { console.log ('=======erreur'+ JSON.stringify(error));}
        });
    }

    /**
     * Gets the normalized component configuration that can be passed down to
     *  the inner components.
     *
     * @type {object}
     * @readonly
     * @private
     */
    get config() {
        return {
            layoutConfig: {
                resultsLayout: this.resultsLayout,
                cardConfig: {
                    showImage: this.showProductImage,
                    resultsLayout: this.resultsLayout,
                    actionDisabled: this.isCartLocked
                }
            }
        };
    }

    /**
     * Gets or sets the normalized, displayable results for use by the display components.
     *
     * @private
     */
    get displayData() {
        return this._displayData || {};
    }
    set displayData(data) {
        this._displayData = transformData(data, this._cardContentMapping);
    }

    /**
     * Gets whether product search is executing and waiting for result.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    // get isLoading() {
    //     return this._isLoading;
    // }

    /**
     * Gets whether results has more than 1 page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasMorePages() {
        return this.displayData.total > this.displayData.pageSize;
    }

    /**
     * Gets the current page number.
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get pageNumber() {
        return this._pageNumber;
    }

    /**
     * Gets the header text which shows the search results details.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get headerText() {
        let text = '';
        const totalItemCount = this.displayData.total;
        const pageSize = this.displayData.pageSize;
        if (totalItemCount > 1) {
            const startIndex = (this._pageNumber - 1) * pageSize + 1;
            const endIndex = Math.min(
                startIndex + pageSize - 1,
                totalItemCount
            );

            text = `${startIndex} - ${endIndex} sur ${totalItemCount} produits`;
        } else if (totalItemCount === 1) {
            text = '1 Resultat';
        }
        return text;
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get isCartLocked() {
        const cartStatus = (this._cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    /**
     * Handles a user request to add the product to their active cart.
     *
     * @private
     */
    handleAction(evt) {
        evt.stopPropagation();
        addToCart({
            communityId: communityId,
            productId: evt.detail.productId,
            quantity: evt.detail.quantity,
            effectiveAccountId: this.resolvedEffectiveAccountId
        }).then(() => {
                this.dispatchEvent(
                    new CustomEvent('cartchanged', {
                        bubbles: true,
                        composed: true
                    })
                );
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Succès',
                        message: 'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
        }).catch(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erreur',
                    message:
                        '{0} could not be added to your cart at this time. Please try again later.',
                    messageData: [evt.detail.productName],
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
    }

    /**
     * Handles a user request to clear all the filters.
     *
     * @private
     */
    handleClearAll(/*evt*/) {
        this._refinements = [];
        this._recordId = this._landingRecordId;
        this._pageNumber = 1;
        this.template.querySelector('c-search-filter-custom').clearAll();
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to navigate to the product detail page.
     *
     * @private
     */
    handleShowDetail(evt) {
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: evt.detail.productId,
                actionName: 'view'
            }
        });
    }

    /**
     * Handles a user request to navigate to previous page results page.
     *
     * @private
     */
    handlePreviousPage(evt) {
        evt.stopPropagation();
        this._pageNumber = this._pageNumber - 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to navigate to next page results page.
     *
     * @private
     */
    handleNextPage(evt) {
        evt.stopPropagation();
        this._pageNumber = this._pageNumber + 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to filter the results from facet section.
     *
     * @private
     */
    handleFacetValueUpdate(evt) {
        evt.stopPropagation();
        this._refinements = evt.detail.refinements;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to show a selected category from facet section.
     *
     * @private
     */
    handleCategoryUpdate(evt) {
        evt.stopPropagation();
        this._recordId = evt.detail.categoryId;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    /**
     * Ensures cart information is up to date
     */
    updateCartInformation() {
        //Call method only for connected users
        if(this.resolvedEffectiveAccountId != null) {
            getCartSummary({
                communityId: communityId,
                effectiveAccountId: this.resolvedEffectiveAccountId
            }).then((result) => {
                    this._cartSummary = result;
                    this.cartId = result.cartId;
            }).catch((e) => {
                    // Handle cart summary error properly
                    // For this sample, we can just log the error
                    if (showDebug) { console.log (e);}
            });
        }
    }

    _displayData;
    displayExtraData = [];
    _displayDataTest;
    //_isLoading = false;
    _pageNumber = 1;
    _refinements = [];
    _term;
    _recordId;
    _landingRecordId;
    _cardContentMapping;
    _effectiveAccountId;
    /**
     * The cart summary information
     * @type {ConnectApi.CartSummary}
     */
    _cartSummary;

    /**
     *  Gets or sets the unique identifier of a category.
     *
     * @type {string}
     */
     @api
     get recordId() {
         return this._recordId;
     }
     set recordId(value) {
         this._recordId = value;
         this._landingRecordId = value;
         if (showDebug) { console.log ('triggerProductSearch log');}
         //this.triggerProductSearch();
     }

     /**
     *  Gets or sets the search term.
     *
     * @type {string}
     */
    @api
    get term() {
        return this._term;
    }
    set term(value) {
        this._term = value;
        if (value) {
            //this.triggerProductSearch();
        }
    }
 

    renderedCallback(){
        if(this.displayData !== undefined){
            this.showStuff = true;
        }
        //if (showDebug) { console.log ('displayExtraData', this.displayExtraData);}
    }
}