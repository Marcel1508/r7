public without sharing class B2BPromotionsControllerCustom {
    
    @AuraEnabled(cacheable=true)
    public static Promotion__c getPromotions(
        String productId,
        String effectiveAccountId
    ) {
        system.debug('getPromotions: ' + productId + ', ' + effectiveAccountId);
        if(effectiveAccountId != '000000000000000' && effectiveAccountId != null){
            system.debug('get promotion promotion if: ');
            Account account= Queries.getEffectiveAccount(effectiveAccountId);
            List<Promotion__c> res = [SELECT Id, Phrase_offre__c, Type_d_offre__c, Type_de_promotion__c, Mecanique_Promotion_TECH__c,
                                      Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c, Libelle_periode_de_promotion__c,
                                      Quantite_minimum_de_commande__c, Quantite_offerte__c, Quantite_payee__c,
                                      Prix_sous_mecanique__c, Remise_en_e__c, Remise_en_p__c, Prix_de_vente_promotion__c, Produit__r.Libelle_du_conditionnement_vente__c
                                      FROM Promotion__c 
                                      WHERE Magasin__c =:account.Magasin_actif_en_cours__c AND Produit__c =:productId AND Date_de_debut_de_promotion__c <= TODAY AND Date_de_fin_de_promotion__c >= TODAY];
            system.debug('get promotion promotion: ' + res);
            
            if(res != null && res.size() > 0)
                return res.get(0);
        } 
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Promotion__c getPromotionsForGuestUser(
        String productId
    ) {
        Promotion__c[] promotion;
        String lyonGerlandMagasin = System.Label.LyonGerlandMagasinId;
        system.debug('get promotion promotion if: ');
        promotion = [SELECT Id, Phrase_offre__c, Type_d_offre__c, Type_de_promotion__c, Mecanique_Promotion_TECH__c,
                     Date_de_debut_de_promotion__c, Date_de_fin_de_promotion__c, Libelle_periode_de_promotion__c,
                     Quantite_minimum_de_commande__c, Quantite_offerte__c, Quantite_payee__c,
                     Prix_sous_mecanique__c, Remise_en_e__c, Remise_en_p__c, Prix_de_vente_promotion__c, Produit__r.Libelle_du_conditionnement_vente__c
                     FROM Promotion__c 
                     WHERE Magasin__c =:lyonGerlandMagasin AND Produit__c =:productId AND Date_de_debut_de_promotion__c <= TODAY AND Date_de_fin_de_promotion__c >= TODAY];
        
        system.debug('get promotion promotion: ' + promotion);
        
        Promotion__c promo;
        if(promotion.size() > 0){
            promo = promotion[0];
        }
        return promo;
    }
    
    @AuraEnabled(cacheable=true)
    public static void calculateCartItemPromotions(
        String cartId,
        String effectiveAccountId
    ) {
        List<CartItem> cartItemsExtract = new List<CartItem>([SELECT Id, Name, AdjustmentAmount,UnitAdjustmentAmount, Product2Id,Product2.Vignette_alcool__c, TotalPrice,
                                                              Quantity, UnitAdjustedPrice From CartItem where CartId =: cartId ]);
        
        Set<Id> cartItemIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        
        for(CartItem cartItem : cartItemsExtract){
            productIds.add(cartItem.Product2Id);
            cartItemIds.add(cartItem.Id);
        }        
        
        Account account= Queries.getEffectiveAccount(effectiveAccountId);
        List<Promotion__c> promotionList = new List<Promotion__c>([SELECT Id, Type_d_offre__c, Type_de_promotion__c, Quantite_minimum_de_commande__c,
                                                                   Prix_sous_mecanique__c, Remise_en_e__c, Remise_en_p__c, Prix_de_vente_promotion__c, Produit__c 
                                                                   FROM Promotion__c 
                                                                   WHERE Magasin__c =:account.Magasin_actif_en_cours__c AND Produit__c in:productIds
                                                                   AND Date_de_debut_de_promotion__c <= TODAY AND Date_de_fin_de_promotion__c >= TODAY]);
        Map<String, Promotion__c> promotionMap = new Map<String, Promotion__c>();
        for(Promotion__c promo : promotionList){
            promotionMap.put(promo.Produit__c, promo);
        }
        
        List<CartItem> cartItemsToUpdate = new List<CartItem>();
        cartItemsToUpdate = Utilities2.calculatePromotion(cartItemsExtract,promotionMap);
        if(!cartItemsToUpdate.isEmpty())
        {
            update cartItemsToUpdate;
        }   
    }
    
    }