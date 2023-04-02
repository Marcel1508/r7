import { LightningElement, api, wire, track } from 'lwc';

import getLoggedAsDetails from '@salesforce/apex/TelesalesUtils.getLoggedAsDetails';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import USERNAME from "@salesforce/schema/User.Username";
import NAME from "@salesforce/schema/User.Name";

export default class IsLoggedInAsSmallBanner extends LightningElement {

    @track username;
    @track name
    @track show=false;
    @track error;

    @wire(getRecord, { recordId: USER_ID, fields: [USERNAME, NAME] })
    wireuser({ error, data }) {
      if (error) {
        this.error = error;
      } else if (data) {
        this.username = data.fields.Username.value;
        this.name = data.fields.Name.value;
      }
    }    

    @wire(getLoggedAsDetails, {externalUserName:"$name" })
    prepareData({error, data}) {
        if(data) {

            window.console.group('%c IsLoggedInAs Data', 'background: #76b72a; color: #ffffff');

            this.RRetURL = this.getCookie('RRetURL');

            window.console.log('RRetURL = %O', this.RRetURL);
            if(this.RRetURL != null) {
                window.console.log('On Behalf session detected');

                data.forEach(line => {
                    window.console.log('line: '+JSON.stringify(line));
                    if(line.Display.includes(this.name)) {
                        this.createdById = line.CreatedById;
                        //this.scrUser = line.Field2;
                        this.scrUser = line.CreatedBy.Name;
                        this.display = line.Display;
                    }
                });
                //this.createCookie('isLoggedInAs', this.createdById, null);
                //window.console.log('Cookie Created: \'isLoggedInAs\' = %O', this.getCookie('isLoggedInAs'));
            }
            else {
                window.console.log('Regular session');
            }
            window.console.groupEnd();
            this.show = true;
        }
        if(error) {
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

    createCookie(name, value, days) {
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toGMTString();
        }
        else {
            expires = "";
        }
        document.cookie = name + "=" + escape(value) + expires + "; path=/";
    }
}