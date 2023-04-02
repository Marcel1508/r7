/*
* @author       Preethi.u@ibm.com
* @date         2021-04-26
* @description  Controller for CheeckoutOrderSummary component
*/
public with sharing class CheckoutOrderSummaryCtrl {
    
    @AuraEnabled
    public static CheckoutSummaryWrapper getCheckoutSummary(String inStockOrderId, String outOfStockOrderId) { 
        CheckOutSummaryWrapper wrapper = new CheckOutSummaryWrapper();
        
        //InStockOrder logic
        Map<Id,Order> orders = getOrders(inStockOrderId,outOfStockOrderId);
        if(inStockOrderId != null)
        {
            Order inStockOrder = orders.get(inStockOrderId);
            if (inStockOrder == null) {
                throw Utilities.newAuraHandledException('In Stock Order was not found [ID: ' + inStockOrderId + ']');      
            }
            List<OrderDeliveryGroup> orderDeliveryGroups = inStockOrder.OrderDeliveryGroups;
            if (orderDeliveryGroups.isEmpty() || orderDeliveryGroups == null) {
                throw Utilities.newAuraHandledException('Order Delivery Group was not found [Order ID: ' + inStockOrderId + ']');
            }
            if(inStockOrder.Account.Magasin_actif_en_cours__r.Id == null)
            {
                throw Utilities.newAuraHandledException('Magasin Actif was not found [ID: ' + inStockOrder.Account.Magasin_actif_en_cours__c + ']');
            }
            if(inStockOrder.Tech_Creneau_Salesforce__r.id == null ) {
                throw Utilities.newAuraHandledException('Creneau Salesforcce was not found [ID: ' + inStockOrder.Tech_Creneau_Salesforce__c + ']');
            }
            
            Magasin__c magasin = new Magasin__c(Id=inStockOrder.Account.Magasin_actif_en_cours__r.Id, Adresse_1_drive__c=inStockOrder.Account.Magasin_actif_en_cours__r.Adresse_1_drive__c, Adresse_2_drive__c=
                                                inStockOrder.Account.Magasin_actif_en_cours__r.Adresse_2_drive__c, Adresse_du_drive_deporte__c = inStockOrder.Account.Magasin_actif_en_cours__r.Adresse_du_drive_deporte__c, 
                                                Montant_FEF__c = inStockOrder.Account.Magasin_actif_en_cours__r.Montant_FEF__c);
            
            Creneau_Salesforce__c creneauClient = new Creneau_Salesforce__c(Id= inStockOrder.Tech_Creneau_Salesforce__r.id, Date__c = inStockOrder.Tech_Creneau_Salesforce__r.Date__c,Heure_de_debut__c = inStockOrder.Tech_Creneau_Salesforce__r.Heure_de_debut__c);
            
            wrapper.inStockOrder = inStockOrder;
            wrapper.orderDeliveryGroup = inStockOrder.OrderDeliveryGroups[0];
            wrapper.magasin = magasin;
            wrapper.slot = creneauClient;
            wrapper.slotDate = creneauClient.Date__c.format();
            wrapper.slotTime = String.valueOf(creneauClient.Heure_de_debut__c).left(8);
            
            List<Frais__c> frais = getFrais(magasin.Id,inStockOrder.AccountId);
            if (!frais.isEmpty()) {
                wrapper.indicateurFEF = frais[0].Indicateur_FEF__c;
                Decimal montantLivraison =  inStockOrder.TotalAdjustedDeliveryAmount - magasin.Montant_FEF__c;
                wrapper.montantLivraison = montantLivraison;
            }
            
            Decimal taxesConsigne = 0;
            List<OrderItemTaxLineItem> orderConsigneTaxes = inStockOrder.OrderItemTaxLineItems;
            if(orderConsigneTaxes != null && !orderConsigneTaxes.isEmpty())
            {
                for(OrderItemTaxLineItem oit: orderConsigneTaxes ) {
                    taxesConsigne= taxesConsigne+ oit.Amount;
                }             
            }
            wrapper.totalTaxesConsigne=taxesConsigne;
            
            if(outOfStockOrderId != null)
            {
                Order outOfStockOrder = orders.get(outOfStockOrderId);
                if (outOfStockOrder == null) {
                    throw Utilities.newAuraHandledException('Out of Stock Order was not found [ID: ' + outOfStockOrderId + ']');  
                }
                wrapper.outStockOrder = outOfStockOrder;  
            }
            
        } else if(outOfStockOrderId != null)
        {
            List<Order> outOfStockOrders = getOutOfTheStockOrder(outOfStockOrderId);
            if (outOfStockOrders.isEmpty()) {
                throw Utilities.newAuraHandledException('Out of Stock Order was not found [ID: ' + outOfStockOrderId + ']');
            }
            
            wrapper.outStockOrder = outOfStockOrders[0];
        }
        return wrapper;
    }
    
    public class CheckoutSummaryWrapper{
        @AuraEnabled
        public Magasin__c magasin;
        @AuraEnabled
        public Creneau_Salesforce__c slot;
        @AuraEnabled
        public Order inStockOrder;
        @AuraEnabled
        public Order outStockOrder;
        @AuraEnabled
        public OrderDeliveryGroup orderDeliveryGroup;
        //modified date to string by ajay-12/01/2022
        @AuraEnabled
        public String slotDate;
        @AuraEnabled
        public String slotTime;
        @AuraEnabled
        public String indicateurFEF; 
        @AuraEnabled
        public Decimal montantLivraison;
        @AuraEnabled
        public Decimal totalTaxesConsigne; 
    }
    
    private static Map<Id,Order> getOrders(String inStockOrderId, String outOfStockOrderId){
        List<String> orderIds = new List<String>();
        if(inStockOrderId != null)
        {
            orderIds.add(inStockOrderId);
        }
        if(outOfStockOrderId != null)
        {
            orderIds.add(outOfStockOrderId); 
        }
        Map<Id,Order> orders = new Map<Id,Order>([SELECT Id, ShippingStreet, ShippingCity, ShippingCountry, ShippingPostalCode, TotalAmount, TotalTaxAmount, Commande_en_stock__c, TotalAdjustedDeliveryAmount, 
                                                  Instructions_de_livraison__c,Account.Magasin_actif_en_cours__c,Account.Magasin_actif_en_cours__r.Id,Account.Magasin_actif_en_cours__r.Adresse_1_drive__c, 
                                                  Account.Magasin_actif_en_cours__r.Adresse_2_drive__c, Account.Magasin_actif_en_cours__r.Adresse_du_drive_deporte__c, Account.Magasin_actif_en_cours__r.Montant_FEF__c,
                                                  Tech_Creneau_Salesforce__c,Tech_Creneau_Salesforce__r.id, Tech_Creneau_Salesforce__r.Date__c,Tech_Creneau_Salesforce__r.Heure_de_debut__c, AccountId,
                                                  (SELECT Id, OrderId, Name, Amount FROM OrderItemTaxLineItems where Name='Consigne'),
                                                  (SELECT OrderDeliveryMethodId, OrderDeliveryMethod.Name FROM OrderDeliveryGroups)
                                                  FROM Order 
                                                  WHERE Id IN :orderIds]);
        
        return Orders;
    }
    
    private static List<Order> getOutOfTheStockOrder(String outOfStockOrderId){
        
        List<Order> outStockOrders = [
            SELECT Id, TotalAmount,TotalTaxAmount,Commande_en_stock__c
            FROM Order 
            WHERE Id = :outOfStockOrderId];
        
        return outStockOrders;
    } 
    
    private static List<Frais__c> getFrais(String magasinId, String accountId)
    {
        List<Frais__c> frais = [
            SELECT Id, Indicateur_FEF__c
            FROM Frais__c 
            WHERE Magasin_Associe__c = :magasinId and Account__c = :accountId];
        return frais;
    }
    
    
    
    
    
    
    /* you should maybe use this when you have the order ids:    
List<OrderSummary> orderSummary =  [SELECT Id, OriginalOrderId, TotalAdjDistAmount, TotalProductAdjDistAmount, TotalDeliveryAdjDistAmount, TotalTaxAmount,
TotalAmount, GrandTotalAmount From OrderSummary where OriginalOrderId =: orderid];
you can retrieve the ids from the flow (inStockorderId, outOfStockoRderId) if i remember correctly
*/
    // check customLookupController.returnAllTaxes to have an idea of how you can get the taxes from the cart tax object
    //to get order taxes, query this object:  OrderItemTaxLineItem
    //to get cart taxes, query this object:  CartTax
    //to get order promos, query this object:  OrderItemAdjustmentLineItem
    //
    //
    
    
}