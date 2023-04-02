import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RedirectToServicesContactPage extends NavigationMixin(LightningElement) {
    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/promocash/s/contact-support-services"
            }
        });
    }
}