public with sharing class Einvoice_Request {

    public String body;
    public String invoiceID;
    public String invoiceCheck;
    public String invoiceNumber;
    public String codeMagasin;
    public String numeroClient;
   
    public static Einvoice_Request parse(String json) {
        Einvoice_Request res = (Einvoice_Request) System.JSON.deserialize(json, Einvoice_Request.class);
        res.body = json;
        return res;
    }

}