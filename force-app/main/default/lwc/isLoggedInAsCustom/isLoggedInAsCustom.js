import { LightningElement, api, wire, track } from 'lwc';

import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

import getLoggedAsDetails from '@salesforce/apex/TelesalesUtils.getLoggedAsDetails';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import USERNAME from "@salesforce/schema/User.Username";
import NAME from "@salesforce/schema/User.Name";
import USERID from "@salesforce/schema/User.Id";

export default class IsLoggedInAs extends LightningElement {

    @track username;
    @track name
    @track show=false;    
    @track error;
    @api availableActions = [];
    @api realUserID;


    
    @wire(getRecord, { recordId: USER_ID, fields: [USERNAME, NAME, USERID] })
    wireuser({ error, data }) {
      if (error) {
        this.error = error;
      } else if (data) {
        this.username = data.fields.Username.value;
        this.name = data.fields.Name.value;
        this.realUserID = data.fields.Id.value;
      }
    }    

    @wire(getLoggedAsDetails, { externalUserName:"$name"})
    prepareData({error, data}) {
        if(data) {

            window.console.group('%c IsLoggedInAs Data', 'background: #76b72a; color: #ffffff');

            this.RRetURL = this.getCookie('RRetURL');

            window.console.log('RRetURL = %O', this.RRetURL);
            if(this.RRetURL != null) {
                window.console.log('On Behalf session detected');
                
                data.forEach(line => {
                    if(line.Display.includes(this.name)) {
                        this.createdById = line.CreatedById;
                        //this.scrUser = line.Field2;
                        // fix 11 May 2021: added CreatedBy.Name
                        this.scrUser = line.CreatedBy.Name;
                        this.display = line.Display;
                        this.realUserID = line.CreatedById;
                    }
                });
            }
            else {
                window.console.log('Regular session');
            }
            
            window.console.log('realUserID = %O',this.realUserID);
            // notify the flow of the attribut value
            const attributeChangeEvent = new FlowAttributeChangeEvent('realUserID', this.realUserID);
            this.dispatchEvent(attributeChangeEvent);
            this.handleGoNext();
            
            window.console.groupEnd();
            this.show = true;
        }
        else if(error) {
            window.console.group('%c IsLoggedInAs Error', 'background: #ff0000; color: #ffffff');
            window.console.log('status:'+error.status);
            window.console.log('exceptionType:'+error.body.exceptionType);
            window.console.log('message:'+error.body.message);
            window.console.log('stackTrace:'+error.body.stackTrace);
            window.console.groupEnd();
            this.error = error;
            this.show = undefined;
        }
    }

    getCookie(name) {
        var cookieString = "; " + document.cookie;
        var parts = cookieString.split("; " + name + "=");
        if (parts.length === 2) {
            return parts.pop().split(";").shift();
        }
        return null;
    }

    handleGoNext() {
        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }    



}