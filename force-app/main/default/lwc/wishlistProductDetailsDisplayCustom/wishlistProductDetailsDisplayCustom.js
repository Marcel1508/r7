import { LightningElement ,api} from 'lwc';

export default class WishlistProductDetailsDisplayCustom extends LightningElement {
    @api description;
    @api categorypath;
    @api image;
    @api instock;
    @api name;
    @api price;
    @api sku;

    get urlIsNull(){
        return this.image.url == null;
    }
    


}