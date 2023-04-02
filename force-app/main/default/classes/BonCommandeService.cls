public without sharing class BonCommandeService {
    private static Map<String, String> frenchDaysMap = new Map<String, String>{'Monday'=> 'Lundi', 'Tuesday'=> 'Mardi', 'Wednesday'=> 'Mercredi', 'Thursday'=> 'Jeudi', 
        'Friday'=> 'Vendredi', 'Saturday'=> 'Samedi', 'Sunday'=> 'Dimanche'};
            
            public static List<BonCommandePdfController.BonPreparationWr> constructJSON(List<Id> ordersIds, Set<String> rayons, Boolean withProductPicture) {
                List<BonCommandePdfController.BonPreparationWr> res = new List<BonCommandePdfController.BonPreparationWr>();
                list<Order> ordersList = getOrderList(ordersIds);
                Map<Id, List<OrderItem>> orderItemsByOrderId = getOrderItemsByOrderId(ordersList, rayons);
                
                for(Order ord: ordersList) {
                    BonCommandePdfController.BonPreparationWr bn = new BonCommandePdfController.BonPreparationWr();
                    bn.withProductPicture = withProductPicture;
                    bn.numCommande = ord.OrderNumber;
                    bn.numClient = ord.Account.N_client__c;
                    bn.raisonSociale = ord.Account.Name;
                    bn.montantTotalTTC = ord.TotalAmount;
                    bn.contact = ord.CreatedBy.Contact.Telephone_portable__c;
                    bn.paiement = ord.Moyen_de_Paiement__c;
                    bn.commentaires = ord.Instructions_de_livraison__c;
                    bn.cssClass = 'page-break';
                    bn.nombreProduits =  0;
                    bn.nombreReferences = 0;
                    /********Livraison********/
                    BonCommandePdfController.Livraison liv = new BonCommandePdfController.Livraison();
                   //liv.modeRetrait = ord.Mode_de_retrait__c;
                    liv.modeRetrait = getLalelPicklistByValue(ord.Mode_de_retrait__c);
                    if(ord.Creneau_client__r.Creneau_Salesforce__r.Date__c != null) {
                        liv.dateLivraison = getFormattedDateLivraison(ord.Creneau_client__r.Creneau_Salesforce__r.Date__c);
                        system.debug('liv.dateLivraison: ' + liv.dateLivraison);
                        liv.heureDebut = ord.Creneau_client__r.Creneau_Salesforce__r.Heure_de_debut__c.hour()+'h'+ord.Creneau_client__r.Creneau_Salesforce__r.Heure_de_debut__c.minute();
                        liv.heureFin = ord.Creneau_client__r.Creneau_Salesforce__r.Heure_de_fin__c.hour()+'h'+ord.Creneau_client__r.Creneau_Salesforce__r.Heure_de_fin__c.minute();
                    }
                    bn.livraison = liv;
                    /********Livraison********/
                    List<BonCommandePdfController.RayonsSelectionne> rayonsSelectionnes = new List<BonCommandePdfController.RayonsSelectionne>();
                    /********orderItems********/
                    List<BonCommandePdfController.ProductWr> products = new List<BonCommandePdfController.ProductWr>();
                    Map<String, List<BonCommandePdfController.ProductWr>> productsByRayon = new Map<String, List<BonCommandePdfController.ProductWr>>();
                    if(orderItemsByOrderId.get(ord.Id) != null) {
                        for(OrderItem oi: orderItemsByOrderId.get(ord.Id)) {
                            if(oi.Product2.Code_rayon__c != null) {
                                BonCommandePdfController.ProductWr pr = new BonCommandePdfController.ProductWr();
                                pr.image = oi.Product2.DisplayUrl;
                                pr.name = oi.Product2.name;
                                pr.conditionnement = oi.Product2.Libelle_du_conditionnement_vente__c;
                                pr.ifls = oi.Product2.Code_IFLS__c;
                                pr.prixHT = oi.UnitPrice;
                                pr.quantity = oi.quantity;
                                pr.cssClass = '';
                                
                                bn.nombreProduits++;
                                bn.nombreReferences += (Integer) pr.quantity;
                                
                                if(productsByRayon.get(oi.Product2.Code_rayon__c) != null) {
                                    productsByRayon.get(oi.Product2.Code_rayon__c).add(pr);
                                } else {
                                    productsByRayon.put(oi.Product2.Code_rayon__c, new List<BonCommandePdfController.ProductWr>{pr});
                                }
                            }
                        }
                    }
                    
                    /********RayonsSelectionnes********/
                    for(String ray: OrdersController.libelleRayonByCode.keySet()) {
                        BonCommandePdfController.RayonsSelectionne rayonsSelectionne = new BonCommandePdfController.RayonsSelectionne();
                        
                        rayonsSelectionne.name = OrdersController.libelleRayonByCode.get(ray);
                        Boolean selected = false;
                        if(productsByRayon.get(ray) != null) { //Rayon selected
                            selected = true;
                        }
                        rayonsSelectionne.selected = selected;
                        rayonsSelectionnes.add(rayonsSelectionne);
                    }
                    /********RayonsSelectionnes********/
                    List<BonCommandePdfController.OrderItemWr> orderItems = new List<BonCommandePdfController.OrderItemWr>();
                    for(String codeRayon: productsByRayon.keySet()) {
                        BonCommandePdfController.OrderItemWr oiw = new BonCommandePdfController.OrderItemWr();
                        oiw.rayon = OrdersController.libelleRayonByCode.get(codeRayon);
                        oiw.codeRayon = codeRayon;
                        oiw.products = productsByRayon.get(codeRayon);
                        orderItems.add(oiw);
                        
                    }
                    /*****Tri Rayons*****/
                    List<BonCommandePdfController.OrderItemWr> orderItemsOrdered = new List<BonCommandePdfController.OrderItemWr>();
                    // **1 == At the first of list, add products of rayon = '23'=>'Brasserie' / '21'=>'Vins - Champagnes' / '22'=>'Alcools'
                    for(BonCommandePdfController.OrderItemWr oi: orderItems) {
                        if(oi.codeRayon == '23' || oi.codeRayon == '21' || oi.codeRayon == '22') {
                            orderItemsOrdered.add(oi);
                        }
                    }
                    // Add normal products (others than **1 and **2)
                    for(BonCommandePdfController.OrderItemWr oi: orderItems) {
                        if(oi.codeRayon != '23' && oi.codeRayon != '21' && oi.codeRayon != '22' && oi.codeRayon != '31' && oi.codeRayon != '36' && oi.codeRayon != '33') {
                            orderItemsOrdered.add(oi);
                        }
                    }
                    // **2 == At the end of list, add products of rayon = '31'=>'Boucherie' / '36'=>'Marée' / '33'=>'Fruits et légumes'
                    for(BonCommandePdfController.OrderItemWr oi: orderItems) {
                        if(oi.codeRayon == '31' || oi.codeRayon == '36' || oi.codeRayon == '33') {
                            orderItemsOrdered.add(oi);
                        }
                    }
                    /*****Tri products*****/
                    Integer counter = 1;
                    Integer rayonsCounter = 1;
                    Integer offset = 3;
                    for(BonCommandePdfController.OrderItemWr oi: orderItemsOrdered) {
                        oi.backgroundColor = 'white';
                        if(Math.mod(rayonsCounter, 2) == 0)
                            oi.backgroundColor = 'rgb(231, 230, 230)';
                        for(BonCommandePdfController.ProductWr pr: oi.products) {
                            if(Math.mod(counter, offset) == 0) {
                                pr.cssClass = 'page-break';
                                offset = 6;
                            }
                            counter++;
                        }
                        rayonsCounter++;
                    }
                    
                    if(orderItemsOrdered.size() > 0) {
                        BonCommandePdfController.OrderItemWr lastOrderItem = orderItemsOrdered.get(orderItemsOrdered.Size() - 1);
                        if(lastOrderItem.products != null && lastOrderItem.products.size() > 0) {
                            lastOrderItem.products.get(lastOrderItem.products.size() - 1).cssClass = '';
                        }
                    }
                    bn.rayonsSelectionnes = rayonsSelectionnes;
                    bn.orderItems = orderItemsOrdered;
                    /********orderItems********/
                    res.add(bn);
                }
                res.get(res.size()-1).cssClass= '';
                updateOrdersStatus(ordersList);
                return res;
            }
    
    
    public static list<Order> getOrderList(List<Id> ordersIds) {
        List<Order> res = [SELECT ID, OrderNumber, Account.N_client__c, Account.Name, TotalAmount, CreatedBy.Contact.Telephone_portable__c, Moyen_de_Paiement__c, toLabel(Mode_de_retrait__c), Instructions_de_livraison__c, Date_de_livraison__c, 
                           Creneau_client__r.Creneau_Salesforce__r.Date__c, Creneau_client__r.Creneau_Salesforce__r.Heure_de_debut__c, Creneau_client__r.Creneau_Salesforce__r.Heure_de_fin__c, 
                           is_BDP_generated__c, status, (SELECT id, OrderId, UnitPrice, Quantity, Product2Id, Product2.name, Product2.Libelle_du_conditionnement_vente__c, Product2.Code_rayon__c, Product2.DisplayUrl, Product2.Code_IFLS__c from OrderItems ) FROM ORDER where id in :ordersIds];
        return res;
    }
    
    public static Map<Id, List<OrderItem>> getOrderItemsByOrderId(List<Order> orderList, Set<String> rayons) {
        Map<Id, List<OrderItem>> orderItemsByOrderId = new Map<Id, List<OrderItem>>();
        if(rayons == null) { // if the user has choosen to view all "rayons", we initialize the set rayons with all "rayons"
            rayons = OrdersController.libelleRayonByCode.KeySet();
        }
        
        List<OrderItem> res = new List<OrderItem>();
        if(orderList != null && !orderList.isEmpty())
        {
            for(Order o : OrderList)
            {
                for( OrderItem oi : o.OrderItems)
                {
                    for(String rayon: rayons)
                    {
                        if(oi.Product2.Code_rayon__c == rayon)
                        {
                            res.add(oi);
                        }
                    }
                }
            }
        }
        
        if( res!= null && res.size() > 0) {
            for(OrderItem oi: res) {
                if(orderItemsByOrderId.get(oi.OrderId) != null) { // OrderId already exists in the map
                    orderItemsByOrderId.get(oi.OrderId).add(oi);
                } else {
                    orderItemsByOrderId.put(oi.OrderId, new List<OrderItem>{oi});
                }
            }
        }
        return orderItemsByOrderId;
    }
    private static String getFormattedDateLivraison(Date theDate) {
        String res = '';
        DateTime dt=DateTime.newInstance(theDate, Time.newInstance(0, 0, 0, 0));
        String dateFormatted=dt.format('dd/MM/yyyy');
        String dayOfAWeek=dt.format('EEEE');
        
        res = frenchDaysMap.get(dayOfAWeek) + ' ' + dateFormatted;
        return res;
    }
    
    public static void updateOrdersStatus(List<Order> ordersList) {
        if(ordersList != null && ordersList.size() > 0) {
            List<Order> ordersToUpdate = new List<Order>();
            for(Order o: ordersList) {
                if(!o.is_BDP_generated__c) {
                    o.Status = '2';
                    o.is_BDP_generated__c = true;
                    ordersToUpdate.add(o);
                }
            }
            if(!ordersToUpdate.isEmpty())
                update ordersToUpdate;
        }
    }

    public static String getLalelPicklistByValue(String value){
        String lalelPicklist ='';
        Map<String, String> lalelPicklistByValue = new Map<String, String>();
         Schema.DescribeFieldResult fieldResult = Order.Mode_de_retrait__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            lalelPicklistByValue.put(pickListVal.getValue(), pickListVal.getLabel());
         }     
         lalelPicklist =  lalelPicklistByValue.get(value);
         return lalelPicklist;
    }

}