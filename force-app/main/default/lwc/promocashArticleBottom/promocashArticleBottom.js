import { LightningElement } from 'lwc';

export default class PromocashArticleBottom extends LightningElement {  
    facebookURL;
    twitterURL;
    googleURL;
    linkedinURL;
    currrentTop;

    connectedCallback() {
      let urlString = window.location.href;
      this.facebookURL = "http://www.facebook.com/sharer.php?u="+urlString;
      this.twitterURL = "https://twitter.com/share?url="+urlString;
      this.googleURL = "https://plus.google.com/share?url="+urlString;
      this.linkedinURL = "http://www.linkedin.com/shareArticle?url="+urlString;
      this.currentTop=urlString+"#top";
    }
}