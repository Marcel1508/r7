@isTest
public class NavigationMenuController_TST {
    static testMethod void testNavigationMenuController() {
        //Cette méthode est très compliquée à tester de manière propre (tester les résultats)
        List<NavigationMenuItem> lst = NavigationMenuController.getNavigationMenuItems('MyMenuTest');
		System.assertEquals(0, lst.size());
    }
    
}