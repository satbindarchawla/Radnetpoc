@RestResource(urlMapping='/deactivateUsersAPI/*')
global with sharing class UserDeactivationRESTResource {

    // The main method to handle the POST request
    @HttpPost
    global static String deactivateUsers() {
        // Parse the JSON request body (you can specify criteria like months of inactivity)
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(body);
        Integer monthsInactive = (Integer)params.get('monthsInactive');
        
        // If the monthsInactive parameter is not provided, default to 6 months
        if (monthsInactive == null) {
            monthsInactive = 6;
        }
        
        // Calculate the target date (users who haven't logged in since this date should be deactivated)
        Date targetDate = System.today().addMonths(-monthsInactive);
        system.debug('targetDate ++++' + targetDate );
        
        // Query users who haven't logged in for the specified number of months
        //List<User> usersToDeactivate = [SELECT Id, LastLoginDate, LastModifiedDate, FederationIdentifier, IsActive FROM User WHERE LastModifiedDate <= :targetDate AND FederationIdentifier!=NULL AND IsActive = true AND Id != '005Uw000003rC69IAE'];
        List<User> usersToDeactivate = [SELECT Id, LastLoginDate,Logincheck__c,LastModifiedDate, FederationIdentifier, IsActive FROM User WHERE Logincheck__c <=:targetDate AND FederationIdentifier!=NULL AND IsActive = true AND Id != '005Uw000003rC69IAE'];
        system.debug('usersToDeactivate ++++' + usersToDeactivate );
        
        // If there are users to deactivate, call the batch process
        if (!usersToDeactivate.isEmpty()) {
            // Trigger the batch job for deactivation
            BulkUserDeactivationBatch batch = new BulkUserDeactivationBatch(targetDate);
            Database.executeBatch(batch, 200);
            return 'Batch job started for deactivating users.';
        }
        
        return 'No users meet the deactivation criteria.';
    }
}