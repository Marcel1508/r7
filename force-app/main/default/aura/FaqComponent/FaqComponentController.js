({
    myAction : function(component, event, helper) {
        
    },
    doInit : function(component, event, helper) {
        console.log("11111111");
        
        var selectedCType = component.get('v.contentType');
       // var selectedMCIds = component.get('v.managedContentIds');
       // var selectedTopics = component.get('v.topicNames');
       //	var selectedTopics = component.get('v.topicNames');
        var selectedLanguage = component.get('v.language');
        var contentAction = component.get("c.getMContent");
       /* if(selectedMCIds){
            contentAction.setParam('managedContentIds_str', selectedMCIds);    
        } */      
      //   contentAction.setParam('topicNames_str', selectedTopics);
         contentAction.setParam('language', 'fr');    
        if(selectedCType){
            contentAction.setParam('contentType', selectedCType);    
        }
        contentAction.setCallback(this, function(action) {
                      var state = action.getState();
                    if (state === 'SUCCESS') {
						console.log('action.getReturnValue()...'+action.getReturnValue());
                        
						//console.log('action.getReturnValue();contentNodes...'+action.getReturnValue()[0].contentNodes);
                        
                        component.set("v.contentList",action.getReturnValue());
                    }
                    else{
                        console.log("Error occurrred");
                    }
                   });
        $A.enqueueAction(contentAction);
    },
    getMcContent : function(component, event, helper) {
    }
    
})