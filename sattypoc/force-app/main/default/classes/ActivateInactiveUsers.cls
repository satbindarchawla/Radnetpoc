public class ActivateInactiveUsers {
    public static void updateInactiveUsers(){
        
        List<User> InactiveUsers = [Select Id, IsActive from user where IsActive = false and LastModifiedDate =Today and Logincheck__c != NULL];
			if (!InactiveUsers.isEmpty()) {
    			for(User u : InactiveUsers){
       			 u.IsActive = true;
    		}
    		update InactiveUsers;
    		System.debug(InactiveUsers.size() + 'user activated successfully');
		}
    }
}