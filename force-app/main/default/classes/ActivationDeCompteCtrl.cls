/* .
--------------------------------------------------------------------------------------
Version#     Date                           Author                    Description
--------------------------------------------------------------------------------------
1.0          04-04-2021           Ajay Tiwari              Initial Version
--------------------------------------------------------------------------------------
*/ 
global without sharing class ActivationDeCompteCtrl {
    /*
     * added by Marouane
     * Date: 10/2
	*/
    public class FlowRequest {
        @InvocableVariable(label = 'AccountID' required = true)
        public Id accountId;
        
    }
    
    @InvocableMethod(label = 'create AccountShare')
    public static void createAccountShare(List<FlowRequest> flowRequest) {
        Id accountId;
        for(FlowRequest f: flowRequest) {
            accountId = f.accountId;
        
        }
       set<Id> accountIds=new set<Id>();
       accountIds.add(accountId);
       accountShareWithGroup(accountIds);
    }
    
    public static List<ActivationDeCompteCtrlWrapper> updateNonActivateAccount(list<Account> accList){
        
        Set<Id> accountIdsList = new Set<Id>();
        for(Account a: accList)
        {
            accountIdsList.add(a.Id);
        }
        List<ActivationDeCompteCtrlWrapper> results = new List<ActivationDeCompteCtrlWrapper>();
        ActivationDeCompteCtrlWrapper response = new ActivationDeCompteCtrlWrapper();
        response.isSuccess = true;
        results.add(response);

        try{
           List<Account> processAccounts=[select Id, Name, IsBuyer,Magasin_actif_en_cours__c,Magasin_actif_en_cours__r.Name,Magasin_de_rattachement__c,
                                         (Select Id,IsActive from BuyerAccounts ) from Account where id in: accountIdsList];
       
            Map<Id,Account> accountMap=new Map<Id,Account>(processAccounts);
            List<AccountShare> lstAccShare = new List<AccountShare>();
            List<BuyerGroup> insertBuyerGroupList = new List<BuyerGroup>();
            List<BuyerGroup> tempBuyerGroupList = new List<BuyerGroup>();
            List<BuyerGroup> finalBuyerGroupList = new List<BuyerGroup>();
            Map<String,BuyerGroup> buyerGroupMap=new Map<String,BuyerGroup>();
            Map<String,BuyerGroup> updatedBuyerGroupMap=new Map<String,BuyerGroup>();
            Set<Id> buyerGroupIds=new Set<Id>();
            List<BuyerGroupMember> newBGMlist = new List<BuyerGroupMember>();

            
            
            
            
            //create Account Share Records
            //*******************************************************call account share method here ************8
            accountShareWithGroup(accountMap.keySet());

            //Check if the Account has a buyer Account
            List<BuyerAccount> buyerAccountList=new List<BuyerAccount>();
            List<BuyerAccount> updatebuyerAccount=new List<BuyerAccount>();

            for(Account acc : accountMap.values()){
                if(acc.BuyerAccounts==null || acc.BuyerAccounts.isEmpty()){
                    BuyerAccount buyAcc=new BuyerAccount();
                    buyAcc.BuyerId=acc.Id;
                    buyAcc.PayerId=acc.Id;
                    buyAcc.SendToId=acc.Id;
                    buyAcc.BuyerStatus='Active';
                    buyAcc.CommerceType='Acheteur' ;
                    buyAcc.IsActive=true;
                    buyAcc.Name=acc.Name;
                    buyerAccountList.add(buyAcc);
                }else{
                    if(!acc.BuyerAccounts[0].IsActive)// if buyer account exist and if its disable then we enable it.
                    {
                        acc.BuyerAccounts[0].IsActive=true;
                        updatebuyerAccount.add(acc.BuyerAccounts[0]);
                    }
                }
            }

            if(!buyerAccountList.isEmpty()){  
              
                insert buyerAccountList;
            }
            if(!updatebuyerAccount.isEmpty()){  
              
                update updatebuyerAccount;
            }

            // get the Buyer group 
            List<BuyerGroup> buyerGroupList = getBuyerGroups(); 
            //create a map with standard product name and buyer group
            if(buyerGroupList != null && !buyerGroupList.isEmpty()){
               for(BuyerGroup bg : buyerGroupList){
                buyerGroupMap.put(bg.Name, bg);
            }     
            }
            
            for(Account acc : accountMap.values()){
                if(acc.Magasin_actif_en_cours__c!=null){
                    String tempName='Standard '+acc.Magasin_actif_en_cours__r.Name;

                    if(buyerGroupMap.containsKey(tempName)){
                        tempBuyerGroupList.add(buyerGroupMap.get(tempName));
                    }else{
                        BuyerGroup buyerGroupObj=new BuyerGroup();
                        buyerGroupObj.Name=tempName;
                        insertBuyerGroupList.add(buyerGroupObj);
                    }

                }
            }

            if(!insertBuyerGroupList.isEmpty()){
                insert insertBuyerGroupList;
                //merge the both list in single list
                finalBuyerGroupList.addAll(insertBuyerGroupList);
            }
            if(!tempBuyerGroupList.isEmpty()){
                finalBuyerGroupList.addAll(tempBuyerGroupList);
            }

            for(BuyerGroup bg : finalBuyerGroupList){
                updatedBuyerGroupMap.put(bg.Name,bg);
                buyerGroupIds.add(bg.Id);
            }

            List<Account> accountsList=[Select Id,Magasin_actif_en_cours__c,Magasin_actif_en_cours__r.Name,
                                        (Select Id,BuyerGroupId From BuyerGroupMembers where BuyerGroupId in :buyerGroupIds)
                                            from Account  where id in: accountMap.keySet()];
            for(Account ac :accountsList ){
                if(ac.BuyerGroupMembers.isEmpty()){
                    String tempName=ac.Magasin_actif_en_cours__c!=null ? 'Standard '+ac.Magasin_actif_en_cours__r.Name : '';

                    if(tempName!='' && updatedBuyerGroupMap.containsKey(tempName)){
                        BuyerGroupMember  bgm =new BuyerGroupMember();
                        bgm.BuyerId = ac.Id;
                        bgm.BuyerGroupId = updatedBuyerGroupMap.get(tempName).Id;
                        newBGMlist.add(bgm);
                    }
                }
            }

            if(!newBGMlist.isEmpty()){
               
                insert newBGMlist;
                response.message = 'Buyer Group Member Inserted Successfully !!';
               }

        }
        catch(Exception ex) {
            response.isSuccess = false;
            response.message = 'error:' + ex.getMessage();
        }
        return results;
    }

    //method for get Buyer Group
    private static List<BuyerGroup> getBuyerGroups(){
        return [Select Id,Name from BuyerGroup where Name Like 'Standard %'];
    }

    // wrapper class 
    public without sharing class ActivationDeCompteCtrlWrapper {
        public Boolean isSuccess;
        public String message;
        
    }

    public static void accountShareWithGroup(Set<Id> accountIds){
        List<AccountShare> lstAccShare = new List<AccountShare>();
        Map<String,Id> codeEstablishmentVsGroupId = new Map<String,Id>();// added by ajay-us844
        Map<Id,String> magaIdVsCodeEtalishment = new Map<Id,String>();// added by ajay-us844
        Set<String> codeEstablishmentIds = new Set<String>();// added by ajay-us844
        Map<Id,Account> accounts=new Map<Id,Account>([select Id,Magasin_actif_en_cours__c,Magasin_actif_en_cours__r.Code_etablissement__c from Account where id in: accountIds]);
            for(Account rec : accounts.values()){
                    magaIdVsCodeEtalishment.put(rec.Magasin_actif_en_cours__c,rec.Magasin_actif_en_cours__r.Code_etablissement__c);// added by ajay-us844
                    codeEstablishmentIds.add('%'+rec.Magasin_actif_en_cours__r.Code_etablissement__c);// added by ajay-us844
            }
        if(magaIdVsCodeEtalishment != null && !magaIdVsCodeEtalishment.isEmpty() && !codeEstablishmentIds.isEmpty()){
            for(Group g : [select id, developername, name from group where developername like : codeEstablishmentIds and name like '%/ Magasin']){
                        String groupName=g.developername;
                        //String str='Magasin_AGDE_BIRASO__2000';
                        Integer i = groupName.lastIndexOf('_');
                        if(i!=-1){
                            String establishmentCode = groupName.substring(i+1, groupName.length());//2000 unique code
                            codeEstablishmentVsGroupId.put(establishmentCode,g.Id);
                        }
                    }
                }   
                
        Map<Id, Id> groupIdVsAccId = new Map<Id,Id>();
        List<Id> gId = codeEstablishmentVsGroupId.values();
            for(AccountShare accS : [Select Id,AccountId,UserOrGroupId FROM Accountshare WHERE AccountId IN :accounts.keySet() AND UserOrGroupId IN :gId]){
                    groupIdVsAccId.put(accS.UserOrGroupId,accS.AccountId);
                }
                
        Map<String, AccountShare> accountShareVsKey = new Map<String, AccountShare>();
                
                for(Account rec : accounts.values()) {
                    String codeEtablissement = rec.Magasin_actif_en_cours__r.Code_etablissement__c;
                    Id grpId = codeEstablishmentVsGroupId.get(codeEtablissement);
                    if(grpId != null ) {
                        String key = rec.Id + '' + grpId;
                        if(!accountShareVsKey.containsKey(key)) {
                            AccountShare acctShare = new AccountShare(AccountId = rec.Id, UserOrGroupId = grpId, AccountAccessLevel = 'edit', OpportunityAccessLevel = 'edit', RowCause = 'Manual');   
                            lstAccShare.add(acctShare);
                            accountShareVsKey.put(key, acctShare);
                        }
                    }
                }
    
                if(!lstAccShare.isEmpty()){
                    insert lstAccShare;
                }
    
        }

}