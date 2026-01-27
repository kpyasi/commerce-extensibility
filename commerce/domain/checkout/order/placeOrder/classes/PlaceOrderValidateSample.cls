/*
* Use Case:
* ===============================
* This sample covers the use case of validating the products in the order before it is placed by making a callout to the external ERP system.
* If the ERP validation is successful, the order will proceed as normal.
* If not, the order creation gets failed.
*
* This code sample throws a CalloutException if the validation fails, this should be modified according to the customer use case.
*/
public virtual class PlaceOrderValidateSample extends CartExtension.CheckoutPlaceOrder {

    public virtual override CartExtension.PlaceOrderResponse validate(CartExtension.PlaceOrderRequest placeOrderRequest, List<String> domainList) {
        
        CartExtension.Cart cart = placeOrderRequest.getCart();
        CartExtension.CartItemList cartItems = cart.getCartItems();
        
        // Get the list of product IDs from cart items
        List<ID> productIds = new List<ID>();
        for (Integer i = (cartItems.size() - 1); i >= 0; i--) {
                CartExtension.CartItem cartItem = cartItems.get(i);
                ID productId = cartItem.getProduct2Id();
                productIds.add(productId);
        }
        
        System.debug('Product IDs list: ' + productIds);
        
        // You MUST change this to be your service or you must launch your own Third Party Service
        // and add the host in Setup | Security | Remote site settings.
        String url = 'https://example.com';
        
        // Add product IDs as query parameters to the URL
        // Adding products to the URL as query parameters this should be modified depending on the API contract.
        if (productIds != null && !productIds.isEmpty()) {
            String productIdsParam = String.join(productIds, ',');
            url += '?productIds=' + EncodingUtil.urlEncode(productIdsParam, 'UTF-8');
        }
        
        // Create an HTTP object and request
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Set the HTTP request properties
        request.setEndpoint(url); 
        request.setMethod('GET');
        
        try {
            // Send the HTTP request and get the response
            HttpResponse response = http.send(request);
            
            // Handle the response (log or process it)
            if (response.getStatusCode() == 200) {
                System.debug('Callout successful! Response: ' + response.getBody());
                
                // Parse the JSON response body
                String responseBody = response.getBody();
                
                // Process the response
                processResponse(responseBody);
            } else {
                throw new CalloutException(
                    'There was a problem with the request. Error: ' + response.getStatusCode()
                );
            }
        } catch (Exception e) {
            // Handle any other exceptions that occur during the HTTP callout
            System.debug('Exception during callout: ' + e.getMessage());
            throw new CalloutException('Exception during validation callout: ' + e.getMessage());
        }

        // Call the default validate method to validate the order
        return super.validate(placeOrderRequest, domainList);
    }
    
    /**
     * Processes the HTTP response body to determine if order placement should proceed.
     * Throws CalloutException if validation fails, allowing the order placement to be blocked.
     * @param responseBody The JSON response body from the HTTP callout
     * @throws CalloutException if response is invalid or status does not indicate success
     */
    private void processResponse(String responseBody) {
        if (responseBody != null && responseBody.trim().length() > 0) {
            try {
                // Parse JSON response
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                
                // Check for status field that indicates whether to proceed
                String status = (String) responseMap.get('status');
                
                // Check if status indicates we should proceed
                if (status != null && status.equalsIgnoreCase('success')) {
                    // Everything is alright, proceed further
                    System.debug('Validation successful. Proceeding with order placement.');
                } else {
                    // Response status indicates failure, throw exception
                    throw new CalloutException(
                        'Validation failed. Response status does not indicate success. Status: ' + status
                    );
                }
            } catch (Exception e) {
                // If JSON parsing fails, throw exception
                throw new CalloutException(
                    'Failed to parse response JSON: ' + e.getMessage() + '. Response body: ' + responseBody
                );
            }
        } else {
            // Empty response body, throw exception
            throw new CalloutException('Validation failed. Empty response body received.');
        }
    }
}
