import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

const RIS_REQUEEST_WAS_CREATED = 'RIS request was successfully created';

export default class LwcToastParams extends LightningElement {
    @api recordId;

    title='';
    message='';
    variant='';
    mode='';

    CHANNEL_NAME = '/event/Common_Message_Event__e';
    subscription = {};
    
    connectedCallback(){
        subscribe(this.CHANNEL_NAME, -1, this.manageEvent).then(response => {
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed Channel');
        });
    }

    manageEvent = event => {
        const { payload } = event.data;

        switch (payload.Message_Type__c) {
            case 'SPECIALITY_CHANGE':
            case 'PRACTICE_OVERVIEW_CHANGE':
                if (this.recordId === payload.Record_Id__c) {
                    this.dispatchEvent(
                        new ShowToastEvent(
                            {
                                title:'Success',
                                message: RIS_REQUEEST_WAS_CREATED,
                                variant:'success',
                                mode: 'dismissable'
                            }
                        )
                    );
                }
                break;
            default:
                break;
        }
    }

    @api handleSavedResults(listsavedresults){
        console.log('SAVED RESULTS IN TOAST PARAM' + JSON.stringify(listsavedresults));
        if(listsavedresults!=null && Array.isArray(listsavedresults) && listsavedresults.length>0){
            console.log('IN HERE');
            listsavedresults.forEach(saveResRec=>{
                console.log('saveResRec-------'+JSON.stringify(saveResRec));
                if('isSuccess' in saveResRec && saveResRec.isSuccess){
                    if('isCreated'  in saveResRec &&  saveResRec.isCreated){
                        this.handleInsertSuccessLogic();
                    }
                    if('isUpdated'  in saveResRec &&  saveResRec.isUpdated){
                        this.handleUpdateSuccessLogic();
                    }
                    if('isDeleted' in saveResRec && saveResRec.isDeleted){
                        this.handleDeleteSuccessLogic();
                    }
                }
                else{
                    this.handleErrorLogic(saveResRec);
                }
            });
        }
    }

    @api handleInsertSuccessLogic(){
        const evt = new ShowToastEvent({
            title:'SUCCESS!!',
            message:'Record created.',
            variant:'success',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleUpdateSuccessLogic(){
        const evt = new ShowToastEvent({
            title:'SUCCESS!!',
            message:'Record updated.',
            variant:'success',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleDeleteSuccessLogic(){
        const evt = new ShowToastEvent({
            title:'SUCCESS!!',
            message:'Record deleted.',
            variant:'success',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleErrorLogic(saveResRec){
        if(saveResRec!=null && 'listErrors' in saveResRec){
            let listErrors = saveResRec['listErrors'];
            if(listErrors!=null && Array.isArray(listErrors) && listErrors.length>0){
                for(var err of listErrors){
                    const evt = new ShowToastEvent({
                        title:'ERROR!!',
                        message:err,
                        variant:'error',
                        mode:'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
            }
        }
        
    }

    @api handleErrorToast(errMsg){
        if(errMsg!=null && errMsg!=''){
            const evt = new ShowToastEvent({
                title:'ERROR!!',
                message:errMsg,
                variant:'error',
                mode:'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    @api handleInfoToast(infoMsg){
        if(infoMsg!=null && infoMsg!=''){
            const evt = new ShowToastEvent({
                title:'Info. ',
                message:infoMsg,
                variant:'info',
                mode:'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    displayToastParams(toastParam){

    }
}