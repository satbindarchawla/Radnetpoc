public with sharing class UserActivationController {

    // Fetch users based on the selected status
    @AuraEnabled(cacheable=true)
    public static List<User> getUsersByStatus(Boolean isActive) {
        List<User> users;
        
        // Fetch active users (IsActive = TRUE and JIT_Status__c = TRUE)
        if (isActive) {
            users = [SELECT Id, Name, JIT_Status__c, IsActive, 
                            LastModifiedBy.Name, LastModifiedDate 
                     FROM User 
                     WHERE IsActive = TRUE AND JIT_Status__c = TRUE];
        } 
        // Fetch deactivated users (IsActive = FALSE and JIT_Status__c = FALSE)
        else {
            users = [SELECT Id, Name, JIT_Status__c, IsActive, 
                            LastModifiedBy.Name, LastModifiedDate 
                     FROM User 
                     WHERE IsActive = FALSE AND JIT_Status__c = FALSE];
        }
        
        return users;
    }
}