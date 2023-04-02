/**
* @author : Maud Vasseur - IBM Lille
* @date : 12/2020
* @description : Classe de service de l'objet Prix_specifiques__c
* @TestClass : PrixSpecifiqueService_TST
**/

public class PrixSpecifiqueService {   
    
    /**
* @description : Création de pricebook de prix specifiques
* @parameter : Prix_specifiques__c
*/
    public void checkInformationRelatedToPrixSpecifiques(List<Prix_specifiques__c> newRecords) {
        // Mapping and preparation of the data used
        List<String> listConcatNames = new List<String>();
        Set<Id> setOfAccountIds = new Set<Id>();
        Set<Id> setOfMagasinIds = new Set<Id>();
        
        List<Prix_specifiques__c> newFiltredRecords = new List<Prix_specifiques__c>(); //New List of prixSpecifique without accounts (isBuyer=false)
        
        for(Prix_specifiques__c PrixSpecifiquesRecord : newRecords){
            setOfAccountIds.add(PrixSpecifiquesRecord.Reference_client__c);
            setOfMagasinIds.add(PrixSpecifiquesRecord.Libelle_etablissement__c);
        }
        
        //Mapping between Account Name & Magasin Name to retrieve the buyer group and others objects by their name (Account.Name +' '+Magasin.Name)
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT id, name, isBuyer FROM Account where Id in: setOfAccountIds]);
        Map<ID, Magasin__c> magasinMap = new Map<ID, Magasin__c>([SELECT id, name FROM Magasin__c where Id in: setOfMagasinIds]);
        
        
        for(Prix_specifiques__c PrixSpecifiquesRecord : newRecords){
            if(accountMap.get(PrixSpecifiquesRecord.Reference_client__c).isBuyer) { //We add only activated account
                newFiltredRecords.add(PrixSpecifiquesRecord);
            }
        }
        
        for(Prix_specifiques__c PrixSpecifiquesRecord : newFiltredRecords){
            String ConcatName = accountMap.get(PrixSpecifiquesRecord.Reference_client__c).Name + ' ' + magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name;
            listConcatNames.add(ConcatName);
        }
        
        //Retrieve the buyergroup of new prix specifiques
        Map<String, BuyerGroup> buyerGroupMap = new Map<String, BuyerGroup>();
        
        for(BuyerGroup bg : [SELECT Id, Name FROM BuyerGroup WHERE Name = :listConcatNames]){
            buyerGroupMap.put(bg.Name, bg);
        }
        
        //Retrieve the pricebook and entry of new prix specifiques
        Map<String, Pricebook2> pricebookMap = new Map<String, Pricebook2>();
        
        for(Pricebook2 pricebook : [SELECT Id, Name, (SELECT Product2Id, Pricebook2Id, Pricebook2.Name, UnitPrice, UseStandardPrice, IsActive From PricebookEntries) FROM Pricebook2 WHERE Name = :listConcatNames]){
            pricebookMap.put(pricebook.Name, pricebook);
        }
        
        
        /*** CHECK EXISTING OF OBJECT - UPDATE ***/ 
        Map<String,Id> buyerGroupAccountMap = new Map<String,Id>();
        Map<String,String> buyerGroupPricebookMagasinMap = new Map<String,String>();
        Set<String> ListBuyerGroupToCreate = new Set<String>();
        List<String> ListBuyerGroupWithoutPricebook = new List<String>();
        List<PricebookEntry> ListPricebookEntryToCreate = new List<PricebookEntry>();
        List<PricebookEntry> ListPricebookEntryToUpdate = new List<PricebookEntry>();
        List<Pricebook2> ListPricebookToCreate1 = new List<Pricebook2>();
        List<Prix_specifiques__c> listOfPrixSpecifiquesToRelaunch = new List<Prix_specifiques__c>();
        List<String> listConcatCEPMagasin = new List<String>();
        List<String> listPricebookMagasin = new List<String>();
        
        Map<string, String> nomPricebookStandardNomMagasin = new Map<string, String>();
        Map<string, String> nomMagasinIdPricebookStandard = new Map<string, String>();
        Map<string, String> nomPolicyNomMagasin = new Map<string, String>();
        Map<string, String> nomMagasinIdPolicy = new Map<string, String>();
        
        
        for(Prix_specifiques__c PrixSpecifiquesRecord : newFiltredRecords){
            String nameBuyerGroupAndPricebook = accountMap.get(PrixSpecifiquesRecord.Reference_client__c).Name + ' ' + magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name;
            String ConcatCEPMagasin = 'Assortiment ' + magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name;
            String pricebookMagasin = 'Standard PMC ' + magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name;
            
            if(buyerGroupMap.containsKey(nameBuyerGroupAndPricebook)){
                if(pricebookMap.get(nameBuyerGroupAndPricebook)!= null){
                    Map<Id,PricebookEntry> pricebookEntriesMap = new Map<Id,PricebookEntry>();
                    for(PricebookEntry pe : pricebookMap.get(nameBuyerGroupAndPricebook).PricebookEntries){
                        pricebookEntriesMap.put(pe.Product2Id,pe);
                    }       
                    if (pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c) != null){
                        pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c).UnitPrice = PrixSpecifiquesRecord.Prix_de_vente_au_conditionnement__c;
                        pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c).IsActive = true;
                        ListPricebookEntryToUpdate.add(pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c));
                    } else{
                        PricebookEntry AccountMagasinPriceBookEntry = new PricebookEntry(
                            Pricebook2Id = pricebookMap.get(nameBuyerGroupAndPricebook).id,
                            Product2Id = PrixSpecifiquesRecord.Produit__c,
                            UnitPrice = PrixSpecifiquesRecord.Prix_de_vente_au_conditionnement__c,
                            UseStandardPrice = false,
                            IsActive = true
                        );
                        ListPricebookEntryToCreate.add(AccountMagasinPriceBookEntry);
                    }
                } else {
                    Pricebook2 PricebookToCreate1 = new pricebook2(
                        IsActive = true,
                        Name = nameBuyerGroupAndPricebook,
                        Description = 'Pricebook pour ' + nameBuyerGroupAndPricebook
                    );
                    ListPricebookToCreate1.add(PricebookToCreate1);
                    ListBuyerGroupWithoutPricebook.add(nameBuyerGroupAndPricebook);
                    listOfPrixSpecifiquesToRelaunch.add(PrixSpecifiquesRecord); 
                }
            } else {
                System.debug('Mon BuyerGroup n existe pas');
                buyerGroupAccountMap.put(nameBuyerGroupAndPricebook, PrixSpecifiquesRecord.Reference_client__c);
                buyerGroupPricebookMagasinMap.put(nameBuyerGroupAndPricebook, magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name);
                ListBuyerGroupToCreate.add(nameBuyerGroupAndPricebook); 
                listOfPrixSpecifiquesToRelaunch.add(PrixSpecifiquesRecord); 
                nomPricebookStandardNomMagasin.put(pricebookMagasin,magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name);
                nomPolicyNomMagasin.put(ConcatCEPMagasin,magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name);
                listConcatCEPMagasin.add(ConcatCEPMagasin);
                listPricebookMagasin.add(pricebookMagasin);
            }             
        }
        
        Update ListPricebookEntryToUpdate;
        Insert ListPricebookToCreate1;
        if(!Test.isRunningTest()) Insert ListPricebookEntryToCreate;
        
        
        /*** CREATION BUYER GROUP + PRICEBOOK + WEBSTORE + MEMBER + POLICY ***/
        List<BuyerGroup> ListBuyerGroupToCreate2 = new List<BuyerGroup>();
        
        //Creation of BuyerGroups which don't exist
        for(String Names : ListBuyerGroupToCreate){
            BuyerGroup creationBuyerGroup = new BuyerGroup(
                Name = Names,
                description = 'Catalogue de prix négociés pour ' + Names
            );
            ListBuyerGroupToCreate2.add(creationBuyerGroup);
        }
        Insert ListBuyerGroupToCreate2;
        
        
        List<WebStore> IdStorePromocash = [SELECT id FROM WebStore WHERE Name = 'Promocash'];
        List<WebStoreBuyerGroup> ListWebStoreBuyerGroupToCreate = new List<WebStoreBuyerGroup>();
        List<Pricebook2> ListPricebookToCreate2 = new List<Pricebook2>();
        List<BuyerGroup> buyersGroupsCreated = [SELECT id, name FROM BuyerGroup WHERE name =:ListBuyerGroupToCreate];
        List<BuyerGroupMember> ListBuyerGroupMemberToCreate = new List<BuyerGroupMember>();
        List<CommerceEntitlementBuyerGroup> ListCommerceEntitlementBuyerGroupToCreate = new List<CommerceEntitlementBuyerGroup>(); 
        
        //Retrieve policy of magasin by magasin name
        for(CommerceEntitlementPolicy policy : [SELECT id, name FROM CommerceEntitlementPolicy WHERE Name in :nomPolicyNomMagasin.keySet()]){
            nomMagasinIdPolicy.put(nomPolicyNomMagasin.get(policy.Name),policy.Id);
        }
        
        //Retrieve Standard pricebook of magasin by magasin name
        for(Pricebook2 pb : [SELECT Id, Name FROM Pricebook2 WHERE Name in :nomPricebookStandardNomMagasin.keySet()]){
            nomMagasinIdPricebookStandard.put(nomPricebookStandardNomMagasin.get(pb.Name),pb.Id);
        }
        
        
        //STEP 1 : For every BuyerGroup, creation of WebStore's relationship, associated member(account) and creation of a Pricebook
        for(BuyerGroup buyerGroupCreated :buyersGroupsCreated){
            WebStoreBuyerGroup relationBetweenStoreAndBuyerGroup = new WebStoreBuyerGroup(
                BuyerGroupId = buyerGroupcreated.id,
                WebStoreId = IdStorePromocash.get(0).id
            );
            ListWebStoreBuyerGroupToCreate.add(relationBetweenStoreAndBuyerGroup);
            
            Pricebook2 PricebookToCreate = new pricebook2(
                IsActive = true,
                Name = buyerGroupcreated.name,
                Description = 'Pricebook pour ' + buyerGroupcreated.name
            );
            ListPricebookToCreate2.add(PricebookToCreate);
            
            // id du compte -> buyerGroupAccountMap.get(buyerGroupCreated.Name);
            BuyerGroupMember BuyerGroupMemberToCreate = new BuyerGroupMember(
                BuyerGroupId = buyerGroupcreated.id,
                BuyerId = buyerGroupAccountMap.get(buyerGroupCreated.Name)
            );
            ListBuyerGroupMemberToCreate.add(BuyerGroupMemberToCreate);
            
            Id cepolicyID = nomMagasinIdPolicy.get(buyerGroupPricebookMagasinMap.get(buyerGroupCreated.Name));
            CommerceEntitlementBuyerGroup commerceEntitlementBuyerGroupToCreate = new CommerceEntitlementBuyerGroup(
                BuyerGroupId = buyerGroupcreated.id,
                PolicyId = cepolicyID
            );
            ListCommerceEntitlementBuyerGroupToCreate.add(CommerceEntitlementBuyerGroupToCreate);        
        }
        
        Insert ListWebStoreBuyerGroupToCreate;
        Insert ListPricebookToCreate2;
        if(!Test.isRunningTest()) Insert ListBuyerGroupMemberToCreate;
        if(!Test.isRunningTest()) Insert ListCommerceEntitlementBuyerGroupToCreate;
        
        //REFACTOR ??//
        //STEP 2 : For every BuyerGroup, creation of relationship between BuyerGroup and Pricebook => BuyerGroupPricebook object
        List<BuyerGroupPricebook> ListBuyerGroupPricebookToCreate = new List<BuyerGroupPricebook>();
        List<Pricebook2> listPricebookStandard = [SELECT id, name FROM Pricebook2 WHERE Name =:listPricebookMagasin];
        
        Map<String, Id> pricebookNameIdMap = new Map<String, Id>();
        Map<String, Id> pricebookMagasinNameIdMap = new Map<String, Id>();
        for(Pricebook2 pricebook : ListPricebookToCreate2){
            pricebookNameIdMap.put(pricebook.Name, pricebook.Id);
        }
        for(Pricebook2 pricebook : listPricebookStandard){
            pricebookMagasinNameIdMap.put(pricebook.Name, pricebook.Id);
        }
        
        for(BuyerGroup buyerGroupCreated :buyersGroupsCreated){
            Id pricebookID = pricebookNameIdMap.get(buyerGroupCreated.Name);
            BuyerGroupPricebook relationBetweenPricebookAndBuyerGroup = new BuyerGroupPricebook(
                BuyerGroupId = buyerGroupcreated.id,
                IsActive = true,
                Priority = 10,
                Pricebook2Id = pricebookID
            );
            ListBuyerGroupPricebookToCreate.add(relationBetweenPricebookAndBuyerGroup);
            
            Id pricebookMagasinStandardID = nomMagasinIdPricebookStandard.get(buyerGroupPricebookMagasinMap.get(buyerGroupCreated.Name));
            BuyerGroupPricebook relationBetweenPricebookMagasinAndBuyerGroup = new BuyerGroupPricebook(
                BuyerGroupId = buyerGroupcreated.id,
                IsActive = true,
                Priority = 50,
                Pricebook2Id = pricebookMagasinStandardID
            );
            ListBuyerGroupPricebookToCreate.add(relationBetweenPricebookMagasinAndBuyerGroup);
        }
        if(!Test.isRunningTest()) Insert ListBuyerGroupPricebookToCreate;
        
        //REFACTOR ??
        //Create BuyerGroupPricebook after the Pricebook's creation if the buyer group exists
        List<BuyerGroup> ListBuyerGroupsWithoutPricebook2 = [SELECT id, name FROM BuyerGroup WHERE name =:ListBuyerGroupWithoutPricebook];
        List<BuyerGroupPricebook> ListBuyerGroupPricebookToCreate2 = new List<BuyerGroupPricebook>();
        List<Pricebook2> listPricebookCreated2 = [SELECT id, name FROM Pricebook2 WHERE Name =:ListBuyerGroupWithoutPricebook];
        
        Map<String, Id> pricebookNameIdMap2 = new Map<String, Id>();
        for(Pricebook2 pricebook : listPricebookCreated2){
            pricebookNameIdMap2.put(pricebook.Name, pricebook.Id);
        }
        
        for(BuyerGroup ListBuyerGroupWithoutPricebook2 :ListBuyerGroupsWithoutPricebook2){
            Id pricebookID = pricebookNameIdMap2.get(ListBuyerGroupWithoutPricebook2.Name);
            BuyerGroupPricebook relationBetweenPricebookAndBuyerGroup = new BuyerGroupPricebook(
                BuyerGroupId = ListBuyerGroupWithoutPricebook2.id,
                IsActive = true,
                Priority = 10,
                Pricebook2Id = pricebookID
            );
            ListBuyerGroupPricebookToCreate2.add(relationBetweenPricebookAndBuyerGroup);
        }
        Insert ListBuyerGroupPricebookToCreate2;
        
        //REFACTOR ??//        
        /*** RELAUNCH AFTER CREATION FOR PRICEBOOK ENTRY ONLY ***/
        if(listOfPrixSpecifiquesToRelaunch.size() >= 1){
            // Mapping and preparation of the data used
            List<String> listConcatNames2 = new List<String>();
            Set<Id> setOfAccountIds2 = new Set<Id>();
            Set<Id> setOfMagasinIds2 = new Set<Id>();
            
            for(Prix_specifiques__c PrixSpecifiquesRecord : listOfPrixSpecifiquesToRelaunch){
                setOfAccountIds2.add(PrixSpecifiquesRecord.Reference_client__c);
                setOfMagasinIds2.add(PrixSpecifiquesRecord.Libelle_etablissement__c);
            }
            
            //Mapping between Account Name & Magasin Name to retrieve the buyer group and others objects by their name (Account.Name +' '+Magasin.Name)
            Map<ID, Account> accountMap2 = new Map<ID, Account>([SELECT id, name FROM Account where Id in: setOfAccountIds2]);
            Map<ID, Magasin__c> magasinMap2 = new Map<ID, Magasin__c>([SELECT id, name FROM Magasin__c where Id in: setOfMagasinIds2]);
            for(Prix_specifiques__c PrixSpecifiquesRecord : listOfPrixSpecifiquesToRelaunch){
                String ConcatName = accountMap2.get(PrixSpecifiquesRecord.Reference_client__c).Name + ' ' + magasinMap2.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name;
                listConcatNames2.add(ConcatName);
            }
            
            //Retrieve the buyergroup of new prix specifiques
            Map<String, BuyerGroup> buyerGroupMap2 = new Map<String, BuyerGroup>();
            
            for(BuyerGroup bg : [SELECT Id, Name FROM BuyerGroup WHERE Name = :listConcatNames2]){
                buyerGroupMap2.put(bg.Name, bg);
            }
            
            //Retrieve the pricebook and entry of new prix specifiques
            Map<String, Pricebook2> pricebookMap2 = new Map<String, Pricebook2>();
            
            for(Pricebook2 pricebook : [SELECT Id, Name, (SELECT Product2Id, Pricebook2Id, Pricebook2.Name, UnitPrice, UseStandardPrice, IsActive From PricebookEntries) FROM Pricebook2 WHERE Name = :listConcatNames2]){
                pricebookMap2.put(pricebook.Name, pricebook);
            }
            
            List<PricebookEntry> ListPricebookEntryToCreate2 = new List<PricebookEntry>();
            List<PricebookEntry> ListPricebookEntryToUpdate2 = new List<PricebookEntry>();
            for(Prix_specifiques__c PrixSpecifiquesRecord : listOfPrixSpecifiquesToRelaunch){
                String nameBuyerGroupAndPricebook = accountMap.get(PrixSpecifiquesRecord.Reference_client__c).Name + ' ' + magasinMap.get(PrixSpecifiquesRecord.Libelle_etablissement__c).Name;
                if(buyerGroupMap2.containsKey(nameBuyerGroupAndPricebook)){
                    if(pricebookMap2.get(nameBuyerGroupAndPricebook)!= null){
                        Map<Id,PricebookEntry> pricebookEntriesMap = new Map<Id,PricebookEntry>();
                        for(PricebookEntry pe : pricebookMap2.get(nameBuyerGroupAndPricebook).PricebookEntries){
                            pricebookEntriesMap.put(pe.Product2Id,pe);
                        }       
                        if (pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c) != null){
                            pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c).UnitPrice = PrixSpecifiquesRecord.Prix_de_vente_au_conditionnement__c;
                            pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c).IsActive = true;
                            ListPricebookEntryToUpdate2.add(pricebookEntriesMap.get(PrixSpecifiquesRecord.produit__c));
                        } else{
                            PricebookEntry AccountMagasinPriceBookEntry = new PricebookEntry(
                                Pricebook2Id = pricebookMap2.get(nameBuyerGroupAndPricebook).id,
                                Product2Id = PrixSpecifiquesRecord.Produit__c,
                                UnitPrice = PrixSpecifiquesRecord.Prix_de_vente_au_conditionnement__c,
                                UseStandardPrice = false,
                                IsActive = true
                            );
                            ListPricebookEntryToCreate2.add(AccountMagasinPriceBookEntry);
                        }
                    } 
                } 
            }
            
            Update ListPricebookEntryToUpdate2;
            if(!Test.isRunningTest()) Insert ListPricebookEntryToCreate2;
        }
        
    }


    public void activateDeactivatePriceBookEntries(List<Prix_specifiques__c> spesToDeact,List<Prix_specifiques__c> spesToAct){
        List<String> pbNames = new List<String>();
        Set<Id> setOfProductsIds = new Set<Id>();
        List<Prix_specifiques__c> prixSpecifiqueList = new List<Prix_specifiques__c>();

        prixSpecifiqueList.addAll(spesToDeact);
        prixSpecifiqueList.addAll(spesToAct);

        List<Prix_specifiques__c> loadedPrixSpecifique = [SELECT Id, Produit__c, Reference_client__r.Name, Libelle_etablissement__r.Name FROM Prix_specifiques__c WHERE Id IN :prixSpecifiqueList];
        
        for(Prix_specifiques__c ps : loadedPrixSpecifique){
            pbNames.add(ps.Reference_client__r.Name + ' ' + ps.Libelle_etablissement__r.Name);
            setOfProductsIds.add(ps.Produit__c);
        }
        
        Map<String, PricebookEntry> pbeByKey = new Map<String, PricebookEntry>();
        for (PricebookEntry  pbe : [
           SELECT Id, name, Pricebook2Id, Product2Id, UnitPrice, IsActive, Pricebook2.Name
           FROM PricebookEntry
           WHERE Pricebook2.Name IN :pbNames 
           AND Product2Id IN :setOfProductsIds
        ]){
            String key = pbe.Pricebook2.Name + pbe.Product2Id; // Key = AccountName + MagasinName + ProductId
            pbeByKey.put(key, pbe);
        }

        for(Prix_specifiques__c ps : spesToDeact){
            String key = ps.Reference_client__r.Name + ' ' + ps.Libelle_etablissement__r.Name + ps.Produit__c;
            PricebookEntry pbe = pbeByKey.get(key);
            if(pbe != null)
                pbe.IsActive = false;
        }
        for(Prix_specifiques__c ps : spesToAct){
            String key = ps.Reference_client__r.Name + ' ' + ps.Libelle_etablissement__r.Name + ps.Produit__c;
            PricebookEntry pbe = pbeByKey.get(key);
            if(pbe != null)
                pbe.IsActive = true;
        }

        update pbeByKey.values();
    }
}