/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Handler du trigger Product
**/
public with sharing class ProductTriggerHandler extends TriggerHandler {
    private final List<Product2> newRecords;
    private final Map<Id, Product2> oldRecordsMap;
    @testVisible private static ProductService productServiceInstance = new ProductService();
    @testVisible private static OffreProduitMagasinService OffreProduitMagasinService = new OffreProduitMagasinService();
    @testVisible private static PrixSpecifiqueService PrixSpecifiqueService = new PrixSpecifiqueService();

    public ProductTriggerHandler(List<Product2> newRecords, Map<Id, Product2> oldRecordsMap) {
        this.newRecords = newRecords;
        this.oldRecordsMap = oldRecordsMap;
    }

    public override void beforeInsert() {
        ProductService.populateLibellFinalField(newRecords);
    }

    public override void afterInsert() {
        ProductService.createPricebookEntry(newRecords);
        ProductService.checkAssortimentForGuestPolicy(newRecords);
        productServiceInstance.addProductsToCategories(newRecords);
    }

    public override void beforeUpdate() {
        System.debug('$$$$ before update');
        ProductService.populateLibellFinalField(newRecords);
    }

    public override void afterUpdate(){
        List<Product2> filteredProducts = ProductService.filterProduct(newRecords, oldRecordsMap);
        if(!filteredProducts.isEmpty()){
            List<Offre_Produit_Magasin__c> opms = ProductService.getOPMs(filteredProducts);
            productServiceInstance.startProductFlow(opms);
            ProductService.checkAssortimentForGuestPolicy(filteredProducts);
        }
        List<Product2> filteredProductsPrice = ProductService.filterProductPrice(newRecords, oldRecordsMap);
        if (!filteredProductsPrice.isEmpty()){
            ProductService.updatePricebooks(filteredProductsPrice);
        }
        List<Product2> filterProductPriceForUpdateOPMAndPrixSpecifiques = ProductService.filterProductPriceForUpdateOPMAndPrixSpecifiques(newRecords, oldRecordsMap);
        if (!filterProductPriceForUpdateOPMAndPrixSpecifiques.isEmpty()){
            List<Offre_Produit_Magasin__c> opms = ProductService.getOPMsForPricebook(filterProductPriceForUpdateOPMAndPrixSpecifiques);
            OffreProduitMagasinService.UpdatePriceBooksOPM(opms);
        }
    }
}