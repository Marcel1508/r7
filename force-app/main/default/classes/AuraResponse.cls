/* .
This class is the part of framework use for lightning response.
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          22-04-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 
public without sharing class AuraResponse {
   
    @AuraEnabled @testVisible
    public Boolean isSuccess{get; set;}
   
    @AuraEnabled @testVisible
    public String message{get; set;}
   
    @AuraEnabled @testVisible
    public String response{get; set;}
   
    public AuraResponse(Boolean isSuccess, String message, String response) {
        this.isSuccess = isSuccess;
        this.message   = message;
        this.response  = response;
    }
    public String returnResponse() {
        return response;
    }
}