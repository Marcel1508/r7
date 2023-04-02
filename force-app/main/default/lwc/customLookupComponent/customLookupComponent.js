import { LightningElement, track, wire, api } from "lwc";  
import findMagasinRecords from "@salesforce/apex/CreneauMagasinRecurrentService.findMagasinRecords";  
import { fireEvent, registerListener } from 'c/pubsubCustom';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class CustomLookup extends LightningElement {
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedId;
  @api selectedRecordId;  
  @api objectApiName;
  @api lookupLabel = "Magasin";
  @api defaultMagasin; 
  @api defaultMagasinName;  
  @track message;  
    

  @wire(CurrentPageReference) pageRef;


  connectedCallback(){
      if(this.defaultMagasin == undefined) {
        if (showDebug) { console.log ('default magasin undefined: ');}
      } else {
        if (showDebug) { console.log ('AddToCartButtonCustom connectedCallback: ' + this.defaultMagasin);}
        this.selectedRecordId = this.defaultMagasin;
        this.selectedId = this.selectedRecordId;
        this.selectedValue = this.defaultMagasinName;
      }
  }

  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedId = this.selectedRecordId;

   this.selectedValue = event.target.dataset.name;
   //alert('defaultMagasin: ' + this.defaultMagasin);
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
   
  removeRecordOnLookup(event) {  
   this.searchKey = "";  
   this.selectedValue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   this.onSeletedRecordUpdate();  
 }  

  getLookupResult() {  
    findMagasinRecords({ magasinName: this.searchKey})  
    .then((result) => {  
     if (result.length===0) {  
       this.recordsList = [];  
       this.message = "Aucun magasin trouvé";  
      } else {  
       this.recordsList = result;  
       this.message = "";  
      }  
      this.error = undefined;  
    })  
    .catch((error) => {  
     this.error = error;  
     this.recordsList = undefined;  
    });  
  }  
   
  onSeletedRecordUpdate(){  
    if (showDebug) { console.log ('Enseigne selected');}
    fireEvent(this.pageRef, 'enseigneSelected', this.selectedRecordId);
  }

  @api
    validate() {
      if(this.selectedRecordId == null || this.selectedRecordId == undefined) {
        return { 
          isValid: false, 
          errorMessage: 'Veuillez selectionner un magasin' 
       }; 
      } else {
        return { 
          isValid: true
       }; 
      } 
    }
 }