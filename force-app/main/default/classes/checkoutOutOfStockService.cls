public without sharing class checkoutOutOfStockService {
    public class RequestWrapper {
        @InvocableVariable(required=true)
        public Id cartId;
        @InvocableVariable(required=true)
        public Id inStockOrderId;
    }
    
    @InvocableMethod(label='Delete the cart' description='Delete cart in case of order with outofstock products' category='Promocash')
    public static void deleteCart() {
        System.debug('Delete cart');
        Id webstoreId = (Test.isRunningTest())? null: [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
        ConnectApi.CommerceCart.deleteCart(webstoreId, null, 'current');
    }
}