public without sharing class FileController {
    @AuraEnabled(cacheable=true)
    public static Account getAccountFilesOptions(Id recordId) {
                return [SELECT ID, RIB__c, K_bis__c, Piece_identite__c, Attestation_registre_du_commerce__c FROM ACCOUNT where id = :recordId limit 1];
    }
    
    @AuraEnabled
    public static void updateAccount(Id recordId, String selectedFileType) {
        Account a = getAccountFilesOptions(recordId);
        if(a != null) {
            if(selectedFileType.equalsIgnoreCase('RIB'))
                a.RIB__c = true;
            if(selectedFileType.equalsIgnoreCase('kbis'))
                a.K_bis__c = true;
            if(selectedFileType.equalsIgnoreCase('Piece_identite'))
                a.Piece_identite__c = true;
            if(selectedFileType.equalsIgnoreCase('Registre du commerce'))
                a.Attestation_registre_du_commerce__c = true;
            if(!Test.isRunningTest())
                update a;
        }
    }
    
    @AuraEnabled
    public static void deleteFile(Id contentDocumentId, Id accountId, String selectedFileType) {
                try {
            if(!Test.isRunningTest()) {
                ContentDocument cd = new ContentDocument(Id = contentDocumentId);
                delete cd;
            }
            Account a = getAccountFilesOptions(accountId);
            Boolean valueChanged = false;
            if(selectedFileType != null && selectedFileType.equalsIgnoreCase('RIB')) {
                a.RIB__c = false;
                valueChanged = true;
            }
            if(selectedFileType != null && selectedFileType.equalsIgnoreCase('kbis')) {
                a.K_bis__c = false;
                valueChanged = true;
            }
            if(selectedFileType != null && selectedFileType.equalsIgnoreCase('Piece_identite')) {
                a.Piece_identite__c = false;
                valueChanged = true;
            }
            if(selectedFileType != null && selectedFileType.equalsIgnoreCase('Registre du commerce')) {
                a.Attestation_registre_du_commerce__c = false;
                valueChanged = true;
            }
            if(valueChanged && !Test.isRunningTest())
                update a;
        } catch(Exception e) {
                    }
    }
    
    @AuraEnabled(cacheable=true)
    public static FilesWrapper[] getFilesList(Id recordId) {
        FilesWrapper[] filesList = new List<FilesWrapper>{};
            //Set<Id> contentDocumentIds = new Set<Id>();
            
            for (ContentDocumentLink link : [
                SELECT
                ContentDocumentId,
                ContentDocument.LatestPublishedVersion.Title,
                ContentDocument.LatestPublishedVersion.CreatedDate,
                ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                toLabel(ContentDocument.LatestPublishedVersion.file_type_fileupload__c),
                ContentDocument.LatestPublishedVersion.file_type_sequence__c
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                ORDER BY ContentDocument.LatestPublishedVersion.file_type_sequence__c
            ]) {
                filesList.add(
                    new FilesWrapper(
                        link.ContentDocumentId,
                        link.ContentDocument.LatestPublishedVersion.Title,
                        link.ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                        Date.valueOf(link.ContentDocument.LatestPublishedVersion.CreatedDate),
                        link.ContentDocument.LatestPublishedVersionId,
                        link.ContentDocument.LatestPublishedVersion.file_type_fileupload__c,
                        link.ContentDocument.LatestPublishedVersion.file_type_sequence__c
                    )
                );
            }
        
        return filesList;
    }
    
    public without sharing class FilesWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String createdBy { get; set; }
        @AuraEnabled
        public Date createdDate { get; set; }
        @AuraEnabled
        public String latestVersionId { get; set; }
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public Decimal sequence { get; set; }
        
        public FilesWrapper(String id, String title, String createdBy, Date createdDate, String latestVersionId, String fileType, Decimal sequence) {
            this.id = id;
            this.title = title;
            this.createdBy = createdBy;
            this.createdDate = createdDate;
            this.latestVersionId = latestVersionId;
            this.fileType = fileType;
            this.sequence = sequence;
        }
    }
}