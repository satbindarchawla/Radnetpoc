@RestResource(urlMapping='/deactivateUser/*')
global with sharing class DH_UserInfoRestResource {

@HttpPatch
global static String deactivateUser() {
    RestResponse res = RestContext.response;
    RestRequest req = RestContext.request;
    String userId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    
    try{
        User userToDeactivate = [Select Id, IsActive FROM User WHERE Id =:userId LIMIT 1];
        
        If (userToDeactivate  != null && userToDeactivate.IsActive) {
              
              userToDeactivate.IsActive = false;
              update userToDeactivate;
              return 'User Successfully deactivated. ' ; 
         }else {
             return 'User is already inactive or does not exist.';
             }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
            }
         }
     }