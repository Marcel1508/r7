import { LightningElement, track, api } from 'lwc';
import findRecords from '@salesforce/apex/CustomLookupController.findRecords';
import findIsBuyerRecords from '@salesforce/apex/CustomLookupController.findIsBuyerRecords';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
export default class CustomLookup extends LightningElement {
    @track records;
    @track error;
    @track selectedRecord;
    @api selectedRecordId = '';
    @api index;
    @api relationshipfield;
    @api iconname = "standard:record";
    @api objectname;
    @api searchfield;
    @api querylimit = 100;
    @api charlimit = 0;
    //added by ajay for apartage la liste button 
    @api ismagsin;
    @api magaisnactifencours;

    /*constructor(){
        super();
        this.iconname = "standard:account";
        this.objectName = 'Account';
        this.searchField = 'Name';
    }*/

    handleOnchange(event){
        //event.preventDefault();
        const searchKey = event.detail.value;
        //this.records = null;
        /* eslint-disable no-console */
        //if (showDebug) { console.log (searchKey);
        if (showDebug) { console.log (this.ismagsin);}
        if (showDebug) { console.log (searchKey)}
        

        if(this.ismagsin){
            /* Call the Salesforce Apex class method to find the Records with is buyer true with same magsin */
        findIsBuyerRecords({
            searchKey : searchKey, 
            objectname : this.objectname, 
            searchField : this.searchfield,
            queryLimit : this.querylimit,
            magaisnActifEnCours : this.magaisnactifencours  
        })
        .then(result => {
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.searchfield];
            }
            this.error = undefined;
            //if (showDebug) { console.log (' records ', this.records);
        })
        .catch(error => {
            if (showDebug) { console.log ('error');}
            if (showDebug) { console.log (error);}
            this.error = error;
            this.records = undefined;
        });
    }
    else{
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey : searchKey, 
            objectname : this.objectname, 
            searchField : this.searchfield,
            queryLimit : this.querylimit
        })
        .then(result => {
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.searchfield];
            }
            this.error = undefined;
            //if (showDebug) { console.log (' records ', this.records);
        })
        .catch(error => {
            if (showDebug) { console.log ('error');}
            if (showDebug) { console.log (error);}
            this.error = error;
            this.records = undefined;
        });
    }
                
        
        
    }
    handleSelect(event){
        const selectedRecordId = event.detail;
        this.selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find( record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedRecordId
                detail : { recordId : selectedRecordId, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedRecordId = undefined;
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


}