/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          22-04-2021           Ajay.Tiwari3 @ibm              Initial Version
--------------------------------------------------------------------------------------
*/ 
public with sharing class ShippingAddressCustomCntrl {

    private static final String ERROR_CONTACT_POINT_ADDRESSES_NOT_FOUND= System.Label.ShippingAddressCustom_ContactPointAddressesNotFound;
    public static final String SUCCESSMESSAGE = 'SUCCESS';
    public static final String ERRORMESSAGE = 'ERROR';
   

    /**
    * @description : get all the contact point address realetd to that account
    * @author Ajay.Kumar Tiwari | 04-23-2021 
    * @param cartId 
    * @return AuraResponse 
    **/
    @AuraEnabled
    public static AuraResponse getContactPointAddress(String cartId) {
        try {
            
            ShippingAddressCustomCntrlWrapper wrap=new  ShippingAddressCustomCntrlWrapper();

            WebCart cart = [SELECT Id, AccountId FROM WebCart WHERE Id = :cartId];
            List<ContactPointAddress> contactPointAddresses = [
                SELECT Id, City, Street, Country, PostalCode 
                FROM ContactPointAddress 
                WHERE ParentId = :cart.AccountId 
                AND AddressType = 'Shipping'];

            if (!contactPointAddresses.isEmpty()) {
                
                List<AddressWrapper> cpAddresses = new List<AddressWrapper>();
                for (ContactPointAddress cpa : contactPointAddresses) {
                    AddressWrapper cpAddress = new AddressWrapper();
                    cpAddress.value = cpa.Id;
                    cpAddress.label = cpa.Street + ', ' + 
                                        cpa.City + ' ' + 
                                        cpa.PostalCode + ' ' + 
                                        cpa.Country;
                    cpAddresses.add(cpAddress);
                }
                wrap.contactPointAddresses=cpAddresses;
                return new AuraResponse(true,SUCCESSMESSAGE,JSON.serialize(wrap));
            } else {
               
                return new AuraResponse(false,ERRORMESSAGE,ERROR_CONTACT_POINT_ADDRESSES_NOT_FOUND);
            }
        } catch (Exception ex) {
                        return new AuraResponse(false,ERRORMESSAGE,ex.getMessage());
        }
    }

    public class AddressWrapper {
         public String value;
         public String label;
    }
    
    public class ShippingAddressCustomCntrlWrapper {
        List<AddressWrapper> contactPointAddresses;
   }

}