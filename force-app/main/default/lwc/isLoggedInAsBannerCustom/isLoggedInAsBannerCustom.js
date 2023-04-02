import { LightningElement, track } from 'lwc';
import getLoggedAsDetails from '@salesforce/apex/TelesalesUtils.getLoggedAsDetails';
import getUserInfo from '@salesforce/apex/B2BCartControllerCustom.getUserInfo';
import USER_ID from "@salesforce/user/Id";

export default class IsLoggedInAsBanner extends LightningElement {

    @track username;
    @track name
    @track show=false;
    @track error;

    connectedCallback() {
        let loggedinAsName = sessionStorage.getItem('loggedinAsName');
        if(loggedinAsName) {
            this.name = loggedinAsName;
            this.getLoggedAsDetails();
        } else {
            getUserInfo({userId: USER_ID}).then(res => {
                if(res) {
                    this.name = res.Name;
                    sessionStorage.setItem('loggedinAsName', this.name);
                    this.getLoggedAsDetails();
                }
            });
        }
    }

    getLoggedAsDetails() {
        let loggedinAsvalue = sessionStorage.getItem('loggedinAsData');
        if(loggedinAsvalue) {
            let data = JSON.parse(loggedinAsvalue);
            this.setloggedinAs(data);
        } else {
            getLoggedAsDetails({externalUserName:"$name"}).then((data) => {
                if(data) {
                    this.setloggedinAs(data);
                    sessionStorage.setItem('loggedinAsData', JSON.stringify(data));
                }
            }).catch((error) => {
                window.console.group('%c IsLoggedInAs Error', 'background: #ff0000; color: #ffffff');
                window.console.log('status:'+error.status);
                window.console.log('exceptionType:'+error.body.exceptionType);
                window.console.log('message:'+error.body.message);
                window.console.log('stackTrace:'+error.body.stackTrace);
                window.console.groupEnd();
                this.error = error;
                this.show = undefined;
            });
        }
    }

    setloggedinAs(data) {
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
        console.log('this.show');
        console.log(this.show);

        console.log('this.name');
        console.log(this.name);
    }

    /*@wire(getLoggedAsDetails, {externalUserName:"$name" })
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
    } */

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