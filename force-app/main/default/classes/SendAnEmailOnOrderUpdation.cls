/* .
class used for send email to user on update of order status field.Class invoke from process builder 'Show all versionsOrder : email when status change 2'
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          03-05-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 
public without sharing class SendAnEmailOnOrderUpdation {
    private static final String CUSTOM_NOTIFICATION_TITLE= System.Label.Facture_editee;
    private static final String CUSTOM_NOTIFICATION_BODY= System.Label.custom_notification_body;
    public static final String EMAIL_TEMPLATE_DEVELOPER_NAME = 'Commande_termin_e';
    public static final String CUSTOM_NOTIFICATION_TYPE_DEVELOPER_NAME = 'Facture_PDF_disponible';
    
    @InvocableMethod(label='Send an email from apex class' description='sends an email')
    public static void sendEmailWithAttachment(List<Id> orderIds)
    {
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            Map<Id,Order> orderMap=new Map<Id,Order>([Select Id,CreatedBy.Email,CreatedById,CreatedBy.ContactId,TotalTaxAmount,TotalAmount,OrderNumber  from Order where Id in : orderIds ]);
            List<EmailTemplate> emailTemplate=[SELECT Id, Name,DeveloperName,HtmlValue FROM EmailTemplate where DeveloperName =:EMAIL_TEMPLATE_DEVELOPER_NAME];
            CustomNotificationType notificationType = [SELECT Id, DeveloperName  FROM CustomNotificationType WHERE DeveloperName=:CUSTOM_NOTIFICATION_TYPE_DEVELOPER_NAME];

            Map<Id,Messaging.EmailFileAttachment> mapAttachment=getEmailAttachment(orderMap.keyset())!=null ? getEmailAttachment(orderMap.keyset()): new Map<Id,Messaging.EmailFileAttachment>();

            for(Order orderRecord : orderMap.values()){
               
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(orderRecord.CreatedBy.ContactId) ; 
                message.setWhatId(orderRecord.Id);
                message.setTemplateId(emailTemplate[0].Id);
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(false);
                if(!mapAttachment.isEmpty() && mapAttachment.containsKey(orderRecord.Id)){
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    attachments.add(mapAttachment.get(orderRecord.Id));
                    message.setFileAttachments(attachments);      
                }
                String[] emailIds= new String[]{orderRecord.CreatedBy.Email};
                message.setToAddresses(emailIds);
                mails.add(message); 

                // add for custom notification to community user 
                Messaging.CustomNotification notification= new Messaging.CustomNotification();
                
                // Set the contents for the notification
                notification.setTitle(CUSTOM_NOTIFICATION_TITLE);
                notification.setBody(CUSTOM_NOTIFICATION_BODY);
                    
                // Set the notification type and target
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(orderRecord.Id);
                            
                Set<String> addressee = new Set<String>();
                addressee.add(orderRecord.CreatedById);
               
               // Actually send the notification
                notification.send(addressee);
            }
            
                   
            Messaging.SendEmailResult[] results =  Messaging.sendEmail(mails);
			

        }catch (Exception ex) {
                    }
    }



    //map Order id and files*****
    public static Map<Id,Messaging.EmailFileAttachment> getEmailAttachment(Set<Id> orderIds){

        set<Id> contentDocumentIds=new set<Id>();
        Map<Id,Messaging.EmailFileAttachment> emailAttachmentMap=new Map<Id,Messaging.EmailFileAttachment>();
        Map<Id,Id> contentDocVsOrderIDMap=new Map<Id,Id>();
        List<Facture__c> factureList=new List<Facture__c>();
        factureList =[Select id,Commande__c,(Select Id, LinkedEntityId, ContentDocumentId from ContentDocumentLinks Limit 1) from Facture__c where Commande__c in : orderIds];

        for(Facture__c fac : factureList){

            if(fac.ContentDocumentLinks!=null || !fac.ContentDocumentLinks.isEmpty()){
                contentDocumentIds.add(fac.ContentDocumentLinks[0].ContentDocumentId);
                contentDocVsOrderIDMap.put(fac.ContentDocumentLinks[0].ContentDocumentId,fac.Commande__c);
            }
            
        }

        if(!contentDocumentIds.isEmpty()){

            for(ContentVersion cversion : [SELECT title, PathOnClient, FileType,versiondata ,ContentDocumentId
											  FROM contentversion 
											  WHERE ContentDocumentId IN :contentDocumentIds ]){
             
              blob filebody = cversion.versiondata;
			  Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
			  efa.setFileName(cversion.title+'.'+cversion.FileType);
			  efa.setBody(filebody);

              if(contentDocVsOrderIDMap.containsKey(cversion.ContentDocumentId)){
                emailAttachmentMap.put(contentDocVsOrderIDMap.get(cversion.ContentDocumentId),efa);
              }
            }
            return emailAttachmentMap;
                    }
        return null;  
    }
    
}