/**
*
* Promocash cart to order for the checkout flow
* Main difference with standard is that this can split the cart into two orders: one for inStock items, one for outOfStock items
* Main documentation for cart to  order is here:
* https://developer.salesforce.com/docs/atlas.en-us.b2b_comm_lex_dev.meta/b2b_comm_lex_dev/b2b_comm_lex_import_export_carttoorder.htm
*
*/
public with sharing class B2BSplitOrdersCustom {
    
    public class RequestWrapper {
        @InvocableVariable(required=true)
        public Id checkoutSessionId;
        
        @InvocableVariable(required=true)
        public Id cartId;
        
        @InvocableVariable(required=true)
        public Id realUserId;
    }
    
    public class ResultWrapper {
        @InvocableVariable(required=false)
        public Id inStockOrderId;
        
        @InvocableVariable(required=false)
        public Id outOfStockOrderId;
    }
    
    private static final Date TODAY_DATE = Date.today();
    private static final DateTime SYSTEM_NOW = System.now();
    private static final String DRAFT_ORDER = 'Draft order'; //todo: change to 0
    private static final String EN_ATTENTE_DE_PREPARATION = '1';
    private static final String ECOMMERCE = 'E-commerce';
    private static final String TELEVENTE = 'Télévente';
    private static final String IN_STOCK_ORDER = 'In Stock order';
    private static final String OUT_OF_STOCK_ORDER = 'Out of Stock order';
    private static final String OUI = 'O';
    private static final String NON = 'N';
    
    
    private static OrderDeliveryMethod defaultMethod {
        get {
            if (defaultMethod == null) {
                defaultMethod = [SELECT Id, Name FROM OrderDeliveryMethod WHERE Name = 'Default Delivery Method'];
            }
            return defaultMethod;
        }
        set;
    }
    
    @InvocableMethod(label='Split Orders for Promocash' description='Create order(s) based on the cart' category='Promocash')
    public static List<ResultWrapper> splitCartToOrders(List<RequestWrapper> request) {
        Id cartId = request[0].cartId;
        Id checkoutSessionId = request[0].checkoutSessionId;
        Id realUserId = request[0].realUserId;
        
        WebCart cart = getCart(cartId);
        
        if(cart.Account.Id == null){throw new B2BSplitOrdersException('No Account record was found (Id: ' + cart.accountId + ')');}
        if(cart.Account.Magasin_actif_en_cours__r.Id == null){throw new B2BSplitOrdersException('No Magasin__c record was found (Id: ' + cart.Account.Magasin_actif_en_cours__c + ')');} 
        if(cart.Account.Frais_autorisations__r.Id == null){throw new B2BSplitOrdersException('No Frais__c record was found (Id: ' + cart.Account.Frais_autorisations__c + ')');}
        Map<String,Decimal> decimalFields = new Map<String,Decimal>
            
            
        {'fraisTauxDeMajorationLivraison'=> cart.Account.Frais_autorisations__r.Taux_de_majoration_livraison__c,
            
            'fraisForfaitMajorationLivraison'=> cart.Account.Frais_autorisations__r.Forfait_majoration_livraison__c,
            'fraisTauxDeMajorationZone'=> cart.Account.Frais_autorisations__r.Taux_de_majoration_zone__c,
            'fraisForfaitMajorationZone'=> cart.Account.Frais_autorisations__r.Forfait_majoration_zone__c,
            'fraisCADebutTranche1'=> cart.Account.Frais_autorisations__r.CA_debut_tranche_1__c,
            'fraisCAFinTranche1'=> cart.Account.Frais_autorisations__r.CA_fin_tranche_1__c,
            'fraisForfaitLivraisonCATranche1'=> cart.Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_1__c,
            'fraisTauxMajorationCATranche1'=> cart.Account.Frais_autorisations__r.Taux_majoration_CA_tranche_1__c,
            'fraisCADebutTranche2'=> cart.Account.Frais_autorisations__r.CA_debut_tranche_2__c,
            'fraisCAFinTranche2'=> cart.Account.Frais_autorisations__r.CA_fin_tranche_2__c,
            'fraisForfaitLivraisonCATranche2'=> cart.Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_2__c,
            'fraisTauxMajorationCATranche2'=> cart.Account.Frais_autorisations__r.Taux_majoration_CA_tranche_2__c,
            'fraisCADebutTranche3'=> cart.Account.Frais_autorisations__r.CA_debut_tranche_3__c,
            'fraisCAFinTranche3'=> cart.Account.Frais_autorisations__r.CA_fin_tranche_3__c,
            'fraisForfaitLivraisonCATranche3'=> cart.Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_3__c,
            'fraisTauxMajorationCATranche3'=> cart.Account.Frais_autorisations__r.Taux_majoration_CA_tranche_3__c,
            'fraisCADebutTranche4'=> cart.Account.Frais_autorisations__r.CA_debut_tranche_4__c,
            'fraisCAFinTranche4'=> cart.Account.Frais_autorisations__r.CA_fin_tranche_4__c,
            'fraisForfaitLivraisonCATranche4'=> cart.Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_4__c,
            'fraisTauxMajorationCATranche4'=> cart.Account.Frais_autorisations__r.Taux_majoration_CA_tranche_4__c,
            'fraisCADebutTranche5'=> cart.Account.Frais_autorisations__r.CA_debut_tranche_5__c,
            'fraisCAFinTranche5'=> cart.Account.Frais_autorisations__r.CA_fin_tranche_5__c,
            'fraisForfaitLivraisonCATranche5'=> cart.Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_5__c,
            'fraisTauxMajorationCATranche5'=> cart.Account.Frais_autorisations__r.Taux_majoration_CA_tranche_5__c,
            'magasinForfaitMajorationLivraison'=> cart.Account.Magasin_actif_en_cours__r.Forfait_majoration_livraison__c,
            'magasinTauxDeMajorationLivraison'=> cart.Account.Magasin_actif_en_cours__r.Taux_de_majoration_livraison__c,
            'magasinTauxDeMajorationZone'=> cart.Account.Magasin_actif_en_cours__r.Taux_de_majoration_zone__c,
            'magasinForfaitMajorationZone'=> cart.Account.Magasin_actif_en_cours__r.Forfait_majoration_zone__c,
            'magasinCADebutTranche1'=> cart.Account.Magasin_actif_en_cours__r.CA_debut_tranche_1__c,
            'magasinCAFinTranche1'=> cart.Account.Magasin_actif_en_cours__r.CA_fin_tranche_1__c,
            'magasinForfaitLivraisonCATranche1'=> cart.Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_1__c,
            'magasinTauxMajorationCATranche1'=> cart.Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_1__c,
            'magasinCADebutTranche2'=> cart.Account.Magasin_actif_en_cours__r.CA_debut_tranche_2__c,
            'magasinCAFinTranche2'=> cart.Account.Magasin_actif_en_cours__r.CA_fin_tranche_2__c,
            'magasinForfaitLivraisonCATranche2'=> cart.Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_2__c,
            'magasinTauxMajorationCATranche2'=> cart.Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_2__c,
            'magasinCADebutTranche3'=> cart.Account.Magasin_actif_en_cours__r.CA_debut_tranche_3__c,
            'magasinCAFinTranche3'=> cart.Account.Magasin_actif_en_cours__r.CA_fin_tranche_3__c,
            'magasinForfaitLivraisonCATranche3'=> cart.Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_3__c,
            'magasinTauxMajorationCATranche3'=> cart.Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_3__c,
            'magasinCADebutTranche4'=> cart.Account.Magasin_actif_en_cours__r.CA_debut_tranche_4__c,
            'magasinCAFinTranche4'=> cart.Account.Magasin_actif_en_cours__r.CA_fin_tranche_4__c,
            'magasinForfaitLivraisonCATranche4'=> cart.Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_4__c,
            'magasinTauxMajorationCATranche4'=> cart.Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_4__c,
            'magasinCADebutTranche5'=> cart.Account.Magasin_actif_en_cours__r.CA_debut_tranche_5__c,
            'magasinCAFinTranche5'=> cart.Account.Magasin_actif_en_cours__r.CA_fin_tranche_5__c,
            'magasinForfaitLivraisonCATranche5'=> cart.Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_5__c,
            'magasinTauxMajorationCATranche5'=> cart.Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_5__c, 
            'magasinTauxDeMajorationPreparation'=> cart.Account.Magasin_actif_en_cours__r.Taux_de_majoration_preparation__c ,
            'fraisTauxDeMajorationPreparation'=> cart.Account.Frais_autorisations__r.Taux_de_majoration_preparation__c,
            'fraisTauxDeMajorationPreparationDrive'=> cart.Account.Frais_autorisations__r.Taux_de_majoration_preparation_drive__c,
            'magasinTauxDeMajorationPreparationDrive'=> cart.Account.Magasin_actif_en_cours__r.Taux_de_majoration_preparation_drive__c
            
            };
                
                Map<String,String> stringFields = new Map<String,String>{
                    'magasinTypeDeFraisDeLivraison'=> cart.Account.Magasin_actif_en_cours__r.Type_de_frais_de_livraison__c,
            'fraisTypeDeFraisDeLivraison'=> cart.Account.Frais_autorisations__r.Type_de_frais_de_livraison__c 
                };
                     
        
        List<CartItem> cartItems = cart.CartItems;
        Map<String,Double> inStockMap = new Map<String,Double>();
        Map<String,Double> outOfStockMap = new Map<String,Double>();
        Set<Id> productsIDs = new Set<ID>();
        
        for (CartItem cartItem : cartItems) {
            productsIDs.add(cartItem.Product2Id);
            
            Double availableQuantity = (cartItem.Available_Quantity__c != null) ? cartItem.Available_Quantity__c : 0;      
            if (cartItem.Quantity <= availableQuantity) { //  whole quantity is available
                inStockMap.put(cartItem.Id, cartItem.Quantity);
            } else if (availableQuantity <= 0) { // no stock; the whole line as out of stock
                outOfStockMap.put(cartItem.Id, cartItem.Quantity);
            } else { // the asked quantity is bigger than the available, we need to split the line
                inStockMap.put(cartItem.Id, availableQuantity);
                outOfStockMap.put(cartItem.Id, cartItem.Quantity - availableQuantity);
            }
        }
        Frais_par_Zone_de_Chalandise__c fraisParZoneDeChalandise;
        if (cart.Account.Magasin_actif_en_cours__r.Type_de_frais_de_livraison__c == 'Frais par zone de chalandise' && cart.Account.Frais_autorisations__r.Type_de_frais_de_livraison__c == 'Pas de frais négociés') {
            if(String.isBlank(cart.Account.Frais_autorisations__r.Code_zone_de_chalandise__c))
            {
                String codeZoneDeChalandise =  getCodeZoneDeChalandise(cart.Account.ShippingPostalCode,cart.Account.ShippingCity,cart.Account.Magasin_actif_en_cours__c);
                fraisParZoneDeChalandise = getFraisParZoneDeChalandise(codeZoneDeChalandise,cart.Account.Magasin_actif_en_cours__c);
            } else
            {fraisParZoneDeChalandise = getFraisParZoneDeChalandise(cart.Account.Frais_autorisations__r.Code_zone_de_chalandise__c, cart.Account.Magasin_actif_en_cours__c);}        
        }
        //End added by Suliman
        
        ResultWrapper result = new ResultWrapper();
        Map<Id, Offre_produit_Magasin__c> opmMap = getOPMap(cart.Account.Magasin_actif_en_cours__c, productsIDs);
        // InStock order
        if (!inStockMap.isEmpty()) {
            Order order = createOrder(cart, true, realUserId);
            OrderDeliveryGroup deliveryGroup = createOrderDeliveryGroup(order);
            List<OrderItem> orderItems = createOrderItems(cartItems, order, deliveryGroup, inStockMap, opmMap);
            List<OrderItemAdjustmentLineItem> adjustmentLineItems = createOrderItemAdjustmentLineItems(orderItems, cartItems, inStockMap,cart.Account.Magasin_actif_en_cours__c);
            List<OrderItemTaxLineItem> taxLineItems = createOrderItemTaxLineItems(orderItems, cartItems, inStockMap);
            deliveryGroup = updateOrderDeliveryGroup(deliveryGroup, cart , fraisParZoneDeChalandise, decimalFields,stringFields);
            result.inStockOrderId = order.Id;
        }
        
        // Out Of Stock order
        if (!outOfStockMap.isEmpty()) {
            Order order = createOrder(cart,false, realUserId);
            OrderDeliveryGroup deliveryGroup = createOrderDeliveryGroup(order);
            List<OrderItem> orderItems = createOrderItems(cartItems, order, deliveryGroup, outOfStockMap, opmMap);
            List<OrderItemTaxLineItem> taxLineItems = createOrderItemTaxLineItems(orderItems, cartItems, outOfStockMap);
            deliveryGroup = updateOrderDeliveryGroup(deliveryGroup, cart , fraisParZoneDeChalandise, decimalFields,stringFields);
            result.outOfStockOrderId = order.Id;
        }
        
        updateCheckoutSession(checkoutSessionId, result);
        return new List<ResultWrapper>{result};
            }
    
    private static Map<Id, Offre_produit_Magasin__c> getOPMap(Id magasinId, Set<Id> productsIds) {
        Map<Id, Offre_produit_Magasin__c> res = new Map<Id, Offre_produit_Magasin__c>();
        
        List<Offre_produit_Magasin__c> opms = [SELECT Id, Prix_de_vente_magasin__c , Prix_kilo__c, Libelle_du_conditionnement_de_vente__c, libelle_du_condionnement_value__c , Produit__r.Unite_de_prix__c,
                                               Produit__r.Contenance__c from Offre_produit_Magasin__c WHERE Magasin__c = :magasinId AND produit__c IN :productsIds];
        if(opms != null && opms.size() > 0) {
            for(Offre_produit_Magasin__c opm: opms) {
                res.put(opm.produit__c, opm);
            }
        }
        return res;
    }
    
    
    /**
* @description Satisfy the preconditions required to use the following call to Activate the Order
*/
    private static void updateCheckoutSession(Id checkoutSessionId, ResultWrapper result) {
        CartCheckoutSession checkoutSession = [SELECT Id FROM CartCheckoutSession WHERE Id = :checkoutSessionId];
        checkoutSession.OrderId = result.inStockOrderId;
        update checkoutSession;
    }
    
    private static Order createOrder(WebCart cart, Boolean inStock, Id realUserId) {
        Order order = new Order();
        order.AccountId = cart.AccountId;
        order.EffectiveDate = TODAY_DATE;
        order.CurrencyIsoCode = cart.CurrencyIsoCode;
        order.OrderedDate = SYSTEM_NOW;
        // order.OwnerId = magasin.Responsable__c;
        order.OwnerId = cart.OwnerId;
        order.SalesStoreId = cart.WebStoreId;
        order.Status = DRAFT_ORDER;
        order.Commande_payee__c = NON;
        order.Placed_By__c = realUserId;
        order.Origine_de_la_commande__c = realUserId == UserInfo.getUserId() ? ECOMMERCE : TELEVENTE;
        order.Description = inStock ? IN_STOCK_ORDER : OUT_OF_STOCK_ORDER;
        order.Commande_en_stock__c = inStock ? OUI : NON;
        order.Magasin_actif__c = cart.Account.Magasin_actif_en_cours__c;
        
        insert order;
        return [SELECT GrandTotalAmount, TotalTaxAmount FROM Order WHERE Id = :order.Id];
    }
    
    private static List<OrderItem> createOrderItems(List<CartItem> cartItems, Order order, OrderDeliveryGroup deliveryGroup, Map<String,Double> cartItemMap, Map<Id, Offre_produit_Magasin__c> opmap) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (CartItem cartItem : cartItems) {
            if (cartItemMap.get(cartItem.Id) == null) { continue; }
            
            OrderItem oi = new OrderItem();
            oi.OrderId = order.Id;
            oi.OrderDeliveryGroupId = deliveryGroup.Id;
            oi.Product2Id = cartItem.Product2Id;
            oi.Quantity = cartItemMap.get(cartItem.Id);
            oi.quantityToAquilon__c = oi.Quantity;
            oi.Type = 'Order Product';
            oi.ListPrice = (cartItem.ListPrice != null) ? cartItem.ListPrice : cartItem.UnitAdjustedPrice;
            oi.UnitPrice = cartItem.UnitAdjustedPrice;
            //(cartItem.SalesPrice != null) ? cartItem.SalesPrice : cartItem.ListPrice;
            oi.TotalLineAmount = oi.UnitPrice * oi.Quantity;
            //AddedBy Marouane
            Offre_produit_Magasin__c opm = opmap.get(cartItem.Product2Id);
            if(opm != null) {
                if(opm.Produit__r.Unite_de_prix__c.equalsIgnoreCase('UVC')) {
                    if(opm.libelle_du_condionnement_value__c != null)
                        oi.quantityToAquilon__c = Integer.valueOf(opm.libelle_du_condionnement_value__c) * cartItemMap.get(cartItem.Id);
                    oi.UnitPrice = opm.Prix_de_vente_magasin__c;
                } else if(opm.Produit__r.Unite_de_prix__c.equalsIgnoreCase('UCT')) {
                    if(opm.Produit__r.Contenance__c != null)
                        oi.quantityToAquilon__c = Double.valueOf(opm.Produit__r.Contenance__c) * cartItemMap.get(cartItem.Id);
                    oi.UnitPrice = opm.Prix_kilo__c;
                }
            }
            orderItems.add(oi);
        }
        insert orderItems;
        return orderItems;
    }
    
    private static List<OrderItemAdjustmentLineItem> createOrderItemAdjustmentLineItems(List<OrderItem> orderItems, List<CartItem> cartItems, Map<String, Double> cartItemQuantityMap, Id magasinId) {
        List<OrderItemAdjustmentLineItem> adjustmentLineItems = new List<OrderItemAdjustmentLineItem>();
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>(orderItems);
        Map<String,CartItem> cartItemMap = new Map<String,CartItem>();
        for (CartItem ci : cartItems) {
            if (cartItemQuantityMap.get(ci.Id) == null) { continue; }
            cartItemMap.put(ci.Product2Id, ci);
        }
        
        for (OrderItem orderItem : orderItems) {
            OrderItemAdjustmentLineItem ali = new OrderItemAdjustmentLineItem();
            CartItem correspondingCartItem = cartItemMap.get(orderItem.Product2Id);
            ali.Promotion__c = correspondingCartItem.Promotion__c;
            ali.Name = 'Promotion';
            ali.OrderItemId = orderItem.Id;
            ali.Amount = correspondingCartItem.AdjustmentAmount;
            adjustmentLineItems.add(ali);
        }
        insert adjustmentLineItems;
        return adjustmentLineItems;
    }
    
    private static List<OrderItemTaxLineItem> createOrderItemTaxLineItems(List<OrderItem> orderItems, List<CartItem> cartItems, Map<String,Double> cartItemQuantityMap) {
        Map<String, CartTax> cartTaxesByProductId = new Map<String, CartTax>();
        Map<String, Double> totalQuantitiesTotalByCartItemId = new Map<String, Double>();
        Map<String, Double> splitQuantitiesTotalByCartItemId = new Map<String, Double>();
        for (CartTax ct : [
            SELECT Id, CartItemId, CartItem.TotalPrice, CartItem.TotalListPrice,  Amount, Name, TaxCalculationDate, TaxType, TaxRate, Description, CartItem.Product2Id, CartItem.Quantity
            FROM CartTax
            WHERE CartItemId IN :cartItemQuantityMap.keySet()]) {
                cartTaxesByProductId.put(ct.CartItem.Product2Id + ',' + ct.Name , ct);
            }
        
        List<OrderItemTaxLineItem> taxLineItems = new List<OrderItemTaxLineItem>();
        for (OrderItem orderItem : orderItems) {
            CartTax cartTva = cartTaxesByProductId.get(orderItem.Product2Id + ',' + 'TVA');
            CartTax cartEco = cartTaxesByProductId.get(orderItem.Product2Id + ',' + 'Ecotaxe');
            CartTax cartConsigne = cartTaxesByProductId.get(orderItem.Product2Id + ',' + 'Consigne');
            CartTax cartVignette = cartTaxesByProductId.get(orderItem.Product2Id + ',' + 'Taxe Vignette Alcool');
            
            if (cartTva != null) {
                OrderItemTaxLineItem tlitva = new OrderItemTaxLineItem();
                tlitva.Amount = cartTva.Amount;
                tlitva.Name = cartTva.Name;
                tlitva.OrderItemId = orderItem.Id;
                tlitva.TaxEffectiveDate = cartTva.TaxCalculationDate;
                tlitva.Type = cartTva.TaxType;
                tlitva.Rate = cartTva.TaxRate;
                tlitva.Description = cartTva.Description;
                taxLineItems.add(tlitva);
            }
            
            if (cartEco != null) {
                OrderItemTaxLineItem tliecotaxe = new OrderItemTaxLineItem();
                tliecotaxe.Amount = cartEco.Amount;
                tliecotaxe.Name = cartEco.Name;
                tliecotaxe.OrderItemId = orderItem.Id;
                tliecotaxe.TaxEffectiveDate = cartEco.TaxCalculationDate;
                tliecotaxe.Type = cartEco.TaxType;
                tliecotaxe.Rate = cartEco.TaxRate;
                tliecotaxe.Description = cartEco.Description;
                taxLineItems.add(tliecotaxe);
            }
            
            if (cartConsigne != null) {
                OrderItemTaxLineItem tlicconsigne = new OrderItemTaxLineItem();
                tlicconsigne.Amount = cartConsigne.Amount;
                tlicconsigne.Name = cartConsigne.Name;
                tlicconsigne.OrderItemId = orderItem.Id;
                tlicconsigne.TaxEffectiveDate = cartConsigne.TaxCalculationDate;
                tlicconsigne.Type = cartConsigne.TaxType;
                tlicconsigne.Rate = cartConsigne.TaxRate;
                tlicconsigne.Description = cartConsigne.Description;
                taxLineItems.add(tlicconsigne);
            }
            
            if (cartVignette != null) {
                OrderItemTaxLineItem tlivignette = new OrderItemTaxLineItem(Amount = cartVignette.Amount, Name = cartVignette.Name, OrderItemId = orderItem.Id, TaxEffectiveDate = cartVignette.TaxCalculationDate,
                                                                            Type = cartVignette.TaxType, Rate = cartVignette.TaxRate, Description = cartVignette.Description);
                
                taxLineItems.add(tlivignette);
            }
        }
        insert taxLineItems;
        return taxLineItems;
    }
    
    private static OrderDeliveryGroup createOrderDeliveryGroup(Order order) {
        OrderDeliveryGroup odg = new OrderDeliveryGroup();
        odg.OrderDeliveryMethodId = defaultMethod.Id;
        odg.OrderId = order.Id;
        odg.DeliverToName = 'Not Defined yet';
        
        insert odg;
        return odg;
    }
    
    private static OrderDeliveryGroup updateOrderDeliveryGroup(OrderDeliveryGroup odg,WebCart cart,Frais_par_Zone_de_Chalandise__c fraisParZoneDeChalandise, Map<String,Decimal> decimalFieldsMap, Map<String,String> stringFieldsMap) {
        
        Order order = [SELECT Id, GrandTotalAmount, TotalTaxAmount FROM Order WHERE Id = :odg.OrderId];
        Decimal montantHTCommande = order.GrandTotalAmount - order.TotalTaxAmount;
        
        Decimal fraisDePrepFrais = 0;
        Decimal fraisDeFacturation = 0;
        if(cart.Account.Frais_autorisations__r.Indicateur_FEF__c == 'O'){
            if(cart.Account.Magasin_actif_en_cours__r.Montant_FEF__c >0)
            {fraisDeFacturation = cart.Account.Magasin_actif_en_cours__r.Montant_FEF__c;}
        }
        if(cart.Account.Frais_autorisations__r.Taux_de_majoration_preparation__c != null){
            fraisDePrepFrais = montantHTCommande * (cart.Account.Frais_autorisations__r.Taux_de_majoration_preparation__c/100);
        } else {
            fraisDePrepFrais = montantHTCommande * (cart.Account.Magasin_actif_en_cours__r.Taux_de_majoration_preparation__c/100);
        }
        
        OrderDeliveryGroup odgUpdated = Utilities2.calculateFrais(fraisDePrepFrais,fraisDeFacturation,odg,montantHTCommande,decimalFieldsMap,stringFieldsMap);
       
        return odgUpdated;
    }
    
    private static Frais_par_Zone_de_Chalandise__c getFraisParZoneDeChalandise(String code, Id magasinId) {
        List<Frais_par_Zone_de_Chalandise__c> fraisParZoneDeChalandise = [
            SELECT Id, Forfait_de_majoration__c, Taux_majoration__c 
            FROM Frais_par_Zone_de_Chalandise__c 
            WHERE Code_zone_de_chalandise__c =: code AND Magasin__c =: magasinId];
        
        if (fraisParZoneDeChalandise.isEmpty()) {
            throw new B2BSplitOrdersException('No Frais_par_Zone_de_Chalandise__c record was found (Code_zone_de_chalandise__c: ' + code + ', Magasin__c: ' + magasinId + ')');
        } 
        
        return fraisParZoneDeChalandise[0];
    }
    
    private static Webcart getCart(Id cartId){     
        WebCart cart = [
            SELECT Id, AccountId,Account.Id,Account.Name, Account.Magasin_actif_en_cours__c, Account.Frais_autorisations__c, Account.ShippingPostalCode, Account.ShippingCity,
            Account.BillingCity,(SELECT Product2Id, Sku, Quantity, Available_Quantity__c, ListPrice, SalesPrice, Promotion__c, AdjustmentAmount, UnitAdjustedPrice
                                 FROM CartItems where Type = 'Product'), 
            BillingLatitude, BillingLongitude, BillingPostalCode, BillingStreet,  
            CurrencyIsoCode, OwnerId, WebStoreId,Account.Magasin_actif_en_cours__r.Id,
            Account.Magasin_actif_en_cours__r.Name, Account.Magasin_actif_en_cours__r.Responsable__c, 
            Account.Magasin_actif_en_cours__r.Frais_de_Drive__c, Account.Magasin_actif_en_cours__r.Frais_de_livraison__c, 
            Account.Magasin_actif_en_cours__r.Type_de_frais_de_livraison__c,
            Account.Magasin_actif_en_cours__r.Forfait_Livraison__c, Account.Magasin_actif_en_cours__r.Forfait_majoration_livraison__c, 
            Account.Magasin_actif_en_cours__r.Forfait_majoration_zone__c, 
            Account.Magasin_actif_en_cours__r.Taux_de_majoration_zone__c, Account.Magasin_actif_en_cours__r.Taux_de_majoration_preparation__c, 
            Account.Magasin_actif_en_cours__r.Taux_de_majoration_livraison__c, 
            Account.Magasin_actif_en_cours__r.Taux_de_majoration_preparation_drive__c,Account.Magasin_actif_en_cours__r.CA_debut_tranche_1__c, 
            Account.Magasin_actif_en_cours__r.CA_debut_tranche_2__c, Account.Magasin_actif_en_cours__r.CA_debut_tranche_3__c, 
            Account.Magasin_actif_en_cours__r.CA_debut_tranche_4__c, Account.Magasin_actif_en_cours__r.CA_debut_tranche_5__c,
            Account.Magasin_actif_en_cours__r.CA_fin_tranche_1__c, Account.Magasin_actif_en_cours__r.CA_fin_tranche_2__c,Account.Magasin_actif_en_cours__r.CA_fin_tranche_3__c,
            Account.Magasin_actif_en_cours__r.CA_fin_tranche_4__c, Account.Magasin_actif_en_cours__r.CA_fin_tranche_5__c,Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_1__c, 
            Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_2__c,Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_3__c,Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_4__c, 
            Account.Magasin_actif_en_cours__r.Forfait_livraison_CA_tranche_5__c, Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_1__c, Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_2__c, 
            Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_3__c, 
            Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_4__c, Account.Magasin_actif_en_cours__r.Taux_majoration_CA_tranche_5__c, Account.Magasin_actif_en_cours__r.Montant_FEF__c,Account.Frais_autorisations__r.Id,
            Account.Frais_autorisations__r.Zone_territoriale__c, Account.Frais_autorisations__r.Code_zone_de_chalandise__c, Account.Frais_autorisations__r.Frais_de_Drive__c, Account.Frais_autorisations__r.Frais_de_livraison__c, Account.Frais_autorisations__r.Type_de_frais_de_livraison__c,
            Account.Frais_autorisations__r.Forfait_Livraison__c, Account.Frais_autorisations__r.Forfait_majoration_livraison__c, Account.Frais_autorisations__r.Forfait_majoration_zone__c,
            Account.Frais_autorisations__r.Taux_de_majoration_zone__c, Account.Frais_autorisations__r.Taux_de_majoration_preparation__c, Account.Frais_autorisations__r.Taux_de_majoration_livraison__c, 
            Account.Frais_autorisations__r.Taux_de_majoration_preparation_drive__c,Account.Frais_autorisations__r.CA_debut_tranche_1__c, Account.Frais_autorisations__r.CA_debut_tranche_2__c,
            Account.Frais_autorisations__r.CA_debut_tranche_3__c, Account.Frais_autorisations__r.CA_debut_tranche_4__c, Account.Frais_autorisations__r.CA_debut_tranche_5__c,Account.Frais_autorisations__r.CA_fin_tranche_1__c, 
            Account.Frais_autorisations__r.CA_fin_tranche_2__c, Account.Frais_autorisations__r.CA_fin_tranche_3__c, Account.Frais_autorisations__r.CA_fin_tranche_4__c, Account.Frais_autorisations__r.CA_fin_tranche_5__c, 
            Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_1__c, Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_2__c, Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_3__c, 
            Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_4__c, Account.Frais_autorisations__r.Forfait_livraison_CA_tranche_5__c, 
            Account.Frais_autorisations__r.Taux_majoration_CA_tranche_1__c, Account.Frais_autorisations__r.Taux_majoration_CA_tranche_2__c, Account.Frais_autorisations__r.Taux_majoration_CA_tranche_3__c, Account.Frais_autorisations__r.Taux_majoration_CA_tranche_4__c, Account.Frais_autorisations__r.Taux_majoration_CA_tranche_5__c,Account.Frais_autorisations__r.Indicateur_FEF__c
            FROM WebCart 
            WHERE Id = :cartId];
        return cart;      
    }
    
    /* Aida le 08/11: getCodeDeChandise method */
    private static String getCodeZoneDeChalandise(String shippingPostalCode, String shippingCity, Id magasinId ) {
        
        List<Zone_de_chalandise__c> zoneChalandiseActiveStore = [SELECT id, name, Code_postal_text__c, Magasin__c,Libelle_ville__c,Code_Chalandise__c
                                                                 FROM Zone_de_chalandise__c
                                                                 WHERE Code_postal_text__c =: shippingPostalCode
                                                                 AND Libelle_ville__c =: shippingCity
                                                                 AND Magasin__c =: magasinId];
        
        if (zoneChalandiseActiveStore.isEmpty()) {
            throw new B2BSplitOrdersException('No Zone_de_chalandise__c record was found');
        }
        
        return zoneChalandiseActiveStore[0].Code_Chalandise__c; 
    }
    public class B2BSplitOrdersException extends Exception {}
}