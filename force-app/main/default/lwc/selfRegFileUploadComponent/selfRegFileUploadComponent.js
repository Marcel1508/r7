import { LightningElement, track, api } from 'lwc';
import saveFile from "@salesforce/apex/selfRegService.saveFile";
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

export default class SelfRegFileUploadComponent extends LightningElement {
    // FILE TEST 
    @api fileTitle;
    @api fileType;
    @api isrequired = false;
    @api parentRecordId;
    @track columns = {label: 'Title', fieldName: 'Title'};
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    @api
    setParentRecordId(recordId) {
        this.parentRecordId = recordId;
    }
    // getting file 
    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    @api
    handleSave() {
        if (showDebug) { console.log ('HANDLE SAVE CLICK');}
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else if(this.isrequired == true){
            this.fileName = 'Please select a file to upload.';
        }
    }
    @api hasFile(){ 
        return this.filesUploaded.length > 0;
    }

    uploadHelper() {
        if (showDebug) { console.log ('uploadHelper CLICK');}
        this.file = this.filesUploaded[0];
       if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log ('File Size is too long');
            return ;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader= new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            
            // call the uploadProcess method 
            this.saveToFile();
        });
    
        this.fileReader.readAsDataURL(this.file);
    }

    saveToFile() {
        if (showDebug) { console.log ('saveFile CLICK');}
        saveFile({ idParent: this.parentRecordId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents), fileType: this.fileType})
        .then(result => {
            window.console.log ('result ====> ' +result);
            // refreshing the datatable
            //this.getRelatedFiles();

            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.UploadFile = 'File Uploaded Successfully';
            this.isTrue = true;
            this.showLoadingSpinner = false;

            // Showing Success message after file insert
            if (showDebug) { console.log ('Successful upload');}
        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log (error);
        });
    }

    // FILE TEST
}