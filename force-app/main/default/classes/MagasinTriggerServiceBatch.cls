public without sharing class MagasinTriggerServiceBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{
   List<Magasin__c> listNewRecords;
   public MagasinTriggerServiceBatch(List<Magasin__c> newRecords) {
        this.listNewRecords = newRecords;
    }
    
    @testVisible Boolean prixVenteActif; 
    @testVisible Decimal StockAndEnCours;
    Decimal NiveauDeStock;
    Decimal EnCoursDeCommande;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //the batch launch every product in the database to find the corresponding image
        return Database.getQueryLocator([SELECT Id, 
            name, 
            Produit__c,
            Actif_Aquilon__c,
            Produit_actif__c, 
            Produit_avec_assortiment_text__c,
            Code_departement__c,
            Statut__c,
            Magasin__c,
            Extension_de_gamme__c,
            Produit_en_extension_de_gamme__c,
            Prix_de_vente_magasin_au_conditionnement__c,
            Prix_de_vente_magasin__c,
            Prix_de_vente_tarif_T2__c,
            Prix_de_vente_tarif_T3__c,
            Prix_T3_au_conditionnement_de_vente__c,
            Prix_T2_au_conditionnement_de_vente__c,
            Produit__r.Prix_de_vente_tarif_T2__c,
            Produit__r.Prix_de_vente_tarif_T3__c,
            Magasin__r.Extension_de_gamme__c,
            Ref_tarifaire_magasin__c,
            Rang_tarifaire__c,
            Niveau_de_stock__c,
            En_cours_de_commande__c,
            Rupture_entrepot1__c
            FROM Offre_Produit_Magasin__c 
            WHERE Magasin__c = :listNewRecords]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Offre_Produit_Magasin__c> OPM = (List<Offre_Produit_Magasin__c>) scope;
    
     /**
     * @description : Methode qui lance le flow produit
     * params : List of Offre_Produit_Magasin__c
     */ 
    //public void startProductFlow(List<sObject> scope){
                for(Offre_Produit_Magasin__c OPMrecord: OPM){
            //Verification si produit actif
            if(OPMrecord.Produit_actif__c == 'N'){ //todo: what should be the behaviour if Produit_actif__c will be different from 'O' or 'N'? e.g. NULL or any other value (added in the future)?
                deactivateProduct(OPMrecord, '5');
            } else if(OPMrecord.Produit_actif__c == 'O'){
                //Vérification si le produit est avec assortiment
                if(OPMrecord.Produit_avec_assortiment_text__c == '1' || OPMrecord.Produit_avec_assortiment_text__c == '2' || OPMrecord.Produit_avec_assortiment_text__c == null){ //todo: what should be the behaviour if Produit_avec_assortiment_text__c will be different from '0, '1', '2', NULL? 
                    checkExistingPrices(OPMrecord);
                    if(prixVenteActif == false){
                        deactivateProduct(OPMrecord, '5');
                    } else {
                        checkExistInAquilon(OPMrecord);
                    }
                } else if(OPMrecord.Produit_avec_assortiment_text__c == '0'){
                    //Vérification si produit en extension de gamme
                    if(!OPMrecord.Produit_en_extension_de_gamme__c){
                        checkExistingPrices(OPMrecord);
                        if(prixVenteActif == false){
                            deactivateProduct(OPMrecord, '5');
                        } else {
                            checkExistInAquilon(OPMrecord);
                        }
                    } else{
                        checkExistingPrices(OPMrecord);
                        if(prixVenteActif == false && (OPMrecord.Code_departement__c == null || OPMrecord.Code_departement__c == '1' || OPMrecord.Code_departement__c == '2' || OPMrecord.Code_departement__c == '3' || OPMrecord.Code_departement__c == '5')){ //todo: what should be the behaviour if prixVenteActif = TRUE and Code_departement__c will be different from '0', '1', '2', '3', '4', '5'? e.g. NULL or any other value (added in the future)?
                            deactivateProduct(OPMrecord, '5');
                        } else if(prixVenteActif == false && OPMrecord.Code_departement__c == '4'){
                            // cas du pole frais - possible qu'il n'y ait pas de prix
                            checkExistInAquilonIfExtension(OPMrecord);
                        } else if(prixVenteActif == true){
                            checkExistInAquilonIfExtension(OPMrecord);
                        }
                    }
                }
            }
        }
                //}
    }
    
    public void finish(Database.BatchableContext info){     
    }
    /**
     * @description : Fonction de désactivation des produits (retire le produit dans les Entitlement policies)
     * @parameter : Offre produit magasin + Statut à assigner à l'offre (voir champ statut sur l'objet Offre produit Magasin)
     */ 
    private void deactivateProduct(Offre_Produit_Magasin__c OPMrecord, String statut){
        List<CommerceEntitlementProduct> CEProduct = [
            SELECT productId, 
            product.name, 
            name, 
            policyId, 
            policy.name,
            policy.Libelle_Etablissement__c
            FROM CommerceEntitlementProduct 
            WHERE productId = :OPMrecord.produit__c and policy.Libelle_Etablissement__c = :OPMrecord.magasin__c
        ];
        if(!CEProduct.isEmpty()){
            delete CEProduct;
        }
        OPMrecord.statut__c = statut;
        Update OPMRecord;
    }
    
    /**
     * @description : Fonction d'activation des produits (ajout du produit dans les Entitlement policies)
     * @parameter : Offre produit magasin + Statut à assigner à l'offre (voir champ statut sur l'objet Offre produit Magasin)
     */ 
    @testVisible
    private void activateProduct(Offre_Produit_Magasin__c OPMrecord, String statut){
        List<CommerceEntitlementProduct> CEProduct = [
            SELECT productId, 
            product.name, 
            name, 
            policyId, 
            policy.name,
            policy.Libelle_Etablissement__c
            FROM CommerceEntitlementProduct 
            WHERE productId = :OPMrecord.produit__c and policy.Libelle_Etablissement__c = :OPMrecord.magasin__c
        ];
        
        List<CommerceEntitlementPolicy> CEPolicy = [
            SELECT id,
            IsActive,
            name,
            Libelle_Etablissement__c
            FROM CommerceEntitlementPolicy 
            WHERE Libelle_Etablissement__c = :OPMrecord.magasin__c
        ];
        if(CEProduct.isEmpty() && !CEPolicy.isEmpty()){
            CommerceEntitlementProduct cep = new CommerceEntitlementProduct(productId = OPMrecord.produit__c, policyId = CEPolicy.get(0).Id);
            CEProduct.add(cep);
            upsert CEProduct;
        }
        OPMrecord.statut__c = statut;
        update OPMRecord;
    }
    
    /**
     * @description : Fonction de vérification de la présence de prix et de rang tarifaire - Met à jour la variable prixVenteActif
     * @parameter : Offre produit magasin 
     */ 
    @testVisible
    private void checkExistingPrices(Offre_Produit_Magasin__c OPMrecord){
        if(OPMrecord.Prix_de_vente_magasin__c == null || OPMrecord.Prix_de_vente_magasin__c == 0 ){
            if(OPMrecord.Rang_tarifaire__c == 'T2'){
                if(OPMrecord.Produit__r.Prix_de_vente_tarif_T2__c == null || OPMrecord.Produit__r.Prix_de_vente_tarif_T2__c == 0 ){
                    prixVenteActif = false;
                } else {
                    prixVenteActif = true;
                }
            } else if(OPMrecord.Rang_tarifaire__c == 'T3'){
                if(OPMrecord.Produit__r.Prix_de_vente_tarif_T3__c == null || OPMrecord.Produit__r.Prix_de_vente_tarif_T3__c == 0){
                    prixVenteActif = false;
                } else {
                    prixVenteActif = true;
                }
            }
        }else if(OPMrecord.Prix_de_vente_magasin__c > 0){
            prixVenteActif = true;
        }
    }

    /**
     * @description : Fonction de vérification de produit actif dans Aquilon (Produit pas en extension de gamme)
     * @parameter : Offre produit magasin 
     */
    @testVisible
    private void checkExistInAquilon(Offre_Produit_Magasin__c OPMrecord){
        //Vérifie si produit actif dans Aquilon
        if(!OPMrecord.Actif_Aquilon__c){
            deactivateProduct(OPMrecord, '5');
        } else {
            // Si produit actif dans Aquilon, on vérifie la quantité de stock pour mettre à jour la disponibilité avec le statut de l'offre
            Utilities.checkStockAndEnCours(OPMrecord, niveauDeStock, stockAndEnCours, enCoursDeCommande);
            if(StockAndEnCours <= 0 ){
                deactivateProduct(OPMrecord, '5');
            } else {
                activateProduct(OPMrecord, '3');
            }
        } 
    }
 
    /**
     * @description : Fonction de vérification de produit actif dans Aquilon (Produit en extension de gamme)
     * @parameter : Offre produit magasin 
     */
    @testVisible
    private void checkExistInAquilonIfExtension(Offre_Produit_Magasin__c OPMrecord){
        if(!OPMrecord.Actif_Aquilon__c){
            Utilities.checkStockAndEnCours(OPMrecord, niveauDeStock, stockAndEnCours, enCoursDeCommande);
            //cas impossible mais demande d'action par le client
            if(StockAndEnCours > 0 ){
                activateProduct(OPMrecord, '1');
            } else if(StockAndEnCours <= 0 ){
                // /!\ Rupture entrepot = true => disponible en entrepot
                // /!\ Rupture entrepot = false => non disponible en entrepot
                if(OPMrecord.Rupture_entrepot1__c){
                    if(OPMrecord.Magasin__r.Extension_de_gamme__c == 'oui'){ //todo: what should be the behaviour if Extension_de_gamme__c will be different from 'oui' or 'non'? e.g. NULL or any other value (added in the future)?
                        activateProduct(OPMrecord, '2');
                    }else if(OPMrecord.Magasin__r.Extension_de_gamme__c == 'non'){
                        deactivateProduct(OPMrecord, '5');
                    }
                } else{ 
                    deactivateProduct(OPMrecord, '4');
                }
            }
        } else{ 
            Utilities.checkStockAndEnCours(OPMrecord, niveauDeStock, stockAndEnCours, enCoursDeCommande);
            if(StockAndEnCours > 0 ){
                if(OPMrecord.Rupture_entrepot1__c){ 
                    activateProduct(OPMrecord, '1');
                } else {
                    activateProduct(OPMrecord, '3');
                }
            } else {
                // /!\ Rupture entrepot = true => disponible en entrepot
                // /!\ Rupture entrepot = false => non disponible en entrepot
                if(OPMrecord.Rupture_entrepot1__c){
                    if(OPMrecord.Magasin__r.Extension_de_gamme__c == 'oui'){ //todo: what should be the behaviour if Extension_de_gamme__c will be different from 'oui' or 'non'? e.g. NULL or any other value (added in the future)?
                        activateProduct(OPMrecord, '2');
                    }else if(OPMrecord.Magasin__r.Extension_de_gamme__c == 'non'){
                        deactivateProduct(OPMrecord, '5');
                    }
                } else {
                    deactivateProduct(OPMrecord, '4');
                }
            }
        }
    }
}