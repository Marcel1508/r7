import { api, track ,LightningElement } from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
export default class CustomPicklistForFlow extends LightningElement {
    @api selectedRecordId = '';
    @api selectedRecord;

    @api records = [];
    @api label='';
    @api placeholder='';
    
    // @api fieldColumns = [
    //     { label: 'Name', fieldName: 'Name' },
    //     { label: 'Title', fieldName: 'Title'},
    //     { label: 'Department', fieldName: 'Department' }
    // ];

    // connectedCallback(){
    //     console.log('this.records');
    //     console.log(this.records);
    //     this.records.forEach(record => {
    //         console.log('record');
    //         console.log(record);
    //         console.log('createdbyid');
    //         console.log(record.CreatedById);
    //         console.log('id');
    //         console.log(record.Id);
    //         console.log('nom mag');
    //         console.log(record.Nom_Magasin__c);
    //         console.log('id mag');
    //         console.log(record.Magasin__c);
    //     });
    // }

    // renderedCallback(){
    //     console.log('this.records');
    //     console.log(this.records);
    //     this.records.forEach(record => {
    //         console.log('record');
    //         console.log(record);
    //     });
    // }

    get options() {
        var returnOptions = [];
            this.records.forEach(ele =>{
                returnOptions.push({label:ele.Nom_Magasin__c, value:ele.Magasin__c});
            }); 
            if (showDebug) { console.log (JSON.stringify(returnOptions));}
        return returnOptions;
    }
    
    handleChange(event){
        const selectedRecordId = event.detail.value;
        this.selectedRecordId = event.detail.value;
        if (showDebug) { console.log ('this.selectedRecordId');}
        if (showDebug) { console.log (this.selectedRecordId);}
        if (showDebug) { console.log ('this.selectedRecord');}
        if (showDebug) { console.log (this.selectedRecord);}
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find( record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        // const attributeChangeEvent = new FlowAttributeChangeEvent('selectedRecordId', this.selectedRecordId);
        // this.dispatchEvent(attributeChangeEvent);
        // const attributeChangeEvent2 = new FlowAttributeChangeEvent('selectedRecord', this.selectedRecord);
        // this.dispatchEvent(attributeChangeEvent2);

        const selectedRecordEvent = new CustomEvent(
            "selectedpicklistvalue",
            {
                //detail : selectedRecordId
                detail : { recordId : this.selectedRecordId, record : this.selectedRecord}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

}