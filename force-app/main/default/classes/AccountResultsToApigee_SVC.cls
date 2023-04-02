/**
 * @CreatedBy       : Suliman A.
 * @Date            : 09/04/2021
 * @Company         : IBM, Bluewolf
 * @Description     : On after create or after update, verify account status is not Lead and send it to AccountsToApigeeCallout_SVC class.  
 */

public without sharing class AccountResultsToApigee_SVC {
    private static AccountService service = new AccountService();

    public static void getAccounts(String postOrPut, List<Account> accounts){
        //Get URL and APIKey from ApiGee_Setting__mdt object
        ApiGee_Setting__mdt apiGeeSetting = [SELECT MasterLabel, ApiGee_ClientId__c, ApiGee_ClientSecret__c, ApiGee_URL__c FROM ApiGee_Setting__mdt WHERE MasterLabel = 'ApiGee_Account_Identifier' AND Bypass_INT13__c = false LIMIT 1];
        String apiGeeURL;
        String apiGeeId;
        String apiGeeKey;
        if(apiGeeSetting != null){
            apiGeeId = apiGeeSetting.ApiGee_ClientId__c;
            apiGeeKey = apiGeeSetting.ApiGee_ClientSecret__c;
            apiGeeURL = apiGeeSetting.ApiGee_URL__c;
        }
        
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        Set<Id> apeCodes = new Set<Id>();
        //Send only accouts which have Status Prospect or client
        for(Account acc : accounts){
            if(acc.Statut_Fiche_client__c == 'Prospect' || acc.Statut_Fiche_client__c == 'Client'){
                accountsMap.put(acc.Id, acc);
                apeCodes.add(acc.Code_APE__c);
            }
        }
        
        List<Account> accountInfos = [SELECT Id,(SELECT Id, Account__c, Nom_banque__c, Adresse_banque__c, Code_banque__c, Code_guichet__c, N_de_compte__c, Cle_RIB__c, 
                                     Code_IBAN__c, BIC__c, RUM__c, ICS__c, Nom_de_voie_Banque__c, numro_de_voie_Banque__c, Type_voie_Banque__c, Code_postal_Banque__c,
                                     complment_adresse_Banque__c, Ville_Banque__c, Siret_Payeur__c FROM Informations_financieres__r),
                                     (SELECT Id, AccountId, LastName, FirstName, Email, Email_du_contact__c, Telephone_portable__c, Salutation, Accepte_courrier__c, 
                                     Accepte_fax__c, Accepte_eMail__c, Accepte_telephone__c, Accepte_SMS__c FROM Contacts WHERE Contact_principal__c = True),
                                     (SELECT Id, ParentId, Nom_de_voie__c, Numero_de_voie__c, Type_de_voie__c, PostalCode, City, CountryCode, Complement_d_adresse__c, AddressType FROM ContactPointAddresses WHERE IsDefault = True)
                                     from Account where Id =: accountsMap.keySet()];
        
        List<Contact> contactsList = new List<Contact>();
        List<Information_financiere__c> financeInfosList = new List<Information_financiere__c>();
        List<ContactPointAddress> contactPointAddressList = new List<ContactPointAddress>();
        if(accountInfos != null && !accountInfos.isEmpty())
        {
            for(Account a : accountInfos)
        		{
            		financeInfosList.addAll(a.Informations_financieres__r);
                    contactsList.addAll(a.Contacts);
                    contactPointAddressList.addAll(a.ContactPointAddresses);   
        		}
        }
        List<ContactPointAddress> shippingAddress = new List<ContactPointAddress>();
        List<ContactPointAddress> billingAddress = new List<ContactPointAddress>();
        if(contactPointAddressList != null && !contactPointAddressList.isEmpty())
        {
            for(ContactPointAddress cpa: contactPointAddressList)
            {
                if(cpa.AddressType == 'Shipping')
                {
                    shippingAddress.add(cpa);
                    
                } else if(cpa.AddressType == 'Billing')
                {
                    billingAddress.add(cpa);
                }
            }
        }
        
        //Map Account with Information_financiere
        Map<Id, Information_financiere__c> financeInfosMap = new Map<Id, Information_financiere__c>();
        for(Information_financiere__c finInfo : financeInfosList){
            financeInfosMap.put(finInfo.Account__c, finInfo);
        }
        
        //Map Account with personal_informations
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        for(Contact contact : contactsList){
            contactsMap.put(contact.AccountId, contact);
        }
        
        //Retrieve Code APE
        List<Code_APE__c> apeCodesList = [SELECT Id, Name, APE_code__c, Code_specialisation__c FROM Code_APE__c WHERE Id =: APECodes];
        //Map Account with personal_informations
        Map<Id, String> apeCodesMap = new Map<Id, String>();
        Map<Id, String> apeCodeSpecialisationMap = new Map<Id, String>();
        for(Code_APE__c apeCode : apeCodesList){
            apeCodesMap.put(apeCode.Id, apeCode.APE_code__c);
            apeCodeSpecialisationMap.put(apeCode.Id, apeCode.Code_specialisation__c);
        }
            
        //Map Account with CPA
        Map<Id, ContactPointAddress> shippingAddressMap = new Map<Id, ContactPointAddress>();
        Map<Id, ContactPointAddress> billingAddressMap = new Map<Id, ContactPointAddress>();
        //Retrieve Shipping Address
        if(!shippingAddress.isEmpty()){
            for(ContactPointAddress cpa : shippingAddress){
                shippingAddressMap.put(cpa.ParentId, cpa);
            }
        }
        
        //Retrieve Billing Address
        if(!billingAddress.isEmpty()){
            for(ContactPointAddress cpa : billingAddress){
                billingAddressMap.put(cpa.ParentId, cpa);
            }
        }
        
        Integer loopCount = 0;
        for(Account acc : accountsMap.values()){
            
            //String account = JSON.serialize( accountsMap.get(acc.Id) );
            
            //Get the value of Finance info
            Information_financiere__c finInfo = financeInfosMap.get(acc.Id);
            
            //Get personal info
            Contact personalInfo = contactsMap.get(acc.Id);
            
            //Check the value of shipping and billing address
            ContactPointAddress shippingaddr = shippingAddressMap.get(acc.Id);
            ContactPointAddress billingaddr = billingAddressMap.get(acc.Id);
            
            
            //Check if account data is complete
            if(!service.isAccountDataComplete(acc, personalInfo, billingaddr, shippingaddr, apeCodesMap.get(acc.Code_APE__c))){
               continue;
            }
            
            //Create a JSONGenerator object.
            //Pass true to the constructor for pretty print formatting.
            JSONGenerator gen = JSON.createGenerator(true);
            // Write data to the JSON string.
            gen.writeStartObject();
            
            gen.writeFieldName('detailed_account');
            gen.writeStartObject();
            if(acc.Numero_Client__c == null){gen.writeStringField('Numero_Client__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Numero_Client__c.length() > 9 ){
                        String numeroClient = acc.Numero_Client__c.substring(0, 9);
                        gen.writeStringField('Numero_Client__c', numeroClient);
                    } else {
                        gen.writeStringField('Numero_Client__c', acc.Numero_Client__c);
                    }
                }
            if(acc.Code_etablissement__c == null){gen.writeStringField('Code_etablissement__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Code_etablissement__c.length() > 4 ){
                        String codeEtablissement = acc.Code_etablissement__c.substring(0, 4);
                        gen.writeStringField('Code_etablissement__c', codeEtablissement);
                    } else {
                        gen.writeStringField('Code_etablissement__c', acc.Code_etablissement__c);
                    }
                }
            if(acc.Forme_juridique__c == null){gen.writeStringField('Forme_juridique__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Forme_juridique__c.length() > 2 ){
                        String formeJuridique = acc.Forme_juridique__c.substring(0, 2);
                        gen.writeStringField('Forme_juridique__c', formeJuridique);
                    } else {
                        gen.writeStringField('Forme_juridique__c', acc.Forme_juridique__c);
                    }
                }
            if(acc.Name == null){gen.writeStringField('Name', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Name.length() > 28 ){
                        String name = acc.Name.substring(0, 28);
                        gen.writeStringField('Name', name);
                    } else {
                        gen.writeStringField('Name', acc.Name);
                    }
                }
            if(acc.Numero_Siret__c == null){gen.writeStringField('Numero_Siret__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Numero_Siret__c.length() > 14 ){
                        String numeroSiret = acc.Numero_Siret__c.substring(0, 14);
                        gen.writeStringField('Numero_Siret__c', numeroSiret);
                    } else {
                        gen.writeStringField('Numero_Siret__c', acc.Numero_Siret__c);
                    }
                }
            if(acc.Enseigne_commerciale__c == null){gen.writeStringField('Enseigne_commerciale__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Enseigne_commerciale__c.length() > 30 ){
                        String enseigneCommerciale = acc.Enseigne_commerciale__c.substring(0, 30);
                        gen.writeStringField('Enseigne_commerciale__c', enseigneCommerciale);
                    } else {
                        gen.writeStringField('Enseigne_commerciale__c', acc.Enseigne_commerciale__c);
                    }
                }
            
            gen.writeFieldName('personal_informations');
            gen.writeStartObject();
                if(personalInfo == null || personalInfo.Salutation == null){gen.writeStringField('Salutation', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(personalInfo.Salutation.length() > 4 ){
                            String salutation = personalInfo.Salutation.substring(0, 4);
                            gen.writeStringField('Salutation', salutation);
                        } else {
                            gen.writeStringField('Salutation', personalInfo.Salutation);
                        }
                    }
                if(personalInfo == null || personalInfo.LastName == null){gen.writeStringField('LastName', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(personalInfo.LastName.length() > 25 ){
                            String lastName = personalInfo.LastName.substring(0, 25);
                            gen.writeStringField('LastName', lastName);
                        } else {
                            gen.writeStringField('LastName', personalInfo.LastName);
                        }
                    }
                if(personalInfo == null || personalInfo.FirstName == null){gen.writeStringField('FirstName', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(personalInfo.FirstName.length() > 20 ){
                            String firstName = personalInfo.FirstName.substring(0, 20);
                            gen.writeStringField('FirstName', firstName);
                        } else {
                            gen.writeStringField('FirstName', personalInfo.FirstName);
                        }
                    }
                if(personalInfo == null || personalInfo.Email == null){gen.writeStringField('Email_du_contact__c', ' ');} else {gen.writeStringField('Email_du_contact__c', personalInfo.Email);}
            gen.writeEndObject();
            if(personalInfo == null || personalInfo.Telephone_portable__c == null){gen.writeStringField('Telephone_portable__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(personalInfo.Telephone_portable__c.length() > 14 ){
                        String telephonePortable = personalInfo.Telephone_portable__c.substring(0, 14);
                        gen.writeStringField('Telephone_portable__c', telephonePortable);
                    } else {
                        gen.writeStringField('Telephone_portable__c', personalInfo.Telephone_portable__c);
                    }
                }
            
            gen.writeFieldName('shipping_address');
            gen.writeStartObject();
                if(shippingaddr == null || shippingaddr.Numero_de_voie__c == null){gen.writeStringField('Numero_de_voie__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.Numero_de_voie__c.length() >= 5 ){
                            String numeroDeVoie = shippingaddr.Numero_de_voie__c.substring(0, 5);
                            gen.writeStringField('Numero_de_voie__c', numeroDeVoie);
                        } else {
                            gen.writeStringField('Numero_de_voie__c', shippingaddr.Numero_de_voie__c);
                        }
                    }
                if(shippingaddr == null || shippingaddr.Nom_de_voie__c == null){gen.writeStringField('Nom_de_voie__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.Nom_de_voie__c.length() > 32 ){
                            String nomDeVoie = shippingaddr.Nom_de_voie__c.substring(0, 32);
                            gen.writeStringField('Nom_de_voie__c', nomDeVoie);
                        } else {
                            gen.writeStringField('Nom_de_voie__c', shippingaddr.Nom_de_voie__c);
                        }
                    }
                if(shippingaddr == null || shippingaddr.Type_de_voie__c == null){gen.writeStringField('Type_de_voie__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.Type_de_voie__c.length() > 5 ){
                            String typeDeVoie = shippingaddr.Type_de_voie__c.substring(0, 5);
                            gen.writeStringField('Type_de_voie__c', typeDeVoie);
                        } else {
                            gen.writeStringField('Type_de_voie__c', shippingaddr.Type_de_voie__c);
                        }
                    }
                if(shippingaddr == null || shippingaddr.PostalCode == null){gen.writeStringField('PostalCode', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.PostalCode.length() > 5 ){
                            String postalCode = shippingaddr.PostalCode.substring(0, 5);
                            gen.writeStringField('PostalCode', postalCode);
                        } else {
                            gen.writeStringField('PostalCode', shippingaddr.PostalCode);
                        }
                    }
                if(shippingaddr == null || shippingaddr.Complement_d_adresse__c == null){gen.writeStringField('Complement_d_adresse__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.Complement_d_adresse__c.length() > 32 ){
                            String complementAdresse = shippingaddr.Complement_d_adresse__c.substring(0, 32);
                            gen.writeStringField('Complement_d_adresse__c', complementAdresse);
                        } else {
                            gen.writeStringField('Complement_d_adresse__c', shippingaddr.Complement_d_adresse__c);
                        }
                    }
            	if(shippingaddr == null || shippingaddr.City == null){gen.writeStringField('City', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.City.length() > 32 ){
                            String city = shippingaddr.City.substring(0, 32);
                            gen.writeStringField('City', city);
                        } else {
                            gen.writeStringField('City', shippingaddr.City);
                        }
                    }
                if(shippingaddr == null || shippingaddr.CountryCode == null){gen.writeStringField('Country', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(shippingaddr.CountryCode.length() > 2 ){
                            String countryCode = shippingaddr.CountryCode.substring(0, 2);
                            gen.writeStringField('Country', countryCode);
                        } else {
                            gen.writeStringField('Country', shippingaddr.CountryCode);
                        }
                    }
            gen.writeEndObject();
            if(acc.NPAI_livraison__c == null){gen.writeStringField('NPAI_livraison__c', ' ');} else {gen.writeBooleanField('NPAI_livraison__c', acc.NPAI_livraison__c);}
            
            gen.writeFieldName('billing_address');
            gen.writeStartObject();
                if(billingaddr == null || billingaddr.Numero_de_voie__c == null){gen.writeStringField('Numero_de_voie__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(billingaddr.Numero_de_voie__c.length() > 5 ){
                            String numeroDeVoie = billingaddr.Numero_de_voie__c.substring(0, 5);
                            gen.writeStringField('Numero_de_voie__c', numeroDeVoie);
                        } else {
                            gen.writeStringField('Numero_de_voie__c', billingaddr.Numero_de_voie__c);
                        }
                    }
                if(billingaddr == null || billingaddr.Nom_de_voie__c == null){gen.writeStringField('Nom_de_voie__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(billingaddr.Nom_de_voie__c.length() > 32 ){
                            String nomDeVoie = billingaddr.Nom_de_voie__c.substring(0, 32);
                            gen.writeStringField('Nom_de_voie__c', nomDeVoie);
                        } else {
                            gen.writeStringField('Nom_de_voie__c', billingaddr.Nom_de_voie__c);
                        }
                    }
                if(billingaddr == null || billingaddr.Type_de_voie__c == null){gen.writeStringField('Type_de_voie__c', ' ');} else {gen.writeStringField('Type_de_voie__c', billingaddr.Type_de_voie__c);}
                if(billingaddr == null || billingaddr.PostalCode == null){gen.writeStringField('PostalCode', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(billingaddr.PostalCode.length() > 5 ){
                            String postalCode = billingaddr.PostalCode.substring(0, 5);
                            gen.writeStringField('PostalCode', postalCode);
                        } else {
                            gen.writeStringField('PostalCode', billingaddr.PostalCode);
                        }
                    }
                if(billingaddr == null || billingaddr.Complement_d_adresse__c == null){gen.writeStringField('Complement_d_adresse__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(billingaddr.Complement_d_adresse__c.length() > 32 ){
                            String complementAdresse = billingaddr.Complement_d_adresse__c.substring(0, 32);
                            gen.writeStringField('Complement_d_adresse__c', complementAdresse);
                        } else {
                            gen.writeStringField('Complement_d_adresse__c', billingaddr.Complement_d_adresse__c);
                        }
                    }
            	if(billingaddr == null || billingaddr.City == null){gen.writeStringField('City', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(billingaddr.City.length() > 32 ){
                            String city = billingaddr.City.substring(0, 32);
                            gen.writeStringField('City', city);
                        } else {
                            gen.writeStringField('City', billingaddr.City);
                        }
                    }
                if(billingaddr == null || billingaddr.CountryCode == null){gen.writeStringField('Country', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(billingaddr.CountryCode.length() > 2 ){
                            String countryCode = billingaddr.CountryCode.substring(0, 2);
                            gen.writeStringField('Country', countryCode);
                        } else {
                            gen.writeStringField('Country', billingaddr.CountryCode);
                        }
                    }
            gen.writeEndObject();
            if(acc.NPAI_facturation__c == null){gen.writeStringField('NPAI_facturation__c', ' ');} else {gen.writeBooleanField('NPAI_facturation__c', acc.NPAI_facturation__c);}
            
            if(apeCodesMap.get(acc.Code_APE__c) == null){gen.writeStringField('Code_APE__c', ' ');} else {gen.writeStringField('Code_APE__c', apeCodesMap.get(acc.Code_APE__c));}
            if(acc.Categorie__c == null){gen.writeStringField('Categorie__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Categorie__c.length() > 1 ){
                        String categorie = acc.Categorie__c.substring(0, 1);
                        gen.writeStringField('Categorie__c', categorie);
                    } else {
                        gen.writeStringField('Categorie__c', acc.Categorie__c);
                    }
                }
            if(apeCodeSpecialisationMap.get(acc.Code_APE__c) == null){gen.writeStringField('Specialisation__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(apeCodeSpecialisationMap.get(acc.Code_APE__c).length() > 2 ){
                        String specialisation = apeCodeSpecialisationMap.get(acc.Code_APE__c).substring(0, 2);
                        gen.writeStringField('Specialisation__c', specialisation);
                    } else {
                        gen.writeStringField('Specialisation__c', apeCodeSpecialisationMap.get(acc.Code_APE__c));
                    }
                }
            //if(acc.CodeSpecialisation__c == null){gen.writeStringField('Specialisation__c', ' ');} else {gen.writeStringField('Specialisation__c', acc.CodeSpecialisation__c);}
            if(acc.Theme__c == null){gen.writeStringField('Theme__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Theme__c.length() > 2 ){
                        String theme = acc.Theme__c.substring(0, 2);
                        gen.writeStringField('Theme__c', theme);
                    } else {
                        gen.writeStringField('Theme__c', acc.Theme__c);
                    }
                }
            if(acc.Libell_code_APE__c == null){gen.writeStringField('Libell_code_APE__c', ' ');} else {gen.writeStringField('Libell_code_APE__c', acc.Libell_code_APE__c);}
            if(acc.Email__c == null){gen.writeStringField('Email__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Email__c.length() > 50 ){
                        String email = acc.Email__c.substring(0, 50);
                        gen.writeStringField('Email__c', email);
                    } else {
                        gen.writeStringField('Email__c', acc.Email__c);
                    }
                }
            if(acc.Piece_identite__c == null){gen.writeStringField('Piece_identite__c', ' ');} else {gen.writeBooleanField('Piece_identite__c', acc.Piece_identite__c);}
            if(acc.Attestation_registre_du_commerce__c == null){gen.writeStringField('Attestation_registre_du_commerce__c', ' ');} else {gen.writeBooleanField('Attestation_registre_du_commerce__c', acc.Attestation_registre_du_commerce__c);}
            if(acc.Origine__c == null){gen.writeStringField('Origine__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Origine__c.length() > 1 ){
                        String origine = acc.Origine__c.substring(0, 1);
                        gen.writeStringField('Origine__c', origine);
                    } else {
                        gen.writeStringField('Origine__c', acc.Origine__c);
                    }
                }
            if(acc.Telephone_Siret__c == null){gen.writeStringField('Telephone_Siret__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Telephone_Siret__c.length() > 14 ){
                        String telephoneSiret = acc.Telephone_Siret__c.substring(0, 14);
                        gen.writeStringField('Telephone_Siret__c', telephoneSiret);
                    } else {
                        gen.writeStringField('Telephone_Siret__c', acc.Telephone_Siret__c);
                    }
                }
            if(acc.K_bis__c == null){gen.writeStringField('K_bis__c', ' ');} else {gen.writeBooleanField('K_bis__c', acc.K_bis__c);}
            if(acc.RIB__c == null){gen.writeStringField('RIB__c', ' ');} else {gen.writeBooleanField('RIB__c', acc.RIB__c);}
            
            gen.writeFieldName('financial_informations');
            gen.writeStartObject();
                if(finInfo == null || finInfo.Nom_banque__c == null){gen.writeStringField('Nom_banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Nom_banque__c.length() > 30 ){
                            String nomBanque = finInfo.Nom_banque__c.substring(0, 30);
                            gen.writeStringField('Nom_banque__c', nomBanque);
                        } else {
                            gen.writeStringField('Nom_banque__c', finInfo.Nom_banque__c);
                        }
                    }
                if(finInfo == null || finInfo.Nom_de_voie_Banque__c == null){gen.writeStringField('Nom_de_voie_Banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Nom_de_voie_Banque__c.length() > 32 ){
                            String nomDeVoieBanque = finInfo.Nom_de_voie_Banque__c.substring(0, 32);
                            gen.writeStringField('Nom_de_voie_Banque__c', nomDeVoieBanque);
                        } else {
                            gen.writeStringField('Nom_de_voie_Banque__c', finInfo.Nom_de_voie_Banque__c);
                        }
                    }
                if(finInfo == null || finInfo.numro_de_voie_Banque__c == null){gen.writeStringField('numro_de_voie_Banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.numro_de_voie_Banque__c.length() >= 5 ){
                            String numeroDeVoieBanque = finInfo.numro_de_voie_Banque__c.substring(0, 5);
                            gen.writeStringField('numro_de_voie_Banque__c', numeroDeVoieBanque);
                        } else {
                            gen.writeStringField('numro_de_voie_Banque__c', finInfo.numro_de_voie_Banque__c);
                        }
                    }
                if(finInfo == null || finInfo.Type_voie_Banque__c == null){gen.writeStringField('Type_voie_Banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Type_voie_Banque__c.length() >= 5 ){
                            String typeVoieBanque = finInfo.Type_voie_Banque__c.substring(0, 5);
                            gen.writeStringField('Type_voie_Banque__c', typeVoieBanque);
                        } else {
                            gen.writeStringField('Type_voie_Banque__c', finInfo.Type_voie_Banque__c);
                        }
                    }
            	if(finInfo == null || finInfo.Code_postal_Banque__c == null){gen.writeStringField('Code_postal_Banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Code_postal_Banque__c.length() >= 5 ){
                            String codePostalBanque = finInfo.Code_postal_Banque__c.substring(0, 5);
                            gen.writeStringField('Code_postal_Banque__c', codePostalBanque);
                        } else {
                            gen.writeStringField('Code_postal_Banque__c', finInfo.Code_postal_Banque__c);
                        }
                    }
                if(finInfo == null || finInfo.complment_adresse_Banque__c == null){gen.writeStringField('complment_adresse_Banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.complment_adresse_Banque__c.length() >= 32 ){
                            String complementAdresseBanque = finInfo.complment_adresse_Banque__c.substring(0, 32);
                            gen.writeStringField('complment_adresse_Banque__c', complementAdresseBanque);
                        } else {
                            gen.writeStringField('complment_adresse_Banque__c', finInfo.complment_adresse_Banque__c);
                        }
                    }
                if(finInfo == null || finInfo.Ville_Banque__c == null){gen.writeStringField('Ville_Banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Ville_Banque__c.length() >=25 ){
                            String villeBanque = finInfo.Ville_Banque__c.substring(0, 25);
                            gen.writeStringField('Ville_Banque__c', villeBanque);
                        } else {
                            gen.writeStringField('Ville_Banque__c', finInfo.Ville_Banque__c);
                        }
                    }
                if(finInfo == null || finInfo.Code_banque__c == null){gen.writeStringField('Code_banque__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Code_banque__c.length() >= 5 ){
                            String codeBanque = finInfo.Code_banque__c.substring(0, 5);
                            gen.writeStringField('Code_banque__c', codeBanque);
                        } else {
                            gen.writeStringField('Code_banque__c', finInfo.Code_banque__c);
                        }
                    }
                if(finInfo == null || finInfo.Code_guichet__c == null){gen.writeStringField('Code_guichet__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Code_guichet__c.length() >= 5 ){
                            String codeGuichet = finInfo.Code_guichet__c.substring(0, 5);
                            gen.writeStringField('Code_guichet__c', codeGuichet);
                        } else {
                            gen.writeStringField('Code_guichet__c', finInfo.Code_guichet__c);
                        }
                    }
                if(finInfo == null || finInfo.N_de_compte__c == null){gen.writeStringField('N_de_compte__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.N_de_compte__c.length() >= 11 ){
                            String numDeCompte = finInfo.N_de_compte__c.substring(0, 11);
                            gen.writeStringField('N_de_compte__c', numDeCompte);
                        } else {
                            gen.writeStringField('N_de_compte__c', finInfo.N_de_compte__c);
                        }
                    }
                if(finInfo == null || finInfo.Cle_RIB__c == null){gen.writeStringField('Cle_RIB__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Cle_RIB__c.length() >= 2 ){
                            String cleRib = finInfo.Cle_RIB__c.substring(0, 2);
                            gen.writeStringField('Cle_RIB__c', cleRib);
                        } else {
                            gen.writeStringField('Cle_RIB__c', finInfo.Cle_RIB__c);
                        }
                    }
                if(finInfo == null || finInfo.Code_IBAN__c == null){gen.writeStringField('Code_IBAN__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Code_IBAN__c.length() >= 34 ){
                            String codeIban = finInfo.Code_IBAN__c.substring(0, 34);
                            gen.writeStringField('Code_IBAN__c', codeIban);
                        } else {
                            gen.writeStringField('Code_IBAN__c', finInfo.Code_IBAN__c);
                        }
                    }
                if(finInfo == null || finInfo.BIC__c == null){gen.writeStringField('BIC__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.BIC__c.length() >= 11 ){
                            String bic = finInfo.BIC__c.substring(0, 11);
                            gen.writeStringField('BIC__c', bic);
                        } else {
                            gen.writeStringField('BIC__c', finInfo.BIC__c);
                        }
                    }
                if(finInfo == null || finInfo.RUM__c == null){gen.writeStringField('RUM__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.RUM__c.length() > 35 ){
                            String rum = finInfo.RUM__c.substring(0, 35);
                            gen.writeStringField('RUM__c', rum);
                        } else {
                            gen.writeStringField('RUM__c', finInfo.RUM__c);
                        }
                    }
                if(finInfo == null || finInfo.ICS__c == null){gen.writeStringField('ICS__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.ICS__c.length() > 35 ){
                            String ics = finInfo.ICS__c.substring(0, 35);
                            gen.writeStringField('ICS__c', ics);
                        } else {
                            gen.writeStringField('ICS__c', finInfo.ICS__c);
                        }
                    }
            	if(finInfo == null || finInfo.Siret_Payeur__c == null){gen.writeStringField('Siret_Payeur__c', ' ');} 
            		else {
                        //Verify the length of the field to be recieved by Aquillon
                        if(finInfo.Siret_Payeur__c.length() >= 14 ){
                            String siretPayeur = finInfo.Siret_Payeur__c.substring(0, 14);
                            gen.writeStringField('Siret_Payeur__c', siretPayeur);
                        } else {
                            gen.writeStringField('Siret_Payeur__c', finInfo.Siret_Payeur__c);
                        }
                    }
            gen.writeEndObject();
            if(acc.Chaine_bloquee__c == null){gen.writeStringField('Chaine_bloquee__c', ' ');} else {gen.writeBooleanField('Chaine_bloquee__c', acc.Chaine_bloquee__c);}
            if(acc.Code_Externe_Chaine_Text__c == null){gen.writeStringField('Code_Externe_Chaine_Text__c', ' ');} else {gen.writeStringField('Code_Externe_Chaine_Text__c', acc.Code_Externe_Chaine_Text__c);}
            if(personalInfo == null || personalInfo.Accepte_courrier__c == null){gen.writeStringField('Accepte_courrier__c', ' ');} else {gen.writeBooleanField('Accepte_courrier__c', personalInfo.Accepte_courrier__c);}
            if(personalInfo == null || personalInfo.Accepte_fax__c == null){gen.writeStringField('Accepte_fax__c', ' ');} else {gen.writeBooleanField('Accepte_fax__c', personalInfo.Accepte_fax__c);}
            if(personalInfo == null || personalInfo.Accepte_eMail__c == null){gen.writeStringField('Accepte_eMail__c', ' ');} else {gen.writeBooleanField('Accepte_eMail__c', personalInfo.Accepte_eMail__c);}
            if(personalInfo == null || personalInfo.Accepte_telephone__c == null){gen.writeStringField('Accepte_telephone__c', ' ');} else {gen.writeBooleanField('Accepte_telephone__c', personalInfo.Accepte_telephone__c);}
            if(personalInfo == null || personalInfo.Accepte_SMS__c == null){gen.writeStringField('Accepte_SMS__c', ' ');} else {gen.writeBooleanField('Accepte_SMS__c', personalInfo.Accepte_SMS__c);}
            if(acc.Code_Chaine__c == null){gen.writeStringField('Code_Chaine__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Code_Chaine__c.length() > 5 ){
                        String codeChaine = acc.Code_Chaine__c.substring(0, 5);
                        gen.writeStringField('Code_Chaine__c', codeChaine);
                    } else {
                        gen.writeStringField('Code_Chaine__c', acc.Code_Chaine__c);
                    }
                }
            if(acc.Libelle_Chaine_nationale__c == null){gen.writeStringField('Libelle_Chaine_nationale__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Libelle_Chaine_nationale__c.length() > 30 ){
                        String libelleChaineNationale = acc.Libelle_Chaine_nationale__c.substring(0, 30);
                        gen.writeStringField('Libelle_Chaine_nationale__c', libelleChaineNationale);
                    } else {
                        gen.writeStringField('Libelle_Chaine_nationale__c', acc.Libelle_Chaine_nationale__c);
                    }
                }
            if(acc.Code_Externe_Chaine_Text__c == null){gen.writeStringField('Code_Externe_Chaine_Text__c', ' ');} 
            	else {
                    //Verify the length of the field to be recieved by Aquillon
                    if(acc.Code_Externe_Chaine_Text__c.length() >=15 ){
                        String codeExterneChaineText = acc.Code_Externe_Chaine_Text__c.substring(0, 15);
                        gen.writeStringField('Code_Externe_Chaine_Text__c', codeExterneChaineText);
                    } else {
                        gen.writeStringField('Code_Externe_Chaine_Text__c', acc.Code_Externe_Chaine_Text__c);
                    }
                }
            
            gen.writeEndObject();
            
            gen.writeEndObject();
            
            // Get the JSON string.
            String accountDetails = gen.getAsString();
            
            String clientNum;
            //Check if it is Update or Insert to add the client number to URL
            if(acc.ifAccountSentToAkeneo__c) // Account is already created in Akeneo, we need to do an update
                clientNum = acc.Numero_Client__c;
            else
                clientNum = '';
            
            /*
            if(PostOrPut == 'AUpdate'){
                clientNum = acc.Numero_Client__c;
            } else if(PostOrPut == 'AInsert'){
                clientNum = '';
            }*/
            AccountsToApigeeCallout_SVC.accountPostOrPutCallout(clientNum, accountDetails, acc.Id, apiGeeURL, apiGeeId, apiGeeKey);
            loopCount++;
        } 

    }
    
  
    
}