public without sharing class B2BBasePhotoControllerCustom {
    
    @AuraEnabled(cacheable=true)
    public static List<Product_Image_URL__c> getProductImagesForPDP(
        String productId
    ){
        List<Product_Image_URL__c> productImages = new List<Product_Image_URL__c>([SELECT Id, Name, AlternativeText__c, Image_ExternalId__c, ProductId__c, Product_Image_URL__c, Product_URL_Vignette__c, Titre__c, Ordre_Affichage__c FROM Product_Image_URL__c WHERE  ProductId__c =: productId ORDER BY Ordre_Affichage__c]);
        if(productImages != null && !productImages.isEmpty())
        {
            return productImages;
        }else{
            return null;
        }       
    }
    
    @AuraEnabled(cacheable=true)
    public static Product_Image_URL__c getProductImageURL(
        String productId
    ){
        List<Product_Image_URL__c> productImages = new List<Product_Image_URL__c>([SELECT Id, Name, AlternativeText__c, Image_ExternalId__c, ProductId__c, Product_Image_URL__c, Product_URL_Vignette__c, Titre__c, Ordre_Affichage__c FROM Product_Image_URL__c WHERE  ProductId__c =: productId ORDER BY Ordre_Affichage__c]);
       if(productImages != null && !productImages.isEmpty())
       {
           Product_Image_URL__c productImage = productImages[0];
           return productImage;
       }
        else
        {
            return null ;   
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Product_Image_URL__c> getProductsImageURL(
        List<String> listproducts
    ){
        Map<String, Product_Image_URL__c> productImagesMap = new Map<String, Product_Image_URL__c>([SELECT Id, Name, AlternativeText__c, Image_ExternalId__c, ProductId__c, Product_Image_URL__c, Product_URL_Vignette__c, Titre__c, Ordre_Affichage__c FROM Product_Image_URL__c WHERE  ProductId__c in:listproducts ORDER BY Ordre_Affichage__c]);
        
        return productImagesMap;   
    }
    
}