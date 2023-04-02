/**
* @author : Maud Vasseur - IBM Lille
* @date : 04/2021
* @description : Class to create the productMedia object between image (in CMS content) and product - A productMedia is created for PLP and PDP 
* @TestClass : ProductMediaBatch_TST
**/
// OLD classes - unused
public without sharing class ProductMediaBatch {
//public without sharing class ProductMediaBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
/*	public Database.QueryLocator start(Database.BatchableContext bc) {
        //the batch launch every product in the database to find the corresponding image
        return Database.getQueryLocator([SELECT Id, Name, Code_EAN_13__c, DisplayUrl
                                         FROM Product2 
                                         WHERE Code_EAN_13__c != null]);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        // If there are several communities, set here your community ID after finding it
        String communityId = '';
        //Get Id for PDP & PLP to create ProductMedia => ElectronicMediaGroup
        String productListGroupId=[SELECT Id FROM ElectronicMediaGroup WHERE DeveloperName='productListImage'].Id;
        String productDetailGroupId=[SELECT Id FROM ElectronicMediaGroup WHERE DeveloperName='productDetailImage'].Id;

        if (communityId=='') {
            List<Network> networks = [SELECT id, name FROM Network WHERE name = 'Promocash'];
            for (Network network: networks ) {
                            }
            if (networks.size() > 1) {
                              return;
            } else {
                communityId = networks[0].Id;            
            }
        }
        integer i = 0;
        //This connectApi retrieves all images in CMS content, it's not an accessible object for a query. 
		//Looks every page of images to add in ContentCollection.
        ConnectApi.ManagedContentVersionCollection contentCollection = null;
        //Product Media is the junction object between Content image and Product
        List<ProductMedia> currentMedia = [SELECT Id, ElectronicMediaGroupId, ElectronicMediaId, ProductId FROM ProductMedia];
        List<ProductMedia> productMediaToUpsert = new List<ProductMedia>();
        Set<String> listEAN = new set<String>();
        do{
                        contentCollection = ConnectApi.ManagedContent.getAllManagedContent(communityId, i, 200,null, null);
                        for(ConnectApi.ManagedContentVersion mcv : contentCollection.items) {
                if(mcv.title.length() > 13){
                    //Extract EAN in image title(13 first caracters to get EAN) and to compare 
                    String eANToCompare = mcv.title.substring(0,13);
                    Product2 product = findProductByEAN(scope, eANToCompare);
                    if (product != null) {
                        //listEAN allows to avoid the error message when creating Product Media, if there are several images to be attached to the same object for the PLP
                        if(!listEAN.contains(eANToCompare)){
                            //Check if our product has an image for PLP yet
                            if (!mediaPLPExists(currentMedia, productListGroupId, mcv.managedContentId, product.Id) ) {
                                // We can't upsert checking on compound key, so we check here
                                if (!mediaExists(currentMedia, productListGroupId, mcv.managedContentId, product.Id) ) {
                                    ProductMedia pmList = new ProductMedia();
                                    pmList.ElectronicMediaGroupId = productListGroupId;
                                    pmList.ElectronicMediaId = mcv.managedContentId;
                                    pmList.ProductId = product.Id;
                                    productMediaToUpsert.add(pmList);
                                    listEAN.add(eANToCompare);
                                    
                                    //insert url of image in the field displayUrl of product only when the batch inserts PLP image
                                    Map<String, ConnectApi.ManagedContentNodeValue> contentNodes = mcv.contentNodes;
                                    for (ConnectApi.ManagedContentNodeValue nodeValue:contentNodes.values()){
                                        if (nodeValue instanceOf ConnectApi.ManagedContentMediaSourceNodeValue){
                                            product.DisplayUrl = ((ConnectApi.ManagedContentMediaSourceNodeValue)nodeValue).url;
                                        }
                                    }
                                }
                            }
                        }
                        
                        // We can't upsert checking on compound key, so we check here
                        if (!mediaExists(currentMedia, productDetailGroupId, mcv.managedContentId, product.Id) ) {
                            ProductMedia pmDetail = new ProductMedia();
                            pmDetail.ElectronicMediaGroupId = productDetailGroupId;
                            pmDetail.ElectronicMediaId = mcv.managedContentId;
                            pmDetail.ProductId = product.Id;
                            productMediaToUpsert.add(pmDetail);
                        }
                    }
                }           
            }
            i++;
        }while(contentCollection.items.size() > 0);
                update scope;
        upsert productMediaToUpsert; 
    }
    
    public void finish(Database.BatchableContext info){     
    }
    
    //returns the list of products which correspond to the EANs in the titles of the images 
    static Product2 findProductByEAN(List<Product2> productList, String eAN) {
        for(Product2 prod: productList) {
            if (prod.Code_EAN_13__c == eAN) {
                return prod;
            }
        }
        return null;
    }
    
    //Check if a product media exist for our product 
    static boolean mediaExists(List<ProductMedia> productMediaList, String productGroupId, String mediaId, String productId) {
        for (ProductMedia pm: productMediaList) {
            if (pm.ElectronicMediaGroupId == productGroupId && pm.ElectronicMediaId == mediaId && pm.ProductId == productId) {
                  return true;
            }
        }
        return false;
    }
    
    //Check if a product media exist for our product only for PLP image
    static boolean mediaPLPExists(List<ProductMedia> productMediaList, String productGroupId, String mediaId, String productId) {
        for (ProductMedia pm: productMediaList) {
            if (pm.ElectronicMediaGroupId == productGroupId && pm.ProductId == productId) {
                  return true;
            }
        }
        return false;
    } */
}