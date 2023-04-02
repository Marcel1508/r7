/**
* @author       foued.dilmi@ibm.com
* @date         2021-05-21
* @description  Test class for AutocreatedRegHandler apex class
**/
@isTest
private class Test_AutocreatedRegHandler 
{
    @testSetup 
    static void setup() 
    {
        
        Profile p = [SELECT id 
                     FROM profile 
                     WHERE name ='Contract Manager'];
        
        User u1 = new User(alias = 'GDISSO01',
                           email = 'GDI_SSO_01@promocash.com',
                           emailencodingkey = 'UTF-8',
                           lastname = 'GDI_SSO',
                           languagelocalekey = 'en_US',
                           localesidkey = 'en_US',
                           profileId = p.Id,
                           timezonesidkey = 'America/Los_Angeles',
                           username = 'GDI_SSO_01@promocash.com',
                           federationidentifier = 'GDI_SSO_Id');
        insert u1;
    
    }
    
 	@isTest
    static void TestCreateUser() 
 	{
         AutocreatedRegHandler handler = new AutocreatedRegHandler();
         Auth.UserData sampleData = new Auth.UserData(
             'GDI_SSO_Id', 
             'GDI_SSO_First', 
             'GDI_SSO',
             'GDI_SSO_First GDI_SSO', 
             'GDI_SSO_01@promocash.com',
             null, 
             'GDI_SSO_long', 
             'fr_FR', 
             'GDI',
             null, 
             new Map<String, String>{'language' => 'fr_FR'});
         
         User u = handler.createUser(null, sampleData);
         /*
         System.assertEquals('GDI_SSO_01@promocash.com', u.userName);
         System.assertEquals('GDI_SSO_01@promocash.com', u.email);
         System.assertEquals('GDI_SSO', u.lastName);
         System.assertEquals('GDI_SSO_First', u.firstName);
         System.assertEquals('GDISSO01', u.alias);
         System.assertEquals('GDI_SSO_Id', u.federationidentifier);
		*/
	
    }
    
	@isTest
	static void TestCreateUser1() 
 	{
     	AutocreatedRegHandler handler = new AutocreatedRegHandler();

         Auth.UserData sampleData = new Auth.UserData(
             'GDI_SSO_Id_1', 
             'GDI_SSO_First', 
             'GDI_SSO',
             'GDI_SSO_First GDI_SSO', 
             'GDI_SSO_01@promocash.com',
             null, 
             'GDI_SSO_long', 
             'fr_FR', 
             'GDI',
             null, 
             new Map<String, String>{'language' => 'fr_FR'});
         
        User u1 = handler.createUser(null, sampleData);
 	}
}