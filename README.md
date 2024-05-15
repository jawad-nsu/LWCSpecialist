### Some of the Challenges faced while completing the SuperBadge and their solution

- Challenge 4:  Get BoatDataService class ready for action
    -   Error:
        -   Invalid type: BoatType (3:34)
        -   Invalid type: Schema.BoatType (4:16)
    -   Solution: Append BoatType with BoatType__c. [https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4SxDSAV](https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4SxDSAV)
	        -   __c is used **to denote the custom fields and custom objects** in salesforce org, whereas __r is used to refer the parent object fields in their child object.
- Challenge 12: boatAddReviewForm component
	- Error:
		- Challenge Not yet complete... here's what's wrong: We can't find the handleSuccess function implemented correctly. Make sure the success toast is being dispatched with the correct attributes, the custom event 'createreview' is dispatched correctly, and the handleReset() function is being called in the boatAddReviewForm component, with the proper case-sensitivity and quotation
    
	-   Solution: create separate const variable and assign it toast notification message