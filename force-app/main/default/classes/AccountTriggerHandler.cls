public with sharing class AccountTriggerHandler extends TriggerHandler{
	private Account[] newAccounts;
	private Account[] oldAccounts;
	private Map<Id, Account> oldAccountsMap;
	private Map<Id, Account> newAccountsMap;

	protected override void populateTriggerData(
		List<SObject> oldSObjectsList, 
		List<SObject> newSObjectsList,
		Map<Id, SObject> oldSObjectsMap, 
		Map<Id, SObject> newSObjectsMap
	) {
		this.newAccounts = (Account[]) newSObjectsList;
		this.oldAccounts = (Account[]) oldSObjectsList;
		this.newAccountsMap = (Map<Id, Account >) newSObjectsMap;
		this.oldAccountsMap = (Map<Id, Account >) oldSObjectsMap;
	}

	protected override void onAfterInsert() {
        Set<String> accountsZipCodes = new Set<String>();
        for(Account newAccount : newAccounts) {
            accountsZipCodes.add(newAccount.ShippingPostalCode);
        }	
		List<Competition__c> competitiveZipCodes = batchZipCodeMappingHelper.collectCompetitiveWithZipCodes(accountsZipCodes);
		List<Account_Competition_Relationship__c> existAccountCompetitionRelationship = batchZipCodeMappingHelper.collectAccountCompetitionRelationship();		
		List<Account_Competition_Relationship__c> createAccountCompetitionRelationship = batchZipCodeMappingHelper.populateAccountCompetitionRelationship(
			competitiveZipCodes,
			newAccounts,			
			existAccountCompetitionRelationship
		);
		
		if(!createAccountCompetitionRelationship.isEmpty()){
			try{
				insert createAccountCompetitionRelationship;
				system.debug('createAccountCompetitionRelationship : '+createAccountCompetitionRelationship);
			}catch(Exception e){
				System.debug('Error : '+e.getMessage()+' LineNo : '+e.getLineNumber());
			}
		}
	}
}