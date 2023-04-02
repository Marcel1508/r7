@isTest
public class OrderSummaryButtonsControllerTest {
    
    @isTest
    private static void testDisableButtons() {
        OrderSummary mock = new OrderSummary();
        OrderSummaryButtonsController.orderSummaryMock = mock;
        OrderSummaryButtonsController.disableButtons(null);
    }
    
    @isTest
    private static void cancelOrder() {
        OrderSummary mock = new OrderSummary();
        OrderSummaryButtonsController.orderSummaryMock = mock;
        try {
            OrderSummaryButtonsController.cancelOrder(null);
        } catch(Exception e) {}
    }
    
    @isTest
    private static void orderAgain() {
        OrderSummary mock = new OrderSummary();
        List<OrderItem> orderItemsMock = new List<OrderItem>{new OrderItem()};
        
        OrderSummaryButtonsController.orderSummaryMock = mock;
        OrderSummaryButtonsController.orderItemsMock = orderItemsMock;
        try {
            OrderSummaryButtonsController.orderAgain(null);
        } catch(Exception e) {}
    }
    
    @isTest
    private static void adjustOrder() {
        OrderSummary mock = new OrderSummary();
        List<OrderItem> orderItemsMock = new List<OrderItem>{new OrderItem()};
        
        OrderSummaryButtonsController.orderSummaryMock = mock;
        OrderSummaryButtonsController.orderItemsMock = orderItemsMock;
        try {
            OrderSummaryButtonsController.adjustOrder(null);
        } catch(Exception e) {}
    }
}