import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import SelectedShelf_FIELD from '@salesforce/schema/Campaign.Selected_Rayons__c';
import ValidationCampaign_FIELD from '@salesforce/schema/Campaign.Validation_Campaign__c';
import CampaignRecordType_FIELD from '@salesforce/schema/Campaign.RecordTypeId';
import SendDate_FIELD from '@salesforce/schema/Campaign.Send_Date__c';
import EmailSubject_FIELD from '@salesforce/schema/Campaign.EmailSubject__c';
import SelectedPromotion_FIELD from '@salesforce/schema/Campaign.Selected_Promotion__c';
import PromoState_FIELD from '@salesforce/schema/Campaign.PromoState__c';
import userId from '@salesforce/user/Id';
import getCampaignRecord from '@salesforce/apex/SelectionPromotionController.getCampaign';
import getProductsByShelf from '@salesforce/apex/SelectionPromotionController.getProductsByShelf';
import getPromotionSetByTemplate from '@salesforce/apex/SelectionPromotionController.getPromotionSetByTemplate';
import getCampaignMembers from '@salesforce/apex/SelectionPromotionController.getCampaignMembers';
import updateCampMbrStatus from '@salesforce/apex/SelectionPromotionController.updateCampMbrStatus';
import emailBAT from '@salesforce/label/c.emailBAT';
import objectEmpty from '@salesforce/label/c.objectEmpty';
import campaignValidated from '@salesforce/label/c.campaignValidated';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import wrongTemplate from '@salesforce/label/c.wrongTemplate';
import summaryCampaign from '@salesforce/label/c.summaryCampaign';
import scheduleSendCampaign from '@salesforce/label/c.scheduleSendCampaign';
import cancel from '@salesforce/label/c.cancel';
import previewEmail from '@salesforce/label/c.previewEmail';
import checkboxAcceptCampaign from '@salesforce/label/c.checkboxAcceptCampaign';
import sendNow from '@salesforce/label/c.sendNow';
import selectedContactPromo from '@salesforce/label/c.selectedContactPromo';
import validateSelection from '@salesforce/label/c.validateSelection';
import validationCampaign from '@salesforce/label/c.validationCampaign';
import selectionPromo from '@salesforce/label/c.selectionPromo';
import validatedCampaign from '@salesforce/label/c.validatedCampaign';
import previewEmailUrlRayons from '@salesforce/label/c.previewEmailUrlRayons';
import previewEmailUrlMultiPrd from '@salesforce/label/c.previewEmailUrlMultiPrd';
import confirmationValidationCmp from '@salesforce/label/c.confirmationValidationCmp';
import initializationCampaign from '@salesforce/label/c.initializationCampaign';
import nbrProductMax from '@salesforce/label/c.nbrProductMax';
import priorisationPromo from '@salesforce/label/c.priorisationPromo';
import selectCorrectNbrPromo from '@salesforce/label/c.selectCorrectNbrPromo';
import msgSelectPromoCamapaign from '@salesforce/label/c.msgSelectPromoCamapaign';
import acceptCheckboxValidCampaign from '@salesforce/label/c.acceptCheckboxValidCampaign';
import validateModal from '@salesforce/label/c.validateModal';
import saveState from '@salesforce/label/c.saveState';
import updateFieldSObject from '@salesforce/apex/SelectionPromotionController.updateFieldSObject';
import addLeadTestToCampaign from '@salesforce/apex/SelectionPromotionController.addLeadTestToCampaign';
import getCampaignSettings from '@salesforce/apex/SelectionPromotionController.getCampaignSettings';

import GoBack from '@salesforce/label/c.GoBack';
import { NavigationMixin } from 'lightning/navigation';

export default class SelectionPromoLWC extends NavigationMixin(LightningElement){
    cmpId;
    RTReadOnlyCmp = '0125r000000FQVGAA4';
    data = '';
    shelves = [];
    selectedPromoLines = '';
    displayCmp = false;
    displayModalError = false;
    msgSelectPromoCamapaign = msgSelectPromoCamapaign;
    wrongTemplate=wrongTemplate;
    selectionPromo=selectionPromo;
    summaryCampaign = summaryCampaign;
    emailBAT = emailBAT;
    initializationCampaign=initializationCampaign;
    validationCampaign=validationCampaign;
    scheduleSendCampaign = scheduleSendCampaign;
    acceptCheckboxValidCampaign = acceptCheckboxValidCampaign;
    checkboxAcceptCampaign = checkboxAcceptCampaign;
    selectedContactPromo=selectedContactPromo;
    saveState = saveState;
    previewEmail = previewEmail;
    GoBackToCampaign = GoBack;
    priorisationPromo= priorisationPromo;
    validateSelection=validateSelection;
    selectCorrectNbrPromo=selectCorrectNbrPromo;
    sendNow = sendNow;
    validateModal=validateModal;
    nbrProductMax = nbrProductMax;
    cancel = cancel;
    confirmationValidationCmp=confirmationValidationCmp;
    selectedPromoNoPrio = '';
    campaignUrl = '';
    categsSelected = '';
    @track shelfPrd = [];
    checkedpromoLines = [];
    checkedpromos = [];
    keywordProduct = '';
    @track searchDic = [];
    checkBoxDic = [];
    @track productChecked = [];
    checkedItemSize = 0 ;
    tempPromoSetting = '';
    ctgSelectedPrdMap = new Map (); 
    //testMap = new Map ([["ALCOOLS", 0], ["Brasserie", 0 ] ,["Bazar", 0]]); 
    members = new Map();
    displaySelectionPromo = false;
    displayValidationPromo = false;
    nbPromoShelfOK = true;
    maxPromoOK;
    nbrContacts;
    acceptCheckBox=false;
    isConfirmModal = false;
    isSendNowModal = false;
    showSpinner = true;
    dateTimeToday = new Date().toISOString();
    options = [];
    value = '';
    promoLinesPrio = [];
    sortedPriority = [];
    checkedpromos = [];
    membersIds = [];
    contactIds = [];
    @api recordId;
    @track isSelectionPromoForm = false;
    //handle of display footer
    @track goToSelectionPromScreenFooter = false;
    @track goToPriorisationScreenFooter = false;
    @track goToValidationScreenFooter = false;
   
   

    @wire(getCampaignSettings)
    campaignSettings;

    sendTestEmail(){
        this.showSpinner = true;
        addLeadTestToCampaign({cmpId : this.cmpId, userId : userId}).then(cmpMbr=>{
            updateCampMbrStatus({cmpId : this.cmpId, idsList : [cmpMbr.LeadId], memberType :'Lead', statusValue : 'Validé'}).then(campMbrStatus =>{
                if(campMbrStatus){
                        this.showSpinner = false;
                        console.log('Result updateCampMbrStatus() : ' + JSON.stringify(campMbrStatus));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Succès',
                                message: 'Succès - Email de test envoyé',
                                variant: 'success'
                            })
                        );
                }
            })
            .catch(error => {
            this.showSpinner = false;
                console.log('ERROR updateCampMbrStatus() : ' + JSON.stringify(error));
                this.error = error;
            })
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('ERROR addLeadToCampaignTest() : ' + JSON.stringify(error));
            this.error = error;
        });
    }

    handlePriorChange(event) {
        console.log('prior selected : ' +  event.detail.value);
        console.log('id product combobox : ' + event.currentTarget.dataset.key);
        console.log(this.checkedpromoLines);
        var sortedPriority = [];
        this.checkedpromoLines.forEach(function (item) {
            console.log(item);
            var prd = [];
            item.products.forEach(function (it) {
                if(it.id === event.currentTarget.dataset.key){
                    it.priority = event.detail.value;
                }
                prd.push(it);
                sortedPriority.push(it);
            });
            item.products = prd;
            console.log('size rayon : ' +  item.products.length);
        });

        sortedPriority.sort(function(a, b){
            return a.priority - b.priority;
        });

        this.sortedPriority = sortedPriority;
        console.log('sorted items prio : ' +  JSON.stringify(this.sortedPriority));
        console.log('checkedpromoLines : ' +  JSON.stringify(this.checkedpromoLines));
    }


    startSelectionPromoProcess() {

        console.log('startSelectionPromoProcess');
        this.shelfPrd = [];
        this.data = '';
        this.productChecked = [];
        this.isSelectionPromoForm = true;

        this.goToSelectionPromScreenFooter = true;
        this.goToPriorisationScreenFooter = false;
        this.goToValidationScreenFooter = false;

        this.mainMethod();
    }

    openModal() {
        // to open modal set isSelectionPromoForm tarck value as true
        this.isSelectionPromoForm = true;
    }

    closeModal() {
        // to close modal set isSelectionPromoForm tarck value as false
        this.isSelectionPromoForm = false;
       // this.shelfPrd = [];
       // this.data = '';
      
    }
    
    mainMethod() {
    
        console.log('mainMethod');
        console.log('name field : ' + JSON.stringify(SelectedPromotion_FIELD));
        console.log('date time : ' + this.dateTimeToday);
        console.log('date time : ' + new Date().toUTCString());
   
       // this.cmpId = new URLSearchParams(window.location.search).get('c__cmpId');

       //this.cmpId = '7015r000000G8LWAA0';
        this.cmpId = this.recordId; 
        this.campaignUrl = '/'+this.cmpId;
 
        console.log('id cmp : ' + this.cmpId);
 
        getCampaignRecord({recordId : this.cmpId}).then(result=>{
            this.data  = (result != undefined) ? result : '';
            this.isEmailPromo = this.data.Type == 'Email - Promotions' ;
            console.log('data campaign : ' + JSON.stringify(this.data));
            getPromotionSetByTemplate({templateName : this.data.Template__c}).then(result=>{
                this.tempPromoSetting = result;
                console.log('Setting Template Promotions : ' + JSON.stringify(this.tempPromoSetting));
            })
           
            if(this.data.Template__c !== 'Promotions multi-produits' && this.data.Template__c !== 'Promotions avec rayons'){
                console.log('wrong template : ' + this.data.Template__c);
                this.displayModalError = true;
                this.showSpinner = false;
            }
            else if(this.data.Validation_Campaign__c == true){
                this.wrongTemplate = validatedCampaign;
                this.displayModalError = true;
                this.showSpinner = false;
            }
            else{
                this.isPromoRayons = this.data.Template__c == 'Promotions avec rayons' ;
                this.isPromoMulti = this.data.Template__c == 'Promotions multi-produits' ;
                this.displayCmp = true
                console.log('data campaign : ' + JSON.stringify(this.data));
                getProductsByShelf({promoHeaderId : this.data.Promotion_Header__c, magasinId : this.data.Magasin__c}).then(res=>{
                    this.prdByShelf = res;
                    console.log('List des rayons / products (ordre de priorité) : ' + JSON.stringify(res));
                     for(var key in res){
                        for(var key2 in res[key]){
                            this.ctgSelectedPrdMap.set(key2, 0);
                            let x = res[key];
                            let tab = [];
                            let tab2 = [];
                            for(var key3 in x[key2]){
                                let y = x[key2];
                                if(this.data.PromoState__c){
                                    this.checkedpromos = JSON.parse(this.data.PromoState__c);
                                    this.checkedpromos.forEach((item) => {
                                        if(item.categorie == key2){
                                                var exist= item.products.find(it => it.id == key3);
                                                if(exist){
                                                    this.productChecked.push(key3);
                                                    console.log('prd checked 1 '+ JSON.stringify(this.productChecked));
                                                    tab.push({id:key3, details:y[key3][0], checked: true});
                                                    let x = this.ctgSelectedPrdMap.get(key2);
                                                    x = x+1;
                                                    this.ctgSelectedPrdMap.set(key2, x);      
                                                }
                                                else{
                                                    tab.push({id:key3, details:y[key3][0], checked: false});
                                                }
                                        }
                                    });
                                }
                                else{
                                    tab.push({id:key3, details:y[key3][0], checked:false});
                                }
                            } 
                            this.shelfPrd.push({ categorie:key2, products:tab, productselected : 0});
                            this.checkBoxDic = (this.data.PromoState__c) ? this.shelfPrd : [];
                        }
                    }
                    console.log('List des rayons / products to display on UI : ' + JSON.stringify(this.shelfPrd));
                    this.showSpinner = false;
                })
            }
        })

        getCampaignMembers({cmpId : this.cmpId}).then(result=>{
            for(let member in result) {
                this.membersIds.push(result[member].Id);
                if(result[member].ContactId){
                    this.contactIds.push(result[member].ContactId);
                }
             }
            console.log('members : ' + JSON.stringify(this.membersIds));
            console.log('contact Ids : ' + JSON.stringify(this.contactIds));
        })
        .catch(error => {
            console.log('ERROR getCampaignMembers() : ' + JSON.stringify(error));
            this.error = error;
        });
    }

    renderedCallback(){
        this.checkedItemSize = this.productChecked.length;
    } 

    navigateToCampaign(){
        window.open('/'+this.cmpId,"_self");

        //this.showSpinner = true;
        /*
             updateFieldSObject({recordId : this.cmpId, sObjectName : SelectedPromotion_FIELD.objectApiName, qApiName : SelectedPromotion_FIELD.fieldApiName, value : ''}).then(()=>{
                updateFieldSObject({recordId : this.cmpId, sObjectName : SelectedShelf_FIELD.objectApiName, qApiName : SelectedShelf_FIELD.fieldApiName, value : ''}).then(()=>{
                   // updateFieldSObject({recordId : this.cmpId, sObjectName : 'Campaign', qApiName : 'PromoState__c', value : ''}).then(()=>{
          
                   this.showSpinner = false;
                        window.open('/'+this.cmpId,"_self");
                    //})
 
                })
                .catch(error => {
                    console.log('ERROR : ' + JSON.stringify(error));
                    this.error = error;
                });
 
            })
            .catch(error => {
                console.log('ERROR : ' + JSON.stringify(error));
                this.error = error;
            });
        */
    }
    
    clickProductCheckBox(event){
        console.log('product checked : ' + JSON.stringify(this.productChecked));
        console.log('checkbox label: ' + event.target.label);
        console.log('checkbox checked: ' + event.target.checked);
        console.log('id product checked : ' + event.currentTarget.dataset.key);
        console.log('categ product checked : ' + event.currentTarget.dataset.id);
        var idProduct = event.currentTarget.dataset.key;
        var ctgProduct = event.currentTarget.dataset.id;
        var checked = event.target.checked;
        this.checkBoxDic = [];
        this.checkedpromos = [];

        for(var key in this.prdByShelf){
            for(var key2 in this.prdByShelf[key]){
                if(ctgProduct == key2){
                    console.log('key2 : ' + key2);
                    if(this.ctgSelectedPrdMap.has(key2) === false){
                        if(checked === true){
                            this.ctgSelectedPrdMap.set(key2, 1);
                        }
                        else{
                            this.ctgSelectedPrdMap.set(key2, 0);
                        }
                    }
                    else{
                        if(checked === true){
                            let x = this.ctgSelectedPrdMap.get(key2);
                            x = x+1;
                            this.ctgSelectedPrdMap.set(key2, x);      
                        }
                        else{
                            let x = this.ctgSelectedPrdMap.get(key2);
                            x = x-1;
                            this.ctgSelectedPrdMap.set(key2, x);   
                        } 
                    }
                }
               let x = this.prdByShelf[key];
               //array to get all the products checked and not checked
               let tab = [];
               //array to get only the selected products
               let tabSelectedPrds = [];
                for(var key3 in x[key2]){
                    let y = x[key2];
                    if(checked === true){
                            if(key3 === idProduct){
                                tab.push({id:key3, details:y[key3][0], checked:true}); 
                                tabSelectedPrds.push({id:key3, checked:true}); 
                                this.productChecked.push(idProduct);
                            }
                            else{
                                if(this.productChecked.includes(key3)){
                                    tab.push({id:key3, details:y[key3][0], checked:true})
                                    //get only selected products
                                    tabSelectedPrds.push({id:key3, checked:true}); 
                                }
                                else{
                                    tab.push({id:key3, details:y[key3][0], checked:false});
                                }
                            }
                            console.log('array checked : ' +  JSON.stringify(this.productChecked));
                    }
                    else if(checked === false){
                        if(key3 === idProduct){
                            tab.push({id:key3, details:y[key3][0], checked:false});
                            this.productChecked = this.arrayRemove(this.productChecked, idProduct);
                            console.log('array checked : ' +  JSON.stringify(this.productChecked));
                        }
                        else{
                            if(this.productChecked.includes(key3)){
                                tab.push({id:key3, details:y[key3][0], checked:true});
                                tabSelectedPrds.push({id:key3, checked:true}); 
                            }
                            else{
                                tab.push({id:key3, details:y[key3][0], checked:false});
                            }
                        }
                    }
                }
                this.checkBoxDic.push({ categorie:key2, products:tab});
                this.checkedpromos.push({ categorie:key2, products:tabSelectedPrds});
            }
        }
        this.checkedItemSize= this.productChecked.length;
        console.log('map checked and not checked : ' + JSON.stringify(this.checkBoxDic));
        this.checkedpromos.forEach(function (item) {
            console.log('map for checked promo lines  : ' + JSON.stringify(item.categorie));
            
        });
        console.log('size checked : ' + this.checkedItemSize);
        console.log('checked Promos  : ' + JSON.stringify(this.checkedpromos));
    }  

    savePromoState(){
        this.showSpinner = true;
        if(this.checkedpromos){
            console.log('promo state : ' + JSON.stringify(this.checkedpromos));
            updateFieldSObject({recordId : this.cmpId, sObjectName : PromoState_FIELD.objectApiName, qApiName : PromoState_FIELD.fieldApiName, value : JSON.stringify(this.checkedpromos)}).then(result=>{
                if(result){
                    this.showSpinner = false;
                    window.open('/'+this.cmpId,"_self");this.navigateToCampaignWwithoutReset();
                }
            })
            .catch(error => {
                console.log('ERROR savePromoState updateFieldSObject: ' + JSON.stringify(error));
                this.error = error;
            });
        }
        else{
            console.log('nthg to save');
        }    
    }

    arrayRemove(arr, value) { 
        return arr.filter(function(ele){ 
            return ele != value; 
        });
    }
    
    getCheckedPromoLines(){
        console.log('prio : ' + JSON.stringify(this.sortedPriority));
        console.log('prd sel : ' + JSON.stringify(this.productChecked));
        console.log('shelf prd : ' + JSON.stringify(this.shelfPrd));
        this.options=[];
        console.log('checkBoxDic : ' + JSON.stringify(this.checkBoxDic));
        this.checkedpromoLines = JSON.parse(JSON.stringify(this.checkBoxDic));
        var productCheckedAll = [];
        console.log('checked promo : ' + JSON.stringify(this.checkedpromoLines));
        this.checkedpromoLines.forEach(function (item) {
            console.log(item);
            var prd = [];
            item.products.forEach(function (it) {
                if(it.checked === true){
                    prd.push(it);
                    productCheckedAll.push(it);
                }
            });
            item.products = prd;
            console.log('size rayon : ' +  item.products.length);
        });

        console.log('New  : ' + JSON.stringify(this.checkedpromoLines));
        console.log('selected promo lines : ' + JSON.stringify(productCheckedAll));   
        this.selectedPromoNoPrio = productCheckedAll.join(',');
        for(let i=1; i<productCheckedAll.length+1; i++){
            this.options.push({label : i.toString(), value : i.toString() });
        }
        console.log('options : ' + JSON.stringify(this.options));
        console.log('selected promo no prio : ' + this.selectedPromoNoPrio);

    }
    searchProduct(event){
        this.keywordProduct= event.target.value;
        this.keywordProduct= this.keywordProduct.toLowerCase();
        this.searchDic = [];
        console.log('search- tab checked prd : ' + this.productChecked );
        for(var key in this.prdByShelf){
            console.log('key : ' + key);
            for(var key2 in this.prdByShelf[key]){
                console.log('key2 : ' + key);
                let x = this.prdByShelf[key];
                let tab = [];
                for(var key3 in x[key2]){
                    let y = x[key2];
                    let prdLabel = y[key3][0].toLowerCase();
                    let codeRayon = y[key3][1].toLowerCase();
                    let marque = y[key3][2].toLowerCase();
                    let codeIFLS = y[key3][3].toLowerCase();
                    console.log('Product Detail : '+  JSON.stringify(y[key3]));
                    if(prdLabel.includes(this.keywordProduct) || codeRayon.includes(this.keywordProduct) || marque.includes(this.keywordProduct) || codeIFLS.includes(this.keywordProduct)){
                        if(this.productChecked.includes(key3)){
                            tab.push({id:key3, details:y[key3][0], checked:true});
                        }
                        else{
                            tab.push({id:key3, details:y[key3][0], checked:false});
                         }
                    }
                }
                this.searchDic.push({ categorie:key2, products:tab});
            }
        }
        this.shelfPrd = this.searchDic;
        console.log('Search Result: ' + JSON.stringify(this.searchDic));
    }

    validateSelectionPromo(){
        console.log('nb promo ctg alcools : ' + this.ctgSelectedPrdMap.get('ALCOOLS'));
        console.log('nb promo ctg brasserie : ' + this.ctgSelectedPrdMap.get('Brasserie'));
        console.log('Nom Template : ' + this.data.Template__c);
        console.log('Nom metadata type : ' + this.tempPromoSetting.Label);
        console.log('Nb promo : ' + this.tempPromoSetting.Number_of_Promotions__c);
        console.log('Nb promo/rayon : ' + this.tempPromoSetting.Nb_Max_Promo_Shelf__c);
        let categsSelectedArray = [];
        for (let [key, value] of this.ctgSelectedPrdMap) {
                if(value>0){
                categsSelectedArray.push(key);
            }
        }
        this.categsSelected = categsSelectedArray.join(',');
        console.log("categs selected : " +this.categsSelected );
        this.maxPromoOK = true;
        this.nbPromoShelfOK = true;;
        this.showSpinner = true;
        if(this.data.Template__c == this.tempPromoSetting.Label){
            if(this.tempPromoSetting.Number_of_Promotions__c && this.tempPromoSetting.Nb_Max_Promo_Shelf__c){
                console.log('Number promo pour template Promotions avec rayons : ' +this.tempPromoSetting.Number_of_Promotions__c);
                console.log('nb of selected products : ' + this.checkedItemSize);
                if(this.checkedItemSize > this.tempPromoSetting.Number_of_Promotions__c || this.checkedItemSize == 0){
                    console.log('inside error toast1');
                    this.showSpinner = false;
                    this.maxPromoOK = false;
                    const event = new ShowToastEvent({
                        "title": "Erreur",
                        'variant' :"error",
                        "message": this.msgSelectPromoCamapaign
                    });
                    this.dispatchEvent(event);
                }
                else{
                    for (let [key, value] of this.ctgSelectedPrdMap) {
                        console.log(key + " = " + value);
                        this.showSpinner = false;
                        console.log('Nb max à selectionner par rayon : ' + this.tempPromoSetting.Nb_Max_Promo_Shelf__c);
                        if((value != this.tempPromoSetting.Nb_Max_Promo_Shelf__c) && value != ''){
                            console.log('inside error toast2');
                            this.nbPromoShelfOK = false;
                            const event = new ShowToastEvent({
                                "title": "Erreur",
                                'variant' :"error",
                                "message": this.msgSelectPromoCamapaign// this.nbrProductMax + this.tempPromoSetting.Nb_Max_Promo_Shelf__c
                            });
                            this.dispatchEvent(event);
                        }
                    }
                }
                if(this.maxPromoOK && this.nbPromoShelfOK){
                    this.showSpinner = true;
                    this.goToPriorisationScreen();
                    this.goToPriorisationScreenFooter = true;
                    this.goToSelectionPromScreenFooter = false;
                    this.goToValidationScreenFooter = false;
                   /* updateFieldSObject({cmpId : this.cmpId, qApiName : 'Selected_Rayons__c', value : this.categsSelected}).then(result=>{
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.log('ERROR : ' + JSON.stringify(error));
                        this.error = error;
                    });*/
                }
            }
            else if(this.tempPromoSetting.Multiple_de__c){
                this.showSpinner = true;
                if((this.checkedItemSize % (this.tempPromoSetting.Multiple_de__c)) != 0 || this.checkedItemSize == 0){  
                    this.showSpinner = false;
                        const event = new ShowToastEvent({
                        "title": "Erreur",
                        'variant' :"error",
                        "message": this.selectCorrectNbrPromo+ " : Multiple de " + this.tempPromoSetting.Multiple_de__c
                    });
                    this.dispatchEvent(event);
                }
                else{
                    this.goToPriorisationScreen();
                    this.goToPriorisationScreenFooter = true;
                    this.goToSelectionPromScreenFooter = false;
                    this.goToValidationScreenFooter = false;
                }
            }
        }
    }

    updateSelectedPromoCampaign(){
        this.showSpinner = true;
        console.log('promolines selected : '+ this.selectedPromoLines);
        updateFieldSObject({recordId : this.cmpId, sObjectName : SelectedPromotion_FIELD.objectApiName, qApiName : SelectedPromotion_FIELD.fieldApiName,value : this.selectedPromoLines}).then(result=>{
            console.log('template : ' + this.data.Template__c);
            if(this.data.Template__c == 'Promotions avec rayons'){
                console.log('selected categ : ' + this.categsSelected);
                updateFieldSObject({recordId : this.cmpId, sObjectName : SelectedShelf_FIELD.objectApiName, qApiName : SelectedShelf_FIELD.fieldApiName, value : this.categsSelected}).then((cmp)=>{
                    console.log('updated campaign : ' + JSON.stringify(cmp));
               })
               .catch(error => {
                   console.log('ERROR : ' + JSON.stringify(error));
                   this.error = error;
               });
            }
            this.template.querySelector(".priorisationPromo").classList.add("slds-hide");
            this.template.querySelector(".validationPromo").classList.remove("slds-hide");
            let match = this.template.querySelector("li[role='priorisationPromo']");
            match.className = 'slds-path__item slds-is-current';
            match = this.template.querySelector("li[role='validationPromo']");
            match.className = 'slds-path__item slds-is-active'; 
            console.log('get Campaign Members : ' + JSON.stringify(this.data.NumberOfContacts));
            this.nbrContacts = this.data.NumberOfContacts;
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('ERROR updateSelectedPromoCampaign() : ' + JSON.stringify(error));
            this.error = error;
        });
    }

    goToPriorisationScreen(){
        this.template.querySelector(".selectionPromo").classList.add("slds-hide");
        let match = this.template.querySelector("li[role='selectionPromo']");
        match.className = 'slds-path__item slds-is-current';
        this.template.querySelector(".priorisationPromo").classList.remove("slds-hide");
        match = this.template.querySelector("li[role='priorisationPromo']");
        match.className = 'slds-path__item slds-is-active'; 
        this.showSpinner = false;
        this.getCheckedPromoLines();
    }

    goToValidation(){
       // let missingPrio = false;
        let checkDuplicPrioArray = [];
        let duplicatePrioFound = false;
        this.template.querySelectorAll('lightning-combobox').forEach(combobox => {
            console.log('values combobox : ' + combobox.value);
            /*
                if(combobox.value == undefined){
                    missingPrio = true;
                    const event = new ShowToastEvent({
                        "title": "Erreur",
                        'variant' :"error",
                        "message": "Merci de selectionner une priorité pour chaque promotion"
                    });
                    this.dispatchEvent(event);  
                    this.break;
                }*/
                //else{
                    if(combobox.value != undefined){
                        checkDuplicPrioArray.push(combobox.value);
                    }
              //  }
            }
        );

        duplicatePrioFound = checkDuplicPrioArray.some((element, index) => {
            return checkDuplicPrioArray.indexOf(element) !== index
        });
        console.log('duplicate found : ' + duplicatePrioFound);
        if(duplicatePrioFound){
            const event = new ShowToastEvent({
                "title": "Erreur",
                'variant' :"error",
                "message": "Priorisation doit être unique"
            });
            this.dispatchEvent(event);  
        }

        if(!duplicatePrioFound){
            this.template.querySelector(".priorisationPromo").classList.add("slds-hide");
            let match = this.template.querySelector("li[role='priorisationPromo']");
            match.className = 'slds-path__item slds-is-current';
            
            this.template.querySelector(".validationPromo").classList.remove("slds-hide");
            match = this.template.querySelector("li[role='validationPromo']");
            match.className = 'slds-path__item slds-is-active'; 
            // this.showSpinner = true;
            var selectedPromoLineIds = [];
            console.log('checkd sortedPriority : ' + JSON.stringify(this.sortedPriority));
            console.log('checkd promo : ' + JSON.stringify(this.checkedpromoLines));

            if(this.sortedPriority.length >0){
                this.sortedPriority.forEach(function (prd) {
                    selectedPromoLineIds.push(prd.id);
                });
            }
            else {
                this.checkedpromoLines.forEach(function (item) {
                          item.products.forEach(function (it) {
                              selectedPromoLineIds.push(it.id);
                        });
                 });
            }

            this.selectedPromoLines = selectedPromoLineIds.join(',');
            console.log('selected promo lines : ' + this.selectedPromoLines);
            this.goToPriorisationScreenFooter = false;
            this.goToSelectionPromScreenFooter = false;
            this.goToValidationScreenFooter = true;
            this.updateSelectedPromoCampaign();
        }
    }

    handleSelecPromoClick(){
        console.log("click select promo in the path : OK ");
        // set selection promo as active
        let match = this.template.querySelector("li[role='selectionPromo']");
        match.className = 'slds-path__item slds-is-active';
        //set validation promo as inactive
        match = this.template.querySelector("li[role='priorisationPromo']");
        match.className = 'slds-path__item slds-is-incomplete';

        match = this.template.querySelector("li[role='validationPromo']");
        match.className = 'slds-path__item slds-is-incomplete';

        this.template.querySelector(".selectionPromo").classList.remove("slds-hide");
        this.template.querySelector(".priorisationPromo").classList.add("slds-hide");
        this.template.querySelector(".validationPromo").classList.add("slds-hide");
        console.log('selection promo shelf : ' + JSON.stringify(this.shelfPrd));
    }
 

    handlePriorPromoClick() {
        if( this.template.querySelector("li[role='validationPromo']").className == 'slds-path__item slds-is-active'){
            let match = this.template.querySelector("li[role='priorisationPromo']");
            match.className = 'slds-path__item slds-is-active';
            //set validation promo as inactive
            match = this.template.querySelector("li[role='validationPromo']");
            match.className = 'slds-path__item slds-is-incomplete';
            
            this.template.querySelector(".priorisationPromo").classList.remove("slds-hide");
            this.template.querySelector(".validationPromo").classList.add("slds-hide");
        }
    }

    scheduleSendModal() {
        if(!this.acceptCheckBox || (this.template.querySelector('lightning-input[data-name="EmailSubject"]').value == "")){
            const event = new ShowToastEvent({
                "title": "Erreur",
                'variant' :"error",
                "message": (!this.acceptCheckBox ) ? this.checkboxAcceptCampaign : objectEmpty
            });
            this.dispatchEvent(event);
       }
       else{
            this.isConfirmModal = true;
       }
    }

    sendNowModal() {
        if(!this.acceptCheckBox || (this.template.querySelector('lightning-input[data-name="EmailSubject"]').value == "")){
            const event = new ShowToastEvent({
                "title": "Erreur",
                'variant' :"error",
                "message": (!this.acceptCheckBox ) ? this.checkboxAcceptCampaign : objectEmpty
            });
            this.dispatchEvent(event);
        }
        else{
            this.isSendNowModal = true;
        }
    }

    clickCheckBoxAccept(event) {
        console.log('Accept checkbox label: ' + event.target.label);
        console.log('Accept checkbox checked: ' + event.target.checked);
        this.acceptCheckBox = (event.target.checked) ? true : false;
    }

    closeConfirmModal() {
        if(this.isConfirmModal){
            this.isConfirmModal = false;
        }
        if(this.isSendNowModal){
            this.isSendNowModal = false;
        }
    }

    submitCampaign() {
        this.closeConfirmModal();
        this.showSpinner = true;

        console.log('click submit : ' + this.template.querySelector('lightning-input[data-name="scheduledDate"]'));
        var date;
        if(this.template.querySelector('lightning-input[data-name="scheduledDate"]')){
            date = this.template.querySelector('lightning-input[data-name="scheduledDate"]').value;
            updateFieldSObject({recordId : this.cmpId, sObjectName : SendDate_FIELD.objectApiName, qApiName : SendDate_FIELD.fieldApiName, value : date }).then(result=>{
                if(result){
                    console.log('set Send Date OK');
                }
                else{
                    console.log('set Send Date KO');
                }
            })
            .catch(error => {
                console.log('ERROR updateFieldSObject() : ' + JSON.stringify(error));
                this.error = error;
            });
        }
        else{
            date = this.dateTimeToday;
        }
             updateFieldSObject({recordId : this.cmpId, sObjectName : ValidationCampaign_FIELD.objectApiName, qApiName : ValidationCampaign_FIELD.fieldApiName, value : true }).then(result=>{
                updateFieldSObject({recordId : this.cmpId, sObjectName : CampaignRecordType_FIELD.objectApiName, qApiName : CampaignRecordType_FIELD.fieldApiName, value : this.campaignSettings.data.RT_Campaign_ReadOnly__c}).then(result=>{
                    updateCampMbrStatus({cmpId : this.cmpId, idsList : this.contactIds, memberType :'Contact', statusValue : 'Validé'}).then(campMbrStatus =>{
                        console.log('campaign member Id : ' + this.cmpId);
                        console.log('member Ids : ' + this.contactIds);

                        if(campMbrStatus){
                            if(this.template.querySelector('lightning-input[data-name="EmailSubject"]')){
                                updateFieldSObject({recordId : this.cmpId, sObjectName : EmailSubject_FIELD.objectApiName, qApiName : EmailSubject_FIELD.fieldApiName, value : this.template.querySelector('lightning-input[data-name="EmailSubject"]').value }).then(result=>{
                                    if(result){
                                        console.log('set Email Subject OK');
                                    }
                                    else{
                                        console.log('set Email Subject KO');
                                    }
                                })
                                .catch(error => {
                                    console.log('ERROR updateFieldSObject() - Field Email Subject : ' + JSON.stringify(error));
                                    this.error = error;
                                });
                            }
                            this.showSpinner = false;
                            console.log('updateCampMbrStatus() : ' + JSON.stringify(campMbrStatus));
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Succès',
                                    message: campaignValidated,
                                    variant: 'success'
                                })
                            );
                            this.wrongTemplate = validatedCampaign;
                            window.open('/'+this.cmpId,"_self");
                        }
                    })
                    .catch(error => {
                        console.log('ERROR updateCampMbrStatus() : ' + JSON.stringify(error));
                        this.error = error;
                    });
                })
                .catch(error => {
                    console.log('ERROR updateFieldSObject() : ' + JSON.stringify(error));
                    this.error = error;
                });
            })
            .catch(error => {
                console.log('ERROR updateFieldSObject() : ' + JSON.stringify(error));
                this.error = error;
            });

    }

 
    handlePreviewEmail(){

       // let membersId = this.membersIds.join(',');
       // let subscriberKey = this.contactIds.join(',');
        console.log('camp Id : ' + this.cmpId);

      //  this.showSpinner = true;
/*
        // API Callout to Marketing Cloud
        sendDataToMarketingCallout({configName : 'MC_Inject_Members', campId : this.cmpId, rayons : this.categsSelected, promoIds : this.selectedPromoLines, campaignMemberID : membersId, subscriberKey : subscriberKey}).then((res)=>{
            console.log('Response Callout Fire Event : ' + JSON.stringify(res));*/
         //   this.showSpinner = false;
            if(this.data.Template__c == 'Promotions avec rayons'){  
                window.open(previewEmailUrlRayons+'?CampaignID='+this.cmpId);
            }
            else if(this.data.Template__c == 'Promotions multi-produits'){
                window.open(previewEmailUrlMultiPrd+'?CampaignID='+this.cmpId);
            }
            /*
        })
        .catch(error => {
            console.log('ERROR sendDataToMarketingCallout() : ' + JSON.stringify(error));
            this.error = error;
        });*/
    }
}