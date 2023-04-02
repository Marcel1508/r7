/**
 * @CreatedBy       : Suliman A.
 * @Date            : 01/07/2021
 * @Company         : IBM, Bluewolf
 * @Description     : B2BUtilsCustom test class.  
 */

@isTest
public class B2BUtilsCustom_TST {
    @isTest
    static void getWebStoreId(){
       // Network communityId = [SELECT Id, name FROM Network where name = 'Promocash' LIMIT 1][0];
        //String communityString = String.valueOf(communityId.Id);
        B2BUtilsCustom.resolveCommunityIdToWebstoreId('');
        B2BUtilsCustom.resolveSortParam('CreatedDateAsc');
    }
}