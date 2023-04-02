/**
 * @description       : 
 * @author            : Ajay.Kumar Tiwari
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ajay.Kumar Tiwari
**/
@IsTest
class BatchToCreateProductCategoryProductTest {
    @isTest
	private static void testBulkProductCateegoryProductCreation(){

      ProductCatalog pc=new ProductCatalog();
      pc.Name='Test Promomcash';
      insert pc;
    
    ProductTriggerHandler.bypassTrigger=true;

      List<ProductCategory> proCategories=new List<ProductCategory>();

      ProductCategory depart=new ProductCategory();
      depart.CatalogId=pc.Id;
      depart.Name='EPICERIE';
      depart.Category_External_Id__c='DEPART_8';
      depart.Code_categorie__c='8';
      depart.Type_de_categorie__c='DEPART';
      proCategories.add(depart);
      
      ProductCategory rayon=new ProductCategory();
      rayon.CatalogId=pc.Id;
      rayon.Name='SURGELES';
      rayon.Category_External_Id__c='RAYONS_38';
      rayon.Code_categorie__c='38';
      rayon.Type_de_categorie__c='RAYONS';
      proCategories.add(rayon);
      
      ProductCategory fam=new ProductCategory();
      fam.CatalogId=pc.Id;
      fam.Name='ELECTRICITE';
      fam.Category_External_Id__c='FAMBCG_387';
      fam.Code_categorie__c='387';
      fam.Type_de_categorie__c='FAMBCG';
      proCategories.add(fam);
      
      ProductCategory sfam=new ProductCategory();
      sfam.CatalogId=pc.Id;
      sfam.Name='ANCHOIS';
      sfam.SousFamilleExternalId__c='SFABCG_012_387';
      sfam.Code_categorie__c='012';
      sfam.Type_de_categorie__c='SFABCG';
      proCategories.add(sfam);
      
      insert proCategories;
      List<ProductCategory> proCategoriesNew=new List<ProductCategory>();

      ProductCategory depart1=new ProductCategory();
      depart1.CatalogId=pc.Id;
      depart1.Name='EPICERIEe';
      depart1.Category_External_Id__c='DEPART_9';
      depart1.Code_categorie__c='9';
      depart1.Type_de_categorie__c='DEPART';
      proCategoriesNew.add(depart1);
      
      ProductCategory rayon1=new ProductCategory();
      rayon1.CatalogId=pc.Id;
      rayon1.Name='SURGELESs';
      rayon1.Category_External_Id__c='RAYONS_36';
      rayon1.Code_categorie__c='36';
      rayon1.Type_de_categorie__c='RAYONS';
      proCategoriesNew.add(rayon1);
      
      ProductCategory fam1=new ProductCategory();
      fam1.CatalogId=pc.Id;
      fam1.Name='ELECTRICITEe';
      fam1.Category_External_Id__c='FAMBCG_397';
      fam1.Code_categorie__c='397';
      fam1.Type_de_categorie__c='FAMBCG';
      proCategoriesNew.add(fam1);
      
      ProductCategory sfam1=new ProductCategory();
      sfam1.CatalogId=pc.Id;
      sfam1.Name='ANCHOISs';
      sfam1.SousFamilleExternalId__c='SFABCG_012_397';
      sfam1.Code_categorie__c='012';
      sfam1.Type_de_categorie__c='SFABCG';
      proCategoriesNew.add(sfam1);
      
      insert proCategoriesNew;
    
    List<Product2> prlist=new List<Product2>();

    for(integer i=0;i<200;i++){
        Product2 pr=new Product2();
        pr.Name='test bulk data'+i;
        pr.Code_departement__c='8';
        pr.Code_rayon__c='38';
        pr.Code_famille__c='387';
        pr.Code_sous_famille__c='012';
        prlist.add(pr);
    }
    insert prlist;

     
    
    List<ProductCategoryProduct> produCatProd=new List<ProductCategoryProduct>();
    ProductCategoryProduct obj1=new ProductCategoryProduct();
    obj1.ProductCategoryId=proCategoriesNew[0].Id;
    obj1.ProductId=prlist[0].Id;
    produCatProd.add(obj1);
    
    ProductCategoryProduct obj2=new ProductCategoryProduct();
    obj2.ProductCategoryId=proCategoriesNew[1].Id;
    obj2.ProductId=prlist[0].Id;
    produCatProd.add(obj2);

    ProductCategoryProduct obj3=new ProductCategoryProduct();
    obj3.ProductCategoryId=proCategoriesNew[2].Id;
    obj3.ProductId=prlist[0].Id;
    produCatProd.add(obj3);
    
    ProductCategoryProduct obj4=new ProductCategoryProduct();
    obj4.ProductCategoryId=proCategoriesNew[3].Id;
    obj4.ProductId=prlist[0].Id;
    produCatProd.add(obj4);

    insert produCatProd;

    Test.startTest();

    BatchToCreateProductCategoryProduct obj = new BatchToCreateProductCategoryProduct();
    DataBase.executeBatch(obj); 
    
    Test.stopTest();


    }
}