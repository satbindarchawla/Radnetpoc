public with sharing class UserActivationController {

    // Fetch users based on JIT_Status__c (TRUE or FALSE) and IsActive status
    @AuraEnabled(cacheable=true)
    public static List<User> getUsersByJITStatus(Boolean jitStatus) {
        List<User> users;
        
        // If JIT Status is true, fetch active users created via JIT
        if (jitStatus) {
            users = [SELECT Id, Name, JIT_Status__c, IsActive 
                     FROM User 
                     WHERE JIT_Status__c = TRUE AND IsActive = TRUE];
        } 
        // If JIT Status is false, fetch deactivated users (JIT Status is false and IsActive is false)
        else {
            users = [SELECT Id, Name, JIT_Status__c, IsActive 
                     FROM User 
                     WHERE JIT_Status__c = FALSE AND IsActive = FALSE];
        }
        
        return users;
    }
}