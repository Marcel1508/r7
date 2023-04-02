/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          13-04-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 
@isTest
public class CommonTestData {
      public static Account createAccountRecord(Account acc){
       acc.Name='Aj-AccountData';
       acc.Statut_Fiche_client__c='Lead';
        return acc;
    }
   
    public static Account createProspectAccount(Account acc){
      acc.Name='Aj-AccountData';
      acc.Statut_Fiche_client__c='Prospect';
       return acc;
   }
    public static Magasin__c createMagasinRecord(Magasin__c mag){
     mag.Name='Aj-AccountData';
     mag.Responsable__c=UserInfo.getUserId();
     mag.Code_etablissement__c='7500';
     mag.Pourcentage_additionel_carte__c = 10;
     mag.Minimum_Commande_Drive__c = 10;
     mag.Minimum_Commande_Livraison__c = 5;
     mag.Minimum_Commande_Drive_Deporte__c = 15;
     mag.Services_disponibles__c ='Autres';
    
     mag.API_Key__c  = 'LtsFKJQih9U0Z5hRGm38oSMBc5Nkiq';
     
     return mag;
  }

  public static Contact createContactRecord(Contact con){
   con.LastName='test contact';
   con.FirstName= 'TEST';
   con.Roles__c= 'Propriétaire';
   con.Email= 'TestPromoCash@carrefour.com';
   con.Contact_principal__c= true;
   return con;
 }

 public static ContactPointAddress createContactPointAddressRecord(ContactPointAddress cpa,String addressType){
  cpa.AddressType=addressType;
  cpa.City='Kanpur';
  cpa.Name='testContactPoint';
  cpa.Street='K 288 D';
  return cpa;
}



public static WebCart createWebCartRecord(WebCart wc,String accountId){
  wc.AccountId=accountId;
  wc.Name='Cart';
  return wc;
}
       
    
}