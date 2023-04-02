@isTest
public class ProductMediaBatch_TST {
  /*  private static Product2 createProduct() {
        return (Product2) new SObjectBuilder(Product2.SObjectType)
            .put(Product2.Name, 'TEST Product')
            .put(Product2.Code_EAN_13__c, '0000040052397')
            .create().getRecord();
    }
    
    @isTest static void test() {
        Product2 testProduct = createProduct();
        
        List<ElectronicMediaGroup> listElectronicMediaGroup = new List<ElectronicMediaGroup>();
        ElectronicMediaGroup PLP = new ElectronicMediaGroup(Name='Product List Image');
        ElectronicMediaGroup PDP = new ElectronicMediaGroup(Name='Product Detail Images');
        listElectronicMediaGroup.add(PLP);
        listElectronicMediaGroup.add(PDP);
        
       // ConnectApi.ManagedContentVersionCollection contentCollection = null;
        //contentCollection = ConnectApi.ManagedContent.getAllManagedContent(networks.id, 0, 200,null, null);
        ProductMediaBatch pmb = new ProductMediaBatch();
        
    	Test.startTest();
        insert testProduct;
        insert listElectronicMediaGroup;
        Id batchId = Database.executeBatch(pmb);
        Test.stopTest();
        //System.assertEquals(2, [SELECT count() FROM ProductMedia where ProductId =:testProduct.id]);       
        //System.assert(batchId != NULL, 'We expect that Batch be executed.');
        System.assertEquals(1, [SELECT count() FROM Product2 where id =:testProduct.id]);
    }*/

}