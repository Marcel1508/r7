/**
 * @CreatedBy       : Suliman A.
 * @Date            : 30/03/2021
 * @Company         : IBM, Bluewolf
 * @Description     : This Schedulable class calls OpenHours_Magasin_SVC.getOpenHours() method to schedule the update of Open Hours of Magasins 4 times per day(5h, 11h, 14h, 17h).
 * 						  To Schedule the job, the script below should be run in Anonymous Window
* 							System.schedule('Partoo API Job', '0 0 5,11,14,17 * * ?', new OpenHours_Magasin_SCH());
 */

public without sharing class OpenHours_Magasin_SCH implements Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext SC){
		OpenHours_Magasin_SVC.getOpenHours();
    }
}