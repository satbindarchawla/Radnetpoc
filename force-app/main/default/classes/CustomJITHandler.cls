global class CustomJITHandler implements Auth.SamlJitHandler {

    private class JitException extends Exception {}

    private void handleUser(boolean create, User u, Map<String, String> attributes, 
        String federationIdentifier, boolean isStandard) {

        // Extract user role from SAML attributes
        String roleAttribute = (String) attributes.get('User.Role'); // Adjust 'Role' to the correct attribute name from your SAML response
        system.debug ('ROLE Value is ++++' + roleAttribute );
        // Assign Profile based on Role
        if (roleAttribute != null) {
            if (roleAttribute == 'SupervisorTeamManagerEast') {
                // Query Profile Id for Radnet Manager (replace 'Radnet Manager' with actual profile name)
                Profile p = [SELECT Id FROM Profile WHERE Name = 'RadNet Manager East' LIMIT 1];
                UserRole r = [SELECT Id from UserRole where Name = 'Supervisor/Team Manager East' Limit 1];
                u.ProfileId = p.Id;
                u.UserRoleId=r.Id;
                system.debug ('Profile Value is ++++IF' + u.ProfileId );
                system.debug ('Role  Value is ++++IF' + u.UserRoleId );
            } else if (roleAttribute == 'SchedulerEast') {
                // Query Profile Id for Radnet Scheduler (replace 'Radnet Scheduler' with actual profile name)
                Profile p = [SELECT Id FROM Profile WHERE Name = 'RadNet Scheduler East' LIMIT 1];
                UserRole r = [SELECT Id from UserRole where Name = 'Scheduler East' Limit 1];
                u.ProfileId = p.Id;
                u.UserRoleId=r.Id;
                system.debug ('Profile Value is ++++ ELSEIF' + u.ProfileId );
            } else if (roleAttribute == 'SupervisorTeamManagerWest') {
            
                Profile p = [SELECT Id FROM Profile WHERE Name = 'RadNet Manager West' LIMIT 1];
                UserRole r = [SELECT Id from UserRole where Name = 'Supervisor/Team Manager West' Limit 1];
                u.ProfileId = p.Id;
                u.UserRoleId=r.Id;
                system.debug ('Profile Value is ++++IF' + u.ProfileId );
                system.debug ('Role  Value is ++++IF' + u.UserRoleId );
            }else if (roleAttribute == 'SchedulerWest') {
                Profile p = [SELECT Id FROM Profile WHERE Name = 'RadNet Scheduler West' LIMIT 1];
                UserRole r = [SELECT Id from UserRole where Name = 'Scheduler West' Limit 1];
                u.ProfileId = p.Id;
                u.UserRoleId=r.Id;
                system.debug ('Profile Value is ++++ ELSEIF' + u.ProfileId );
            
            }else {
                // Handle case for unknown role if needed, maybe assign a default profile
                //throw new JitException('Unknown role: ' + roleAttribute);
               Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
               u.ProfileId =   p.Id; //Default Profile
               UserRole r = [SELECT Id from UserRole where Name = 'AVP' Limit 1];
               u.UserRoleId =r.Id;
            }
        }

        // Handle other attributes
        if (attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.Username');
        }
        if (create && attributes.containsKey('User.FederationIdentifier')) {
            u.FederationIdentifier = attributes.get('User.FederationIdentifier');
        } else {
            u.FederationIdentifier = federationIdentifier;
        }
        if (attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if (attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        if (attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        if (attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        if (attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
        }
        if (attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        if (attributes.containsKey('User.AboutMe')) {
            u.AboutMe = attributes.get('User.AboutMe');
        }
        if (attributes.containsKey('User.Street')) {
            u.Street = attributes.get('User.Street');
        }
        if (attributes.containsKey('User.State')) {
            u.State = attributes.get('User.State');
        }
        if (attributes.containsKey('User.City')) {
            u.City = attributes.get('User.City');
        }
        if (attributes.containsKey('User.Zip')) {
            u.PostalCode = attributes.get('User.Zip');
        }
        if (attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }
        if (attributes.containsKey('User.CallCenter')) {
            u.CallCenterId = attributes.get('User.CallCenter');
        }
        if (attributes.containsKey('User.Manager')) {
            u.ManagerId = attributes.get('User.Manager');
        }
        if (attributes.containsKey('User.MobilePhone')) {
            u.MobilePhone = attributes.get('User.MobilePhone');
        }
        if (attributes.containsKey('User.DelegatedApproverId')) {
            u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
        }
        if (attributes.containsKey('User.Department')) {
            u.Department = attributes.get('User.Department');
        }
        if (attributes.containsKey('User.Division')) {
            u.Division = attributes.get('User.Division');
        }
        if (attributes.containsKey('User.EmployeeNumber')) {
            u.EmployeeNumber = attributes.get('User.EmployeeNumber');
        }
        if (attributes.containsKey('User.Extension')) {
            u.Extension = attributes.get('User.Extension');
        }
        if (attributes.containsKey('User.Fax')) {
            u.Fax = attributes.get('User.Fax');
        }
        if (attributes.containsKey('User.DH_User_Region__c')){
            u.DH_User_Region__c = attributes.get('User.DH_User_Region__c');
        }
        else if (create) {
            u.DH_User_Region__c = 'Other';
        }
        if (attributes.containsKey('User.CommunityNickname')) {
            u.CommunityNickname = attributes.get('User.CommunityNickname');
        }
        if (attributes.containsKey('User.ReceivesAdminInfoEmails')) {
            String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
            u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
        }
        if (attributes.containsKey('User.ReceivesInfoEmails')) {
            String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
            u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
        }

        // Default Locale and Time Zone Settings
        String uid = UserInfo.getUserId();
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        
        if (attributes.containsKey('User.LocaleSidKey')) {
            u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else if (create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if (attributes.containsKey('User.LanguageLocaleKey')) {
            u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else if (create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if (attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if (create) {
            String alias = '';
            if (u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if (alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        if (attributes.containsKey('User.TimeZoneSidKey')) {
            u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        } else if (create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if (attributes.containsKey('User.EmailEncodingKey')) {
            u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if (create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }

        if (attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
        if (attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }

        if (!create) {
            update(u);
        }
    }

  /*  private String handleAccount(boolean create, User u, Map<String, String> attributes) {
        // Handle account creation or update based on SAML attributes
        Account a;
        boolean newAccount = false;
        if (create) {
            if (attributes.containsKey('User.Account')) {
                String account = attributes.get('User.Account');
                a = [SELECT Id FROM Account WHERE Id=:account];
            } else {
                a = new Account();
                newAccount = true;
            }
        } else {
            if (attributes.containsKey('User.Account')) {
                String account = attributes.get('User.Account');
                a = [SELECT Id FROM Account WHERE Id=:account];
            }
        }
        if (attributes.containsKey('Account.Name')) {
            a.Name = attributes.get('Account.Name');
        }
        if (newAccount) {
            insert(a);
        } else {
            update(a);
        }
        return a.Id;
    }
*/
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleUser(true, u, attributes, federationIdentifier, true);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id = :userId];
        handleUser(false, u, attributes, federationIdentifier, false);
    }
}