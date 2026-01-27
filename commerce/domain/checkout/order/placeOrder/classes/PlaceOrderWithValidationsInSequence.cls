/*
* Use Case:
* ===============================
* This sample covers the use case of performing validations for each domain in a specific sequence before placing an order.
* The domainList can contain domain types such as: TAXES, PRICING, PROMOTIONS, SHIPPING
* Validations are performed in the following sequence: PRICING, PROMOTIONS, SHIPPING, TAXES
* Only domains that are present in the domainList will be validated.
* Each domain is validated one after another by calling super.validate() for each domain.
* If any domain validation fails, the order placement is blocked and subsequent domains are not validated.
* If all domain validations are successful, the order will proceed as normal.
*
* This code sample will throw an exception if any domain validation fails, this should be modified according to the customer use case.
*/
public virtual class PlaceOrderWithValidationsInSequence extends CartExtension.CheckoutPlaceOrder {

    public virtual override CartExtension.PlaceOrderResponse validate(CartExtension.PlaceOrderRequest placeOrderRequest, List<String> domainList) {
        
        // Validate domains in the specified sequence: PRICING, PROMOTIONS, SHIPPING, TAXES
        // Only validate domains that are present in the domainList
        CartExtension.PlaceOrderResponse response = null;
        
        // Define the validation sequence
        List<String> validationSequence = new List<String>{ 'PRICING', 'PROMOTIONS', 'SHIPPING', 'TAXES' };
        
        if (domainList != null && !domainList.isEmpty()) {
            // Convert domainList to Set for efficient lookup
            Set<String> domainSet = new Set<String>(domainList);
            
            // Validate each domain in the specified sequence
            for (String domain : validationSequence) {
                // Only validate if this domain is present in the domainList
                if (domainSet.contains(domain)) {
                    System.debug('Validating domain: ' + domain);
                    
                    // Create a single-item domain list for this domain
                    List<String> singleDomainList = new List<String>{ domain };
                    
                    // Call super.validate() for this domain
                    // If validation fails, it will throw an exception and stop the sequence
                    response = super.validate(placeOrderRequest, singleDomainList);
                    
                    System.debug('Domain ' + domain + ' validation completed successfully');
                } else {
                    System.debug('Domain ' + domain + ' not in domainList, skipping validation');
                }
            }
        } else {
            // If no domain list provided, call super.validate() with empty list
            response = super.validate(placeOrderRequest, domainList);
        }
        
        return response;
    }
}
