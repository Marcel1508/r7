import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class CustomFooter extends LightningElement {

    // @api logo;
    // @api width;
    // @api footerBackgroundWidth;
    // @api footerBackgroundColor;
    // @api footerThemeBackground;
    // @api useFooterCustomBackgroundColor;
    // @api logoPosition;
    // @api subFooterText;
    // @api subFooterTextAlign;
    @api showCurrentYear;
    // @api contentOneTitle;
    // @api contentTwoTitle;
    // @api contentThreeTitle;
    // @api contentFourTitle;
    // @api contentOne;
    // @api contentTwo;
    // @api contentThree;
    // @api contentFour;
    // @api contentOneType;
    // @api contentTwoType;
    // @api contentThreeType;
    // @api contentFourType;
    @api footerLinkColor;
    @api footerLinkColorDefault;
 
    footerWidth;
    footerContainer;
    footerSelectedBackground;
    footerBg;
    sloganPosition;
    logoStyle;
    currentYear;
    // columnContent_1;
    // columnContent_2;
    // columnContent_3;
    // columnContent_4;
    // subFooterTextAlignment;
    columnTextClasses;
    goTopClass;

    connectedCallback() {
        // this.footerWidth = this.width
        //     ? `max-width: ${this.width}px;`
        //     : 'max-width:100%;';
        // this.footerSelectedBackground = this.footerThemeBackground
        //     ? `background-color: var(--lwc-${this.footerThemeBackground})`
        //     : 'background-color:var(--lwc-brandBackgroundPrimary)';
        // this.footerBg = this.useFooterCustomBackgroundColor
        //     ? `background-color: ${this.footerBackgroundColor}`
        //     : this.footerSelectedBackground;
        // if (this.footerBackgroundWidth) {
        //     this.footerContainer = this.footerBg;
        // } else {
        //     this.footerContainer = this.footerWidth + this.footerBg;
        // }
        // this.sloganPosition = `text-align: ${
        //     FORM_FACTOR === 'Small' ? 'center' : this.logoPosition
        // }`;
        // this.logoStyle = `background-image: var(--lwc-brandLogoImage);background-position: ${
        //     FORM_FACTOR === 'Small' ? 'center' : this.logoPosition
        // }`;
        this.currentYear = this.showCurrentYear
            ? new Date().getFullYear()
            : 'null';
        // this.subFooterTextAlignment = `slds-text-align_${
        //     FORM_FACTOR === 'Small' ? 'center' : this.subFooterTextAlign
        // }`;
        // this.columnTextClasses = `slds-p-around_medium slds-text-align_${
        //     FORM_FACTOR === 'Small' ? 'center' : 'left'
        // }`;
        // this.goTopClass = this.goTopSticky ? 'go-top sticky' : 'go-top';

        // let contents = [
        //     this.contentOne,
        //     this.contentTwo,
        //     this.contentThree,
        //     this.contentFour
        // ];
        // let contentTypes = [
        //     this.contentOneType,
        //     this.contentTwoType,
        //     this.contentThreeType,
        //     this.contentFourType
        // ];

        // for (const [i, value] of contentTypes.entries()) {
        //     let content = contents[i];
        //     this[`columnContent_${i + 1}`] =
        //         value === 'link' ? this.footerLink(content) : content;
        // }
    }

    // footerLink(linkContents) {
    //     let finalLinks = '';
    //     if (linkContents) {
    //         let links = linkContents.split(',');
    //         let linkColor = this.footerLinkColorDefault
    //             ? ''
    //             : `style="color:${this.footerLinkColor}"`;
    //         for (let link of links) {
    //             link = link.trim();
    //             if (
    //                 link.indexOf('http://') !== 0 &&
    //                 link.indexOf('https://') !== 0
    //             ) {
    //                 link = 'https://' + link;
    //             }
    //             try {
    //                 const linkUrl = new URL(link);
    //                 finalLinks += `<a href="${linkUrl}" target="_blank" ${linkColor}>${link}</a><br>`;
    //             } catch (error) {
    //                 // => TypeError, "Failed to construct URL: Invalid URL"
    //             }
    //         }
    //     }
    //     return finalLinks;
    // }

    // goToTop() {
    //     window.scroll(0, 0);
    // }
}