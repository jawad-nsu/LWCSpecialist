import { LightningElement, track, wire } from "lwc"
import getBoatTypes from '@salesforce/apex/BoatDataService.getBoatTypes';

export default class BoatSearchForm extends LightningElement {
    selectedBoatTypeId = '';
    minPrice = 0; 
    maxPrice = 1000000; 
    
    // Private
    error = undefined;
    
    // Observing changes to the properties of object
    @track
    searchOptions;


    
    
    // Wire a custom Apex method
    @wire(getBoatTypes)
    boatTypes({ error, data }) {
        if (data) {
            this.searchOptions = data.map(type => {
                return { label: type.Name, value: type.Id };
            });
            this.searchOptions.unshift({ label: 'All Types', value: '' });
        } else if (error) {
            this.searchOptions = undefined;
            this.error = error;
        }
    }
    
    // Fires event that the search option has changed.
    // passes boatTypeId (value of this.selectedBoatTypeId) in the detail
    handleSearchOptionChange(event) {
      this.selectedBoatTypeId = event.detail.value
      
      const searchEvent = new CustomEvent('search', { 
        detail: {
            boatTypeId: this.selectedBoatTypeId,
            minPrice: this.minPrice,
            maxPrice: this.maxPrice
        }});
        this.dispatchEvent(searchEvent);
    }

    handleMinPriceChange(event){
        this.minPrice = event.detail.value

        const searchEvent = new CustomEvent('search', { 
            detail: {
                boatTypeId: this.selectedBoatTypeId,
                minPrice: this.minPrice,
                maxPrice: this.maxPrice
        }});
        this.dispatchEvent(searchEvent);
    }

    handleMaxPriceChange(event){
        this.maxPrice = event.detail.value

        const searchEvent = new CustomEvent('search', { 
            detail: {
                boatTypeId: this.selectedBoatTypeId,
                minPrice: this.minPrice,
                maxPrice: this.maxPrice
          }});
          this.dispatchEvent(searchEvent);
    }

    handleSearch(event) {
        event.preventDefault(); // Prevents default form submission
        const searchEvent = new CustomEvent('search', {
            detail: {
                boatTypeId: this.selectedBoatTypeId,
                minPrice: this.minPrice,
                maxPrice: this.maxPrice
            }
        });
        this.dispatchEvent(searchEvent);
    }
  }
  