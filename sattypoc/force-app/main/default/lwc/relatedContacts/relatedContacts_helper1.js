import getContacts from '@salesforce/apex/RelatedContactController.getContacts';
import createCaseRecord from '@salesforce/apex/RelatedContactController.createCaseRecord';

const handleRelatedContacts_helper1 = async (parentCmp) => {    
    getContacts({
        recordId: parentCmp.recordId
    })
    .then((data) => {       				
        parentCmp.contacts = data;
        let resp = JSON.parse(JSON.stringify(data));
        resp.forEach(item => {
            item['contactName'] = item.Contact.Name;
            item['contactBudgetSpent'] = item.Contact.Budget_Spent__c;
            item['contactLink'] = parentCmp.a_Record_URL + '/lightning/r/Contact/' + item['ContactId'] + '/view';
            item['physicianNPI'] = item.Contact.Physician_NPI__c;
            item['imagePreference'] = item.Contact.Image_Preference_Notes__c;
            item['physicianPAP'] = item.Contact.PAP__c;
            
        });
        parentCmp.showComp = true;
        parentCmp.contacts = resp;
        //parentCmp.moveAcrsTable = resp;
        //console.info('parentCmp.parentCmp.contacts', JSON.stringify(resp)); 
        //console.info('parentCmp.parentCmp.moveAcrsTable',JSON.stringify(parentCmp.moveAcrsTable)); 
        parentCmp.contactLabel = 'Physicians (' + resp.length + ')';
    }).catch(error => {
        parentCmp.error = error;
    });
}
const handleSave_helper1 = async (parentCmp) => {
    let getPhysicianUpdates = parentCmp.physiciansUpdates;
    
    let getPhysicianUpdatesList = getPhysicianUpdates.map(
        (item) => {
            let descriptions = [];
          
            if (!!item['Phone__c']) {                 
                descriptions = [...descriptions, `Contact Phone : ${item['Phone__c']}`];
               
            }
            if (!!item['FAX__c']) { 
                descriptions = [...descriptions, `Contact FAX : ${item['FAX__c']}`];
              
            }
            if (!!item['PAP__c']) {               
                const valueDesc = `PAP : ${item['PAP__c']}`;                
                descriptions = [...descriptions, valueDesc]; 
            }
            if (!!item['EMR__c']) {               
                const valueDesc = `EMR : ${item['EMR__c']}`;               
                descriptions = [...descriptions, valueDesc];
            }
            if (!!item['Mail_Reports__c']) {                
                descriptions = [...descriptions, `Mail Reports : ${item['Mail_Reports__c']}`];
                console.log('1 mailrep', descriptions);
            }
            if (!!item['Fax_Reports__c']) { 
                descriptions = [...descriptions, `Fax Reports : ${item['Fax_Reports__c']}`];
            }
            if (!!item['Email_Reports__c']) {              
                descriptions = [...descriptions, `Email Reports : ${item['Email_Reports__c']}`];
                console.log('1 emailrep', descriptions);
            }
            /*if (!!item['Image_Preference_Notes__c']) {                
                descriptions = [...descriptions, `Imaging Notes : ${item['Image_Preference_Notes__c']}`];
                console.log('1 image', descriptions);
            }*/
            if (!!item['Preferred_Reader__c']) {                
                descriptions = [...descriptions, `Preferred Reader : ${item['Preferred_Reader__c']}`];
                
            } 
            if (!!item['Contact_Email__c']) {                
                descriptions = [...descriptions, `Contact Email : ${item['Contact_Email__c']}`];
                
            }
         
            return { key: item['Id'], value : descriptions };    
        });

        getPhysicianUpdates.forEach(item => {
            console.log('item ' , item);
            let risrequest = {};
            risrequest['AcrId__c'] = item['Id'];
            risrequest['Contact_Phone_New__c'] = (!!item['Phone__c']) ? item['Phone__c'] : '';
            risrequest['PAP_New__c'] = (!!item['PAP__c']) ? item['PAP__c'] : '';   
            risrequest['Contact_Fax_New__c'] = (!!item['FAX__c']) ? item['FAX__c'] : '';
            risrequest['Email_Reports_New__c'] = (!!item['Email_Reports__c']) ? item['Email_Reports__c'] : '';  
            //risrequest['Image_Preference_Notes_New__c'] = (!!item['Image_Preference_Notes__c']) ?  item['Image_Preference_Notes__c'] : '';
            risrequest['Preferred_Reader_New__c'] = (!!item['Preferred_Reader__c']) ? item['Preferred_Reader__c'] : '';
            risrequest['Contact_Email_New__c'] = (!!item['Contact_Email__c']) ? item['Contact_Email__c'] : '';
            
            parentCmp.relatedRisUpdates.push(risrequest);    
        })

        await createCaseRecord({
            accountId: parentCmp.recordId,
            getPhysicianUpdates : JSON.stringify(getPhysicianUpdatesList),
            risRequestUpdates: parentCmp.relatedRisUpdates
        }).then((data) => {
            console.log('data related ris request', JSON.stringify(data));
            parentCmp.caseNumber = data.Name;
            parentCmp.showToast('Success', `Contacts updated.RIS Request was created ${parentCmp.caseNumber} `, 'success', 'dismissable');
        })
        .catch(error => {
            parentCmp.error = error;
        });
}
export { 
    handleRelatedContacts_helper1,
    handleSave_helper1
}