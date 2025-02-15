/*
* ***************************************************************************************************************************
* LWC Component Name - dH_PatientSearch.js
* Created Date - 20-May-2024
* Function - JS class of Search Additional Patients in RIS screen.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       --------------------------------------------
* CC-430                     20-May-2024         Added onInputChange and handleSearch methods.
* CC-543                     11-July-2024        Updated the Birth Date as per standards.
* CC-622                     25-July-2024        Updated onChange and handelSearch method.
* CC-507                     26-July-2024        Updated handleSearch method and changes related to apiErrorMessage and apiError
* CC-1291                    04-Sept-2024        Added flag variable
* *****************************************************************************************************************************
*/
import {track ,api} from 'lwc';
import LightningModal from 'lightning/modal';
import reduceModalWidth from '@salesforce/resourceUrl/reduceModalWidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import invokeRisPatientSearchApi from '@salesforce/apex/DH_DexOutServiceRisPatientSearch.invokeRisPatientSearchApi';
import getDynamicTableColumnsRecords from '@salesforce/apex/DH_VerifyCallerController.getDynamicTableColumnsRecordsForSearch';
import SearchPatientInRis from '@salesforce/label/c.DH_PatientSearchButtonName';
import emptyFieldError from '@salesforce/label/c.DH_PatientSearchErrorEmptyFields';
import createLogRecord from '@salesforce/apex/DH_DexLoggingUtility.createLogRecord';

export default class SearchPatientManuallyInRisModal extends LightningModal {
    @track apiError = false;
    apiErrorMessage;
    @api recordId;
    firstName;
    lastName;
    email;
    phone;
    birthDate;
    showError=false;
    mrnNumber;
    accessionNumber;
    @api description;
    @api systemId;
    contactData;
    @track columnList = [];
    emptyFieldsError=emptyFieldError;
    searchPatientInRisModelName = SearchPatientInRis;
    @track loggerParam = null;

    renderedCallback() {
        Promise.all([
            loadStyle( this, reduceModalWidth )
            ]).then(() => {
                console.log( 'Files loaded' );
            })
            .catch(error => {
                console.log( error.body.message );
        });
    }
    connectedCallback(){
        getDynamicTableColumnsRecords().then((result)=>{
            this.columnList = result;
            this.columnList.sort((a,b)=>a.DH_AttributeSequenceNumber__c - b.DH_AttributeSequenceNumber__c);
        }).catch((error) => {
            console.log('error in the getDynamicTableColumnsRecords: '+error);
        })
    }
    onInputChange(ev){
        if(ev.target.name==="firstName"){
            this.firstName=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="lastName"){
            this.lastName=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="phone"){
            this.phone=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="email"){
            this.email=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="birthdate"){
            this.birthDate=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="mrnNumber"){
            this.mrnNumber=ev.target.value;
            this.showError=false;
        }
        if(ev.target.name==="accessionNumber"){
            this.accessionNumber=ev.target.value;
            this.showError=false;
        }
    }
    handleSearch() {
        if(this.firstName || this.lastName || this.email || this.phone || this.birthDate || this.mrnNumber || this.accessionNumber){
            const patientSearchParameters = 
            {
                recordId: this.description,
                firstName: this.firstName,
                lastName: this.lastName,
                phoneNumber: this.phone,
                email: this.email,
                dateOfBirth: this.birthDate,
                patientMRN: this.mrnNumber,
                accessionNumber: this.accessionNumber,
                systemId: this.systemId,
                isAdvanceSearch: true
            };
            invokeRisPatientSearchApi({urlParametersWrapper : patientSearchParameters})
            .then((result) => {
                const len =Object.keys(result).length;
                if(len == 1 && Object.keys(result)[0] == -1){
                    this.apiError = true;
                    this.apiErrorMessage = result[-1][0].errorMessage;
                }
                else if(result && len >= 0 && Object.keys(result)[0] != -1){
                    this.contactData = result;
                    this.close({dataEntered: true, data: this.contactData, flag: true});
                }                
            })
            .catch((error) => {
                console.log(error);
                this.close({dataEntered: true, data: 'error in the invokeRisPatientSearchApi: '+this.contactData, flag: false});
                this.loggerParam = 
                {
                    ErrorMessage:error.message,
                    ClassName:'dh_PatientSearch-invokeRisPatientSearchApi',
                    RelatedTo:this.recordId,
                };
                createLogRecord({log : this.loggerParam});
            })
        }
        else{
            this.showError=true;
        }
    }
}