@isTest
public class B2BBasePhotoControllerCustomTest {    
     @IsTest
        static void getProductImagesForPDPTest(){
        Product2 testProduct1 = TestDataFactory.createProduct();
        Product_Image_URL__c img1 = TestDataFactory.createProductImageURL(testProduct1.Id, 'image_url_1','url_vignette1', '1');
        Product_Image_URL__c img2 = TestDataFactory.createProductImageURL(testProduct1.Id, 'image_url_2','url_vignette2', '2');
        List<Product_Image_URL__c> productImages = B2BBasePhotoControllerCustom.getProductImagesForPDP(testProduct1.Id);
        System.assertEquals(2,productImages.size(),'2 Product_Image_URL__c records should be returned');
        Product2 testProduct2 = TestDataFactory.createProduct();
        List<Product_Image_URL__c> productImagesnull = B2BBasePhotoControllerCustom.getProductImagesForPDP(testProduct2.Id);
        System.assertEquals(productImagesnull,null,'productImagesnull should be null');
        
    }   
    @IsTest
        static void getProductImageURLTest(){
        Product2 testProduct1 = TestDataFactory.createProduct();
        Product2 testProduct2 = TestDataFactory.createProduct();
        Product_Image_URL__c img1 = TestDataFactory.createProductImageURL(testProduct1.Id, 'image_url_1','url_vignette1', '1');
        Product_Image_URL__c img2 = TestDataFactory.createProductImageURL(testProduct1.Id, 'image_url_2','url_vignette2', '2');
        Product_Image_URL__c productImage = B2BBasePhotoControllerCustom.getProductImageURL(testProduct1.Id);
        System.assertEquals(testProduct1.Id,productImage.ProductId__c,'Product_Image_URL__c record should be returned');
        Product_Image_URL__c productImagenull = B2BBasePhotoControllerCustom.getProductImageURL(testProduct2.Id);
        System.assertEquals(productImagenull,null,'productImagenull should be null');
    }   
    @IsTest
        static void getProductsImageURLTest(){
        List<String> productList = new List<String>();
        Product2 testProduct1 = TestDataFactory.createProduct();
        Product2 testProduct2 = TestDataFactory.createProduct();
        productList.add(testProduct1.Id);
        productList.add(testProduct2.Id);   
        Product_Image_URL__c img1 = TestDataFactory.createProductImageURL(testProduct1.Id, 'image_url_1','url_vignette1', '1');
        Product_Image_URL__c img2 = TestDataFactory.createProductImageURL(testProduct1.Id, 'image_url_2','url_vignette2', '2');
        Product_Image_URL__c img3 = TestDataFactory.createProductImageURL(testProduct2.Id, 'image_url_3','url_vignette3', '1');
        Product_Image_URL__c img4 = TestDataFactory.createProductImageURL(testProduct2.Id, 'image_url_4','url_vignette4', '2');
        Map<String, Product_Image_URL__c> productImages = B2BBasePhotoControllerCustom.getProductsImageURL(productList);
    }
   
}