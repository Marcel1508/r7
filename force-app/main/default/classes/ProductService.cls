/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Classe de service de l'objet Product
* @TestClass : ProductService_TST
**/

public with sharing class ProductService {

    private final static String DEPARTEMENT = 'DEPART';
    private final static String RAYON = 'RAYONS';
    private final static String FAMILLE = 'FAMBCG';
    private final static String SOUS_FAMILLE = 'SFABCG';

    private static final String GUEST_POLICY_NAME = 'Guest Policy';

	private Map<String, CommerceEntitlementProduct> CEProductMagasinMap = new Map<String, CommerceEntitlementProduct>();
	//private Map<String, CommerceEntitlementProduct> CEProductMagasinMapTocreate = new Map<String, CommerceEntitlementProduct>();
      
    //Permet de déclencher le trigger FluxProduit en fonction de la modification de certains champs  
	//Le trigger sera déclenché si l'ancienne valeur et la nouvelle valeur des champs ci-dessous sont différentes
    public static List<Product2> filterProduct (List<Product2> newRecords, Map<Id,Product2> oldRecords) {
       List<Product2> filteredRecords = new List<Product2>();
       for (Product2 newRecord : newRecords) {
           Product2 oldRecord = oldRecords.get(newRecord.Id);
           if((oldRecord.Prix_de_vente_tarif_T2__c != newRecord.Prix_de_vente_tarif_T2__c)
             || (oldRecord.Prix_de_vente_tarif_T3__c != newRecord.Prix_de_vente_tarif_T3__c)
             || (oldRecord.Produit_avec_assortiment__c != newRecord.Produit_avec_assortiment__c)
             || (oldRecord.Niveau_d_assortiment__c != newRecord.Niveau_d_assortiment__c)
             || (oldRecord.Code_departement__c != newRecord.Code_departement__c)
             || (oldRecord.Extension_de_gamme__c != newRecord.Extension_de_gamme__c)){
                filteredRecords.add(newRecord);
           }
       }
       return filteredRecords;
   }
    
    //Permet de déclencher le trigger Flux des prix en fonction de la modification de certains champs
	//Le trigger sera déclenché si l'ancienne valeur et la nouvelle valeur des champs ci-dessous sont différentes
    public static List<Product2> filterProductPrice (List<Product2> newRecords, Map<Id,Product2> oldRecords) {
       List<Product2> filteredRecords = new List<Product2>();
       for (Product2 newRecord : newRecords) {
           Product2 oldRecord = oldRecords.get(newRecord.Id);
           if ((oldRecord.Prix_de_vente_tarif_T2__c != newRecord.Prix_de_vente_tarif_T2__c)) {
                filteredRecords.add(newRecord);
           }
       }
       return filteredRecords;
   }
    
    public static List<Product2> filterProductPriceForUpdateOPMAndPrixSpecifiques (List<Product2> newRecords, Map<Id,Product2> oldRecords) {
       List<Product2> filteredRecords = new List<Product2>();
       for (Product2 newRecord : newRecords) {
           Product2 oldRecord = oldRecords.get(newRecord.Id);
           if ((oldRecord.Prix_de_vente_tarif_T2__c != newRecord.Prix_de_vente_tarif_T2__c) || 
             (oldRecord.Prix_de_vente_tarif_T3__c != newRecord.Prix_de_vente_tarif_T3__c) || 
             (oldRecord.Conditionnement_de_commande_PCB__c != newRecord.Conditionnement_de_commande_PCB__c)) {
                filteredRecords.add(newRecord);
            }
       }
       return filteredRecords;
   }
    
    public static List<Offre_Produit_Magasin__c> getOPMs(List<Product2> newRecords) {
        List<Offre_Produit_Magasin__c> listOPM = [
                SELECT  Id, Name, Produit__c,Actif_Aquilon__c,Produit_actif__c, Produit_avec_assortiment_text__c,
                        Code_departement__c, Statut__c, Magasin__c,Extension_de_gamme__c, Magasin__r.Extension_de_gamme__c,
			            Produit_en_extension_de_gamme__c,Prix_de_vente_magasin__c,Prix_de_vente_tarif_T2__c,
                        Prix_de_vente_tarif_T3__c, Produit__r.Prix_de_vente_tarif_T2__c,Produit__r.Prix_de_vente_tarif_T3__c,
                        Prix_T2_au_conditionnement_de_vente__c,Prix_T3_au_conditionnement_de_vente__c,Rang_tarifaire__c,
                        Niveau_de_stock__c,En_cours_de_commande__c,Rupture_entrepot1__c,Conditionnement_de_vente_bloque__c,
                        Quantite_minimum_de_commande__c,Vente_au_PCB_Magasin__c, Produit__r.Conditionnement_de_commande_PCB__c,
                        Ref_tarifaire_magasin__c, Prix_de_vente_magasin_au_conditionnement__c
                FROM Offre_Produit_Magasin__c
                WHERE Produit__c = :newRecords
		];
        return listOPM;
    }
    
    public static List<Offre_Produit_Magasin__c> getOPMsForPricebook(List<Product2> newRecords) {
        List<Offre_Produit_Magasin__c> listOPM = [
                SELECT  Id, Name, Produit__c, Statut__c, Magasin__c, Magasin__r.Extension_de_gamme__c,
                        Code_departement__c,Prix_de_vente_magasin__c,Prix_de_vente_tarif_T2__c,Prix_de_vente_tarif_T3__c,
                        Produit__r.Prix_de_vente_tarif_T2__c,Produit__r.Prix_de_vente_tarif_T3__c,
                        Prix_T2_au_conditionnement_de_vente__c,Prix_T3_au_conditionnement_de_vente__c,
                        Produit__r.Conditionnement_de_commande_PCB__c,Rang_tarifaire__c, Conditionnement_de_vente_bloque__c,
                        Quantite_minimum_de_commande__c,Vente_au_PCB_Magasin__c, Ref_tarifaire_magasin__c,
                        Prix_de_vente_magasin_au_conditionnement__c
            FROM Offre_Produit_Magasin__c 
            WHERE Produit__c = :newRecords
		];
        return listOPM;
    }
    
    Boolean prixVenteActif; 
    Decimal stockAndEnCours;
    Decimal niveauDeStock;
    Decimal enCoursDeCommande;
    
    /**
     * @description : Methode qui lance le flow produit
     * params : List of Offre_Produit_Magasin__c
     */ 
    public void startProductFlow(List<Offre_Produit_Magasin__c> oPMs){
        List<Offre_Produit_Magasin__c> opmToDeactivateList = new List<Offre_Produit_Magasin__c>();
        Map<Id, String> opmStatutMap = new Map<Id, String>();
        List<Offre_Produit_Magasin__c> opmToCheckInAcquilon = new List<Offre_Produit_Magasin__c>();
        List<Offre_Produit_Magasin__c> opmToCheckInAcquilonExtention = new List<Offre_Produit_Magasin__c>();
        
        //****
        Set<Id> OPMRelatedMagasins = new Set<Id>();
        Set<Id> OPMRelatedProducts = new Set<Id>();
        for(Offre_Produit_Magasin__c OPMLine: oPMs){
            OPMRelatedMagasins.add(OPMLine.Magasin__c);
            OPMRelatedProducts.add(OPMLine.Produit__c);
        }
        //Retrieve related CommerceEntitlementPolicy
        List<CommerceEntitlementPolicy> CEPolicy = [
            SELECT Id,
            IsActive,
            Name,
            Libelle_Etablissement__c
            FROM CommerceEntitlementPolicy 
            WHERE Libelle_Etablissement__c = :OPMRelatedMagasins FOR UPDATE
        ];
        Map<String, CommerceEntitlementPolicy> CEPolicyMagasinMap = new Map<String, CommerceEntitlementPolicy>();
        for(CommerceEntitlementPolicy CEP : CEPolicy){
            CEPolicyMagasinMap.put(CEP.Libelle_Etablissement__c, CEP);
        }
        //Retrieve related CommerceEntitlementProduct
        List<CommerceEntitlementProduct> CEProducts = [
            SELECT ProductId,
            Product.Name,
            Name,
            PolicyId,
            Policy.Name,
            Policy.Libelle_Etablissement__c
            FROM CommerceEntitlementProduct 
            WHERE ProductId = :OPMRelatedProducts and Policy.Libelle_Etablissement__c = :OPMRelatedMagasins FOR UPDATE
		];
        //Retrieve related CommerceEntitlementProduct
        for(CommerceEntitlementProduct CEProduct : CEProducts){
            String key = CEProduct.ProductId + '' + CEProduct.Policy.Libelle_Etablissement__c;
            this.CEProductMagasinMap.put(key, CEProduct);
        }
       
        for (Offre_Produit_Magasin__c opm : oPMs) {
            //Verification si produit actif
            if(opm.Produit_actif__c == 'N'){ //todo: what should be the behaviour if Produit_actif__c will be different from 'O' or 'N'? e.g. NULL or any other value (added in the future)?
                //deactivateProduct(opm, '5');
                opmToDeactivateList.add(opm);
                opmStatutMap.put(opm.Id, '5');

            } else if (opm.Produit_actif__c == 'O'){
                //Vérification si le produit est avec assortiment
                if (opm.Produit_avec_assortiment_text__c == '1' || opm.Produit_avec_assortiment_text__c == '2' || opm.Produit_avec_assortiment_text__c == null){ //todo: what should be the behaviour if Produit_avec_assortiment__c will be different from '0, '1', '2', NULL? 
                    checkExistingPrices(opm);
                    if(prixVenteActif == false){
                        //deactivateProduct(opm, '5');
                        opmToDeactivateList.add(opm);
                        opmStatutMap.put(opm.Id, '5');
                    } else {
                        //checkExistInAquilon(opm);
                        opmToCheckInAcquilon.add(opm);
                    }
            	} else if(opm.Produit_avec_assortiment_text__c == '0'){
                    //Vérification si produit en extension de gamme
                    if(!opm.Produit_en_extension_de_gamme__c){
						checkExistingPrices(opm);
                        if(prixVenteActif == false){
                        	//deactivateProduct(opm, '5');
                            opmToDeactivateList.add(opm);
                            opmStatutMap.put(opm.Id, '5');
                    	} else {
                        	//checkExistInAquilon(opm);
                            opmToCheckInAcquilon.add(opm);
                        }
					} else{
						checkExistingPrices(opm);
                        if(prixVenteActif == false && (opm.Code_departement__c == null || opm.Code_departement__c == '1' || opm.Code_departement__c == '2' || opm.Code_departement__c == '3' || opm.Code_departement__c == '5')){ //todo: what should be the behaviour if prixVenteActif = TRUE and Code_departement__c will be different from '0', '1', '2', '3', '4', '5'? e.g. NULL or any other value (added in the future)?
                        	//deactivateProduct(opm, '5');
                            opmToDeactivateList.add(opm);
                            opmStatutMap.put(opm.Id, '5');
                    	} else if(prixVenteActif == false && opm.Code_departement__c == '4'){
                            // cas du pole frais - possible qu'il n'y ait pas de prix
                            //checkExistInAquilonIfExtension(opm);
                            opmToCheckInAcquilonExtention.add(opm);
                        } else if(prixVenteActif == true){
                            //checkExistInAquilonIfExtension(opm);
                            opmToCheckInAcquilonExtention.add(opm);
                        }
                    }
        		}
    		}
        }
		Map<Id, String> opmStatutFromCheckInAquilon = new Map<Id, String>();
		Map<Id, String> opmStatutFromCheckInAquilonExtention = new Map<Id, String>();
        List<Offre_Produit_Magasin__c> opmToUpdate = new List<Offre_Produit_Magasin__c>();
        
        if(!opmToDeactivateList.isEmpty()) {
            deactivateProductBulk(opmToDeactivateList, opmStatutMap);
        } 
        if(!opmToCheckInAcquilon.isEmpty()) {
            opmStatutFromCheckInAquilon = checkExistInAquilonBulk(opmToCheckInAcquilon, CEPolicyMagasinMap);
        }
        if(!opmToCheckInAcquilonExtention.isEmpty()) {
            opmStatutFromCheckInAquilonExtention = checkExistInAquilonIfExtensionBulk(opmToCheckInAcquilonExtention, CEPolicyMagasinMap);
        }
        
        for(Offre_Produit_Magasin__c opm: opmToDeactivateList) {
            if(opmStatutMap.get(opm.Id) != null) {
                opm.Statut__c = opmStatutMap.get(opm.Id);
                opmToUpdate.add(opm);
            }
        }
        for(Offre_Produit_Magasin__c opm: opmToCheckInAcquilon) {
            if(opmStatutFromCheckInAquilon.get(opm.Id) != null) {
                opm.Statut__c = opmStatutFromCheckInAquilon.get(opm.Id);
                opmToUpdate.add(opm);
            }
        }
        for(Offre_Produit_Magasin__c opm: opmToCheckInAcquilonExtention) {
            if(opmStatutFromCheckInAquilonExtention.get(opm.Id) != null) {
                opm.Statut__c = opmStatutFromCheckInAquilonExtention.get(opm.Id);
                opmToUpdate.add(opm);
            }
        }
        if (!opmToUpdate.isEmpty()) {
            update opmToUpdate;
        }
    }
    
    /**
     * @description : Fonction de désactivation des produits (retire le produit dans les Entitlement policies)
     * @parameter : Offre produit magasin + Statut à assigner à l'offre (voir champ statut sur l'objet Offre produit Magasin)
     */ 
    private void deactivateProductBulk(List<Offre_Produit_Magasin__c> opmList, Map<Id, String> opmStatutMap) {
        Set<Id> magasinIds = new  Set<Id>();
        Set<Id> produitIds = new  Set<Id>();
        List<CommerceEntitlementProduct> CommerceEntitlementProductToDelete = new List<CommerceEntitlementProduct>();
		List<String> deletedKeys = new List<String>();
            
        for (Offre_Produit_Magasin__c opm: opmList) {
            String key = opm.Produit__c + '' + opm.Magasin__c;
            
            CommerceEntitlementProduct cme = this.CEProductMagasinMap.get(key);
            if(cme != null) {
                CommerceEntitlementProductToDelete.add(cme);
                deletedKeys.add(key);
            }
        }
        
        if(!CommerceEntitlementProductToDelete.isEmpty()) {
            delete CommerceEntitlementProductToDelete;
            for(String deletedKey: deletedKeys) {
                this.CEProductMagasinMap.remove(deletedKey);
            }
        }
    }

     /**
     * @description : Fonction d'activation des produits (ajout du produit dans les Entitlement policies)
     * @parameter : Offre produit magasin + Statut à assigner à l'offre (voir champ statut sur l'objet Offre produit Magasin)
     */
    @testVisible
    private void activateProductBulk(List<Offre_Produit_Magasin__c> oPMList, Map<Id, String> opmStatutMap, Map<String, CommerceEntitlementPolicy> CEPolicyMagasinMap){
        Set<Id> magasinIds = new Set<Id>();
        Set<Id> produitIds = new Set<Id>();
        Map<Id, Id> mapCEPolicy = new  Map<Id, Id> ();
        
        List<CommerceEntitlementProduct> ceProductsToCreate = new List<CommerceEntitlementProduct>();
        List<String> ceProductKeysToCreate = new List<String>();
        
        for (Offre_Produit_Magasin__c opm: oPMList) {
            String key = opm.Produit__c + '' + opm.Magasin__c;
            if(this.CEProductMagasinMap.get(key) == null && CEPolicyMagasinMap.get(opm.Magasin__c) != null) {
                CommerceEntitlementProduct cep = new CommerceEntitlementProduct(ProductId = opm.Produit__c, PolicyId = CEPolicyMagasinMap.get(opm.Magasin__c).Id);
                ceProductsToCreate.add(cep);
                ceProductKeysToCreate.add(key);
            }
        }
        
        if(!ceProductsToCreate.isEmpty()) {
            upsert ceProductsToCreate;
            for(String k: ceProductKeysToCreate) {
                this.CEProductMagasinMap.put(k, new CommerceEntitlementProduct());
            }
        }
    }
    
    
    /**
     * @description : Fonction de vérification de la présence de prix et de rang tarifaire - Met à jour la variable prixVenteActif
     * @parameter : Offre produit magasin 
     */ 
	private void checkExistingPrices(Offre_Produit_Magasin__c opm) {
		if (opm.Prix_de_vente_magasin__c == null || opm.Prix_de_vente_magasin__c == 0 ){
			if (opm.Rang_tarifaire__c == 'T2'){
                if(opm.Produit__r.Prix_de_vente_tarif_T2__c == null || opm.Produit__r.Prix_de_vente_tarif_T2__c == 0 ) {
                    prixVenteActif = false;
                } else {
                    prixVenteActif = true;
                }
			} else if (opm.Rang_tarifaire__c == 'T3'){
                if (opm.Produit__r.Prix_de_vente_tarif_T3__c == null || opm.Produit__r.Prix_de_vente_tarif_T3__c == 0) {
                    prixVenteActif = false;
                } else {
                    prixVenteActif = true;
                }
			}
        } else if (opm.Prix_de_vente_magasin__c > 0){
            prixVenteActif = true;
        }
    }
   
    /**
     * @description : Fonction de vérification de produit actif dans Aquilon (Produit pas en extension de gamme)
     * @parameter : Offre produit magasin 
     */
    private Map<Id, String> checkExistInAquilonBulk(List<Offre_Produit_Magasin__c> oPMs, Map<String, CommerceEntitlementPolicy> CEPolicyMagasinMap){
        List<Offre_Produit_Magasin__c> opmToDeactivateList = new List<Offre_Produit_Magasin__c>();
        List<Offre_Produit_Magasin__c> opmToActivateList = new List<Offre_Produit_Magasin__c>();
        Map<Id, String> opmStatutMap = new Map<Id, String>();

        for (Offre_Produit_Magasin__c opm : oPMs) {
            //Vérifie si produit actif dans Aquilon
            if(!opm.Actif_Aquilon__c){
                opmToDeactivateList.add(opm);
                opmStatutMap.put(opm.Id, '5');
            } else {
                // Si produit actif dans Aquilon, on vérifie la quantité de stock pour mettre à jour la disponibilité avec le statut de l'offre
                Decimal stockValue = Utilities.checkStockAndEnCoursBulk(opm);
                if(stockValue <= 0 ){
                    opmToDeactivateList.add(opm);
                    opmStatutMap.put(opm.Id, '5');
                } else {
                    opmToActivateList.add(opm);
                    opmStatutMap.put(opm.Id, '3');
                }
            }
        }

        if(!opmToDeactivateList.isEmpty()) {
            deactivateProductBulk(opmToDeactivateList, opmStatutMap);
        } 

        if(!opmToActivateList.isEmpty()) {
            activateProductBulk(opmToActivateList, opmStatutMap, CEPolicyMagasinMap);
        }
        return opmStatutMap;
    }
    
    /**
     * @description : Fonction de vérification de produit actif dans Aquilon (Produit en extension de gamme)
     * @parameter : Offre produit magasin 
     */
    @Testvisible
	private Map<Id, String> checkExistInAquilonIfExtensionBulk(List<Offre_Produit_Magasin__c> oPMs, Map<String, CommerceEntitlementPolicy> CEPolicyMagasinMap) {

        List<Offre_Produit_Magasin__c> opmToDeactivateList = new List<Offre_Produit_Magasin__c>();
        List<Offre_Produit_Magasin__c> opmToActivateList = new List<Offre_Produit_Magasin__c>();
        Map<Id, String> opmStatutMap = new Map<Id, String>();

        for (Offre_Produit_Magasin__c opm : oPMs) {
            if (!opm.Actif_Aquilon__c) {
                Decimal stockValue = Utilities.checkStockAndEnCoursBulk(opm);
                //cas impossible mais demande d'action par le client
                if (stockValue > 0) {
                    opmToActivateList.add(opm);
                    opmStatutMap.put(opm.Id, '1');
                } else if (stockValue <= 0 ) {
                    // /!\ Rupture entrepot = true => disponible en entrepot
                    // /!\ Rupture entrepot = false => non disponible en entrepot
                    if(opm.Rupture_entrepot1__c){
                        if(opm.Magasin__r.Extension_de_gamme__c == 'oui') { //todo: what should be the behaviour if Extension_de_gamme__c will be different from 'oui' or 'non'? e.g. NULL or any other value (added in the future)?
                            opmToActivateList.add(opm);
                            opmStatutMap.put(opm.Id, '2');
                        }else if(opm.Magasin__r.Extension_de_gamme__c == 'non') {
                            opmToDeactivateList.add(opm);
                            opmStatutMap.put(opm.Id, '5');
                        }
                    } else{ 
                        opmToDeactivateList.add(opm);
                        opmStatutMap.put(opm.Id, '4');
                    }
                }
            } else{ 
                Decimal stockValue = Utilities.checkStockAndEnCoursBulk(opm);
                if(stockValue > 0 ){
                    if(opm.Rupture_entrepot1__c){ 
                        opmToActivateList.add(opm);
                        opmStatutMap.put(opm.Id, '1');
                    } else {
                        opmToActivateList.add(opm);
                        opmStatutMap.put(opm.Id, '3');
                    }
                } else {
                    // /!\ Rupture entrepot = true => disponible en entrepot
                    // /!\ Rupture entrepot = false => non disponible en entrepot
                    if(opm.Rupture_entrepot1__c){
                        if(opm.Magasin__r.Extension_de_gamme__c == 'oui'){ //todo: what should be the behaviour if Extension_de_gamme__c will be different from 'oui' or 'non'? e.g. NULL or any other value (added in the future)?
                            opmToActivateList.add(opm);
                            opmStatutMap.put(opm.Id, '2');
                        }else if(opm.Magasin__r.Extension_de_gamme__c == 'non'){
                            opmToDeactivateList.add(opm);
                            opmStatutMap.put(opm.Id, '5');
                        }
                    } else {
                        opmToDeactivateList.add(opm);
                        opmStatutMap.put(opm.Id, '4');
                    }
                }
            }
        }
        if(!opmToDeactivateList.isEmpty()) {
            deactivateProductBulk(opmToDeactivateList, opmStatutMap);
        } 
        
        if(!opmToActivateList.isEmpty()) {
            activateProductBulk(opmToActivateList, opmStatutMap, CEPolicyMagasinMap);
        }
        return opmStatutMap;
    }
    
    
    /**
     * @description : Update pricebook Standard of product
     * @parameter : Product
     */
    public static void updatePricebooks(List<Product2> newRecords) {
        Map<Id, PricebookEntry> pbeByProductId = new Map<Id, PricebookEntry>();
        
        for(PricebookEntry pbe: [SELECT Id,Product2Id,Pricebook2Id, Pricebook2.Name, UnitPrice,IsActive
                                 FROM PricebookEntry 
                                 WHERE Product2Id = :newRecords AND Pricebook2.Name = 'Standard Price Book'
                                ]) {
                                    pbeByProductId.put(pbe.Product2Id, pbe);
                                }
        for(Product2 product : newRecords){
            PricebookEntry pe = pbeByProductId.get(product.Id);
            if(pe != null) {
                if(product.Prix_de_vente_tarif_T2__c != null){
                    pe.UnitPrice = product.Prix_de_vente_tarif_T2__c;
                    pe.IsActive = true;
                }
            }
        }
        update pbeByProductId.values();
    }
    
	/**
     * @description : Création de PricebookEntry Standard
     * @parameter : Product
	*/
    public static void createPricebookEntry(List<Product2> newRecords){
        List<PricebookEntry> maListePricebookEntry = new List<PricebookEntry>(); 
        Id standardPriceBookId  = Test.isRunningTest()
                                ? Test.getStandardPricebookId()
                                : [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1]?.Id;
        for (Product2 product : newRecords) {
            maListePricebookEntry.add(new PricebookEntry(
                Pricebook2Id = standardPriceBookId,
                Product2Id = product.Id,
                UnitPrice = (product.Prix_de_vente_tarif_T2__c != null)? product.Prix_de_vente_tarif_T2__c: 0,
                UseStandardPrice = false,
                IsActive = true));
                }
        Database.upsert(maListePricebookEntry, false);
    }
    
    /*** 
     * @descritpion : trigger for guest Policy add and remove product according to field "Niveau_d_assortiment__c" of product
     * @parameter : list of Product
	*/
    public static void checkAssortimentForGuestPolicy(List<Product2> newRecords){
        List<Product2> listProductToAddGuestPolicy = new List<Product2>();
        List<Product2> listProductToDeleteGuestPolicy = new List<Product2>();
        
        for (Product2 product: newRecords){
            if(product.Niveau_d_assortiment__c == '1' || product.Niveau_d_assortiment__c == '2' || product.Niveau_d_assortiment__c == '3' 
               || product.Niveau_d_assortiment__c == '4' || product.Niveau_d_assortiment__c == '5' || product.Niveau_d_assortiment__c == '6'){
                   //Ajout dans la policy Guest des produits nationaux si produit national (assortiment 1 à 6)
                   listProductToAddGuestPolicy.add(product);
               } else {
                //suppression dans la policy Guest les produits nationaux si produit non national (assortiment autre 1 à 6)
                   listProductToDeleteGuestPolicy.add(product);
               }
        }
        if(!listProductToAddGuestPolicy.isEmpty()){
                addInGuestPolicy(listProductToAddGuestPolicy);
        }
        if(!listProductToDeleteGuestPolicy.isEmpty()){
            deleteToGuestPolicy(listProductToDeleteGuestPolicy);
        }
    }
    
    public static void addInGuestPolicy(List<Product2> newRecords) {
        Set<Id> productIdsInGuestPolicy = new Set<Id>();
       	List<CommerceEntitlementProduct> listToAddGuestPolicy = new List<CommerceEntitlementProduct>();
        List<CommerceEntitlementProduct> entitlementProducts = [
                SELECT ProductId, Product.Name, Name, PolicyId, Policy.Name, Policy.Libelle_Etablissement__c
                FROM CommerceEntitlementProduct
                WHERE ProductId =:newRecords AND Policy.Name =: GUEST_POLICY_NAME
        ];

        for(CommerceEntitlementProduct cep: entitlementProducts) {
            productIdsInGuestPolicy.add(cep.ProductId);
		}
        
        List<CommerceEntitlementPolicy> CEPolicy = [SELECT Id,IsActive, Name,  Libelle_Etablissement__c  FROM CommerceEntitlementPolicy WHERE Name =: GUEST_POLICY_NAME FOR UPDATE];
        
        for (Product2 product : newRecords) {
            if(!productIdsInGuestPolicy.contains(product.Id)) {
                listToAddGuestPolicy.add(new CommerceEntitlementProduct(ProductId = product.Id, PolicyId = CEPolicy.get(0).Id));
            }
        }
        if (!listToAddGuestPolicy.isEmpty()) {
            Database.insert(listToAddGuestPolicy, false);
        }
    }
    
    public static void deleteToGuestPolicy(List<Product2> newRecords){
        List<CommerceEntitlementProduct> cEProducts = [
                SELECT Id
                FROM CommerceEntitlementProduct
                WHERE ProductId =:newRecords and Policy.Name =: GUEST_POLICY_NAME
        ];
       	if(!cEProducts.isEmpty()){
            delete cEProducts;
        }
    }

    public void addProductsToCategories(List<Product2> products){
        List<ProductCategoryProduct> prodCateProd = getProductsCategoriesTemplate(products);
        if(!prodCateProd.isEmpty()){
            insert prodCateProd;
        }
        }

    /** addProductsToCategories is called in ProductTrigger while addProductsToCategories_Batch is called in ProductTrigger_Batch, the
     * reason why, is to avoid rolling back all transaction in case of batch execution and to have the error message visible in case of a creation in SF
    */
    public void addProductsToCategories_Batch(List<Product2> products){
        List<ProductCategoryProduct> prodCateProd = getProductsCategoriesTemplate(products);
        if(!prodCateProd.isEmpty()){
            Database.upsert(prodCateProd, false);
        }
    }

    private static List<ProductCategoryProduct> getProductsCategoriesTemplate(List<Product2> products){
        List<ProductCategoryProduct> prodCateProd = new List<ProductCategoryProduct>();
        Map<String,ProductCategory> prodCategoryMap = getProductCategoriesMap();

        for(Product2 prod : products) {
            Boolean isProductAddedToCategory = false;
            if((prodCategoryMap!=null || !prodCategoryMap.isEmpty()) ){
                if(!String.isBlank(prod.Code_departement__c)){
                    String key = DEPARTEMENT + prod.Code_departement__c;
                    if(prodCategoryMap.containsKey(key)){
                        prodCateProd.add(new ProductCategoryProduct(ProductCategoryId = prodCategoryMap.get(key).Id, ProductId = prod.Id));
                        isProductAddedToCategory = true;
                    }
                }
                if(!String.isBlank(prod.Code_rayon__c)){
                    String key = RAYON + prod.Code_rayon__c;
                    if(prodCategoryMap.containsKey(key)){
                        prodCateProd.add(new ProductCategoryProduct(ProductCategoryId = prodCategoryMap.get(key).Id, ProductId = prod.Id));
                        isProductAddedToCategory = true;
                    }
                }
                if(!String.isBlank(prod.Code_famille__c)){
                    String key = FAMILLE + prod.Code_famille__c;
                    if(prodCategoryMap.containsKey(key)){
                        prodCateProd.add(new ProductCategoryProduct(ProductCategoryId = prodCategoryMap.get(key).Id, ProductId = prod.Id));
                        isProductAddedToCategory = true;
                    }
                }
                if(!String.isBlank(prod.Code_sous_famille__c)){
                    String key = SOUS_FAMILLE + prod.Code_sous_famille__c;
                    if(prodCategoryMap.containsKey(key)){
                        prodCateProd.add(new ProductCategoryProduct(ProductCategoryId = prodCategoryMap.get(key).Id, ProductId = prod.Id));
                        isProductAddedToCategory = true;
        }
    }
            }
        }
        return prodCateProd;
    }

    private static Map<String, ProductCategory> getProductCategoriesMap(){
        Cache.OrgPartition categoryPartition = Cache.Org.getPartition('local.CategoryCache');
        String partitionkKey = 'categoryList';
        //Check if Category list exists in org partition
        if (categoryPartition != null && categoryPartition.contains('categoryList')) {
            return (Map<String, ProductCategory>)categoryPartition.get(partitionkKey);
        }

        Map<String, ProductCategory> codeVsProdCategory = new Map<String, ProductCategory>();
        List<ProductCategory> prodCategories = [Select Id, Name, Type_de_categorie__c, Code_categorie__c from ProductCategory where Category_External_Id__c != NULL];

        for(ProductCategory prodCategory : prodCategories){
            if(!String.isBlank(prodCategory.Type_de_categorie__c) && !String.isBlank(prodCategory.Code_categorie__c)){
                String key = buildCompositeKey(prodCategory.Type_de_categorie__c,prodCategory.Code_categorie__c);
                codeVsProdCategory.put(key,prodCategory);
            }
        }
        categoryPartition.put(partitionkKey, codeVsProdCategory);
        return codeVsProdCategory;
    }

    private static String buildCompositeKey(String catType, String code){
        return catType + code;
    }

    /*******************************************************************************************************************
    * @description      method to populate Libell Final field with a correct value
    * @param            newProducts (List<Product2>): list of product records with the latest data
    *******************************************************************************************************************/
    public static void populateLibellFinalField(List<Product2> newProducts) {
        if(newProducts == null) {
            return;
        }
        for(Product2 newProduct : newProducts) {
            getCorrectLabelForLibellFinalField(newProduct);
        }
    }

    /*******************************************************************************************************************
    * @description      helper method to populate Libell Final field with a correct value
    * @param            newProduct (Product2): product record with the latest data
    *******************************************************************************************************************/
    private static void getCorrectLabelForLibellFinalField(Product2 newProduct) {
        List<SObjectField> viableFields = new List<SObjectField>{
                Product2.Libelles_Data_Load__c,
                Product2.Libelle_fournisseur__c,
                Product2.Libelle_commercial__c,
                Product2.Name
        };
        for (SObjectField field : viableFields) {
            String newValue = (String) newProduct.get(field);
            if (String.isNotBlank(newValue)) {
                newProduct.Libell_Final_TA__c = newValue;
                break;
            }
        }
    }
}