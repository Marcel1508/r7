/**
* @description       : 
* @author            : Ajay.Kumar Tiwari
* @group             : 
* @last modified on  : 05-19-2021
* @last modified by  : Ajay.Kumar Tiwari
* Modifications Log 
* Ver   Date         Author              Modification
* 1.0   04-08-2021   Ajay.Kumar Tiwari   Initial Version
**/
public without sharing class UpdateActiveMagasins {

    public static Boolean systemDebug = Utilities.displaySystemDebug();
    
   @InvocableMethod(label='Update the Accounts')
    public static List<UpdateAccountResults> updateMagasinActifEnCours(list<FlowInput> request) {
        
        list<Account> accList=request[0].accountList; 
        Map<Id, Account> updateAccountMap = new  Map<Id, Account>();
        Map<String,Relation_Compte_Magasin__c> mapRelationCompteMagasin=new Map<String,Relation_Compte_Magasin__c>();
        List<Relation_Compte_Magasin__c> newrelationCompteMagasin = new List<Relation_Compte_Magasin__c>();

        List<UpdateAccountResults> results = new List<UpdateAccountResults>();
        UpdateAccountResults response = new UpdateAccountResults();
        results.add(response);
		/*

                                                Fidelite__c,Activite_potentiel__c, (select Id,Roles__c,AccountID,Email,FirstName,LastName,Contact_principal__c 
                                                                                    from Contacts Where Contact_principal__c = True) 

*/        
        try{
            List<Account> processAccountList = [select Id, Name, IsBuyer,Magasin_actif_en_cours__c,
                                                Magasin_de_rattachement__c,Frais_autorisations__c,Statut_Fiche_client__c,
                                                Fidelite__c,Activite_potentiel__c
                                                from Account where id in: accList AND Magasin_de_rattachement__c != NULL];
            
            List<Contact> conList = new List<Contact>();
            /*for(Account a: processAccountList)
            {
                conList.addAll(a.Contacts);
            }*/
            
            Map<String, Contact> conAccMap = new Map<String, Contact>();
            //for(Contact conRecd : conList){
            for(Contact conRecd : [SELECT Id, Email, AccountID FROM Contact WHERE AccountID IN :accList]){
                conAccMap.put(conRecd.AccountID, conRecd);
            }

            for(Account accRec : processAccountList){
                if(conAccMap.containsKey(accRec.Id)){
                    Contact con = conAccMap.get(accRec.Id);
                    if(con.Email != Null && con.Email != ''){
                        accRec.Magasin_actif_en_cours__c = accRec.Magasin_de_rattachement__c;
                        updateAccountMap.put(accRec.id, accRec);
                    }
                }
            }
            if(!updateAccountMap.values().isEmpty()){
                update updateAccountMap.values(); 
            }   
            
            // insert new Relation compete magasin if its not already exist ****start
            mapRelationCompteMagasin=getRelCompteMagasinMap(updateAccountMap.keySet());

            for (Account ac : updateAccountMap.values()) {
                String acIdMagActifCompositeKey = buildCompositeKey(ac.Id, ac.Magasin_actif_en_cours__c);
               if( !mapRelationCompteMagasin.containsKey(acIdMagActifCompositeKey)){
                    Relation_Compte_Magasin__c rcm = new Relation_Compte_Magasin__c();
                    rcm.Compte_Client__c=ac.Id;
                    rcm.Magasin_actif__c=ac.Magasin_actif_en_cours__c;
                    newrelationCompteMagasin.add(rcm);
               }
            }

            if(!newrelationCompteMagasin.isEmpty()){
                insert newrelationCompteMagasin;
            }
            //insert new Relation compete magasin if its not already exist ****end
            
            response.updatedAccounts = updateAccountMap.values();
            response.result = 'success';
            
        }catch(Exception e){
            response.result = 'error:' + e.getMessage();
            if (systemDebug) { System.debug('Message: ' + e.getMessage() +' Line number: ' + e.getLineNumber() + ' Stack: ' + e.getStackTraceString()); }
        }
        return results;
        
    }
    
    public class FlowInput {
        @InvocableVariable(label = 'Account List' required = true)
        public List<Account> accountList;
    }
    
    public class UpdateAccountResults {
        
        @InvocableVariable( label = 'Updated Accounts' )
        public List<Account> updatedAccounts;
        
        @InvocableVariable
        public String result;
    }
    
    private static string buildCompositeKey(String accId, String magasinActifEnCours){
        String compositeKey = accId+magasinActifEnCours;
        return compositeKey;
    }

    // get the map of exising Relation Compete Magasin realed to that  accounts
    private static Map<String,Relation_Compte_Magasin__c> getRelCompteMagasinMap(Set<Id> accountIds){
        Map<String,Relation_Compte_Magasin__c> mapRelationMagasin=new Map<String,Relation_Compte_Magasin__c>();

        List<Relation_Compte_Magasin__c> competeMagasins= [Select Id,Compte_Client__c,Magasin_actif__c from Relation_Compte_Magasin__c 
                                                                                                        where Compte_Client__c in : accountIds];

        for(Relation_Compte_Magasin__c rcm :competeMagasins){
            String relCompteMagaCompositeKey = buildCompositeKey(rcm.Compte_Client__c, rcm.Magasin_actif__c);
                    mapRelationMagasin.put(relCompteMagaCompositeKey, rcm);
            
        }
        return mapRelationMagasin;
    }
    
}