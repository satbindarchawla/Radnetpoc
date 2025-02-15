/*
* **************************************************************************************************************************************************************************************
* LWC Component Name - DH_OmniChannel.js
* Created Date - 06-Aug-2024
* Function - JS class of contact center verify caller screen to close tab when call is disconnected.
* Modification Log :
* --------------------------------------------------------------------------------
* Jira#                         Date                 Description
* ----------------         --------------       ---------------------
* CC-691                     09-Aug-2024          Added closeTabs,handlegetAllTabInfo,messageCallback,disconnectedCallback,handleUnSubscribe,handleSubscribe,connectedCallback methods
* **************************************************************************************************************************************************************************************
*/
import { LightningElement,track,api ,wire } from 'lwc';
import {subscribe, unsubscribe} from 'lightning/empApi';
import { EnclosingTabId, getTabInfo , closeTab, getAllTabInfo} from 'lightning/platformWorkspaceApi';
export default class DH_OmniChannel extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track idToClose;
    @wire(EnclosingTabId) tabId;
    isSubTab;
    channelName = '/event/DH_EventLog__e';
    subscription={};
    @track allTabList=[];
    connectedCallback() {
        this.handlegetAllTabInfo()
        this.handleSubscribe();
    }
    handleSubscribe(){
        subscribe(this.channelName, -1,this.messageCallback).then(response=>{
            this.subscription=response;
        }).catch(error=>{
            console.log('error '+error);
        })
    }
    handleUnSubscribe(){
        unsubscribe(this.subscription, response=>{
            console.log('unsubscribe from  : ' + JSON.stringify(response));
        })
    }
    disconnectedCallback() {
        this.handleUnSubscribe();
    }
    messageCallback=(response)=>{
        let actName = response.data.payload.DH_SObjectId__c;
        let serviceName = response.data.payload.DH_ServiceName__c;
        this.idToClose = actName;
       if(this.serviceName='CallEndEvent'){
            this.closeTabs();
       }
    }
    handlegetAllTabInfo(){
        getAllTabInfo().then((allTabInfo)=>{
            this.allTabList = allTabInfo;
        }).catch(function(error){
            console.log(error);
        });
    }
     closeTabs(){
        if(this.allTabList){
            this.allTabList.forEach(tab=>{
                if(tab.title===this.idToClose){
                    closeTab(tab.tabId);
                }
            });
        }
    }   
}