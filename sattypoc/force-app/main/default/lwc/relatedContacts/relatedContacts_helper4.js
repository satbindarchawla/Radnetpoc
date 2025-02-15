import getContactsForEditNotes from '@salesforce/apex/RelatedContactController.getContactsForEditNotes';
import createRisRequestImageNotes from '@salesforce/apex/RelatedContactController.createRisRequestImageNotes';

const handleEditNotes_helper4 = async (parentCmp) => { 
    if (parentCmp.selectedContactIds.length) {
        parentCmp.isShowEditNotes = true;
        getContactsForEditNotes({
            contactIds: parentCmp.selectedContactIds
        })
        .then((result) => {   
            parentCmp.showComp = true;
            parentCmp.selectedEditNotesList = result;
        });
    } else {
        parentCmp.showToast('Physicians not selected', 'Please select physicians', 'warning', 'dismissable');
        parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
    }
}

const handleSaveEditNotes_helper4 = async (parentCmp) => { 
    let listSelectedObjs = []
    let listInputNotesFields = [... parentCmp.template.querySelectorAll(`lightning-textarea[data-id="editnotes"]`)]
    if(listInputNotesFields && listInputNotesFields.length>0){
        for(let inputNote of listInputNotesFields) {
            let listFilteredRecs = parentCmp.selectedEditNotesList.filter(contactRecord=>contactRecord.Id == inputNote.dataset.contactId);
            let previousNotevalue = (listFilteredRecs.Image_Preference_Notes__c) ? listFilteredRecs.Image_Preference_Notes__c : '';
            let risRequesrObj = {};
            risRequesrObj['ContactId__c'] = inputNote.dataset.contactId;
            risRequesrObj['Status__c'] = 'New';
            risRequesrObj['Type__c'] = 'Image preference notes';
            risRequesrObj['Subject__c'] = 'Image preference notes';
            risRequesrObj['Description__c'] = `Previous IP Notes: <b>${previousNotevalue}</b><br/> New IP Notes Requested: <b>${inputNote.value} </b>`;
            risRequesrObj['New_Image_Preference_Notes__c'] = inputNote.value;
            
            listSelectedObjs = [...listSelectedObjs, risRequesrObj];
            
        }
    }
    createRisRequestImageNotes({
        createRisRequestList : listSelectedObjs
    })       
    .then((result) => {
        parentCmp.isShowEditNotes = false;
    })
    .catch(error => {
        parentCmp.isShowEditNotes = false;
        parentCmp.showToast('Error updating ', error.body.message, 'Error', 'dismissable');
        parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];
    }).finally(() => { 
        parentCmp.template.querySelector('lightning-datatable').setSelectedRows = [];              
    });
}


export {handleEditNotes_helper4, handleSaveEditNotes_helper4}