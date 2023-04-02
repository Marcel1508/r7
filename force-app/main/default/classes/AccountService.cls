/**
* @author       jan.straka@bluewolf
* @date         2021-01-29
* @description  Service class for Account object
**/
public without sharing class AccountService {
    
    /**
    * @author       MAROUANE
    * @date         2021-05-19
    * @description  method to check account, contact and address data is complete to send it to Akeneo
    * Missing fields: account.NPAI_livraison__c
    **/
    public Boolean isAccountDataComplete(Account account, Contact contact, ContactPointAddress billingaddr, ContactPointAddress shippingaddr, String apeCode) {
      
        //Check account data
        if(account == null || account.Code_etablissement__c == null || account.Numero_Client__c == null || account.Forme_juridique__c == null || account.Name == null || account.Enseigne_commerciale__c == null
           || account.Origine__c == null || account.Categorie__c == null)
            return false;
        //Check CodeAPE
        if(apeCode == '' || apeCode == null)
            return false;
        //Check contact data
        if(contact == null || contact.LastName == null)
            return false;
        //Check shippingAddress data
        if(shippingaddr == null || shippingaddr.Nom_de_voie__c == null || shippingaddr.Type_de_voie__c == null || shippingaddr.postalCode == null || shippingaddr.City == null || shippingaddr.CountryCode == null)
            return false;
        //Check billingAddress data
        if(billingaddr == null || billingaddr.Nom_de_voie__c == null || billingaddr.Type_de_voie__c == null || billingaddr.postalCode == null || billingaddr.City == null || billingaddr.CountryCode == null)
            return false;
        
        return true;
    }   
    
    /**
    * @author       jan.straka@bluewolf
    * @date         2021-01-29
    * @description  method to propagate changes to Frais__c records on Account change
    **/
    public void upsertFrais(Map<Id, Account> accounts) {
        Set<Id> processedAccountIds = updateExistingFrais(accounts);
        createFrais(
            filterAccountsForFraisCreation(accounts.values(), processedAccountIds));
    }
    
    /**
    * @author       jan.straka@bluewolf
    * @date         2021-01-29
    * @description  method to create Frais__c record on Account creation
    **/
    public void createFrais(List<Account> accounts) {
        Set<Id> magasinIds = Pluck.ids(Account.Magasin_actif_en_cours__c, accounts);
        Map<Id, Magasin__c> magasins = new Map<Id, Magasin__c>(
            [SELECT Id, Autoriser_livraison_aux_nouveaux_clients__c, responsable__c FROM Magasin__c WHERE Id IN :magasinIds]);
        
        List<Frais__c> frais = new List<Frais__c>();
        for (Account account : accounts) {
            if (account.Magasin_actif_en_cours__c != null) {
                Magasin__c magasin = magasins.get(account.Magasin_actif_en_cours__c);
                String deliveryOptions = 
                    (account.FirstOrder__c == null && magasin != null && !magasin.Autoriser_livraison_aux_nouveaux_clients__c) ?
                    'Drive;Drive déporté' : 
                'Drive;Drive déporté;Livraison';
                
                frais.add(new Frais__c(
                    Account__c = account.Id,
                    Magasin_Associe__c = account.Magasin_actif_en_cours__c,
                    Mode_de_livraison__c = deliveryOptions,
                    OwnerId = magasin.responsable__c
                ));
            }
        }
        
        insert frais;
    }
    
    
    /**
    * @author       KHAYOU Marouane
    * @date         2021-07-12
    * @description  update related objects (frais__c, Fidelite__c, Activite_potentiel__c, Information_financiere__c) when 
    **/
    public void updateExternalIds(List<Account> newRecords, Map<Id, Account> newRecordsMap, Map<Id, Account> oldRecordsMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> magasinsIds = new Set<Id>();
        
        List<frais__c> fraisToUpdate = new List<frais__c>();
        List<Fidelite__c> fideliteToUpdate = new List<Fidelite__c>();
        List<Activite_potentiel__c> activitePotentielToUpdate = new List<Activite_potentiel__c>();
        List<Information_financiere__c> infoFinanciereToUpdate = new List<Information_financiere__c>();
        
        for(Account account: newRecords) {
            Account oldAcccount = oldRecordsMap.get(account.Id);
            if(account.Numero_Client__c != oldAcccount.Numero_Client__c && !String.isEmpty(account.Numero_Client__c)) { //If Numero_Client__c has changed
                accountIds.add(account.Id);
            }
        }
            List<frais__c> fraisList = new List<frais__c>();
        	List<Fidelite__c> fideleteList = new List<Fidelite__c>();
            List<Activite_potentiel__c> activitePotentielList = new List<Activite_potentiel__c>();
            List<Information_financiere__c> infoFinanciereList = new List<Information_financiere__c>();
        if(!accountIds.isEmpty()) {
            List<Account> accountsInfos = [SELECT Id, (SELECT ID, Account__c, Magasin_Associe__r.Code_etablissement__c FROM frais__r),
                                          (SELECT ID, Compte__c, Magasin__r.Code_etablissement__c FROM Fidelite__r),
                                          (SELECT ID, Account__c, Magasin_actif__r.Code_etablissement__c FROM Activit_s_potentiel__r),
                                          (SELECT ID, Account__c, Magasin__r.Code_etablissement__c FROM Informations_financieres__r)
                                           FROM Account where Id in :accountIds];
            if(accountsInfos!=null && !accountsInfos.isEmpty())
            {
                for(Account acc: accountsInfos )
                {
                    fraisList.addAll(acc.frais__r);
                    fideleteList.addAll(acc.Fidelite__r);
                    activitePotentielList.addAll(acc.Activit_s_potentiel__r);  
                }
            }
                        
            if(!fraisList.isEmpty()) {
                for(frais__c fr: fraisList) {
                    if(fr.Magasin_Associe__r != null && !String.isEmpty(fr.Magasin_Associe__r.Code_etablissement__c)) {
                        fr.Frais_externalID__c = newRecordsMap.get(fr.Account__c).Numero_Client__c + '_' + fr.Magasin_Associe__r.Code_etablissement__c;
                        fraisToUpdate.add(fr);
                    }
                }
            }
            if(!fideleteList.isEmpty()) {
                for(Fidelite__c fidelite: fideleteList) {
                    if(fidelite.Magasin__r != null && !String.isEmpty(fidelite.Magasin__r.Code_etablissement__c)) {
                        fidelite.Fid_ExternalID__c = newRecordsMap.get(fidelite.Compte__c).Numero_Client__c + '_' + fidelite.Magasin__r.Code_etablissement__c;
                        fideliteToUpdate.add(fidelite);
                    }
                }
            }
            if(!activitePotentielList.isEmpty()) {
                for(Activite_potentiel__c activite: activitePotentielList) {
                    if(activite.Magasin_actif__r != null && !String.isEmpty(activite.Magasin_actif__r.Code_etablissement__c)) {
                        activite.AP_External_ID__c = newRecordsMap.get(activite.Account__c).Numero_Client__c + '_' + activite.Magasin_actif__r.Code_etablissement__c;
                        activitePotentielToUpdate.add(activite);
                    }
                }
            }
            if(!infoFinanciereList.isEmpty()) {
                for(Information_financiere__c infoFinanciere: infoFinanciereList) {
                    if(infoFinanciere.Magasin__r != null && !String.isEmpty(infoFinanciere.Magasin__r.Code_etablissement__c)) {
                        infoFinanciere.Info_fi_ExternalID__c = newRecordsMap.get(infoFinanciere.Account__c).Numero_Client__c + '_' + infoFinanciere.Magasin__r.Code_etablissement__c;
                        infoFinanciereToUpdate.add(infoFinanciere);
                    }
                }
            }
            if(!fraisToUpdate.isEmpty())
                update fraisToUpdate;
            if(!fideliteToUpdate.isEmpty())
                update fideliteToUpdate;
            if(!activitePotentielToUpdate.isEmpty())
                update activitePotentielToUpdate;
            if(!infoFinanciereToUpdate.isEmpty())
                update infoFinanciereToUpdate;
        }
    }
    
    /**
    * @author       jan.straka@bluewolf
    * @date         2021-01-29
    * @description  method to propagate changes to existing Frais__c records
    **/
    private Set<Id> updateExistingFrais(Map<Id, Account> accountsMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> magasinIds = new Set<Id>();
        for (Account account : accountsMap.values()) {
            accountIds.add(account.Id);
            magasinIds.add(account.Magasin_actif_en_cours__c);
        }
        
        List<Frais__c> existingFrais = [
            SELECT Id, Account__c, Mode_de_livraison__c, Magasin_Associe__r.Autoriser_livraison_aux_nouveaux_clients__c
            FROM Frais__c 
            WHERE Account__c IN :accountIds 
            AND Magasin_Associe__c IN :magasinIds];

        Set<Id> processedAccountIds = new Set<Id>();
        List<Frais__c> fraisToUpdate = new List<Frais__c>();
        for (Frais__c f : existingFrais) {
            if (accountsMap.get(f.Account__c).FirstOrder__c == null && !f.Magasin_Associe__r.Autoriser_livraison_aux_nouveaux_clients__c) {
                if (f.Mode_de_livraison__c != null && f.Mode_de_livraison__c.contains('Livraison')) {
                    Set<String> deliveryMethods = new Set<String>(f.Mode_de_livraison__c.split(';'));
                    deliveryMethods.remove('Livraison');
                    f.Mode_de_livraison__c = String.join(new List<String>(deliveryMethods), ';');
                    fraisToUpdate.add(f);
                }
            }
            processedAccountIds.add(f.Account__c);
        }
        
        update fraisToUpdate;
        return processedAccountIds;
    }
    
    /**
    * @author       jan.straka@bluewolf
    * @date         2021-01-29
    * @description  method to filter out accounts which already have been processed
    **/
    private List<Account> filterAccountsForFraisCreation(List<Account> accounts, Set<Id> accountIds) {
        List<Account> accountsToProcess = new List<Account>();
        for (Account account : accounts) {
            if (!accountIds.contains(account.Id)) {
                accountsToProcess.add(account);
            }
        }
        return accountsToProcess;
    }
    
    
    /**
    * @author       marouane.khayou@ibm
    * @date         
    * @description  method to check siret code of processed accounts
    **/
    public void checkSiret(List<Account> accounts) {
        for(Account acc: accounts) {
            /*if(!SirenService.checkSiren(acc.SirenText__c )) {
acc.SirenText__c.addError('Code Siren incorrect');
}*/
            if(!SirenService.checkSiret(acc.Numero_Siret__c)) {
                acc.Numero_Siret__c.addError('Code Siret incorrect');
            }
        }
    }
    
    /**
    * @author       marouane.khayou@ibm
    * @date         
    * @description  method to filter account for siret check
    **/
    public List<Account> filterAccountsForCheckSiret(List<Account> newRecords) {
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
            
            if(String.isBlank(acc.Magasin_actif_en_cours__c) && String.isNotBlank(acc.Magasin_de_rattachement__c) ){
                acc.Magasin_actif_en_cours__c = acc.Magasin_de_rattachement__c;
            } 
            if(acc.Numero_Siret__c != null) {
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }
    
    /**
    * @author       marouane.khayou@ibm
    * @date         
    * @description  method to filter account for siret check
    **/
    public List<Account> filterAccountsForCheckSiret(List<Account> newRecords, Map<Id, Account> oldRecordsMap) {
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
            
           /* if(acc.Magasin_actif_en_cours__c == Null){
                acc.Magasin_actif_en_cours__c = acc.Magasin_de_rattachement__c;
              } */
          
            Account oldRecord = oldRecordsMap.get(acc.Id);
            if (acc.SirenText__c != oldRecord.SirenText__c || (acc.Numero_Siret__c != oldRecord.Numero_Siret__c && !String.isBlank(acc.Numero_Siret__c))) { //Check if siret or siren have changed
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }
    
    /**
    * @author : Maud Vasseur - IBM Lille
	* @date : 04/2021
    * @date         
    * @description  method to filter account who becomes "Prospect"
    **/
    public List<Account> filterAccountsProspect(List<Account> newRecords, Map<Id, Account> oldRecordsMap){
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
            Account oldRecord = oldRecordsMap.get(acc.Id);
            //retrieve only the account who becomes "Prospect"
            if ((acc.RecordType.Name != oldRecord.RecordType.Name && acc.RecordType.Name == 'Prospect')
               || (acc.Statut_Fiche_client__c != oldRecord.Statut_Fiche_client__c && acc.Statut_Fiche_client__c == 'Prospect')){
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }
    
    /**
    * @description to filter the account if the Statut_Fiche_client__c value change.(filetr account for record type assignment)
    * @author Ajay.Kumar Tiwari | 06-23-2021 
    * @param newRecords 
    * @param oldRecordsMap 
    * @return List<Account> 
    **/
    public List<Account> filterToCheckStatutFicheClient(List<Account> newRecords, Map<Id, Account> oldRecordsMap){
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
            Account oldRecord = oldRecordsMap.get(acc.Id);
           if ((acc.RecordType.Name != oldRecord.RecordType.Name 
               || acc.Statut_Fiche_client__c != oldRecord.Statut_Fiche_client__c ) && String.isNotBlank(acc.Statut_Fiche_client__c)){
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }

    /**
    * @description method to assign a record type according of Statut_Fiche_client
    * @author Ajay.Kumar Tiwari | 06-23-2021 
    * @param accounts 
    **/
    public void assignRecordType(List<Account> accounts) {
      
        for (Account acc : accounts) {
            Id recordTypeId=Schema.SObjectType.Account.RecordTypeInfosByName.get(acc.Statut_Fiche_client__c).RecordTypeId;
            if(acc.RecordTypeId   != recordTypeId)
                acc.RecordTypeId = recordTypeId;
        }
    }

    /**
    * @description method to check  if Code_Chaine__c have value then mark as it true if dont have value then mark it as false
    * @author Ajay.Kumar Tiwari -IBM | 06-23-2021
    * @updated by KHAYOU Marouane | 08-09-2021
    * @param accounts 
    **/
    public void checkGrandCompte(List<Account> accounts) {
        for (Account acc : accounts) {
            if(String.isNotBlank(acc.Code_Chaine__c)){
                if(!acc.Client_grand_compte__c) acc.Client_grand_compte__c = true;
            } else {
                if(acc.Client_grand_compte__c) acc.Client_grand_compte__c = false;
            }
        }
    }
    
   /**
    * @description Method to Update the NumeroClient as Autonumber when status update to Prospect
    * @author Ajay.Kumar Tiwari - IBM | 05-18-2021 
    * @param newRecords 
    **/
    public  void  updateNumeroClient(List<Account> newRecords) {
        List<Account> accounts=new List<Account>();
          accounts=[SELECT Name, MaxProspectNumber__c, Numero_Client__c, Statut_Fiche_client__c FROM Account where  Numero_Client__c!=null and  MaxProspectNumber__c!=null
                                          order by MaxProspectNumber__c desc limit 1 ];
          
           decimal maxCount = !accounts.isEmpty() ? accounts[0].MaxProspectNumber__c :0 ; 
           Double maxNumeroClient = !accounts.isEmpty()? Double.valueof(accounts[0].Numero_Client__c):100000;
          
          for(Account acc : newRecords){
              if(acc.Statut_Fiche_client__c=='Prospect' && (acc.Numero_Client__c==null || acc.Numero_Client__c=='')){
                //  if(maxCount>0){
                      maxNumeroClient++;
                 // }
                  acc.Numero_Client__c=getStringNumeroClient(maxNumeroClient);
                  acc.MaxProspectNumber__c=maxCount+1;
                  maxCount++;
              }
          }     
     }
     
     
     /**
     * @description method used for convert double to 9 character String (8-->000000008)
     * @author Ajay.Kumar Tiwari | 05-18-2021 
     * @param numero 
     * @return String 
     **/
     public  String getStringNumeroClient(Double numero){
         
         String num=String.valueof(numero).removeEnd('.0');
         Integer len=num.length();
         String finalNumeroClient = num.leftPad(9,'0');
         return finalNumeroClient;
     }

     
     /**
     * @description if update account,shipping postal code and shipping city have the value first time  and account orginee is not E-Commerce
     * @author Ajay.Kumar Tiwari | 06-24-2021 
     * @param newRecords 
     * @param oldRecordsMap 
     * @return List<Account> 
     **/
     public List<Account> filterAccountsStoreAssignment(List<Account> newRecords, Map<Id, Account> oldRecordsMap){
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
            Account oldRecord = oldRecordsMap.get(acc.Id);
           if (
                ((oldRecord.ShippingPostalCode != acc.ShippingPostalCode) || (oldRecord.ShippingCity != acc.ShippingCity)) &&
                 (String.isNotBlank(acc.ShippingPostalCode) && String.isNotBlank(acc.ShippingCity)) ){
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }

     /**
     * @description  assign store if shipping postal code and shipping city have assign value 
     * @author Ajay.Kumar Tiwari | 06-23-2021 
     * @param accounts 
     **/
     public void assignStore(List<Account> accounts) {
       
        List<String> listPostalCode = new List<String>();
        List<String> listCity = new List<String>();
        Map<String,Zone_de_chalandise__c> mapCityCodeVsZoneChalandise=new Map<String,Zone_de_chalandise__c>();
        for (Account acc: accounts){
            listPostalCode.add(acc.ShippingPostalCode);
            listCity.add(acc.ShippingCity);
        }
       List<Magasin__c> magsinZoneBlanche=new List<Magasin__c>();
        magsinZoneBlanche=[Select Id From Magasin__c where Name='Magasin Zone Blanche'];
        
        List<Zone_de_chalandise__c> zoneChalandise = [SELECT id, name, Code_postal_text__c, Magasin__c,Libelle_ville__c,Magasin__r.Responsable__c
                                                        FROM Zone_de_chalandise__c 
                                                        WHERE Code_postal_text__c in:listPostalCode
                                                        AND Libelle_ville__c in : listCity ];
        if(!zoneChalandise.isEmpty()) {
            mapCityCodeVsZoneChalandise  =getCityCodeVSZoneMap(zoneChalandise);
        }                                               

        for (Account acc: accounts){
            if(!mapCityCodeVsZoneChalandise.isEmpty()){
                String cityPostalCodeKey= buildCompositeKey(acc.ShippingCity.toUpperCase(), acc.ShippingPostalCode);
                    if(mapCityCodeVsZoneChalandise.containsKey(cityPostalCodeKey)){
                        
                         acc.Etablissement_geographique__c = mapCityCodeVsZoneChalandise.get(cityPostalCodeKey).Magasin__c;     
                    }
                    else{
                        if(!magsinZoneBlanche.isEmpty())
                        acc.Etablissement_geographique__c=magsinZoneBlanche[0].Id;
                    }      
            } else{
                if(!magsinZoneBlanche.isEmpty())
                acc.Etablissement_geographique__c=magsinZoneBlanche[0].Id;      
            }
            
        }
         
    }

    /**
    * @description filetr account if someone update magasin actif en cours 
    * @author Ajay.Kumar Tiwari | 06-24-2021 
    * @param newRecords 
    * @param oldRecordsMap 
    * @return List<Account> 
    **/
    /*public List<Account> isMagasinActifEnCoursChange(List<Account> newRecords, Map<Id, Account> oldRecordsMap){
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
            Account oldRecord = oldRecordsMap.get(acc.Id);
          // if (oldRecord.Magasin_actif_en_cours__c != acc.Magasin_actif_en_cours__c && String.isNotBlank(acc.Magasin_actif_en_cours__c)){
              /* 27/08 Update by Ajay,owner will update when first time fill the magasin actif */
      /*     if (String.isBlank(oldRecord.Magasin_actif_en_cours__c) && String.isNotBlank(acc.Magasin_actif_en_cours__c)){
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }*/

    /**
    * @description filter on Account when magsin populate first time 
    * @author Ajay.Kumar Tiwari | 10-05-2021 
    * @param newRecords 
    * @return List<Account> 
    **/
    public List<Account> isMagasinActifEnCoursChange(List<Account> newRecords){
        List<Account> filteredAccounts = new List<Account>();
        for (Account acc : newRecords) {
         if (String.isNotBlank(acc.Magasin_actif_en_cours__c)){
                filteredAccounts.add(acc);
            }
        }
        return filteredAccounts;
    }
    /**
    * @description assign owner and assigne if someone insert magsin actif en cours and user should be data integration
    * @author Ajay.Kumar Tiwari | 10-05-2021 
    * @param accounts 
    **/
    public void assignOwnerId(List<Account> accounts) {
        Set<Id> magasinIds=new Set<Id>();
        for (Account acc : accounts) {
            magasinIds.add(acc.Magasin_actif_en_cours__c);  
        }

        Map <Id,Magasin__c> magasinMap=new Map<Id,Magasin__c>([Select id,Responsable__c from Magasin__c where id in :magasinIds ]);
        for (Account acc : accounts) {
            if(!magasinMap.isEmpty() && magasinMap.containsKey(acc.Magasin_actif_en_cours__c) && magasinMap.get(acc.Magasin_actif_en_cours__c).Responsable__c!=null){
                acc.assigne_a__c = magasinMap.get(acc.Magasin_actif_en_cours__c).Responsable__c;
                acc.OwnerId= magasinMap.get(acc.Magasin_actif_en_cours__c).Responsable__c;
            }
        }
    }   



    private  string buildCompositeKey(String city, String postalCode){
        String compositeKey = city+postalCode;
        return compositeKey;
    }
    
    /**
    * @description get the zone record map ,where key is combination of postalcode and city 
    * @author Ajay.Kumar Tiwari | 06-24-2021 
    * @param ZoneChalandises 
    * @return Map<String, Zone_de_chalandise__c> 
    **/
    private  Map<String,Zone_de_chalandise__c> getCityCodeVSZoneMap(List<Zone_de_chalandise__c> zoneChalandises){
       Map<String,Zone_de_chalandise__c> mapCityCodeVsZoneChalandise=new Map<String,Zone_de_chalandise__c>();
       for(Zone_de_chalandise__c zone :zoneChalandises){
            String cityPostalCompositeKey = buildCompositeKey(zone.Libelle_ville__c.toUpperCase(), zone.Code_postal_text__c);
            mapCityCodeVsZoneChalandise.put(cityPostalCompositeKey, zone);
            
        }
        return mapCityCodeVsZoneChalandise;
    }
    
   public void updateRelatedFrais(List<Account> accounts) {
           List<Id> accountIds = new List<Id>();
           for(Account a:accounts )
           {
               accountIds.add(a.Id);
           }
            List<Frais__c> relatedFrais = [SELECT Id, Account__c, Magasin_Associe__c FROM Frais__c where Account__c in:accountIds];
            update relatedFrais;
         }
    
    //S.A 17/08/2021: If user select "Personnel Promocash" as Catégorie Client, the Code APE "XXXXX" will be selected automatically 
    Public void setCodeAPEAutomatically(List<Account> accounts){
        Code_APE__c[] codeAPE = [SELECT Id FROM Code_APE__c WHERE Name = 'XXXXX' LIMIT 1];
        if(codeAPE.size() > 0){
            for(Account acc : accounts){
                if(acc.Categorie__c == '2' && codeAPE[0] != null){
                    acc.Code_APE__c =  codeAPE[0].ID;
                }
            }
        }
    }



    /**
    * @description 
    * @author Ajay.Kumar Tiwari | 09-28-2021 
    * @param accounts 
    * @return Boolean 
    **/
    public Boolean checkContactMagasin(List<Account> accounts) {
       
        List<Contact_magasin__c> contactMagsins=new List<Contact_magasin__c> ();
        contactMagsins=[SELECT Id, Magasin__c, Employe__c FROM Contact_magasin__c where 
                        Employe__c=:System.UserInfo.getUserId() ];
        if (contactMagsins.size()==1){
            return true ;    
        }else{
            for(Account acc: accounts){
                if(String.isBlank(acc.Magasin_de_rattachement__c)){
                    acc.Magasin_de_rattachement__c.addError('merci de remplir l\'Etablissement maître.');
                }
            }
            return false;
        }
       
     }   

     /**
     * @description 
     * @author Ajay.Kumar Tiwari | 09-28-2021 
     * @param accounts 
     **/
     public void assignOwnerAndMagasin(List<Account> accounts) {
        
        List<Contact_magasin__c> contactMagsins=new List<Contact_magasin__c> ();
        contactMagsins=[SELECT Id, Magasin__c, Employe__c,Magasin__r.Responsable__c  FROM Contact_magasin__c where 
                        Employe__c=:System.UserInfo.getUserId() ];
       
        for (Account acc : accounts) {
            
            acc.Magasin_de_rattachement__c =contactMagsins[0].Magasin__c;
            acc.Magasin_actif_en_cours__c = contactMagsins[0].Magasin__c;
            
           // acc.OwnerId = contactMagsins[0].Magasin__r.Responsable__c;
            if (String.isBlank(acc.assigne_a__c))
            acc.assigne_a__c = contactMagsins[0].Magasin__r.Responsable__c;
            
         }
         
     }
}