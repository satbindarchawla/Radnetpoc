//import createMovePhysicianRequest from '@salesforce/apex/RelatedContactController.createMovePhysicianRequest';
import movePhysiciansToLocation from '@salesforce/apex/RelatedContactController.movePhysiciansToLocation';
import getRelatedRisRequests from '@salesforce/apex/RelatedContactController.getRelatedRisRequests';

const handleAcrsToMove_helper3 = async (parentCmp) =>{
    if (parentCmp.moveACRList.length) {
        let filterAcrs = parentCmp.contacts.filter(function(item) {
            return parentCmp.moveACRList.indexOf(item.Id) !== -1;
        });        
        parentCmp.moveAcrsTable = JSON.parse(JSON.stringify(filterAcrs));
    } else {
        parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
    }
}

const handleToMove_helper3 = async (parentCmp) =>{
    
    if (parentCmp.moveACRList.length) { 
        let sendData = [];
        if (!parentCmp.moveToAccount) {
            parentCmp.showToast('Please select Future practice location', 'Please select Future practice location', 'warning', 'dismissable');
        } 
        
        let getPrhysicianUpdates = parentCmp.moveAcrsTable;              
        if (getPrhysicianUpdates) {
            getPrhysicianUpdates.forEach(item => {
            let risrequest = {};
            console.log('handleToMove_helper3 JSN' , JSON.stringify(item));
            risrequest['AcrId__c'] = item['Id'];
            risrequest['Physician__c'] = item['ContactId'];
            risrequest['Contact_Phone__c'] = (item['Phone__c']);
            risrequest['PAP__c'] =item['PAP__c'];   
            risrequest['Contact_Fax__c'] =  item['FAX__c'];
            risrequest['Email_Reports_New__c'] = (!!item['Email_Reports__c']) ? item['Email_Reports__c'] : '';
            risrequest['Image_Preference_Notes__c'] =(!!item['Image_Preference_Notes__c']) ?  item['Image_Preference_Notes__c'] : '';
            risrequest['Preferred_Reader__c'] = (!!item['Preferred_Reader__c']) ? item['Preferred_Reader__c'] : '';           
            if (parentCmp.physiciansMoveUpdates !== undefined && parentCmp.physiciansMoveUpdates.some(element => element.Id === item['Id'])) {
                risrequest['Contact_Phone_New__c'] = (!!parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Phone__c) ? parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Phone__c : '';
                risrequest['PAP_New__c'] = (!!parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).PAP__c) ? parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).PAP__c : '';   
                risrequest['Contact_Fax_New__c'] = (!!parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).FAX__c) ? parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).FAX__c : '';
                risrequest['Email_Reports_New__c'] = (!!parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Email_Reports__c) ? parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Email_Reports__c : '';  
                //risrequest['Image_Preference_Notes_New__c'] = (!!parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Image_Preference_Notes__c) ? parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Image_Preference_Notes__c : '';
                risrequest['Preferred_Reader_New__c'] = (!!parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Preferred_Reader__c) ? parentCmp.physiciansMoveUpdates.find(x => x.Id === item['Id']).Preferred_Reader__c : '';     
            }  
            sendData.push(risrequest);    
        });
    } 
    if (!parentCmp.isRisDataManager) {
       getRelatedRisRequests({
        accountId: parentCmp.recordId,
        moveToAccount:parentCmp.moveToAccount,
        selectedACRs : parentCmp.moveACRList,
        risRequestUpdates: sendData
    }).then(data => {
        console.info('data', data);
        if (data && data != []) {
            let parseData = JSON.parse(JSON.stringify(data));
            console.log('parseData ', JSON.stringify(parseData));
            let messageExistsData = [];
            let messageNewData = [];
            let arrayExists = [];
            let arrayNew = [];
           
            for (let key in parseData) {
                console.log('key ', key);
                if (key === 'exist') {
                    arrayExists = parseData[key];
                }
                if (key === 'new') {
                    arrayNew = parseData[key];
                }
                console.log('value ', parseData[key]);
            }
            console.log('arrayExists ', arrayExists);
            console.log('arrayNew ', arrayNew);
            if (arrayExists != []) {
                //parentCmp.existShow = true;
                let getExistRecords =  JSON.parse(JSON.stringify(arrayExists));                
                for (let key in getExistRecords) {                           
                    let mess = {};
                    let physArr = [];
                    mess.url = parentCmp.a_Record_URL + '/lightning/r/RIS_Requests__c/' + getExistRecords[key][0].RIS_Request__c + '/view',
                    mess.label = getExistRecords[key][0].RIS_Request__r.Name;
                    console.log('mess  ', mess);
                    for (let item in getExistRecords[key]) {                               
                        physArr = [...physArr, getExistRecords[key][item].Physician__r.Name];
                    }                           
                    mess.Physicians = physArr.join(', '); 
                    console.log('mess 1451 ', mess);
                    messageExistsData.push(mess);
                    let messageString = 'A similar RIS request has been submitted.  Please review. '+ mess.label + ' for Physicians : ' +  mess.Physicians + ' !';
                    //parentCmp.showToastLink('Info', messageString, mess.Physicians, mess.url, mess.label);
                    parentCmp.showToast('Warning',messageString, 'Warning', 'dismissable');
                    
                }
            }
            console.log('messageExistsData ', messageExistsData);

            if (arrayNew != []) {
                //newShow = true;
                let getNewRecords =  JSON.parse(JSON.stringify(arrayNew));                       
                for (let key in getNewRecords) {                            
                    let mess = {};
                    let physArr =[];
                    mess.url = parentCmp.a_Record_URL + '/lightning/r/RIS_Requests__c/' + getNewRecords[key][0].RIS_Request__c + '/view',
                    mess.label = getNewRecords[key][0].RIS_Request__r.Name;
                    console.log('mess  ', mess);
                    for (let item in getNewRecords[key]) {                                
                        physArr = [...physArr, getNewRecords[key][item].Physician__r.Name];
                    }
                    mess.Physicians = physArr.join(', ');
                    messageNewData.push(mess);
                    parentCmp.showToast('Success',  mess.label + ' Moving Physicians Ris Request was created for Physicians' + mess.Physicians, 'success', 'dismissable');
                
                }
            }
        }  
    })
    .catch(error => {
        parentCmp.error = error;
        console.info('error', error);  
        parentCmp.showToast('Error', error.body.message, 'error', 'dismissable');
    }).finally(() => {
        parentCmp.moveACRList = [];            
        parentCmp.moveToAccount = "";
        parentCmp.selectedRecordName = "";		
        parentCmp.isValueSelected = false;
        parentCmp.searchString ='';
        parentCmp.physiciansMoveUpdates = [];
        parentCmp.showMoveConfirm = false;
        parentCmp.isShowMoveModal = false;
        parentCmp.template.querySelector('lightning-datatable').selectedRows = []; 
    })
        /*createMovePhysicianRequest({
            accountId: parentCmp.recordId,
            moveToAccount:parentCmp.moveToAccount,
            selectedACRs : parentCmp.moveACRList,
            risRequestUpdates: sendData
        }).then((data) => {            
            parentCmp.caseNumber = data.Name;
            parentCmp.showToast('Success', 'Moving Physicians Ris Request was created ' + data.Name, 'Success', 'dismissable');
            parentCmp.isShowMoveModal = false;
        })
        .catch(error => {
            parentCmp.error = error;           
            parentCmp.showToast('Error', error.body.message, 'error', 'dismissable');
        }).finally(() => {            
            parentCmp.moveACRList = [];            
            parentCmp.moveToAccount = "";
            parentCmp.selectedRecordName = "";		
            parentCmp.isValueSelected = false;
            parentCmp.searchString ='';
            parentCmp.physiciansMoveUpdates = [];
            parentCmp.showMoveConfirm = false;
            parentCmp.isShowMoveModal = false;
            parentCmp.template.querySelector('lightning-datatable').selectedRows = []; 
        });*/
    } else {
        movePhysiciansToLocation({
            accountId: parentCmp.recordId,
            moveToAccount:parentCmp.moveToAccount,
            selectedACRs : parentCmp.moveACRList,
            risRequestUpdates: sendData
        }).then((data) => {
            parentCmp.showToast('Success', 'Physicians moved to ' + parentCmp.selectedRecordName, 'Success', 'dismissable');           
        })
        .catch(error => {
            parentCmp.error = error;
            parentCmp.showToast('Error', error.body.message, 'error', 'dismissable');
        }).finally(() => {
            console.log('finally ');
            parentCmp.moveACRList = [];            
            parentCmp.moveToAccount = "";
            parentCmp.selectedRecordName = "";		
            parentCmp.isValueSelected = false;
            parentCmp.searchString ='';
            parentCmp.physiciansMoveUpdates = [];
            parentCmp.showMoveConfirm = false;
            parentCmp.isShowMoveModal = false;
            parentCmp.template.querySelector('lightning-datatable').selectedRows = []; 
            
        });
    }
       
    } else {
        parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');       
        parentCmp.isShowMoveModal = false;
    }
}

export {handleAcrsToMove_helper3, handleToMove_helper3}