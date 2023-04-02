import { LightningElement, track, api } from 'lwc';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class PickListItem extends LightningElement {
    @api item;

    constructor () {
        super();
    }
    connectedCallback () {
        this._item =  JSON.parse(JSON.stringify (this.item));
    }
    get itemClass () {
        return 'slds-listbox__item ms-list-item' + (this.item.selected ? ' slds-is-selected' : '');
    }
    onItemSelected (event) {
        const evt = new CustomEvent ('items', { detail : {'item' :this.item, 'selected' : !this.item.selected }});
        if (showDebug) { console.log ('Item selected: ' + this.item.selected);}
        this.dispatchEvent (evt);
        event.stopPropagation();
    }


}