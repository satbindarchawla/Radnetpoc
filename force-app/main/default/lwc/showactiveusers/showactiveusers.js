import { LightningElement, wire } from 'lwc';
import getUsersByStatus from '@salesforce/apex/UserActivationController.getUsersByStatus';

export default class UserActivationStatusJIT extends LightningElement {
    // Default selected status to true (Active Users)
    isActive = true;
    users = [];
    error;

    // Options for user status selection
    userStatusOptions = [
        { label: 'Active Users', value: true },
        { label: 'Deactivated Users', value: false }
    ];

    // Fetch users based on selected status (Active or Deactivated)
    @wire(getUsersByStatus, { isActive: '$isActive' })
    wiredUsers({ error, data }) {
        if (data) {
            this.users = data;  // Assign the fetched data to 'users'
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.users = [];
        }
    }

    // Handle the change of the user status selection
    handleUserStatusChange(event) {
        this.isActive = event.target.value == 'true';  // Set the selected status (Active or Deactivated)
        console.log('isActive value updated:', this.isActive); // Log the value of isActive
    }

   
}