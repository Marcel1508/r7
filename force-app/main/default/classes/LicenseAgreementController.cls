public with sharing class LicenseAgreementController {

    @AuraEnabled
    public static String getLicenseAgreement() {
        LicenseAgreement__mdt licenseAgreement = [SELECT Content__c FROM LicenseAgreement__mdt WHERE DeveloperName = 'CGU_and_CGV'];
        return licenseAgreement.Content__c;
    }
}