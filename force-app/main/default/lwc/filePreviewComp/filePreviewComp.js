import { LightningElement, api } from "lwc";
//import NOPREVIEWIMGURL from "@salesforce/resourceUrl/nopreviewimg";

const getDocBaseUrl = () => {
    return `https://${
      window.location.hostname.split(".")[0]
    }--c.documentforce.com`;
  };
  
  const getDownloadUrl = (fileId) => {
    return `${getDocBaseUrl()}/sfc/servlet.shepherd/version/download/${fileId}`;
  };
  
  const getPreviewUrl = (fileId) => {
    return `${getDocBaseUrl()}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=${fileId}&operationContext=CHATTER&page=0`;
  };
  
  const getContentDocUrl = (fileId) => {
    return `/lightning/r/ContentDocument/${fileId}/view`;
  };

export default class FilePreviewComp extends LightningElement {
  @api fileId;
  @api heightInRem;

  get baseUrl() {
    return `https://${
      window.location.hostname.split(".")[0]
    }--c.documentforce.com`;
  }

  get url() {
    return getPreviewUrl(this.fileId);
  }

  /*fallback(event) {
    if (event.target.src != NOPREVIEWIMGURL) {
      event.target.src = NOPREVIEWIMGURL;
      this.template.querySelector("img").style.width = "200px";
      this.template.querySelector("img").style.height = "100px";
    }
  }*/

  
}