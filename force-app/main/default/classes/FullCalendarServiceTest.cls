@isTest
private class FullCalendarServiceTest {
    @isTest
	private static void fetchAllEventtest()
		{
            MagasinTriggerHandler.bypassTrigger=true;
            AccountTriggerHandler.bypassTrigger = true;
            List<Event> eventList=new List<Event>();
            Magasin__c  magasinRec = TestDataFactory.createGenericMagasin('uniqueMagasinCD');
            Insert magasinRec ;
    
            Account accTest = TestDataFactory.createGenericAccountRecord('TestAcc','Lead',magasinRec);
            accTest.En_cours_de_creation_au_reg_du_commerce__c = true;
            insert accTest;

            for(integer i=0;i<5;i++){
                Event e = new Event();
                e.WhatId=accTest.id;
                e.StartDateTime=system.today();
                e.EndDateTime=system.today()+5;
                eventList.add(e);
            }
            
            insert eventList;

            Test.startTest();
			List<Event> events=FullCalendarService.fetchAllEvents();
            System.assert(events.size()==5, 'size should be 5');
			Test.stopTest();
		}

}