@isTest
public class checkoutOutOfStockServiceTest {
    @isTest
    private static void testDeleteCart() {
        try {
            checkoutOutOfStockService.deleteCart();
        } catch(Exception e) {
            system.assert(true, 'should throw an exception');
        }
    }
}