/**
 * @description       : 
 * @author            : Ajay.Kumar Tiwari
 * @group             : 
 * @last modified on  : 04-12-2021
 * @last modified by  : Ajay.Kumar Tiwari
 * @last modified on  : 04-12-2021
 * @last modified by  : Ajay.Kumar Tiwari
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   04-01-2021   Ajay.Kumar Tiwari   Initial Version
**/
public without sharing class AccountViewController {
    public List < Account > lstSelectedAccounts {
        get;
        set;
    }
    
    public AccountViewController(ApexPages.StandardSetController listcontroller) {
      
        Set < Id > accountSelectedIds = new set < Id > ();
        lstSelectedAccounts = new List <Account >();
        for (Account ac: (Account[]) listcontroller.getSelected()) {
            accountSelectedIds.add(ac.id);
        }        
         lstSelectedAccounts = [select Id, Name, IsBuyer,Magasin_actif_en_cours__c,Magasin_de_rattachement__c
                                 from Account where id in: accountSelectedIds];

        for(Account ac : lstSelectedAccounts){}
        
        
    }

    public PageReference getAccountListView(){ 
        return new PageReference('/lightning/o/Account/list'); 
    }

}