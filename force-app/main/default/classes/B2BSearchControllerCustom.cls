/**
 * @description Demonstrates how to make REST calls to ConnectApi.CommerceSearch class
 * to perform Search and Category browsing for B2B Commerce on Lightning.
 *
 * @see B2BUtils
 */
public with sharing class B2BSearchControllerCustom {
    // Cached API version of this apex class.
    private static Decimal apiVersionApexClass = [SELECT ApiVersion FROM ApexClass WHERE Name = 'B2BSearchControllerCustom'LIMIT 1 ].ApiVersion;
    private static OffreProduitMagasinService opmService = new OffreProduitMagasinService();
    @AuraEnabled(cacheable=false)
    public static  List<Map<String,Object>> getExtraInfoPLP(List<String> listProducts, String effectiveAccountId){
        List<Map<String,Object>> returnedList = new List<Map<String,Object>>();
        Set<Id> productIds = new Set<Id>();
        
        Map<String, Product2> productMap = new Map<String, Product2>([SELECT Id, Code_departement__c, Code_IFLS__c, Marque_text__c, Picto_front__c, Origines__c,
                                                                      (SELECT Id, Name, AlternativeText__c, Image_ExternalId__c, ProductId__c, Product_Image_URL__c, Product_URL_Vignette__c, Titre__c, Ordre_Affichage__c 
                                                                      FROM Product_Image_URLs__r ORDER BY Ordre_Affichage__c)
                                                FROM Product2
                                                WHERE id in :listProducts]);
        Map<String, Product_Image_URL__c> productImagesMap = getImagesUrlMap(productMap.values());
        returnedList.add(productMap);
        //User is logged - Display fields of opm, Specific prices of customer, promotions of opm, stocks of opm and define if the product is a PFT 
        if(effectiveAccountId != Constants.EFFECTIVE_ACCOUNTID && effectiveAccountId != null){
			Account account= Queries.getEffectiveAccount(effectiveAccountId);
            
        
            Map<String, Offre_produit_Magasin__c> opmMap = new Map<String, Offre_produit_Magasin__c>([SELECT Id, Niveau_de_stock__c,CurrencyIsoCode, Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c, 
                                                produit__r.id, Prix_de_vente_magasin__c, En_cours_de_commande__c, Produit_en_extension_de_gamme__c, Statut__c, Prix_kilo__c, Prix_L__c, Prix_unite__c,
                                                Libelle_du_conditionnement_de_vente__c, Magasin__c,Prix_de_vente_magasin_au_conditionnement__c
                                                FROM Offre_Produit_Magasin__c 
                                                WHERE Magasin__c =:account.Magasin_actif_en_cours__c AND Produit__c in :listProducts]);
            
            Set<Id> opmIds = new Set<Id>();
            for (Offre_Produit_Magasin__c opm : opmMap.values()) {
                opmIds.add((Id)opm.get('Id'));
            }

            
            Map<String,Prix_specifiques__c> prixMap = new Map<String, Prix_specifiques__c>([SELECT id, Prix_de_vente_client__c, Prix_kilo__c, Prix_L__c, Prix_unite__c, Produit__c
                                                                                            FROM Prix_specifiques__c 
                                                                                            WHERE Produit__c in :listProducts AND Reference_client__c =:effectiveAccountId AND Offre_Produit_Magasin__c in :opmIds
                                                                                            AND Date_de_debut_d_application__c <= Today
                                                                                            AND Date_de_fin_d_application__c >= Today]);
            
            Map<String, Promotion__c> promotionMap = new Map<String, Promotion__c>([SELECT Id, Phrase_offre__c, Type_d_offre__c, Type_de_promotion__c, Mecanique_Promotion_TECH__c,
                                                  Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c, Libelle_periode_de_promotion__c,Produit__r.Libelle_du_conditionnement_vente__c,
                                                  Quantite_minimum_de_commande__c, Quantite_offerte__c, Quantite_payee__c,
                                                  Prix_sous_mecanique__c, Remise_en_e__c, Remise_en_p__c, Prix_de_vente_promotion__c, Produit__c 
                                                  FROM Promotion__c 
                                                  WHERE Magasin__c =:account.Magasin_actif_en_cours__c AND Produit__c in:listProducts AND Date_de_debut_de_promotion__c <= TODAY AND Date_de_fin_de_promotion__c >= TODAY]);
            
            //Map<String, Product_Image_URL__c> productImagesMap = new Map<String, Product_Image_URL__c>([SELECT Id, Name, AlternativeText__c, Image_ExternalId__c, ProductId__c, Product_Image_URL__c, Product_URL_Vignette__c, Titre__c, Ordre_Affichage__c FROM Product_Image_URL__c WHERE  ProductId__c in:listProducts ORDER BY Ordre_Affichage__c]);
            
            Map<String, boolean> isPFTMap = new Map<String, boolean>();
            Map<String, Decimal> stock = new Map<String, Decimal>();
            for(Offre_Produit_Magasin__c opm : opmMap.values()){
                if(opm.Code_departement__c != null  && (opm.Prix_de_vente_magasin__c  == null || opm.Prix_de_vente_magasin__c  == 0)) {
                    if(opm.Code_departement__c == '4' && opm.Statut__c == '2' ){
                        isPFTMap.put(opm.produit__r.id,true);
                    } else { 
                            isPFTMap.put(opm.produit__r.id,false); 
                    }
                } else { 
                        isPFTMap.put(opm.produit__r.id,false); 
                }
                
                if(opm.Niveau_de_stock__c != null && opm.En_cours_de_commande__c != null){
                    stock.put(opm.produit__r.id,opm.Niveau_de_stock__c + opm.En_cours_de_commande__c);
                }
                else if(opm.Niveau_de_stock__c != null){
                    stock.put(opm.produit__r.id,opm.Niveau_de_stock__c);
                }
                else if(opm.En_cours_de_commande__c != null){
                    stock.put(opm.produit__r.id,opm.En_cours_de_commande__c);
                }
                else{
                    stock.put(opm.produit__r.id,0);
                }
            }
            
            returnedList.add(opmMap);
            returnedList.add(prixMap);
            returnedList.add(promotionMap);
            returnedList.add(productImagesMap);
            returnedList.add(isPFTMap);
            returnedList.add(stock);
            		            
        } else {
            //For guest USER, display lyon gerland's promotions
            String lyonGerlandMagasin = System.Label.LyonGerlandMagasinId;
            Map<String, Promotion__c> promotionMap = new Map<String, Promotion__c>();
            List<Promotion__c> listPromo = [SELECT Id, Phrase_offre__c, Type_d_offre__c, Type_de_promotion__c, Mecanique_Promotion_TECH__c,
                                            Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c, Libelle_periode_de_promotion__c,Produit__r.Libelle_du_conditionnement_vente__c,
                                            Quantite_minimum_de_commande__c, Quantite_offerte__c, Quantite_payee__c,
                                            Prix_sous_mecanique__c, Remise_en_e__c, Remise_en_p__c, Prix_de_vente_promotion__c, Produit__c 
                                            FROM Promotion__c 
                                            WHERE Magasin__c =:lyonGerlandMagasin AND Produit__c in:listProducts AND Date_de_debut_de_promotion__c <= TODAY AND Date_de_fin_de_promotion__c >= TODAY];
            for(Promotion__c promo : listPromo){
                promotionMap.put(promo.Id,promo);
            }
            returnedList.add(promotionMap);
            returnedList.add(productImagesMap);
        }
        return returnedList;
    }  
    
    private static Map<String, Product_Image_URL__c> getImagesUrlMap(List<Product2> productList) {
        Map<String, Product_Image_URL__c> productImagesMap = new Map<String, Product_Image_URL__c>();
        for(Product2 product: productList) {
            for(Product_Image_URL__c url : product.Product_Image_URLs__r) {
                productImagesMap.put(url.Id, url);
            }
        }
        return productImagesMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static Offre_Produit_Magasin__c opmSearch(String productId, String effectiveAccountId) {
        Account account= Queries.getEffectiveAccount(effectiveAccountId);
        Offre_Produit_Magasin__c opm = [SELECT Id, Niveau_de_stock__c,CurrencyIsoCode, Ref_tarifaire_magasin__c , Code_departement__c, Extension_de_gamme__c, 
                                            produit__r.id, produit__r.Code_IFLS__c, produit__r.Marque_text__c, produit__r.Pictogramme_Rayon__c,
                          					En_cours_de_commande__c, Produit_en_extension_de_gamme__c, Statut__c, Prix_kilo__c, Prix_L__c, Libelle_du_conditionnement_de_vente__c, Prix_unite__c 
                   FROM Offre_Produit_Magasin__c WHERE Magasin__c =:account.Magasin_actif_en_cours__c AND Produit__c =:productId];
        return opm;
    }
    
    /**
     * @description Demonstrates how to call ConnectApi.CommerceSearch.productSearch
     * @param communityId The Id of the community from which the call originated
     * @param searchQuery The search query parameters which includes searchTerm, categoryId, refinements, page and includePrices
     * @param @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     */
    @AuraEnabled(cacheable=false)
    public static Object productSearch(String communityId, String searchQuery, String effectiveAccountId) {
        // Lookup the webstore ID associated with the community
        String webstoreId = (!Test.isRunningTest())? B2BUtilsCustom.resolveCommunityIdToWebstoreId(communityId) : null;

        ConnectApi.ProductSearchInput psi = (ConnectApi.ProductSearchInput)JSON.deserialize(searchQuery, ConnectApi.ProductSearchInput.class);
        /**We are no more using Rest call to query searchApi https://help.salesforce.com/s/articleView?id=000389207&type=1 */
        return ConnectApi.CommerceSearch.searchProducts(
            webstoreId,
            effectiveAccountId, 
            psi
        );
    }
}