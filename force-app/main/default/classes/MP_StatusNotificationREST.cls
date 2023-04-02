/**
* @author       jan.straka@bluewolf
* @date         2021-03-12
* @description  REST API to be used by MarketPay as a callback for async payment status notifications.
                The system must respond to this request with a HTTP status code "200" and the content "OK". 
                If the response differs, the Gateway will continue to send the notification in increasing intervals"
                https://marketpay.paymentsandbox.cloud/documentation/gateway#asynchronous-status-notification
**/
@RestResource(urlMapping='/mpPreauthorizeCallback')
global class MP_StatusNotificationREST {

    private static final String PREAUTHORIZED_SUCCESS = 'Preauthorized - Success';
    private static final String PREAUTHORIZED_ERROR = 'Preauthorized - Error';

    @HttpPost
    global static void incomingStatusNotification() {
        RestResponse res = RestContext.response;
        try {
            MP_StatusResponse req = MP_StatusResponse.parse(RestContext.request.requestBody.toString());
            if (String.isBlank(req.uuid)) {
                throw new MP_StatusNotificationRESTException('Uuid is required');
            }
            List<Order> orders = [SELECT Id FROM Order WHERE Preauthorize_Uuid__c = :req.uuid];
            
            if (orders.size() != 1) {
                throw new MP_StatusNotificationRESTException('Cannot identify order with Uuid = ' + req.uuid);
            }

            Order order = orders[0];
            if (req.result == 'OK') {
                order.Preauthorize_Status__c = PREAUTHORIZED_SUCCESS;
            } else {
                order.Preauthorize_Status__c = PREAUTHORIZED_ERROR;
            }
            order.Preauthorize_Callback_Response__c = req.body;
            update order;

            res.responseBody = Blob.valueOf('OK');
            res.statusCode = 200;
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
     }

     public class MP_StatusNotificationRESTException extends Exception {}
}