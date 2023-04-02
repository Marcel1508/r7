/**
* @author       jan.straka@bluewolf
* @date         2020-11-25
* @description  Service for bypassing process builders
**/
public with sharing class BypassProcess {
    @InvocableMethod(label='Do Nothing' description='Method to bypass process funtionality')
    public static void doNothing() {
        System.debug('---> PROCESS BYPASSED:');
    }
}