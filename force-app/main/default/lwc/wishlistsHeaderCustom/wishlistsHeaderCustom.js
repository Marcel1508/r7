import { LightningElement } from 'lwc';

export default class WishlistsHeaderCustom extends LightningElement {

    openParentModal(event) {
        // Creates the event with the data.
        const modalEvent = new CustomEvent("createnewlistclick", {
          detail: true
        });
    
        // Dispatches the event.
        this.dispatchEvent(modalEvent);
      }
    

}