public without sharing class FormatPhoneNumberBatch implements Database.Batchable<sObject> {
    
    String accountShipCountry;
    String codeCountry;
    
    public FormatPhoneNumberBatch(String accountShipCountry, String codeCountry) {
        this.accountShipCountry = accountShipCountry;
        this.codeCountry = codeCountry;
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Telephone_portable__c , formattedPhone__c,Phone2__c, Account.ShippingCountry FROM Contact where Telephone_portable__c != null and Account.ShippingCountry = \''+accountShipCountry+'\' and Telephone_portable__c != \'0\'';
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext BC, List<Contact> contactList) {
             for(Contact ctc : contactList) {    
                 if(ctc.formattedPhone__c == null || ctc.Phone2__c == null){    
                                                            ctc.formattedPhone__c =  Utilities.formatPhone(ctc.Telephone_portable__c, codeCountry);
                    ctc.Phone2__c =  Utilities.formatPhone(ctc.Telephone_portable__c, codeCountry);
                }
            }
            try {
                update contactList;
            } catch(Exception e) {
                            }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}