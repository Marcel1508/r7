/**
* @author       jan.straka@bluewolf
* @date         2021-03-11
* @description  MarketPay Preauthorize API request body wrapper
**/
public without sharing class MP_PreauthorizeRequest {
    public String merchantTransactionId;
    public String merchantMetaData;
    public String description;
    public String amount;
    public String xcurrency; 
    public String successUrl;
    public String errorUrl;
    public String callbackUrl;
   // public String description;
    public Customer customer;
    public CustomerProfileData customerProfileData;
    public String language;

    public class Customer {
        public String identification;
        public String firstName;
        public String lastName;
        public String gender;
        public String billingAddress1;
        public String billingCity;
        public String billingPostcode;
        public String billingCountry;
        public String billingPhone;
        public String shippingFirstName;
        public String shippingLastName;
        public String shippingCompany;
        public String shippingAddress1;
        public String shippingCity;
        public String shippingPostcode;
        public String shippingCountry;
        public String shippingPhone;
        public String company;
        public String email;
    }

    public class CustomerProfileData {
        public String customerIdentification;
    }

    private static MarketPay_Setting__mdt mpSettings;
    private static Map<String,StaticResource> staticResources;

    @TestVisible
    private static Datetime timeNOW = Datetime.now();

    private MP_PreauthorizeRequest(Order order, Contact contact, User currentUser, Magasin__c magasin) {
        this.merchantTransactionId = timeNOW + '_' + order.Id;
        this.merchantMetaData = ' ';
        this.description = order.OrderNumber;
        this.amount = String.valueOf((order.GrandTotalAmount * (1 + magasin.Pourcentage_additionel_carte__c / 100)).setScale(2));
        this.xcurrency = order.CurrencyIsoCode;
        this.successUrl = getResourceURL(mpSettings.staticResourceSuccessName__c);
        this.errorUrl = getResourceURL(mpSettings.staticResourceErrorName__c);
        this.callbackUrl = mpSettings.preauthorizeCallbackUrl__c;
        //this.description = order.Description;
        this.language = currentUser.LanguageLocaleKey;
        
        this.customer = new MP_PreauthorizeRequest.Customer();
        this.customer.identification = contact.Id;
        this.customer.firstName = contact.FirstName;
        this.customer.lastName = contact.LastName;
        this.customer.gender = getGender(contact.Salutation);
        this.customer.billingAddress1 = order.BillingAddress.getStreet();
        this.customer.billingCity = order.BillingAddress.getCity();
        this.customer.billingPostcode = order.BillingAddress.getPostalCode();
        this.customer.billingCountry = order.BillingAddress.getCountryCode();//added by ajay
        this.customer.billingPhone = getPhone(contact);
        if (order.ShippingAddress != null) {
            this.customer.shippingFirstName = contact.FirstName;
            this.customer.shippingLastName = contact.LastName;
            this.customer.shippingCompany = order.Account.Name;
            this.customer.shippingAddress1 = order.ShippingAddress.getStreet();
            this.customer.shippingCity = order.ShippingAddress.getCity();
            this.customer.shippingPostcode = order.ShippingAddress.getPostalCode();
            this.customer.shippingCountry = order.ShippingAddress.getCountryCode();//added by ajay
            this.customer.shippingPhone = getPhone(contact);
        }
        this.customer.company = order.Account.Name;
        this.customer.email = contact.Email;

        this.customerProfileData = new MP_PreauthorizeRequest.CustomerProfileData();
        this.customerProfileData.customerIdentification = contact.Id;
    }

    private static Map<String,StaticResource> getStaticResources() {
        Map<String, StaticResource> returnMap = new Map<String, StaticResource>();
        for (StaticResource sr : [
            SELECT Name, NamespacePrefix, SystemModStamp 
            FROM StaticResource 
            WHERE Name IN (
                :mpSettings.staticResourceSuccessName__c, 
                :mpSettings.staticResourceErrorName__c)]
        ) {
            returnMap.put(sr.Name, sr);
        }
        return returnMap;
    }

    private static String getResourceURL(String resourceName) {
        StaticResource sr = staticResources.get(resourceName);
        if (sr != null) {
            return mpSettings.communityUrl__c + '/promocash/resource/' + sr.SystemModStamp.getTime() + '/' + resourceName;
        } 
        return null;
    }

    private static String getGender(String salutation) {
        return 
            new Set<String> {'M'}.contains(salutation) ? 'M' :
            new Set<String> {'Mlle', 'MME'}.contains(salutation) ? 'F' :
            null;
    }

    private static String getPhone(Contact contact) {
        return 
            contact.Phone != null ? contact.Phone.replace('+', '00').replace(' ', '') :
            contact.Telephone_portable__c != null ? contact.Telephone_portable__c.replace('+', '00').replace(' ', '') :
            contact.MobilePhone != null ? contact.MobilePhone.replace('+', '00').replace(' ', '') :
            contact.AssistantPhone != null ? contact.AssistantPhone.replace('+', '00').replace(' ', '') :
            contact.HomePhone != null ? contact.HomePhone.replace('+', '00').replace(' ', '') :
            contact.OtherPhone != null ? contact.OtherPhone.replace('+', '00').replace(' ', '') :
            null;
    }

    public static String getRequestBodyString(Order order, Contact contact, User currentUser, Magasin__c magasin, MarketPay_Setting__mdt mpSetting) {
        mpSettings = mpSetting;
        staticResources = getStaticResources();

        MP_PreauthorizeRequest requestBody = 
            new MP_PreauthorizeRequest(order, contact, currentUser, magasin);
        String requestBodyString = JSON.serialize(requestBody, false /* suppressApexObjectNulls */);

        requestBodyString = requestBodyString.replace('"firstName":null,', '');
        requestBodyString = requestBodyString.replace('"gender":null,', '');
        requestBodyString = requestBodyString.replace('"email":null,', '');

        requestBodyString = requestBodyString.replace('"shippingPostcode":null,', '');
        requestBodyString = requestBodyString.replace('"shippingLastName":null,', '');
        requestBodyString = requestBodyString.replace('"shippingFirstName":null,', '');
        requestBodyString = requestBodyString.replace('"shippingCountry":null,', '');
        requestBodyString = requestBodyString.replace('"shippingCompany":null,', '');
        requestBodyString = requestBodyString.replace('"shippingCity":null,', '');
        requestBodyString = requestBodyString.replace('"shippingAddress2":null,', '');
        requestBodyString = requestBodyString.replace('"shippingAddress1":null,', '');
        requestBodyString = requestBodyString.replace('"shippingState":null,', '');
        requestBodyString = requestBodyString.replace('"shippingPhone":null,', '');

        requestBodyString = requestBodyString.replace('"billingAddress1":null,', '');
        requestBodyString = requestBodyString.replace('"billingPostcode":null,', '');
        requestBodyString = requestBodyString.replace('"billingCity":null,', '');
        requestBodyString = requestBodyString.replace('"billingCountry":null,', '');
        requestBodyString = requestBodyString.replace('"billingPhone":null,', '');

        requestBodyString = requestBodyString.replace('xcurrency', 'currency');

        return requestBodyString;
    }
}