public without sharing class BatchToCreateProductCategoryProduct implements Database.Batchable <sObject>{
    
    private static final String DEPARTEMENT = 'DEPART';
    private static final String RAYON = 'RAYONS';
    private static final String FAMILLE = 'FAMBCG';
    private static final String SOUS_FAMILLE = 'SFABCG';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,Code_rayon__c, Code_departement__c, Code_sous_famille__c, Code_famille__c from Product2 '
                        +'where Code_departement__c!=null AND Code_rayon__c!=null AND Code_sous_famille__c!=null AND Code_famille__c!=null';    
        return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext bc, List<Product2> products) {
        List<ProductCategoryProduct> prodCateProd=new List<ProductCategoryProduct>();
        List<ProductCategoryProduct> updateprodCateProd=new List<ProductCategoryProduct>();
        List<ProductCategoryProduct> deleteProdCateProd=new List<ProductCategoryProduct>();
        ProductCategoryWrapper wrapper=new ProductCategoryWrapper();
        set<Id> productId=new set<Id>();
        for(Product2 pro : products){
            productId.add(pro.Id); 
        }

        map<String,ProductCategoryProduct> existProdCategoryProductMap=new map<String,ProductCategoryProduct>();
        existProdCategoryProductMap=getExistProductCategoryProductMap(productId);
        wrapper=getProductCategoryMap();
        map<String,ProductCategory> prodCategoryMap=wrapper.codeVsProdCategory!=null ? wrapper.codeVsProdCategory: new map<String,ProductCategory>();
        map<String,ProductCategory> subFamiliyProdCategoryMap=wrapper.sousFamilleExternalIdVsProdCategory!=null ? wrapper.sousFamilleExternalIdVsProdCategory : new map<String,ProductCategory>();

        for(Product2 prod : products){
            if((prodCategoryMap!=null || !prodCategoryMap.isEmpty()) ){    
                if(!String.isBlank(prod.Code_departement__c)){
                    String productTypeKey=buildCompositeKey(prod.Id,DEPARTEMENT);
                    String key=DEPARTEMENT+prod.Code_departement__c;
                    if(existProdCategoryProductMap.containsKey(productTypeKey) && prodCategoryMap.containsKey(key) ){
                        //update the existing record
                        if(existProdCategoryProductMap.get(productTypeKey).ProductCategoryId != prodCategoryMap.get(key).Id ){
                            ProductCategoryProduct pcp=existProdCategoryProductMap.get(productTypeKey).clone();
                            pcp.ProductCategoryId=prodCategoryMap.get(key).Id;
                            updateprodCateProd.add(pcp);
                            ProductCategoryProduct oldRec=existProdCategoryProductMap.get(productTypeKey);
                            deleteProdCateProd.add(oldRec);
                        }
                    }else{
                        //create new  
                        if(prodCategoryMap.containsKey(key)){
                            ProductCategoryProduct departmentRec=new ProductCategoryProduct();
                            departmentRec.ProductCategoryId=prodCategoryMap.get(key).Id;
                            departmentRec.ProductId=prod.Id;
                            prodCateProd.add(departmentRec);
                        }
                    }
                }
                if(!String.isBlank(prod.Code_rayon__c)){
                    String productTypeKey=buildCompositeKey(prod.Id,RAYON);
                    String key=RAYON+prod.Code_rayon__c;
                    if(existProdCategoryProductMap.containsKey(productTypeKey) && prodCategoryMap.containsKey(key) ){
                        //update the existing record
                        if(existProdCategoryProductMap.get(productTypeKey).ProductCategoryId != prodCategoryMap.get(key).Id ){
                            ProductCategoryProduct pcp=existProdCategoryProductMap.get(productTypeKey).clone();
                            pcp.ProductCategoryId=prodCategoryMap.get(key).Id;
                            updateprodCateProd.add(pcp);
                            
                            ProductCategoryProduct oldRec=existProdCategoryProductMap.get(productTypeKey);
                            deleteProdCateProd.add(oldRec);
                        }
                    }else{
                        //create new  
                        if(prodCategoryMap.containsKey(key)){
                            ProductCategoryProduct departmentRec=new ProductCategoryProduct();
                            departmentRec.ProductCategoryId=prodCategoryMap.get(key).Id;
                            departmentRec.ProductId=prod.Id;
                            prodCateProd.add(departmentRec);
                        }
                    }
                }
                if(!String.isBlank(prod.Code_famille__c)){
                    String productTypeKey=buildCompositeKey(prod.Id,FAMILLE);
                    String key=FAMILLE+prod.Code_famille__c;
                    if(existProdCategoryProductMap.containsKey(productTypeKey) && prodCategoryMap.containsKey(key) ){
                        //update the existing record
                        if(existProdCategoryProductMap.get(productTypeKey).ProductCategoryId != prodCategoryMap.get(key).Id ){
                            ProductCategoryProduct pcp=existProdCategoryProductMap.get(productTypeKey).clone();
                            pcp.ProductCategoryId=prodCategoryMap.get(key).Id;
                            updateprodCateProd.add(pcp);
            
                            ProductCategoryProduct oldRec=existProdCategoryProductMap.get(productTypeKey);
                            deleteProdCateProd.add(oldRec);
                        }
                    }else{
                        //create new  
                        if(prodCategoryMap.containsKey(key)){
                            ProductCategoryProduct departmentRec=new ProductCategoryProduct();
                            departmentRec.ProductCategoryId=prodCategoryMap.get(key).Id;
                            departmentRec.ProductId=prod.Id;
                            prodCateProd.add(departmentRec);
                        }
                    }
    
                }
                if(!String.isBlank(prod.Code_sous_famille__c)){
                    String productTypeKey=buildCompositeKey(prod.Id,SOUS_FAMILLE);
                    String key=buildCompositeKey(SOUS_FAMILLE,prod.Code_sous_famille__c,prod.Code_famille__c) ;
                    if(existProdCategoryProductMap.containsKey(productTypeKey) && subFamiliyProdCategoryMap.containsKey(key) ){
                        //update the existing record
                        if(existProdCategoryProductMap.get(productTypeKey).ProductCategoryId != subFamiliyProdCategoryMap.get(key).Id ){
                            ProductCategoryProduct pcp=existProdCategoryProductMap.get(productTypeKey).clone();
                            pcp.ProductCategoryId=subFamiliyProdCategoryMap.get(key).Id;
                            updateprodCateProd.add(pcp);
                            
                            ProductCategoryProduct oldRec=existProdCategoryProductMap.get(productTypeKey);
                            deleteProdCateProd.add(oldRec);
                        }
                    }else{
                        //create new  
                        if(subFamiliyProdCategoryMap.containsKey(key)){    
                            ProductCategoryProduct departmentRec=new ProductCategoryProduct();
                            departmentRec.ProductCategoryId=subFamiliyProdCategoryMap.get(key).Id;
                            departmentRec.ProductId=prod.Id;
                            prodCateProd.add(departmentRec);
                        }
                    }
                }
            }
        }

        if(!prodCateProd.isEmpty()){
            insert prodCateProd;
        }
        if(!updateprodCateProd.isEmpty()){
            insert updateprodCateProd;
        }
        if(!deleteProdCateProd.isEmpty()){
            delete deleteProdCateProd;
        }
    }   
     
    public void finish(Database.BatchableContext bc) {
    }
    /**
    * @description 
    * @author Ajay.Kumar Tiwari | 03-02-2022 
    * @return map<String, ProductCategory> 
    **/
    public ProductCategoryWrapper getProductCategoryMap(){
        List<ProductCategory> prodCategories=new List<ProductCategory>();
        map<String,ProductCategory> codeVsProdCategory=new map<String,ProductCategory>();
        map<String,ProductCategory> subFamilyExternalIdVsProdCategory=new map<String,ProductCategory>();
        ProductCategoryWrapper wrapper=new ProductCategoryWrapper(); 

        prodCategories=[Select id,Name,Type_de_categorie__c, Code_categorie__c,SousFamilleExternalId__c from ProductCategory where Category_External_Id__c!=null or SousFamilleExternalId__c!=null];

        for(ProductCategory prodCategory : prodCategories){
            if(!String.isBlank(prodCategory.Type_de_categorie__c) && prodCategory.Type_de_categorie__c!='SFABCG' && !String.isBlank(prodCategory.Code_categorie__c)){
                string key= buildCompositeKey(prodCategory.Type_de_categorie__c,prodCategory.Code_categorie__c);
                codeVsProdCategory.put(key,prodCategory);
            }
            if(!String.isBlank(prodCategory.SousFamilleExternalId__c) && prodCategory.Type_de_categorie__c=='SFABCG' ){
                
                subFamilyExternalIdVsProdCategory.put(prodCategory.SousFamilleExternalId__c,prodCategory);
            }
        }

        if(codeVsProdCategory!=null)
        wrapper.codeVsProdCategory=codeVsProdCategory;

        if(subFamilyExternalIdVsProdCategory!=null)
        wrapper.sousFamilleExternalIdVsProdCategory=subFamilyExternalIdVsProdCategory;

        return wrapper;
    }
    /**
    * @description 
    * @author Ajay.Kumar Tiwari | 03-03-2022 
    * @param productIds 
    * @return map<String, ProductCategory> 
    **/
    public map<String,ProductCategoryProduct> getExistProductCategoryProductMap(set<Id> productIds){
        List<ProductCategoryProduct> prodCategoryProducts=new List<ProductCategoryProduct>();
        map<String,ProductCategoryProduct> codeVsProdCategoryProduct=new map<String,ProductCategoryProduct>();
        prodCategoryProducts=[Select id,ProductCategory.Type_de_categorie__c,ProductId,ProductCategoryId,ProductCategory.Code_categorie__c from ProductCategoryProduct  where ProductId in :productIds];

        for(ProductCategoryProduct prodCategory : prodCategoryProducts){
            if(!String.isBlank(prodCategory.ProductId) && !String.isBlank(prodCategory.ProductCategory.Type_de_categorie__c)){
                string key= buildCompositeKey(prodCategory.ProductId,prodCategory.ProductCategory.Type_de_categorie__c);
                codeVsProdCategoryProduct.put(key,prodCategory);
            }
        }
        return codeVsProdCategoryProduct;
    }
    public static string buildCompositeKey(String type, String code){
        String compositeKey = type+code;
        return compositeKey;
    }
    public static string buildCompositeKey(String type, String code, String familycode){
        String compositeKey = type+'_'+code+'_'+familycode;
        return compositeKey;
    }
    public class ProductCategoryWrapper{
        map<String,ProductCategory> codeVsProdCategory;
        map<String,ProductCategory> sousFamilleExternalIdVsProdCategory;

    }
}