/**
*
* Promocash check inventory for the checkout flow
*
*
*/
public without sharing class B2BCheckInventoryCustom {
    @InvocableMethod(label='Check Inventory Promocash' description='Check the available inventory and store the number in the CartItem.AvailableQuantity' category='Promocash')
    public static void checkInventoryPromocash(List<String> cartIds) {
            String cartId = cartIds.get(0);

            // Get all SKUs from cart items.
            List <String> productIdList = new List<String>();

            WebCart cart = [SELECT id,AccountId,(SELECT Product2Id, Sku, Quantity FROM CartItems WHERE Type = 'Product') FROM WebCart WHERE Id = :cartId];

            List<CartItem> cartItemList = cart.CartItems;

            for (CartItem cartItem : cartItemList) {
                productIdList.add(cartItem.Product2Id);
            }

            Map<String,Decimal> productStockMap  = B2BGetInfoCustom.checkStockAndEnCoursForProducts(productIdList,cart.AccountId);

            for (CartItem cartItem : cartItemList) {
                cartItem.Available_Quantity__c=productStockMap.get(cartItem.Product2Id);
            }

            update cartItemList;

    
        
    }
}