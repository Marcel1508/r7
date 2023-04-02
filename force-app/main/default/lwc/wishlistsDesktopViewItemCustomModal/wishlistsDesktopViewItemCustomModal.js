import {LightningElement, track} from 'lwc';
 
export default class WishlistsDesktopViewItemCustomModal extends LightningElement {
   
    @track bShowModal = false;
 
    /* javaScipt functions start */ 
    openModal() {    
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }
 
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    /* javaScipt functions end */ 
}