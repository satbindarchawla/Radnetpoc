@isTest
public with sharing class AccountHandlerTest {
    @TestSetup
    static void makeData(){
        List<Competition__c> competitions = new List<Competition__c>();
        for(Integer count = 0; count < 3; count++){
            competitions.add(new Competition__c (
                Name = 'Test ' + count,
                Address__PostalCode__s = '100089'
            ));
        }
        insert competitions;
    }

    @isTest
    static void testCreatedAccountRelations(){
        List<Account> createAccount = TestDataFactory.returnAccounts(1, 'Practice_Location');
        for(Account account: createAccount) {
            account.ShippingPostalCode = '100089';
        }
        List<Database.SaveResult> listTestSaveResultsAccs =  Database.insert(createAccount);
        update createAccount;
        List<Account_Competition_Relationship__c> acrsCreated =[SELECT Id, Related_Account__c, Related_Competition__c FROM Account_Competition_Relationship__c];
        //assert.areEqual(3, acrsCreated.size(), 'Expexted 3 account competitive relations');
    }

    @isTest
    static void testNullCreatedAccountRelations(){
        List<Account> createAccount = TestDataFactory.returnAccounts(1, 'Practice_Location');        
        for(Account account: createAccount) {
            account.ShippingPostalCode = '10091';
        }
        List<Database.SaveResult> listTestSaveResultsAccs =  Database.insert(createAccount); 
        
        update createAccount;
        List<Account_Competition_Relationship__c> acrsCreated =[SELECT Id, Related_Account__c, Related_Competition__c FROM Account_Competition_Relationship__c];
        assert.areEqual(0, acrsCreated.size(), 'Expexted 0 account competitive relations');
    }
}