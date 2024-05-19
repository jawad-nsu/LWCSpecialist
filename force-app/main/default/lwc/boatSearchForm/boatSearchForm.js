import { LightningElement, track, wire } from "lwc"
import getBoatTypes from '@salesforce/apex/BoatDataService.getBoatTypes';

// Utility function for debounce
function debounce(func, wait) {
    let timeout;
    return function(...args) {
        const context = this;
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), wait);
    };
}

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
    // passes boatTypeId, minPrice, maxPrice in the detail
    handleSearchOptionChange(event) {
        this.selectedBoatTypeId = event.detail.value;
        this.dispatchSearchEvent();
    }

    handleMinPriceChange(event){
        this.minPrice = event.detail.value;
        this.debouncedDispatchSearchEvent();
    }

    handleMaxPriceChange(event){
        this.maxPrice = event.detail.value;
        this.debouncedDispatchSearchEvent();
    }


    // Dispatch search event
    dispatchSearchEvent() {
        const searchEvent = new CustomEvent('search', { 
            detail: {
                boatTypeId: this.selectedBoatTypeId,
                minPrice: this.minPrice,
                maxPrice: this.maxPrice
            }
        });
        this.dispatchEvent(searchEvent);
    }

    debouncedDispatchSearchEvent = debounce(this.dispatchSearchEvent, 1000);

  }
  