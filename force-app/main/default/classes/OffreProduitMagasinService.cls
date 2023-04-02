/**
* @author : Maud Vasseur - IBM Lille
* @date : 11/2020
* @description : Classe de service de l'objet OffreProduitMagasin
* @TestClass : OffreProduitMagasinService_TST
**/

public with sharing class OffreProduitMagasinService {
    Boolean prixVenteActif;
    
    public List<Offre_Produit_Magasin__c> filterOPMs (List<Offre_Produit_Magasin__c> newRecords, Map<Id,Offre_Produit_Magasin__c> oldRecords) {
       List<Offre_Produit_Magasin__c> filteredRecords = new List<Offre_Produit_Magasin__c>();
       for (Offre_Produit_Magasin__c newRecord : newRecords) {
           Offre_Produit_Magasin__c oldRecord = oldRecords.get(newRecord.Id);
           if((oldRecord.Niveau_de_stock__c != newRecord.Niveau_de_stock__c) 
                || (oldRecord.En_cours_de_commande__c != newRecord.En_cours_de_commande__c)
                || (oldRecord.Prix_de_vente_magasin__c != newRecord.Prix_de_vente_magasin__c)
                || (oldRecord.Produit_actif__c != newRecord.Produit_actif__c)
                || (oldRecord.Actif_Aquilon__c != newRecord.Actif_Aquilon__c)
             	|| (oldRecord.Rupture_entrepot1__c != newRecord.Rupture_entrepot1__c)){
                filteredRecords.add(newRecord);
           }
       }
       return filteredRecords;
   }
    
    //Permet de déclencher le trigger Flux des prix en fonction de la modification de certains champs
	//Le trigger sera déclenché si l'ancienne valeur et la nouvelle valeur des champs ci-dessous sont différentes
    public List<Offre_Produit_Magasin__c> filterOPMsPriceAndPrixSpecifiques (List<Offre_Produit_Magasin__c> newRecords, Map<Id,Offre_Produit_Magasin__c> oldRecords) {
       List<Offre_Produit_Magasin__c> filteredRecords = new List<Offre_Produit_Magasin__c>();
       for (Offre_Produit_Magasin__c newRecord : newRecords) {
           Offre_Produit_Magasin__c oldRecord = oldRecords.get(newRecord.Id);
           if((oldRecord.Conditionnement_de_vente_bloque__c != newRecord.Conditionnement_de_vente_bloque__c)
             || (oldRecord.Quantite_minimum_de_commande__c != newRecord.Quantite_minimum_de_commande__c)
             || (oldRecord.Vente_au_PCB_Magasin__c != newRecord.Vente_au_PCB_Magasin__c)
             || (oldRecord.Conditionnement_de_vente_magasin__c != newRecord.Conditionnement_de_vente_magasin__c)
             || (oldRecord.Prix_de_vente_magasin__c != newRecord.Prix_de_vente_magasin__c)
             || (oldRecord.Niveau_de_stock__c != newRecord.Niveau_de_stock__c)
             || (oldRecord.En_cours_de_commande__c != newRecord.En_cours_de_commande__c)){
                filteredRecords.add(newRecord);
           }
       }
       return filteredRecords;
   }
    
    public List<Prix_specifiques__c> getPrixSpecifiquesForPricebook(List<Offre_Produit_Magasin__c> newRecords) {
        List<Prix_specifiques__c> listPrixSpecifiques = [
            SELECT Id, 
			Produit__c,
            Libelle_etablissement__c,
            Conditionnement_de_vente_produit__c,
            Prix_de_vente_au_conditionnement__c,
            Produit__r.Prix_de_vente_tarif_T2__c,
            Produit__r.Prix_de_vente_tarif_T3__c,
            Offre_Produit_Magasin__c,
            Reference_client__c
            FROM Prix_specifiques__c 
            WHERE Offre_Produit_Magasin__c = :newRecords
		];
        return listPrixSpecifiques;
    }

    public Map<Id,List<Prix_specifiques__c>> MapLastValidePrixSpecifiquesForPricebook(List<Offre_Produit_Magasin__c> newRecords) {
        List<Prix_specifiques__c> listPrixSpecifiques = new List<Prix_specifiques__c>();
        

            listPrixSpecifiques.addAll([
                SELECT Id, 
                Prix_de_vente_au_conditionnement__c,
                Offre_Produit_Magasin__c,
                Offre_Produit_Magasin__r.Magasin__c,
                Offre_Produit_Magasin__r.Magasin__r.Name,
                Reference_client__c,
                Produit__c,
                Reference_client__r.Name
                FROM Prix_specifiques__c 
                WHERE Offre_Produit_Magasin__c in :newRecords
                AND Date_de_debut_d_application__c <= Today
                AND Date_de_fin_d_application__c >= Today 
            ]);
        
        Map<Id,List<Prix_specifiques__c>> prixSpecifiquesMap = new Map<Id,List<Prix_specifiques__c>>();
        for(Prix_specifiques__c pspe : listPrixSpecifiques){
            if(prixSpecifiquesMap.get(pspe.Offre_Produit_Magasin__c) == null){
                prixSpecifiquesMap.put(pspe.Offre_Produit_Magasin__c,new List<Prix_specifiques__c>());
            }
            prixSpecifiquesMap.get(pspe.Offre_Produit_Magasin__c).add(pspe);
        }
        return prixSpecifiquesMap;
    }
    
        /**
     * @description : Methode qui lance le flow produit
     * params : List of Offre_Produit_Magasin__c
     */ 
    public void startProductFlow(List<Offre_Produit_Magasin__c> OPM){
        //Added By Suliman
        Set<Id> OPMRelatedMagasins = new Set<Id>();
        Set<Id> OPMRelatedProducts = new Set<Id>();
        List<Offre_Produit_Magasin__c> opmToCheckInAcquilon = new List<Offre_Produit_Magasin__c>();
        List<Offre_Produit_Magasin__c> opmToCheckInAcquilonExtention = new List<Offre_Produit_Magasin__c>();

        List<Offre_Produit_Magasin__c> opmToDeactivate = new List<Offre_Produit_Magasin__c>();
        Map<Id, String> opmStatutMap = new Map<Id, String>();
        
        for(Offre_Produit_Magasin__c OPMLine: OPM){
            OPMRelatedMagasins.add(OPMLine.magasin__c);
            OPMRelatedProducts.add(OPMLine.Produit__c);
        }
        //Call calculateOPM_Prix_unite method to set OPM Prix/Unite
        calculateOPM_Prix_unite(OPMRelatedProducts, OPM);
        //Retrieve related CommerceEntitlementPolicy
        List<CommerceEntitlementPolicy> CEPolicy = [
            SELECT id,
            IsActive,
            name,
            Libelle_Etablissement__c
			FROM CommerceEntitlementPolicy 
			WHERE Libelle_Etablissement__c = :OPMRelatedMagasins FOR UPDATE
		];
        //Map CEPolicy & Magasin
        Map<String, CommerceEntitlementPolicy> CEPolicyMagasinMap = new Map<String, CommerceEntitlementPolicy>();
        for(CommerceEntitlementPolicy CEP : CEPolicy){
            CEPolicyMagasinMap.put(CEP.Libelle_Etablissement__c, CEP);
        }
        //Retrieve related CommerceEntitlementProduct
        List<CommerceEntitlementProduct> CEProducts = [
            SELECT productId, 
			product.name, 
			name, 
			policyId, 
			policy.name,
            policy.Libelle_Etablissement__c
			FROM CommerceEntitlementProduct 
			WHERE productId = :OPMRelatedProducts and policy.Libelle_Etablissement__c = :OPMRelatedMagasins FOR UPDATE
		];
        //Map CEProduct & Magasin
        Map<String, CommerceEntitlementProduct> CEProductMagasinMap = new Map<String, CommerceEntitlementProduct>();
        for(CommerceEntitlementProduct CEProduct : CEProducts){
            String key = CEProduct.productId + '' + CEProduct.policy.Libelle_Etablissement__c;
            CEProductMagasinMap.put(key, CEProduct);
        }
        //END Added By Suliman
        System.debug('Début du flow');
        for(Offre_Produit_Magasin__c OPMrecord: OPM){
            //Verification si produit actif
            if(OPMrecord.Produit_actif__c == 'N'){ //todo: what should be the behaviour if Produit_actif__c will be different from 'O' or 'N'? e.g. NULL or any other value (added in the future)?
                opmToDeactivate.add(OPMrecord);
                opmStatutMap.put(OPMrecord.Id, '5');
            } else if(OPMrecord.Produit_actif__c == 'O'){
                //Vérification si le produit est avec assortiment
                if(OPMrecord.Produit_avec_assortiment_text__c == '1' || OPMrecord.Produit_avec_assortiment_text__c == '2' || OPMrecord.Produit_avec_assortiment_text__c == null){ //todo: what should be the behaviour if Produit_avec_assortiment_text__c will be different from '0, '1', '2', NULL? 
                    checkExistingPrices(OPMrecord);
                    if(prixVenteActif == false){
                        opmToDeactivate.add(OPMrecord);
                        opmStatutMap.put(OPMrecord.Id, '5');
                    } else {
                        opmToCheckInAcquilon.add(OPMrecord);
                    }
            	} else if(OPMrecord.Produit_avec_assortiment_text__c == '0'){
                    //Vérification si produit en extension de gamme
                    if(OPMrecord.Produit_en_extension_de_gamme__c == False || OPMrecord.Produit_en_extension_de_gamme__c == Null){
						checkExistingPrices(OPMrecord);
                        if(prixVenteActif == false){
                            opmToDeactivate.add(OPMrecord);
                            opmStatutMap.put(OPMrecord.Id, '5');
                    	} else {
                        	opmToCheckInAcquilon.add(OPMrecord);
                        }
					} else{
						checkExistingPrices(OPMrecord);
                        if(prixVenteActif == false && (OPMrecord.Code_departement__c == null || OPMrecord.Code_departement__c == '1' || OPMrecord.Code_departement__c == '2' || OPMrecord.Code_departement__c == '3' || OPMrecord.Code_departement__c == '5')){ //todo: what should be the behaviour if prixVenteActif = TRUE and Code_departement__c will be different from '0', '1', '2', '3', '4', '5'? e.g. NULL or any other value (added in the future)?
                            opmToDeactivate.add(OPMrecord);
                            opmStatutMap.put(OPMrecord.Id, '5');
                    	} else if(prixVenteActif == false && OPMrecord.Code_departement__c == '4'){
                            // cas du pole frais - possible qu'il n'y ait pas de prix
                            opmToCheckInAcquilonExtention.add(OPMrecord);
                        } else if(prixVenteActif == true){
                            opmToCheckInAcquilonExtention.add(OPMrecord);
                        }
                    }
        		}
    		}
        }
        
        if(!opmToCheckInAcquilon.isEmpty()) {
            checkExistInAquilonBulk(opmToCheckInAcquilon, CEPolicyMagasinMap, CEProductMagasinMap);
        }
        if(!opmToCheckInAcquilonExtention.isEmpty()) {
            checkExistInAquilonIfExtensionBulk(opmToCheckInAcquilonExtention, CEPolicyMagasinMap, CEProductMagasinMap);
        }
        if(!opmToDeactivate.isEmpty()) {
            deactivateProductBulk(opmToDeactivate, opmStatutMap, CEProductMagasinMap);
        }
        System.debug('Fin du flow');
    }
    
    //Calculate the OPM Prix / unite (This method is replace the Process Builder OPM Prix / unite)
    private void calculateOPM_Prix_unite(Set<ID> productsID, List<Offre_Produit_Magasin__c> OPMList){
        //Retrieve the related product
        Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, Unite_de_mesure__c, Contenance__c FROM Product2 WHERE Id =: productsID]);
        //Calculate Prix_unite__c field
        if (OPMList.size()>0 && productsMap.size()>0) {
            for (Offre_Produit_Magasin__c opm : OPMList) {
                if (productsMap.get(opm.Produit__c) != null) {
                    if(opm.Prix_de_vente_magasin__c != null && productsMap.get(opm.Produit__c).Unite_de_mesure__c == 'U'){
                        opm.Prix_unite__c  = opm.Prix_de_vente_magasin__c / Decimal.valueOf(productsMap.get(opm.Produit__c).Contenance__c);
                    } else if (opm.Prix_de_vente_magasin__c == null && productsMap.get(opm.Produit__c).Unite_de_mesure__c == 'U'){
                        opm.Prix_unite__c  = opm.Ref_tarifaire_magasin__c / Decimal.valueOf(productsMap.get(opm.Produit__c).Contenance__c);
                    } else {
                        opm.Prix_unite__c  = null;
                    }
                }
            }
        }
    }
    
    /**
     * @description : Fonction de désactivation des produits (retire le produit dans les Entitlement policies)
     * @parameter : Offre produit magasin + Statut à assigner à l'offre (voir champ statut sur l'objet Offre produit Magasin)
     */ 
    private void deactivateProductBulk(List<Offre_Produit_Magasin__c> opmList, Map<Id, String> opmStatutMap, Map<String, CommerceEntitlementProduct> CommerceEntitlementProductMap){
        system.debug('deactivateProduct : ');
        List<CommerceEntitlementProduct> CommerceEntitlementProductToDelete = new List<CommerceEntitlementProduct>();
        
        for(Offre_Produit_Magasin__c opm: opmlist) {
            String key = opm.Produit__c + '' + opm.magasin__c;
            CommerceEntitlementProduct cme = CommerceEntitlementProductMap.get(key);
            if(cme != null)
                CommerceEntitlementProductToDelete.add(cme);
            opm.statut__c = opmStatutMap.get(opm.Id);
        }
        
        if(!CommerceEntitlementProductToDelete.isEmpty()){
            delete CommerceEntitlementProductToDelete;
        }
    }
    
    /**
     * @description BULK VERSION : Fonction d'activation des produits (ajout du produit dans les Entitlement policies)
     * @parameter : Offre produit magasin + Statut à assigner à l'offre (voir champ statut sur l'objet Offre produit Magasin)
     */ 
    private void activateProductBulk(List<Offre_Produit_Magasin__c> opmList, Map<Id, String> opmStatutMap, Map<String, CommerceEntitlementPolicy> commerceEntitlementPolicyMap, Map<String, CommerceEntitlementProduct> CommerceEntitlementProductMap){
        system.debug('activateProduct : ');
        Set<Id> productsIds = new Set<Id>();
        Set<Id> magasinsIds = new Set<Id>();
        for(Offre_Produit_Magasin__c opm: opmList) {
            productsIds.add(opm.produit__c);
            magasinsIds.add(opm.magasin__c);
        }
        
        List<CommerceEntitlementProduct> ceProductsToCreate = new List<CommerceEntitlementProduct>();

        for (Offre_Produit_Magasin__c opm: OPMList) {
            String key = opm.Produit__c + '' + opm.magasin__c;
            if(CommerceEntitlementProductMap.get(key) == null && commerceEntitlementPolicyMap.get(opm.Magasin__c) != null && opm.produit__c != null) {
                CommerceEntitlementProduct cep = new CommerceEntitlementProduct(productId = opm.produit__c, policyId = commerceEntitlementPolicyMap.get(opm.magasin__c).Id);
                ceProductsToCreate.add(cep);
            }
        }
        if(!ceProductsToCreate.isEmpty())
            upsert ceProductsToCreate;
        
        for(Offre_Produit_Magasin__c opm: opmList) {
            opm.statut__c = opmStatutMap.get(opm.Id);
        }
    }
    
    
    /**
     * @description : Fonction de vérification de la présence de prix et de rang tarifaire - Met à jour la variable prixVenteActif
     * @parameter : Offre produit magasin 
     */ 
	private void checkExistingPrices(Offre_Produit_Magasin__c OPMrecord){
		if(OPMrecord.Prix_de_vente_magasin__c == null || OPMrecord.Prix_de_vente_magasin__c == 0){
			if(OPMrecord.Rang_tarifaire__c == 'T2'){
                if(OPMrecord.Prix_de_vente_tarif_T2__c == null || OPMrecord.Prix_de_vente_tarif_T2__c == 0){
                    prixVenteActif = false;
                } else {
                    prixVenteActif = true;
                }
			} else if(OPMrecord.Rang_tarifaire__c == 'T3'){
                if(OPMrecord.Prix_de_vente_tarif_T3__c == null || OPMrecord.Prix_de_vente_tarif_T3__c == 0){
                    prixVenteActif = false;
                } else {
                    prixVenteActif = true;
                }
			}
        } else if(OPMrecord.Prix_de_vente_magasin__c > 0){
            prixVenteActif = true;
        }
    }

    /**
     * @description : Fonction de vérification de produit actif dans Aquilon (Produit pas en extension de gamme)
     * @parameter : Offre produit magasin 
*/
    private void checkExistInAquilonBulk(List<Offre_Produit_Magasin__c> opmList, Map<String, CommerceEntitlementPolicy> commerceEntitlementPolicyMap, Map<String, CommerceEntitlementProduct> CommerceEntitlementProductMap){
        List<Offre_Produit_Magasin__c> opmToActivate = new List<Offre_Produit_Magasin__c>();
        List<Offre_Produit_Magasin__c> opmToDeactivate = new List<Offre_Produit_Magasin__c>();
        Map<Id, String> opmStatutMap = new Map<Id, String>();
        
        for(Offre_Produit_Magasin__c opm: opmList) {
            //Vérifie si produit actif dans Aquilon
            if(!opm.Actif_Aquilon__c){
                //deactivateProduct(OPMrecord, '5', RelatedCEProd);
                opmToDeactivate.add(opm);
                opmStatutMap.put(opm.Id, '5');
            } else {
                // Si produit actif dans Aquilon, on vérifie la quantité de stock pour mettre à jour la disponibilité avec le statut de l'offre
                //checkStockAndEnCours(OPMrecord);
                Decimal stockEnCrs = Utilities.checkStockAndEnCoursBulk(opm);
                if(stockEnCrs <= 0 ){
                    //deactivateProduct(OPMrecord, '5', RelatedCEProd);
                    opmToDeactivate.add(opm);
                    opmStatutMap.put(opm.Id, '5');
                } else {
                    //activateProduct(OPMrecord, '3', RelatedCEP);
                    opmToActivate.add(opm);
                    opmStatutMap.put(opm.Id, '3');
                }
            } 
        }
        
        if(!opmToActivate.isEmpty())
            activateProductBulk(opmToActivate, opmStatutMap, commerceEntitlementPolicyMap, CommerceEntitlementProductMap);
        
        if(!opmToDeactivate.isEmpty()) {
            deactivateProductBulk(opmToDeactivate, opmStatutMap, CommerceEntitlementProductMap);
        }        
    }
    
    /**
     * @description : Fonction de vérification de produit actif dans Aquilon (Produit en extension de gamme)
     * @parameter : Offre produit magasin 
     */
    private void checkExistInAquilonIfExtensionBulk(List<Offre_Produit_Magasin__c> opmList, Map<String, CommerceEntitlementPolicy> commerceEntitlementPolicyMap, Map<String, CommerceEntitlementProduct> CommerceEntitlementProductMap){
        List<Offre_Produit_Magasin__c> opmToActivate = new List<Offre_Produit_Magasin__c>();
        List<Offre_Produit_Magasin__c> opmToDeactivate = new List<Offre_Produit_Magasin__c>();
        Map<Id, String> opmStatutMap = new Map<Id, String>();
        system.debug('----- checkExistInAquilonIfExtensionBulk');
        for(Offre_Produit_Magasin__c opm: opmList) {
            Decimal stckEnCours = Utilities.checkStockAndEnCoursBulk(opm);
            if(!opm.Actif_Aquilon__c){
                //cas impossible mais demande d'action par le client
                if(stckEnCours > 0 ){
                    opmStatutMap.put(opm.Id, '1');
                    opmToActivate.add(opm);
                } else if(stckEnCours <= 0 ){
                    // /!\ Rupture entrepot = true => disponible en entrepot
                    // /!\ Rupture entrepot = false => non disponible en entrepot
                    if(opm.Rupture_entrepot1__c){
                        if(opm.Extension_de_gamme__c == 'oui'){ //todo: what should be the behaviour if Extension_de_gamme__c will be different from 'oui' or 'non'? e.g. NULL or any other value (added in the future)?
                            opmStatutMap.put(opm.Id, '2');
                            opmToActivate.add(opm);
                        }else if(opm.Extension_de_gamme__c == 'non'){
                            opmStatutMap.put(opm.Id, '5');
                            opmToDeactivate.add(opm);
                        }
                    } else{ 
                        opmStatutMap.put(opm.Id, '4');
                        opmToDeactivate.add(opm);
                    }
                }
            } else{ 
                if(stckEnCours > 0 ){
                    if(opm.Rupture_entrepot1__c){
                        opmStatutMap.put(opm.Id, '1');
                        opmToActivate.add(opm);
                    } else {
                        opmStatutMap.put(opm.Id, '3');
                        opmToActivate.add(opm);
                    }
                } else {
                    // /!\ Rupture entrepot = true => disponible en entrepot
                    // /!\ Rupture entrepot = false => non disponible en entrepot
                    if(opm.Rupture_entrepot1__c){
                        if(opm.Extension_de_gamme__c == 'oui'){ //todo: what should be the behaviour if Extension_de_gamme__c will be different from 'oui' or 'non'? e.g. NULL or any other value (added in the future)?
                            opmStatutMap.put(opm.Id, '2');
                            opmToActivate.add(opm);
                        }else if(opm.Extension_de_gamme__c == 'non'){
                            opmStatutMap.put(opm.Id, '5');
                            opmToDeactivate.add(opm);
                        }
                    } else {
                        opmStatutMap.put(opm.Id, '4');
                        opmToDeactivate.add(opm);
                    }
                }
            }
        }
        
        if(!opmToActivate.isEmpty())
            activateProductBulk(opmToActivate, opmStatutMap, commerceEntitlementPolicyMap, CommerceEntitlementProductMap);
        if(!opmToDeactivate.isEmpty())
            deactivateProductBulk(opmToDeactivate, opmStatutMap, CommerceEntitlementProductMap);
    }

	/**
     * @description : Rattache le pricebook Standard du magasin de l'OPM au produit et crée l'entry avec le prix de l'OPM 
     * (Prix de vente au conditionnement par défaut sinon prix T2 ou T3)
     * @parameter : Offre produit magasin 
     */    
    public void createPriceBook(List<Offre_Produit_Magasin__c> newRecords){
        List<PricebookEntry> maListePricebookEntry = new List<PricebookEntry>();
        Set<String> listNomMagasin = new Set<String>();
        Map<String, Pricebook2> priceBookByMagasinName = new Map<String, Pricebook2>();
        Set<Id> setOfIds = new Set<Id>();
        
        for(Offre_Produit_Magasin__c opm : newRecords) {
            setOfIds.add(opm.Magasin__c);
        }
        
        Map<ID, magasin__c> magasinMap = new Map<ID, magasin__c>([SELECT id, name FROM magasin__c where Id in: setOfIds]);
        
        for(Offre_Produit_Magasin__c OPMRecord : newRecords){
            String priceBookName = 'Standard PMC ' + magasinMap.get(OPMRecord.Magasin__c).Name;
            listNomMagasin.add(priceBookName);
        }
        for(Pricebook2 priceBook : [SELECT Id, Name FROM Pricebook2 WHERE Name = :listNomMagasin]){
            priceBookByMagasinName.put(priceBook.Name, priceBook);
        }
        for(Offre_Produit_Magasin__c OPMRecord : newRecords){
            String priceBookName = 'Standard PMC ' + magasinMap.get(OPMRecord.Magasin__c).Name;
            Pricebook2 magasinPriceBook = priceBookByMagasinName.get(priceBookName);
            Decimal unitPrice;
            
            if(OPMRecord.Prix_de_vente_magasin__c != null && OPMRecord.Prix_de_vente_magasin__c != 0 && OPMRecord.Produit__c != null){
                unitPrice = OPMRecord.Prix_de_vente_magasin_au_conditionnement__c;
            } else {
                if(OPMRecord.Ref_tarifaire_magasin__c != null && OPMRecord.Ref_tarifaire_magasin__c != 0  && OPMRecord.Produit__c != null){
                    if(OPMRecord.Rang_tarifaire__c == 'T2'){
                        unitPrice = OPMRecord.Prix_T2_au_conditionnement_de_vente__c;
                    } else if(OPMRecord.Rang_tarifaire__c == 'T3'){
                        unitPrice = OPMRecord.Prix_T3_au_conditionnement_de_vente__c;
                    }
                }
            }
            if(unitPrice != null && magasinPriceBook != null)
                maListePricebookEntry.add(new PricebookEntry(
                    Pricebook2Id = magasinPriceBook.Id,
                    Product2Id = OPMRecord.Produit__c,
                    UnitPrice = unitPrice,
                    UseStandardPrice = false,
                    IsActive = true
                ));
        }
        if(!maListePricebookEntry.isEmpty())
            Database.upsert(maListePricebookEntry, false);
    }
    
    /**
     * @description : Modifie l'entry du produit du pricebook Standard Magasin à partir du prix OPM 
     * (Prix de vente au conditionnement par défaut sinon prix T2 ou T3)
     * @parameter : Offre produit magasin 
     */
	public void updatePriceBooksOPM(List<Offre_Produit_Magasin__c> opms) {
        Map<Id, Offre_Produit_Magasin__c> opmsByProduct = new Map<Id, Offre_Produit_Magasin__c>();
        Set<Id> magasinIds = new Set<Id>();
        for (Offre_Produit_Magasin__c opm : opms) {
            opmsByProduct.put(opm.Produit__c, opm);
            magasinIds.add(opm.Magasin__c);
        }
        
        List<Magasin__c> magasins = [
            SELECT Id, Name 
            FROM Magasin__c 
            WHERE Id IN :magasinIds];
        
        Set<String> magasinNames = new Set<String>();
        
        for (Magasin__c magasin : magasins) {
             magasinNames.add('Standard PMC ' + magasin.Name);
        }
        
        List<PricebookEntry> pricebookEntries = [
           SELECT Id, name, Pricebook2Id, Product2Id, UnitPrice, IsActive
           FROM PricebookEntry
           WHERE Pricebook2.Name IN :magasinNames 
           AND Product2Id IN :opmsByProduct.keySet()
        ];
        
        for (PricebookEntry pbe : pricebookEntries) {
            Offre_Produit_Magasin__c opm = opmsByProduct.get(pbe.Product2Id);
            if (opm.Prix_de_vente_magasin__c != null && opm.Prix_de_vente_magasin__c != 0){
               pbe.UnitPrice = opm.Prix_de_vente_magasin_au_conditionnement__c;
               pbe.IsActive = true;
            } else {
                if (opm.Code_departement__c == '4' && opm.Statut__c == '2') {
                    pbe.IsActive = false;
                    
                } else {
                    if (opm.Ref_tarifaire_magasin__c != null && opm.Ref_tarifaire_magasin__c != 0) {
                        if (opm.Rang_tarifaire__c == 'T2') {
                            pbe.UnitPrice = opm.Prix_T2_au_conditionnement_de_vente__c;
                            pbe.IsActive = true;
                        } else if (opm.Rang_tarifaire__c == 'T3') {
                            pbe.UnitPrice = opm.Prix_T3_au_conditionnement_de_vente__c;
                            pbe.IsActive = true;   
                        }
                    } else if (opm.Ref_tarifaire_magasin__c == null || opm.Ref_tarifaire_magasin__c == 0) {
                       pbe.IsActive = false;
                    }
                }
           }  	
       }
       Database.SaveResult[] srList = Database.update(pricebookEntries, false);
   }
    
    /**
     * @description : Modifie l'entry du produit du pricebook Standard Magasin à partir du prix OPM et du prix specifique
     * (prix specifique par defaut sinon Prix de vente au conditionnement sinon prix T2 ou T3)
     * @parameter : Offre produit magasin 
     */
	public void updatePriceBooksOPMWithSpe(List<Offre_Produit_Magasin__c> opms) {
        Map<Id,List<Prix_specifiques__c>> prixSpecifiquesMap = MapLastValidePrixSpecifiquesForPricebook(opms);
        Map<Id, Offre_Produit_Magasin__c> opmsByProduct = new Map<Id, Offre_Produit_Magasin__c>();
        Set<Id> magasinIds = new Set<Id>();
        for (Offre_Produit_Magasin__c opm : opms) {
            opmsByProduct.put(opm.Produit__c, opm);
            magasinIds.add(opm.Magasin__c);
        }
        System.debug('===>'+opmsByProduct+' ==== '+magasinIds);
        List<Magasin__c> magasins = [
            SELECT Id, Name 
            FROM Magasin__c 
            WHERE Id IN :magasinIds];

        List <Account> accList = [SELECT Id, Name, Magasin_actif_en_cours__c FROM Account WHERE Magasin_actif_en_cours__c in :magasinIds ];
        Map<Id,String> MapAccount = new Map<Id,String>();
        for (Account acc:accList){
            MapAccount.put(acc.Magasin_actif_en_cours__c,acc.Name); 
        }
        Set<String> magasinNames = new Set<String>();
        for (Magasin__c magasin : magasins) {
            magasinNames.add(MapAccount.get(magasin.Id)+' ' +magasin.Name);
        }

        Map<String, PricebookEntry> pbeByKey = new Map<String, PricebookEntry>();

        for(PricebookEntry priceBE : [SELECT Id, name, Pricebook2Id, Product2Id, UnitPrice, IsActive, Pricebook2.Name
                                        FROM PricebookEntry
                                        WHERE Pricebook2.Name IN :magasinNames 
                                        AND Product2Id IN :opmsByProduct.keySet()
                                    ]){
            String key = priceBE.Pricebook2.Name + priceBE.Product2Id; //Key = AccountName + ' ' + MagasinName + ProductId
            pbeByKey.put(key, priceBE);
        }

        for(Offre_Produit_Magasin__c opm : opmsByProduct.values()){
            List<Prix_specifiques__c> prixSpeList = prixSpecifiquesMap.get(opm.Id);
            if(prixSpeList != null){
                for(Prix_specifiques__c prixSpe : prixSpeList){
                    String key = MapAccount.get(prixSpe.Offre_Produit_Magasin__r.Magasin__c) + ' ' + prixSpe.Offre_Produit_Magasin__r.Magasin__r.Name + prixSpe.Produit__c;
                    PricebookEntry pbe = pbeByKey.get(key);
                    if(pbe == null)
                        continue;

                    if (prixSpe != null && prixSpe.Prix_de_vente_au_conditionnement__c != null && prixSpe.Prix_de_vente_au_conditionnement__c != 0){
                            pbe.UnitPrice = prixSpe.Prix_de_vente_au_conditionnement__c;
                            pbe.IsActive = true;
                        
                    }else{
                        if (opm.Prix_de_vente_magasin__c != null && opm.Prix_de_vente_magasin__c != 0){
                            pbe.UnitPrice = opm.Prix_de_vente_magasin_au_conditionnement__c;
                            pbe.IsActive = true;
                        } else {
                            if (opm.Code_departement__c == '4' && opm.Statut__c == '2') {
                                pbe.IsActive = false;
                                
                            } else {
                                if (opm.Ref_tarifaire_magasin__c != null && opm.Ref_tarifaire_magasin__c != 0) {
                                    if (opm.Rang_tarifaire__c == 'T2') {
                                        pbe.UnitPrice = opm.Prix_T2_au_conditionnement_de_vente__c;
                                        pbe.IsActive = true;
                                    } else if (opm.Rang_tarifaire__c == 'T3') {
                                        pbe.UnitPrice = opm.Prix_T3_au_conditionnement_de_vente__c;
                                        pbe.IsActive = true;   
                                    }
                                } else if (opm.Ref_tarifaire_magasin__c == null || opm.Ref_tarifaire_magasin__c == 0) {
                                pbe.IsActive = false;
                                }
                            }
                        }  	
                    }
                }
            }
        }
        
       Database.SaveResult[] srList = Database.update(pbeByKey.values(), false);

   }
    
    /**
     * @description : Cree ou modifie le PBE, Méthode utilisé dans "OpmTrigger_Batch"
     * @parameter : Offre produit magasin 
     */
    public void upsertPriceBooksOPM(List<Offre_Produit_Magasin__c> opms) {
        Map<Id, Offre_Produit_Magasin__c> opmsByProduct = new Map<Id, Offre_Produit_Magasin__c>();
        Map<String, PriceBook2> priceBookByMagasinName = new Map<String, PriceBook2>();
        String priceBookBaseName = 'Standard PMC ';
        Map<String, PricebookEntry> pbeByProductKey = new Map<String, PricebookEntry>();
        List<PricebookEntry> priceBookEntriesToUpsert = new List<PricebookEntry>();
        Set<String> priceBookNames = new Set<String>();
        Set<Id> priceBookIds = new Set<Id>();
        
        Set<Id> magasinIds = new Set<Id>();
        for (Offre_Produit_Magasin__c opm : opms) {
            String key = opm.Produit__c + '' + opm.Id;
            opmsByProduct.put(opm.Produit__c, opm);
            priceBookNames.add(priceBookBaseName + opm.Magasin__r.Name);
        }
        
        for(Pricebook2 pb : [SELECT Id, Name FROM Pricebook2 WHERE Name IN :priceBookNames]){
            String magasinName = pb.Name.remove(priceBookBaseName);
            priceBookByMagasinName.put(magasinName, pb);
            priceBookIds.add(pb.Id);
        }
        
        for(PricebookEntry pbe: [SELECT Id, Product2Id, UnitPrice, IsActive, Pricebook2.Name FROM PricebookEntry WHERE Product2Id IN :opmsByProduct.keySet() AND Pricebook2Id IN :priceBookIds]) {
            String magasinName = pbe.Pricebook2.Name.remove(priceBookBaseName);
            String key = pbe.Product2Id + '' + magasinName;
            pbeByProductKey.put(key, pbe);   
        }
        
        for(Offre_Produit_Magasin__c opm: opms) {
            String key = opm.Produit__c + '' + opm.Magasin__r.Name;
            PriceBook2 magasinPriceBook = priceBookByMagasinName.get(opm.Magasin__r.Name);
            if(magasinPriceBook == null)
                continue;
            PricebookEntry pbe = pbeByProductKey.get(key);
            if(pbe == null)  //PBE doit etre créé
                pbe = new PricebookEntry(
                    Pricebook2Id = magasinPriceBook.Id,
                    Product2Id = opm.Produit__c,
                    UseStandardPrice = false
                );
            if (opm.Prix_de_vente_magasin__c != null && opm.Prix_de_vente_magasin__c != 0){
                pbe.UnitPrice = opm.Prix_de_vente_magasin_au_conditionnement__c;
                pbe.IsActive = true;
            } else {
                if (opm.Code_departement__c == '4' && opm.Statut__c == '2') {
                    pbe.IsActive = false;
                    
                } else {
                    if (opm.Ref_tarifaire_magasin__c != null && opm.Ref_tarifaire_magasin__c != 0) {
                        if (opm.Rang_tarifaire__c == 'T2') {
                            pbe.UnitPrice = opm.Prix_T2_au_conditionnement_de_vente__c;
                            pbe.IsActive = true;
                        } else if (opm.Rang_tarifaire__c == 'T3') {
                            pbe.UnitPrice = opm.Prix_T3_au_conditionnement_de_vente__c;
                            pbe.IsActive = true;   
                        }
                    } else if (opm.Ref_tarifaire_magasin__c == null || opm.Ref_tarifaire_magasin__c == 0) {
                        pbe.IsActive = false;
                    }
                }
            }
            priceBookEntriesToUpsert.add(pbe);
        }
        Database.upsert(priceBookEntriesToUpsert, false);
    }
}