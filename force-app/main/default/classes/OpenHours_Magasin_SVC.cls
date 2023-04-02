/**
* @CreatedBy       : Suliman A.
* @Date            : 24/03/2021
* @Company         : IBM, Bluewolf
* @Description     : Rest API call to Partoo system to retrieve Magasins codes and open hours and update Horaires_du_magasin__c field on Magasin object.  
*/

public without sharing class OpenHours_Magasin_SVC {
    
    public static Boolean displaySystemDebug = Utilities.displaySystemDebug();

    @future(callout=true)
    public static void getOpenHours() {
        //Initiate variables
        String code;
        String status;
        String openHrs;
        String specificHrs;
        String lundi;
        String mardi;
        String mercredi;
        String jeudi;
        String vendredi;
        String samedi;
        String dimanche;
        
        //Get URL and APIKey from PartooAPI_Setting__mdt object
        PartooAPI_Setting__mdt partooSet = [SELECT Id, URL_Full_mode__c, User_ID__c, URL_Delta_Mode__c, Integration_Mode__c from PartooAPI_Setting__mdt LIMIT 1];
        //String partooFullURL = partooSet.URL_Full_mode__c;
        String partooAPIKey = partooSet.User_ID__c;
        //String partooDelatURL = partooSet.URL_Delta_Mode__c;
        String partooIntegrationMode = partooSet.Integration_Mode__c;
        
        //Stock the Code_etablissement__c with Horaires_du_magasin__c in Map
        Map<String, String> codeHorairesMap = new Map<String, String>();
        //Stock the Codes with specific_hours in Map
        Map<String, String> codeSpecificHoursMap = new Map<String, String>();
        
        //Magasins to update
        Map<Id, Magasin__c> magasinsToUpdate = new Map<Id, Magasin__c>();
        //List<Magasin__c> magasinsToUpdate = new List<Magasin__c>();
        
        //Retrieve Max Page
        Integer maxPage = getMaxPage(partooAPIKey);
        
        //If Partoo responds with an error
        Boolean isErrorResponse = false;
        HttpResponse httpErrorResponse;
        
        for (Integer pageNum=1; pageNum<=maxPage; pageNum++) {
            //Set the HTTP request to Partoo
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndPoint('callout:Partoo'+'?page='+pageNum);
            request.setHeader('Content-type', 'application/json');
            request.setHeader('x-APIKey', partooAPIKey);
            request.setMethod('GET');
            
            HttpResponse response = h.send(request);
            //In case of response success, get codes and open hours from Partoo and update Magasin object
            if (response.getStatusCode() == 200) {
                Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                maxPage = Integer.valueOf(results.get('max_page'));
                //Loop over the Businesses to retrieve codes and open hours
                List<Object> businesses = (List<Object>) results.get('businesses');
                for (Object busin : businesses) {
                    Map<String, Object> businessDetails = (Map<String, Object>) busin;
                    //Get a codes
                    code = String.valueOf(businessDetails.get('code'));
                    
                    //Get specificHrs
                    specificHrs = String.valueOf(businessDetails.get('specific_hours'));
                    
                    Map<String,Object> specificHours = (Map<String,Object>)(businessDetails.get('specific_hours'));
                    
                    //Retrieve specificHrs Open details
                    String openStartsAt;
                    String openEndsAt;
                    String specificOpenHours;
                    List<Object> specificHoursOpen = (List<Object>) specificHours.get('open');
                    if(specificHoursOpen != null){
                        for (Object openHour : specificHoursOpen) {
                            Map<String, Object> openHourDetails = (Map<String, Object>) openHour;
                            //Retrieve starts_at
                            openStartsAt = String.valueOf(openHourDetails.get('starts_at'));
                            //Retrieve ends_at
                            openEndsAt = String.valueOf(openHourDetails.get('ends_at'));
                            //Retrieve specificOpenHours
                            specificOpenHours = String.valueOf(openHourDetails.get('open_hours'));
                        }
                    }
                    
                    //Retrieve specific_hours Close details
                    String closeStartsAt;
                    String closeEndsAt;
                    List<Object> specificHoursClose = (List<Object>) specificHours.get('close');
                    if (specificHoursClose != null) {
                        for (Object openHour : specificHoursClose) {
                            Map<String, Object> closeHourDetails = (Map<String, Object>) openHour;
                            //Retrieve starts_at
                            closeStartsAt = String.valueOf(closeHourDetails.get('starts_at'));
                            //Retrieve ends_at
                            closeEndsAt = String.valueOf(closeHourDetails.get('ends_at'));
                        }
                    }
                    
                    //Set Specific_hours
                    if(specificHoursOpen.size() != 0 && specificHoursClose.size() != 0){
                        String specificHoursDate = 'Ouverture : Du '+openStartsAt+' au '+openEndsAt+' / '+specificOpenHours+'\n'+'Fermeture : Du '+closeStartsAt+' au '+closeEndsAt;
                        codeSpecificHoursMap.put(code, specificHoursDate);
                    } else {
                        codeSpecificHoursMap.put(code,'');
                    }
                    
                    
                    //Get Open Hours
                    openHrs = String.valueOf(businessDetails.get('open_hours'));
                    
                    Map<String,Object> openHours = (Map<String,Object>)(businessDetails.get('open_hours'));
                    
                    //Get open hours for every day and remove the parenthesis.
                    /*
                    lundi = String.valueOf(openHours.get('monday')).substring(1, String.valueOf(openHours.get('monday')).length() - 1);
                    mardi = String.valueOf(openHours.get('tuesday')).substring(1, String.valueOf(openHours.get('tuesday')).length() - 1);
                    mercredi = String.valueOf(openHours.get('wednesday')).substring(1, String.valueOf(openHours.get('wednesday')).length() - 1);
                    jeudi = String.valueOf(openHours.get('thursday')).substring(1, String.valueOf(openHours.get('thursday')).length() - 1);
                    vendredi = String.valueOf(openHours.get('friday')).substring(1, String.valueOf(openHours.get('friday')).length() - 1);
                    samedi = String.valueOf(openHours.get('saturday')).substring(1, String.valueOf(openHours.get('saturday')).length() - 1);
                    dimanche = String.valueOf(openHours.get('sunday')).substring(1, String.valueOf(openHours.get('sunday')).length() - 1);
                    */
                    
                    lundi = getOpenHoursPerDay('monday', openHours);
                    mardi = getOpenHoursPerDay('tuesday', openHours);
                    mercredi = getOpenHoursPerDay('wednesday', openHours);
                    jeudi = getOpenHoursPerDay('thursday', openHours);
                    vendredi = getOpenHoursPerDay('friday', openHours);
                    samedi = getOpenHoursPerDay('saturday', openHours);
                    dimanche = getOpenHoursPerDay('sunday', openHours);
                    
                    String openHour =  'Lundi : '+lundi+'\n'+'Mardi : '+mardi+'\n'+'Mercredi : '+mercredi+'\n'+'Jeudi : '+jeudi+'\n'+'Vendredi : '+vendredi+'\n'+'Samedi : '+samedi+'\n'+'Dimanche : '+dimanche;
                    codeHorairesMap.put(code, openHour);
                }
                
            } else {
                isErrorResponse = true;
                httpErrorResponse = response;
            }
        }
        
        if(isErrorResponse) {
            //In case of errors, put it in Tech_Partoo_Integration_Error__c field.
            for(Magasin__c magasin : [SELECT Tech_Partoo_Integration_Error__c, Tech_Partoo_Integration_Date__c FROM Magasin__c]){
                magasin.Tech_Partoo_Integration_Error__c = httpErrorResponse.getStatusCode() + ' ' + httpErrorResponse.getStatus();
                magasin.Tech_Partoo_Integration_Date__c = datetime.now();
                magasinsToUpdate.put(magasin.Id, magasin);
            }
        } else {
            //Get all Code from the Map
            Set <String> codes = new Set<String>();
            codes = codeHorairesMap.keySet();
            Integer codesSize = codes.size();
            
            //Get Magazines to update them
            List<Magasin__c> magasins = [SELECT Code_etablissement__c, Horaires_du_magasin__c, Horaires_Exceptionnels__c, Tech_Partoo_Integration_Date__c, Tech_Partoo_Integration_Error__c FROM Magasin__c where Code_etablissement__c IN :codes];
            //List<Magasin__c> magasins = [SELECT Code_etablissement__c, Horaires_du_magasin__c, Horaires_Exceptionnels__c, Tech_Partoo_Integration_Error__c FROM Magasin__c where Code_etablissement__c = '2001'];
            
            
            //Update magasins open hours
            for (Magasin__c magasin : magasins) {

                if (partooIntegrationMode == 'Full') {
                    magasin.Tech_Partoo_Integration_Date__c = datetime.now();
                    magasin.Horaires_du_magasin__c = codeHorairesMap.get(magasin.Code_etablissement__c);
                    magasin.Horaires_Exceptionnels__c = codeSpecificHoursMap.get(magasin.Code_etablissement__c);
                    //If there was an error in Tech_Partoo_Integration_Error__c field from previous API call then empty it.
                    if(magasin.Tech_Partoo_Integration_Error__c != ''){
                        magasin.Tech_Partoo_Integration_Error__c = '';
                    }
                    magasinsToUpdate.put(magasin.Id, magasin);
                } else { //If Integration mode is Delta, update only records which have Open Hours changed
                    //Remove the space in the end of the new vlaue of Open Hours if there is no Open Hour after sunday
                    String openHourValue = String.valueOf(codeHorairesMap.get(magasin.Code_etablissement__c));
                    String openHourLastValue = openHourValue.substringAfter('Dimanche :');
                    Integer lastValueLength = openHourLastValue.length();
                    String newOpHours;
                    
                    if (openHourLastValue == null || openHourLastValue == ' '){
                        newOpHours = codeHorairesMap.get(magasin.Code_etablissement__c).substring(0, String.valueOf(codeHorairesMap.get(magasin.Code_etablissement__c)).length() - 1);
                    } else {
                        newOpHours = codeHorairesMap.get(magasin.Code_etablissement__c);
                    }
                    
                    String oldOpHours = magasin.Horaires_du_magasin__c;
                    // Boolean isEqualOldNew = newOpHours.equals(oldOpHours);
                    if(!newOpHours.equals(oldOpHours)){
                        magasin.Tech_Partoo_Integration_Date__c = datetime.now();
                        magasin.Horaires_du_magasin__c = codeHorairesMap.get(magasin.Code_etablissement__c);
                        magasin.Horaires_Exceptionnels__c = codeSpecificHoursMap.get(magasin.Code_etablissement__c);
                        //If there was an error in Tech_Partoo_Integration_Error__c field from previous API call then empty it.
                        if(magasin.Tech_Partoo_Integration_Error__c != ''){
                            magasin.Tech_Partoo_Integration_Error__c = '';
                        }
                        
                        magasinsToUpdate.put(magasin.Id, magasin);
                    }
                }
            }
            
            //Update Magasins
            Database.SaveResult[] magasinsList = Database.update(magasinsToUpdate.values(), false);
            
            if (displaySystemDebug) {
                for (Database.SaveResult mList : magasinsList) {
                    if (!mList.isSuccess()) {       
                        for (Database.Error err : mList.getErrors())
                        { 
                            System.debug('Error : className = OpenHours_Magasin_SVC : ' +err.getStatusCode() + ': ' + err.getMessage());
                        }   
                    }
                } 
            }
        }
    }
    
    //Get Max Page
    private static Integer getMaxPage(String partooAPIKey){
        Integer maxPage = 1;
        //Retrieve Max Page
        Http hMaxPage = new Http();
        HttpRequest requestMaxPage = new HttpRequest();
        requestMaxPage.setEndPoint('callout:Partoo'+'?max_page');
        requestMaxPage.setHeader('Content-type', 'application/json');
        requestMaxPage.setHeader('x-APIKey', partooAPIKey);
        requestMaxPage.setMethod('GET');
        
        HttpResponse responseMaxPage = hMaxPage.send(requestMaxPage);
        //In case of response success, get codes and open hours from Partoo and update Magasin object
        if(responseMaxPage.getStatusCode() == 200){
            Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(responseMaxPage.getBody());
            
            maxPage = Integer.valueOf(results.get('max_page'));
        }
        
        return maxPage;
    }
    
    //Get Open Hours for every day 
    private static String getOpenHoursPerDay(String day, Map<String,Object> oH) {
        String aDay = String.valueOf(oH.get(day)).substring(1, String.valueOf(oH.get(day)).length() - 1);
        if (String.isEmpty(aDay)) {
            aDay = 'Fermé';
        } 
        return aDay;
    }
    
}