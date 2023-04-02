public class FAQCtrl {    
    @AuraEnabled
    public static List<WrapperCMS_FAQ> getMContent(String contentType, String language) {
        
        List<WrapperCMS_FAQ> listArticles = new List<WrapperCMS_FAQ>();
        try{
            ConnectApi.ManagedContentVersionCollection contentCollection = null;
            contentCollection = ConnectApi.ManagedContent.getAllManagedContent(getCommunityId(), null, 250, null, 'PromocashFAQ', null);
            
            
            for(ConnectApi.ManagedContentVersion contentversion: contentCollection.items){
                
                WrapperCMS_FAQ article = new WrapperCMS_FAQ(); 
                
                article.title = contentversion.title;
                article.managedContentId = contentversion.managedContentId;
                
                system.debug('contentversion.contentNodes.values()[0]...'+contentversion.contentNodes.keySet());
                //Traitement du Type FAQ
                //
                ConnectApi.ManagedContentTextNodeValue questionText = (ConnectApi.ManagedContentTextNodeValue)contentversion.contentNodes.get('question');
                if(questionText != null)
                {
                    article.question = questionText.value;
                }
                
                ConnectApi.ManagedContentTextNodeValue answerText = (ConnectApi.ManagedContentTextNodeValue)contentversion.contentNodes.get('answer');
                if(answerText != null)
                {
                    article.answer = answerText.value; 
                }
                
                ConnectApi.ManagedContentTextNodeValue orderText = (ConnectApi.ManagedContentTextNodeValue)contentversion.contentNodes.get('order');
                if(orderText != null)
                {
                    article.order = orderText.value;       
                }
                
                ConnectApi.ManagedContentTextNodeValue categoryText = (ConnectApi.ManagedContentTextNodeValue)contentversion.contentNodes.get('category');
                if(categoryText != null)
                {
                    article.category = categoryText.value;       
                }
                system.debug('article..'+article);         
                if(questionText != null && answerText != null)
                {
                    listArticles.add(article);
                    
                }
                
            }
            
            
            system.debug('listArticles..'+listArticles.size());
            return listArticles;
        }
        catch(ConnectApi.ConnectApiException e){
            System.debug('Error Message : '+e);
            return null;
        }
    }
    
    
    private static Id getCommunityId(){
        
        if(Test.isRunningTest()){
            return [SELECT Id FROM Network where Name='Promocash site instit'].Id;
        }else{
            return Network.getNetworkId();
        }
    }
    
    
    public class WrapperCMS_FAQ{
        @AuraEnabled public String title;
        @AuraEnabled public String question;
        @AuraEnabled public String answer;
        @AuraEnabled public String category;
        @AuraEnabled public String order;
        @AuraEnabled public String managedContentId;
    }
    
    
}