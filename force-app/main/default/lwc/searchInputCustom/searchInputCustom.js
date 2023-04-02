import { LightningElement, api, wire, track } from 'lwc';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class SearchInputCustom extends LightningElement {

    searchValue = '';

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
            if (showDebug) { console.log ('fvdsqvbgfdsdvbgfd');}
        }

    }

    renderedCallback(){
        if (showDebug) { console.log (this._term);}
    }

    handlesearchinputchange(event) {
        this.term = event.target.value;
    }

    _term

}