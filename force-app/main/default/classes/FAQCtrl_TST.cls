//Pour avoir du ManagedContent, il faut avoir accès à toutes les données
@isTest(SeeAllData=true)
public class FAQCtrl_TST {
    static testMethod void testFAQCtrl() {
        FAQCtrl.getMContent(null,null);
    }
}