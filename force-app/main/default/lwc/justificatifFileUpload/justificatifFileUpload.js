import { LightningElement, api, wire } from 'lwc';
import getRelatedFiles from "@salesforce/apex/FileController.getFilesList";
import getAccountFilesOptions from "@salesforce/apex/FileController.getAccountFilesOptions";
import updateAccount from "@salesforce/apex/FileController.updateAccount";
import deleteFile from "@salesforce/apex/FileController.deleteFile";
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

const actions = [
{ label: "Supprimer", name: "delete" }
];

const BASE64EXP = new RegExp(/^data(.*)base64,/);
const columns = [
{
    label: "Nom",
    fieldName: "id",
    type: "filePreview",
    typeAttributes: {
    anchorText: { fieldName: "title" },
    versionId: { fieldName: "latestVersionId" }
    }
},
{ label: "Date de création", fieldName: "createdDate", type: "date" },
{ label: "Type", fieldName: "fileType", type: "string" },
{ type: "action", typeAttributes: { rowActions: actions } }
];

const versionColumns = [
{
    label: "Download Link",
    fieldName: "id",
    type: "filePreview",
    typeAttributes: { anchorText: "Download" }
},
{ label: "Title", fieldName: "title", type: "string" },
{ label: "Reason for Change", fieldName: "reasonForChange", type: "string" },
{ label: "Uploaded Date", fieldName: "createdDate", type: "date" },
{ label: "Uploaded by", fieldName: "createdBy", type: "string" }
];

export default class JustificatifFileUpload extends LightningElement {
@api recordId;
_filesList;
_loadedAccount;
loadedAccount;
fileTitle;
fileName;
files = [];
showModal = false;
columns = columns;
versionColumns = versionColumns;
versionDetails = [];
fileUpload = false;
_currentDocId = null;
showPreview = false;
currentPreviewFileId = null;
showSpinner = false;
selectedFileType;
typeFilesOptions;
showUploadFileContent;

get acceptedFormats() {
    return ['.pdf', '.png','.jpg','.jpeg'];
}


@wire(getRelatedFiles, { recordId: "$recordId" })
getFilesList(filesList) {
this._filesList = filesList;
const { error, data } = filesList;
if (!error && data) {
    this.files = data;
    if (showDebug) { console.log ("files found " + JSON.stringify(this.files));}
}
}

@wire(getAccountFilesOptions, { recordId: "$recordId" })
getAccountFilesOptions(accountRes) {
    this._loadedAccount = accountRes;
    const { error, data } = accountRes;
    if (!error && data) {
        this.loadedAccount = data;
        if (showDebug) { console.log ("Account found " + JSON.stringify(this.loadedAccount));}
    }
}

handleUploadFinished(event) {
    if (showDebug) { console.log ('Upload finished');}
    if (showDebug) { console.log (JSON.stringify(event));}
    updateAccount({recordId: this.recordId, selectedFileType: this.selectedFileType})
    .then(res => {
        console.error('Upload success: ');
        window.location.reload();
        //this.closeModal();
    })
    .catch((err) => {
        console.error('Upload Error: ' + JSON.stringify(err));
    });
}

initTypeFilesOptions() {
    let res = [];
    if(this.loadedAccount.RIB__c == false) {
        res.push({ label: 'RIB', value: 'RIB' });
    }
    if(this.loadedAccount.K_bis__c == false) {
        res.push({ label: 'k_bis', value: 'kbis' });
    }
    if(this.loadedAccount.Piece_identite__c == false) {
        res.push({ label: 'piece d\'identité', value: 'Piece_identite' });
    }
    if(this.loadedAccount.Attestation_registre_du_commerce__c == false) {
        res.push({ label: 'Attestation registre du commerce', value: 'Registre du commerce' });
    }
    //Count numbre of files with type = 'Autre', the maximum number must be 
    let autreCount = 0;
    if (showDebug) { console.log ('===> FILES ' + JSON.stringify(this.files));}
    for(let i=0; i<this.files.length; i++){
        if (showDebug) { console.log ('===> ' + this.files[i].fileType);}
        if(this.files[i].fileType == 'Autre') {
            autreCount++;
        }
    }

    if(autreCount < 10) {
        res.push({ label: 'Autre', value: 'Autre' });
    }
    
    if (showDebug) { console.log ('res: ' + res);}
    this.typeFilesOptions = res;
}

handleChange(event) {
    this.selectedFileType = event.detail.value;
}

closeModal() {
    this.showModal = false;
    this._currentDocId = null;
    this.fileUpload = false;
    this.versionDetails = [];
    this.fileName = "";
    this.fileTitle = "";
    getRecordNotifyChange([{recordId: this.recordId}]);
    refreshApex(this.filesList);
}

handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;
    if (showDebug) { console.log ('row: ' + JSON.stringify(row));}
    if (showDebug) { console.log ('row fileType: ' + row.fileType);}
    deleteFile({ contentDocumentId: row.id, accountId: this.recordId, selectedFileType: row.fileType })
        .then((result) => {
            if (showDebug) { console.log ('DELETE SUCCESS ' + JSON.stringify(result));}
            window.location.reload();
        })
        .catch((err) => {
            console.error(JSON.stringify(err));
        });
}

newFileUpload() {
    this.initTypeFilesOptions();
    this.showUploadFileContent = false;
    if(this.typeFilesOptions.length > 0) {
        this.selectedFileType = this.typeFilesOptions[0].value;
        this.showUploadFileContent = true;
    }
    if (showDebug) { console.log ('this.selectedFileType: ' + this.selectedFileType);}
    this.showModal = true;
    this.fileUpload = true;
}
}