/**
* @author       Maud VAsseur - IBM Lille
* @date         02/2021
* @description  Class for LookupMagasinOrder Process builder
**/
public without sharing class PB_LookupMagasinOrder {
    
    @InvocableMethod(label='Get Ref Produit Magasin' description='Fills in the Ref Produit Magasin field of the order from the Magasin and Product of the OPM.' category='Order')
    public static void getRefProductMagasin(List<Id> ids) {
        List<OrderItem> orderItems = 
            [SELECT Id, Etablissement_maitre__c, Ref_Produit_Magasin__c, Product2Id 
             FROM OrderItem 
             WHERE Id IN :ids];   
        Set<Id> productIds = Pluck.ids(OrderItem.Product2Id, orderItems);
        Set<Id> magasinIds = Pluck.ids(OrderItem.Etablissement_maitre__c, orderItems);
        List<Offre_Produit_Magasin__c> opms = 
            [SELECT Id, Magasin__c, Produit__c 
        	 FROM Offre_Produit_Magasin__c 
        	 WHERE Produit__c = :productIds 
             AND Magasin__c = :magasinIds];
        for (OrderItem orderItem : orderItems) {
            for (Offre_Produit_Magasin__c opm : opms) {
                if (orderItem.Product2Id == opm.Produit__c && orderItem.Etablissement_maitre__c == opm.Magasin__c) {
                    orderItem.Ref_Produit_Magasin__c = opm.Id;
                }
            }
        }
        update orderItems;
    }
  }