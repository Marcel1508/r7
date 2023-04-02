global class ProductTrigger_Batch implements Database.Batchable<SObject>, Schedulable {
    private static final List<SObjectField> FIELDS = new List<SObjectField>{
            Product2.CreatedDate,
            Product2.LastModifiedDate,
            Product2.Prix_de_vente_tarif_T2__c,
            Product2.Niveau_d_assortiment__c,
            Product2.Code_departement__c,
            Product2.Code_rayon__c,
            Product2.Code_famille__c,
            Product2.Code_sous_famille__c,
            Product2.Libelles_Data_Load__c,
            Product2.Libelle_fournisseur__c,
            Product2.Libelle_commercial__c,
            Product2.Name
    };

    private Integer BATCH_SIZE = 800;
    public String WHERE_CONDITION;

    public ProductTrigger_Batch() {
        this.WHERE_CONDITION = 'LastModifiedDate = TODAY';
    }

    public ProductTrigger_Batch(String whereCondition) {
        this.WHERE_CONDITION = whereCondition;
    }

    public ProductTrigger_Batch(String whereCondition, Integer batchSize) {
        this(whereCondition);
        this.BATCH_SIZE = batchSize;
    }

    public String getQueryString() {
        List<String> fieldStringList = new List<String>();
        for(SObjectField field : FIELDS) {
            fieldStringList.add(field.getDescribe().getName());
        }

        return 'SELECT ' + String.join(fieldStringList, ',') + ' FROM Product2' +
                (WHERE_CONDITION != null ? ' WHERE ' + WHERE_CONDITION : '');

    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator(
                getQueryString()
        );
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        ProductService.createPricebookEntry(scope);
        ProductService.populateLibellFinalField(scope);
//        ProductService.checkAssortimentForGuestPolicy(scope);
        ProductService ps = new ProductService();
        ps.addProductsToCategories_Batch(scope);

        update scope;
    }
    
    global void finish(Database.BatchableContext BC){}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, BATCH_SIZE);
    }
}