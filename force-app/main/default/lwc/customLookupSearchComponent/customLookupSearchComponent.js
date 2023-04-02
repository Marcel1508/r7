import {api, LightningElement, track } from 'lwc';

export default class CustomLookupSearchComponent extends LightningElement {
    
    @api charlimit;
    @track searchKey;
    handleChange(event){
        /* eslint-disable no-console */
        //console.log('Search Event Started ');
        const searchKey = event.target.value;
        /* eslint-disable no-console */
        event.preventDefault();
        const searchEvent = new CustomEvent(
            'change', 
            { 
                detail : searchKey
            }
        );
        this.dispatchEvent(searchEvent);
    }


    get charlimitZero(){
        return this.charlimit == 0;
    }
}