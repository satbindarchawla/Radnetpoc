import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import tabsStyle from '@salesforce/resourceUrl/tabsStyle';
import hasSuperUser from "@salesforce/customPermission/Super_User";
import modalitySearchSuperUser from "@salesforce/customPermission/Modality_Search_Super_User_Permission";
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';

export default class DH_modalitySearchContainer extends LightningElement {
    prfName;
    userId = USER_ID;

    //get profile name of current user
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME_FIELD]
    }) wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.prfName = data.fields.Profile.value.fields.Name.value;
        }
    }
    //set tab visibility
    get isTabVisible() {
        if (this.prfName === 'System Administrator' || hasSuperUser || modalitySearchSuperUser) {
            return true;
        } else {
            return false;
        }
    }

    //load customm css 
    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this, tabsStyle).then(() => {
            console.log('loaded');
        })
        .catch(error => {
            console.log('error to load' + error);
        });
    }
}