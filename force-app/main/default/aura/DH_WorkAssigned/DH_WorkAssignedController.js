/*
* ********************************************************************************
* Aura Component Name - DH_WorkAssigned.js
* Created Date : 11-September-2024
* Function - JS class of contact center verify caller screen.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       ---------------------
* CC-1092                  11-September-2024    Added onWorkAssigned method.
* ********************************************************************************
*/
({
    onWorkAssigned : function( component) {
        let utilityAPI = component.find( "utilitybar" );
        utilityAPI.getAllUtilityInfo().then(function( response ) {
            let myUtilityInfo = response[0];
            utilityAPI.openUtility( {
                utilityId: myUtilityInfo.id
            } );
       	})
        .catch(function(error) {
            console.log( 'Error occurred', JSON.stringify( error ) );
        });
    } 
})