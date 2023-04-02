import {LightningElement, api, track, wire} from 'lwc';
import getMagasinServices from "@salesforce/apex/CreneauMagasinRecurrentService.getMagasinServices";
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsubCustom';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class MultiPickList extends LightningElement {

    @api label  = 'Services disponibles'; //Name of the dropDown
    @api maxselected  = 2; //Max selected item display
    options;

    @api showfilterinput = false; //show filterbutton
    @api showrefreshbutton = false; //show the refresh button
    @api showclearbutton = false; //show the clear button
    @api comboplaceholder = 'Selectionner les services'; 
    
    @track _initializationCompleted = false;
    @track _selectedItems = 'Selectionner les services';
    @track _filterValue;
    @track _mOptions;
    @api selectedEnseigne;
    @api selectedServices;
    @api defaultMagasin;

    constructor () {
        super();
        this._filterValue = '';
        if (showDebug) { console.log ('Constructor');}
    }

    renderedCallback () {
        if (showDebug) { console.log ('renderedCallback');}
        let self = this;
        if (!this._initializationCompleted) {
            this.template.querySelector ('.ms-input').addEventListener ('click', function (event) {
                if (showDebug) { console.log  ('multipicklist clicked');}
                self.onDropDownClick(event.target);
                event.stopPropagation ();
            });
            this.template.addEventListener ('click', function (event) {
                if (showDebug) { console.log  ('multipicklist-1 clicked');}
                event.stopPropagation ();
            });
            document.addEventListener ('click', function (event) {
                if (showDebug) { console.log  ('document clicked');}
                self.closeAllDropDown();
            });
            this._initializationCompleted = true;
            this.setPickListName ();
        }
        if (showDebug) { console.log ('renderedCallback Finished');}
    }
    handleItemSelected (event) {
        if (showDebug) { console.log ('handleItemSelected : ');}
        let self = this;
        this._mOptions.forEach (function (eachItem) {
            if (eachItem.key == event.detail.item.key) {
                eachItem.selected = event.detail.selected;
                return;
            }
        });

        this.selectedServices ='';

        for (let i = 0; i < this._mOptions.length; i++) {
            if(this._mOptions[i].selected) {
                this.selectedServices += this._mOptions[i].value+';';
            }
          }

        if (showDebug) { console.log ('this.selectedServices  ' + this.selectedServices);}

        this.setPickListName ();
        this.onItemSelected ();
    }

    filterDropDownValues (event) {
        this._filterValue = event.target.value;
        this.updateListItems (this._filterValue);
    }
    closeAllDropDown () {
        Array.from (this.template.querySelectorAll ('.ms-picklist-dropdown')).forEach (function (node) {
             node.classList.remove('slds-is-open');
        });
    }

    onDropDownClick (dropDownDiv) {
        let classList = Array.from (this.template.querySelectorAll ('.ms-picklist-dropdown'));
        if(!classList.includes("slds-is-open")){
            this.closeAllDropDown();
            Array.from (this.template.querySelectorAll ('.ms-picklist-dropdown')).forEach (function (node) {
                node.classList.add('slds-is-open');
            });
        } else {
            this.closeAllDropDown();
        }
    }
    onRefreshClick (event) {
        this._filterValue = '';
        this.initArray (this);
        this.updateListItems ('');
        this.onItemSelected ();
    }
    onClearClick (event) {
        this._filterValue = '';
        this.updateListItems ('');
    }

    @wire(CurrentPageReference) pageRef; // Required by pubsub

    connectedCallback () {  
        if (showDebug) { console.log ('== connectedCallback');}
        this.selectedEnseigne = this.defaultMagasin;
        this.getMagasin(this);
        if (showDebug) { console.log ('== connectedCallback Finished');}
        registerListener('enseigneSelected', this.handleEnseigneSelected, this);

        //this.initArray (this);
    }
    handleEnseigneSelected(selectedEnseigneid) {
        this.selectedEnseigne = selectedEnseigneid;
        this.getMagasin(this);
        if (showDebug) { console.log ('eveeeeeent');}
    }
    getMagasin(context) {
        context.options =[];

        getMagasinServices({
            magasin: this.selectedEnseigne
        })
            .then((result) => {
                if (showDebug) { console.log ('getMagasinServices Result : ' + JSON.stringify(result));}
                if(result != null && result != undefined) {
                    result.split(';').forEach(function (service, index){
                        context.options.push({'key':index,'value':service});
                    });
                }
                this.initArray (this);
            })
            .catch((e) => {
                if (showDebug) { console.log ('e');}
                if (showDebug) { console.log (e);}
            });
    }
    initArray (context) {
        if (showDebug) { console.log ('******** initArray : ');}
        context._mOptions = new Array ();  
        context.options.forEach (function (eachItem) {
            context._mOptions.push (JSON.parse (JSON.stringify(eachItem)));
        });
    }
    updateListItems (inputText) {
        Array.from (this.template.querySelectorAll('c-picklistitem')).forEach (function (node) {
            if(!inputText){
                node.style.display = "block";
            } else if(node.item.value.toString().toLowerCase().indexOf(inputText.toString().trim().toLowerCase()) != -1){
                node.style.display = "block";
            } else{
                node.style.display = "none";
            }
        });
        this.setPickListName ();
    }
    setPickListName () {
        let selecedItems = this.getSelectedItems ();
        let selections = '' ;
        if (selecedItems.length < 1) {
            selections = this.comboplaceholder;
        } else if (selecedItems.length > this.maxselected) {
            selections = selecedItems.length + ' Options Selected';
        } else {
            selecedItems.forEach (option => {
                selections += option.value+',';
            });
        }
        this._selectedItems = selections;
    }
    @api
    getSelectedItems () {
        let resArray = new Array ();
        if(this._mOptions == undefined) return resArray; 
        this._mOptions.forEach (function (eachItem) {
            if (eachItem.selected) {
                resArray.push (eachItem);
            }
        });
        return resArray;
    }

    onItemSelected () {
        const evt = new CustomEvent ('itemselected', { detail : this.getSelectedItems ()});
        this.dispatchEvent (evt);
    }


}