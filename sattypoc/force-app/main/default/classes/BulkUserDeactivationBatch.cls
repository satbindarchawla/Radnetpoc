public class BulkUserDeactivationBatch implements Database.Batchable<SObject> {

    private Date targetDate;

    // Constructor to accept the target date (calculated in the REST API)
    public BulkUserDeactivationBatch(Date targetDate) {
        this.targetDate = targetDate;
    }

    // Start method: Define the query for retrieving users to deactivate
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'SELECT Id, LastLoginDate, LastModifiedDate,FederationIdentifier,IsActive FROM User WHERE LastModifiedDate <= :targetDate AND FederationIdentifier!= NULL,IsActive = true AND Id != \'005Uw000003rC69IAE\'';
        String query = 'SELECT Id, LastLoginDate, LastModifiedDate,Logincheck__c,FederationIdentifier,IsActive FROM User WHERE Logincheck__c <= :targetDate AND FederationIdentifier!= NULL AND IsActive = true AND Id != \'005Uw000003rC69IAE\'';
        return Database.getQueryLocator(query);
    }

    // Execute method: Process each batch of users
    public void execute(Database.BatchableContext BC, List<User> scope) {
        List<User> usersToDeactivate = new List<User>();

        // Loop through the users in the current batch and deactivate them
        for (User u : scope) {
            u.IsActive = false;  // Set the user to inactive
            usersToDeactivate.add(u);
        }

        // Perform a bulk update to deactivate the users
        if (!usersToDeactivate.isEmpty()) {
            update usersToDeactivate;
        }
    }

    // Finish method: Optional method that runs after the batch completes (e.g., send notification or logging)
    public void finish(Database.BatchableContext BC) {
        System.debug('User deactivation batch job completed successfully.');
    }
}