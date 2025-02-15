import { LightningElement,wire } from 'lwc';
import getUserType from '@salesforce/apex/DH_KMUtility.getUserType';
import URL_Store from '@salesforce/label/c.URL_Store';  
export default class DH_PreviousPage extends LightningElement {
    showSSRBreadCrumb = false;
    isGuestUser=false;
        // getting the user type of the user whether it is a guest user or not
        @wire(getUserType)
        userType(result) {
            if (result.data) {
                this.isGuestUser = result.data;
            }
            else if (result.error) {
                console.log('error found -> ' + JSON.stringify(result.error));
            }
        }

    handlePreviousPage(){
        if(this.isGuestUser){
            this.dispatchEvent(new CustomEvent('hideaccountdetailpage', {
                detail: {
                  showaccountdetailpage: false
                }
              }));
        }else{
   window.location.href = URL_Store;
        }
    }
}