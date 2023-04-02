public without sharing class Utilities2 {
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                    'value' => f.getValue()
                    };
                        options.add(values);
        }
        system.debug('options :'+options);
        return options;
    }
    
    public static List<CartItem> calculatePromotion(List<CartItem> cartItemsExtract,  Map<String, Promotion__c> promotionMap){
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        for(CartItem cItem : cartItemsExtract){
            Promotion__c promo = promotionMap.get(cItem.Product2Id);
            if(promo != null){ 
                if(promo.Type_de_promotion__c == 'BRI'){
                    cItem.UnitAdjustmentAmount = promo.Remise_en_e__c;
                    cItem.UnitAdjustedPrice = promo.Prix_sous_mecanique__c;
                    cItem.TotalPrice =  promo.Prix_sous_mecanique__c * cItem.Quantity;   
                }
                else if(promo.Type_de_promotion__c == 'LVHO'){  
                    if(promo.Type_d_offre__c == 'Q'){
                        Integer notOnPromotion = math.mod(Integer.valueOf(cItem.Quantity) ,Integer.valueOf(promo.Quantite_minimum_de_commande__c)); 
                        cItem.UnitAdjustedPrice = promo.Prix_de_vente_promotion__c;
                        Decimal QuantityFree = (cItem.Quantity - notOnPromotion) / promo.Quantite_minimum_de_commande__c;
                        Decimal AjustmentAmountTotal = (cItem.Quantity * promo.Prix_de_vente_promotion__c) - (QuantityFree * promo.Prix_de_vente_promotion__c);  
                        cItem.AdjustmentAmount = - QuantityFree * promo.Prix_de_vente_promotion__c; 
                        cItem.TotalPrice  = AjustmentAmountTotal; 
                    }
                    else if(promo.Type_d_offre__c == 'P'){
                        Integer notOnPromotion = math.mod(Integer.valueOf(cItem.Quantity) ,Integer.valueOf(promo.Quantite_minimum_de_commande__c)); 
                        Decimal QuantityPromo = (cItem.Quantity - notOnPromotion) / promo.Quantite_minimum_de_commande__c; 
                        Decimal AjustmentAmountTotal = (cItem.Quantity * promo.Prix_de_vente_promotion__c) - (QuantityPromo *  ((promo.Remise_en_p__c/100) * promo.Prix_de_vente_promotion__c));
                        cItem.UnitAdjustedPrice = promo.Prix_de_vente_promotion__c;
                        cItem.AdjustmentAmount = - QuantityPromo * promo.Prix_de_vente_promotion__c; 
                        cItem.TotalPrice  = AjustmentAmountTotal;
                    }
                    else if(promo.Type_d_offre__c == 'M'){
                        cItem.UnitAdjustmentAmount = promo.Remise_en_e__c;
                        cItem.UnitAdjustedPrice = promo.Prix_sous_mecanique__c;
                        cItem.TotalPrice =  promo.Prix_sous_mecanique__c * cItem.Quantity;     
                    }  
                } else {
                    cItem.UnitAdjustmentAmount = promo.Prix_de_vente_promotion__c;
                    cItem.UnitAdjustedPrice = promo.Prix_sous_mecanique__c;
                    cItem.TotalPrice =  promo.Prix_sous_mecanique__c * cItem.Quantity;
                }
                
                cItem.TotalListPrice =  cItem.UnitAdjustedPrice * cItem.Quantity;  
                cItem.Promotion__c =  promo.Id;
                if(cItem.Product2.Vignette_alcool__c != null && cItem.Product2.Vignette_alcool__c >0 ){ 
                    cItem.UnitAdjustedPrice = cItem.UnitAdjustedPrice + cItem.Product2.Vignette_alcool__c;
                    cItem.TotalPrice = cItem.TotalPrice + (cItem.Product2.Vignette_alcool__c * cItem.Quantity);            
                } 
                cartItemsToUpdate.add(cItem);
            }  
        }
        return cartItemsToUpdate;
    }
    
    public static  List<Offre_produit_Magasin__c> getTwoSimilarProductsAndPrices(String productId, List<Offre_produit_Magasin__c> similarOPMs){
        
        List<Offre_produit_Magasin__c> similarOPMs1 = new List<Offre_produit_Magasin__c>();
        List<Offre_produit_Magasin__c> similarOPMs2 = new List<Offre_produit_Magasin__c>();
        List<Offre_produit_Magasin__c> similarOPMs3 = new List<Offre_produit_Magasin__c>();
        
        Offre_produit_Magasin__c OPM1;
        Offre_produit_Magasin__c OPM2;
        Offre_produit_Magasin__c initialOPM;
        
        //Sort the list for retrieve only my product and only products in status 1
        for (Offre_produit_Magasin__c opm : similarOPMs){
            if (opm.Produit__c == productId) { 
                initialOPM = opm;
                similarOPMs1.add(initialOPM);
                continue;
            }
            if(opm.Prix_de_vente_magasin__c == null || opm.Prix_de_vente_magasin__c == 0){
                opm.Prix_de_vente_magasin__c = opm.Ref_tarifaire_magasin__c;
            }
            if(opm.statut__c == '1' && opm.Prix_de_vente_magasin__c != 0){
                similarOPMs1.add(opm);
            }
        }
        
        //Find index of initial product in the list sorted ASC, to return 2 product with price closest - Return the products with index -1 or +1 compared to my product in the list
        //If my product is positioned index 0 or last index of the list, adapt the return position in OPM1 or OPM2
        //If the list with product in statut 1 does not have enough product to return, same processus with product in statut 2 or 3 in last time.
        Integer indexOPM = similarOPMs1.indexOf(initialOPM);
        System.debug('similarOPMs1: '+similarOPMs1);
        System.debug('indexOPM: '+indexOPM);
        System.debug('similarOPMs1.size(): '+similarOPMs1.size());
        if(similarOPMs1.size() >= 3){
            if(indexOPM == 0){
                OPM1 = similarOPMs1.get(indexOPM + 1);
                OPM2 = similarOPMs1.get(indexOPM + 2);
            } else if(indexOPM == (similarOPMs1.size()-1)){
                OPM1 = similarOPMs1.get(indexOPM - 1);
                OPM2 = similarOPMs1.get(indexOPM - 2);
            } else {
                OPM1 = similarOPMs1.get(indexOPM - 1);
                OPM2 = similarOPMs1.get(indexOPM + 1);
            }
        } else {
            if(similarOPMs1.size() == 2){
                if(indexOPM == 0){
                    OPM1 = similarOPMs1.get(indexOPM + 1);
                } else if(indexOPM == 1){
                    OPM1 = similarOPMs1.get(indexOPM - 1);
                }
            }
            // check there are product with Statut__c = 2 to suggest
            for (Offre_produit_Magasin__c opm : similarOPMs){
                if (opm.Produit__c == productId) { 
                    initialOPM = opm;
                    similarOPMs2.add(initialOPM);
                    continue;
                }
                if(opm.Prix_de_vente_magasin__c == null || opm.Prix_de_vente_magasin__c == 0){
                    opm.Prix_de_vente_magasin__c = opm.Ref_tarifaire_magasin__c;
                }
                if(opm.statut__c == '2' && opm.Prix_de_vente_magasin__c != 0){
                    similarOPMs2.add(opm);
                }
            }
            Integer indexOPM2 = similarOPMs2.indexOf(initialOPM);
            System.debug('similarOPMs2.size(): '+similarOPMs2.size());
            if(similarOPMs2.size() > 2){
                //If OPM1 has a value yet with a data product with statut 1, Retrieve only OPM2 with product statut 2 or 3
                if(similarOPMs1.size() == 2){                    
                    if(indexOPM2 == 0){
                        OPM2 = similarOPMs2.get(indexOPM2 + 1);
                    } else if(indexOPM2 == (similarOPMs2.size()-1)){
                        OPM2 = similarOPMs2.get(indexOPM2 - 1);
                    } else {
                        OPM2 = similarOPMs2.get(indexOPM2 + 1);
                    }
                } else if(similarOPMs1.size() < 2){
                    if(indexOPM2 == 0){
                        OPM1 = similarOPMs2.get(indexOPM2 + 1);
                        OPM2 = similarOPMs2.get(indexOPM2 + 2);
                    } else if(indexOPM2 == (similarOPMs2.size()-1)){
                        OPM1 = similarOPMs2.get(indexOPM2 - 1);
                        OPM2 = similarOPMs2.get(indexOPM2 - 2);
                    } else {
                        OPM1 = similarOPMs2.get(indexOPM2 - 1);
                        OPM2 = similarOPMs2.get(indexOPM2 + 1);
                        Integer i = 2;
                        while(OPM1.Prix_de_vente_magasin__c == 0){
                            OPM1 = similarOPMs.get(indexOPM + i);
                            i++;
                        }
                    }
                }
            } else {
                if(similarOPMs2.size() == 2){
                    if(similarOPMs1.size() == 1){
                        if(indexOPM2 == (similarOPMs2.size()-1)){
                            OPM1 = similarOPMs2.get(indexOPM2 - 1);
                        } else {
                            OPM1 = similarOPMs2.get(indexOPM2 + 1);
                        } 
                    } else if(similarOPMs1.size() == 2){
                        if(indexOPM2 == (similarOPMs2.size()-1)){
                            OPM2 = similarOPMs2.get(indexOPM2 - 1);
                        } else {
                            OPM2 = similarOPMs2.get(indexOPM2 + 1);
                        }
                    }
                } 
                // check there are product with Statut__c = 3 to suggest
                for (Offre_produit_Magasin__c opmBis : similarOPMs){
                    if (opmBis.Produit__c == productId) { 
                        initialOPM = opmBis;
                        similarOPMs3.add(initialOPM);
                        continue;
                    }
                    if(opmBis.Prix_de_vente_magasin__c == null || opmBis.Prix_de_vente_magasin__c == 0){
                        opmBis.Prix_de_vente_magasin__c = opmBis.Ref_tarifaire_magasin__c;
                    }
                    if(opmBis.statut__c == '3' && opmBis.Prix_de_vente_magasin__c != 0){
                        similarOPMs3.add(opmBis);
                    }
                }
                
                Integer indexOPM3 = similarOPMs3.indexOf(initialOPM);
                if(similarOPMs3.size() > 2){
                    if(similarOPMs2.size() == 2){
                        if(similarOPMs1.size() == 2){
                            if(indexOPM3 == 0){
                                OPM2 = similarOPMs3.get(indexOPM3 + 1);
                            } else if(indexOPM3 == (similarOPMs3.size()-1)){
                                OPM2 = similarOPMs3.get(indexOPM3 - 1);
                            } else {
                                OPM2 = similarOPMs3.get(indexOPM3 + 1);
                            }
                        } else if(similarOPMs1.size() < 2){
                            if(indexOPM2 == (similarOPMs2.size()-1)){
                                OPM1 = similarOPMs2.get(indexOPM2 - 1);
                            } else OPM1 = similarOPMs2.get(indexOPM2 + 1);
                            if(indexOPM3 == (similarOPMs3.size()-1)){
                                OPM2 = similarOPMs3.get(indexOPM3 - 1);
                            } else {
                                OPM2 = similarOPMs3.get(indexOPM3 + 1);
                            }
                        }
                    } else if(similarOPMs2.size() < 2){
                        
                        if(indexOPM3 == 0){
                            OPM1 = similarOPMs3.get(indexOPM3 + 1);
                            OPM2 = similarOPMs3.get(indexOPM3 + 2);
                        } else if(indexOPM3 == (similarOPMs3.size()-1)){
                            OPM1 = similarOPMs3.get(indexOPM3 - 1);
                            OPM2 = similarOPMs3.get(indexOPM3 - 2);
                        } else {
                            OPM1 = similarOPMs3.get(indexOPM3 - 1);
                            OPM2 = similarOPMs3.get(indexOPM3 + 1);
                        }
                    }
                    //If 2 product in list of product with statut 3 => Fill only OPM1 
                } else if(similarOPMs3.size() == 2){
                    if(similarOPMs2.size() == 2){
                        if(similarOPMs1.size() == 2){
                            if(indexOPM3 == 0){
                                OPM2 = similarOPMs3.get(indexOPM3 + 1);
                            } else {
                                OPM2 = similarOPMs3.get(indexOPM3 - 1);
                            }
                        } else if(similarOPMs1.size() < 2){
                            if(indexOPM2 == (similarOPMs2.size()-1)){
                                OPM1 = similarOPMs2.get(indexOPM2 - 1);
                            } else OPM1 = similarOPMs2.get(indexOPM2 + 1);
                            
                            if(indexOPM3 == 0){
                                OPM2 = similarOPMs3.get(indexOPM3 + 1);
                            } else {
                                OPM2 = similarOPMs3.get(indexOPM3 - 1);
                            }
                        }
                    } else if(similarOPMs2.size() < 2){
                        if(indexOPM3 == 0){
                            OPM1 = similarOPMs3.get(indexOPM3 + 1);
                        } else {
                            OPM1 = similarOPMs3.get(indexOPM3 - 1);
                        }
                    }
                }
            }
        }
        List<Offre_produit_Magasin__c> result = new List<Offre_produit_Magasin__c>{OPM1, OPM2};
        return result;   
        
    }
    
   public static OrderDeliveryGroup calculateFrais(Decimal fraisDePrepFrais, Decimal fraisDeFacturation, OrderDeliveryGroup odg, Decimal montantHTCommande,Map<String,Decimal> decimalFieldsMap, Map<String,String> stringFieldsMap ) {
        
                
        //when 'Livraison' {
        switch on stringFieldsMap.get('fraisTypeDeFraisDeLivraison') {
            when 'Frais fixes' {
                Decimal fraisDeLivraison = decimalFieldsMap.get('fraisForfaitMajorationLivraison') + ( montantHTCommande * (decimalFieldsMap.get('fraisTauxDeMajorationLivraison') /100));
                odg.Livraison_Fees_Tech__c = fraisDePrepFrais + fraisDeLivraison;
                if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
            }
            when 'Frais par zone de chalandise' {
                Decimal fraisDeLivraison = decimalFieldsMap.get('fraisForfaitMajorationZone') + (montantHTCommande * (decimalFieldsMap.get('fraisTauxDeMajorationZone')/100));
                odg.Livraison_Fees_Tech__c = fraisDePrepFrais + fraisDeLivraison;
                if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
            }
            when 'Frais par tranche de CA' {	
                Decimal fraisDeLivraison = 0;
                
                if(decimalFieldsMap.get('fraisCADebutTranche1') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('fraisCAFinTranche1')){
                    fraisDeLivraison = decimalFieldsMap.get('fraisForfaitLivraisonCATranche1') + (montantHTCommande * (decimalFieldsMap.get('fraisTauxMajorationCATranche1')/100));
                }
                else if(decimalFieldsMap.get('fraisCADebutTranche2') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('fraisCAFinTranche2')){
                    fraisDeLivraison = decimalFieldsMap.get('fraisForfaitLivraisonCATranche2') + (montantHTCommande * (decimalFieldsMap.get('fraisTauxMajorationCATranche2')/100));
                }
                 else if(decimalFieldsMap.get('fraisCADebutTranche3') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('fraisCAFinTranche3')){
                    fraisDeLivraison = decimalFieldsMap.get('fraisForfaitLivraisonCATranche3') + (montantHTCommande * (decimalFieldsMap.get('fraisTauxMajorationCATranche3')/100));

                }
                else if(decimalFieldsMap.get('fraisCADebutTranche4') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('fraisCAFinTranche4')){
                    fraisDeLivraison = decimalFieldsMap.get('fraisForfaitLivraisonCATranche4') + (montantHTCommande * (decimalFieldsMap.get('fraisTauxMajorationCATranche4')/100));
                }
                 else if(decimalFieldsMap.get('fraisCADebutTranche5') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('fraisCAFinTranche5')){
                    fraisDeLivraison = decimalFieldsMap.get('fraisForfaitLivraisonCATranche5') + (montantHTCommande * (decimalFieldsMap.get('fraisTauxMajorationCATranche5')/100));

                }
                odg.Livraison_Fees_Tech__c = fraisDePrepFrais + fraisDeLivraison;
                if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
            }
            when 'Pas de frais négociés' {
                Decimal fraisDePrepMagasin;
                if(decimalFieldsMap.get('fraisTauxDeMajorationPreparation') != null){
                    fraisDePrepMagasin = montantHTCommande * (decimalFieldsMap.get('fraisTauxDeMajorationPreparation')/100);
                } else {
                    fraisDePrepMagasin = montantHTCommande * (decimalFieldsMap.get('magasinTauxDeMajorationPreparation')/100);
                }
                //Decimal fraisDePrepMagasin =  montantHTCommande * (magasin.Taux_de_majoration_preparation__c/100);
                switch on stringFieldsMap.get('magasinTypeDeFraisDeLivraison')  {
                    when 'Frais fixes'{
                        Decimal fraisDeLivraison =  decimalFieldsMap.get('magasinForfaitMajorationLivraison') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxDeMajorationLivraison')/100));
                        odg.Livraison_Fees_Tech__c = fraisDePrepMagasin + fraisDeLivraison;
                        if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
                    }	
                    when 'Frais par zone de chalandise' {
                        Decimal fraisDeLivraison = decimalFieldsMap.get('magasinForfaitMajorationZone') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxDeMajorationZone')/100));
                        odg.Livraison_Fees_Tech__c = fraisDePrepMagasin + fraisDeLivraison;
                        if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
                    }
                    when 'Frais par tranche de CA' {
                        Decimal fraisDeLivraison = 0;
                        
                       if(decimalFieldsMap.get('magasinCADebutTranche1') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('magasinCAFinTranche1')){
                    fraisDeLivraison = decimalFieldsMap.get('magasinForfaitLivraisonCATranche1') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxMajorationCATranche1')/100));
                }
                else if(decimalFieldsMap.get('magasinCADebutTranche2') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('magasinCAFinTranche2')){
                    fraisDeLivraison = decimalFieldsMap.get('magasinForfaitLivraisonCATranche2') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxMajorationCATranche2')/100));
                }
                 else if(decimalFieldsMap.get('magasinCADebutTranche3') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('magasinCAFinTranche3')){
                    fraisDeLivraison = decimalFieldsMap.get('magasinForfaitLivraisonCATranche3') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxMajorationCATranche3')/100));

                }
                else if(decimalFieldsMap.get('magasinCADebutTranche4') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('magasinCAFinTranche4')){
                    fraisDeLivraison = decimalFieldsMap.get('magasinForfaitLivraisonCATranche4') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxMajorationCATranche4')/100));
                }
                 else if(decimalFieldsMap.get('magasinCADebutTranche5') <= montantHTCommande &&  montantHTCommande < decimalFieldsMap.get('magasinCAFinTranche5')){
                    fraisDeLivraison = decimalFieldsMap.get('magasinForfaitLivraisonCATranche5') + (montantHTCommande * (decimalFieldsMap.get('magasinTauxMajorationCATranche5')/100));
                }
                odg.Livraison_Fees_Tech__c = fraisDePrepFrais + fraisDeLivraison;
                if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
                    }
                    when else {
                        Decimal fraisDeLivraison = 0;
                        odg.Livraison_Fees_Tech__c = fraisDePrepMagasin + fraisDeLivraison;
                        if(fraisDeFacturation>0){odg.Livraison_Fees_Tech__c = odg.Livraison_Fees_Tech__c+fraisDeFacturation;}
                    }
                }
            }
            when else {
                throw new B2BSplitOrdersCustom.B2BSplitOrdersException('Unrecognized Type de frais de livraison' + stringFieldsMap.get('fraisTypeDeFraisDeLivraison') + ')');
            }
        }
        
        //when 'Drive' {
        
        if(decimalFieldsMap.get('fraisTauxDeMajorationPreparation') != null){
            odg.Drive_Fees_Tech__c = montantHTCommande * (decimalFieldsMap.get('fraisTauxDeMajorationPreparation')/100);
            if(fraisDeFacturation>0){odg.Drive_Fees_Tech__c = odg.Drive_Fees_Tech__c+fraisDeFacturation;}
        } else {
            odg.Drive_Fees_Tech__c = montantHTCommande * (decimalFieldsMap.get('magasinTauxDeMajorationPreparation')/100);
            if(fraisDeFacturation>0){odg.Drive_Fees_Tech__c = odg.Drive_Fees_Tech__c+fraisDeFacturation;}
        }
        
        //when 'Drive déporté' {
        if(decimalFieldsMap.get('fraisTauxDeMajorationPreparation') != null && decimalFieldsMap.get('fraisTauxDeMajorationPreparationDrive') != null){
            odg.Drive_Deporte_Fees_Tech__c = montantHTCommande * ((decimalFieldsMap.get('fraisTauxDeMajorationPreparation')/100) + (decimalFieldsMap.get('fraisTauxDeMajorationPreparationDrive')/100));
            if(fraisDeFacturation>0){odg.Drive_Deporte_Fees_Tech__c = odg.Drive_Deporte_Fees_Tech__c+fraisDeFacturation;}
        } else {
            odg.Drive_Deporte_Fees_Tech__c = montantHTCommande * ((decimalFieldsMap.get('magasinTauxDeMajorationPreparation')/100) + (decimalFieldsMap.get('magasinTauxDeMajorationPreparationDrive')/100));
            if(fraisDeFacturation>0){odg.Drive_Deporte_Fees_Tech__c = odg.Drive_Deporte_Fees_Tech__c+fraisDeFacturation;}
        }
        
        update odg;
        return odg;
    }
    
    Public static void createErrorLogBatch(Id infoId, String batchName){
         AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed, ExtendedStatus, CreatedDate,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :infoId];
        
         Error_Log__c errorLog = new Error_Log__c(
            Name = batchName+' '+job.Id,
            Batch_Name__c = batchName,
            ID_Job__c = job.Id,
            Job_Name__c = batchName,
            Execution_Time__c = job.CreatedDate,
            Error__c = job.ExtendedStatus

        );
        insert errorLog;
        
    }

}