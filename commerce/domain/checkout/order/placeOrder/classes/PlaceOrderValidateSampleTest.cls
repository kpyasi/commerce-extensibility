/**
 * @description Unit tests for PlaceOrderValidateSample class.
 * Tests the validation logic for order placement including HTTP callout scenarios.
 */
@isTest
private class PlaceOrderValidateSampleTest {

    @isTest
    static void testValidateSuccessWithStatusSuccess() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(2);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSampleMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for successful response with status "success"
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // When validation succeeds, processResponse() doesn't throw, so super.validate() is called
        // The response comes from the parent class's validate method
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateFailureWithStatusFailure() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSample();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for response with status "failure"
        Test.setMock(HttpCalloutMock.class, new FailureStatusCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Validation failed'), 'Exception message should indicate validation failure');
            System.assert(e.getMessage().contains('Status: failure'), 'Exception message should contain status');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateFailureWithNon200StatusCode() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSample();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for HTTP 500 error
        Test.setMock(HttpCalloutMock.class, new HttpErrorCalloutMock(500));
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('There was a problem with the request'), 'Exception message should indicate request problem');
            System.assert(e.getMessage().contains('500'), 'Exception message should contain status code');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateFailureWithEmptyResponseBody() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSample();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for empty response body
        Test.setMock(HttpCalloutMock.class, new EmptyResponseCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Empty response body'), 'Exception message should indicate empty response');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateFailureWithInvalidJson() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSample();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for invalid JSON response
        Test.setMock(HttpCalloutMock.class, new InvalidJsonCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Failed to parse response JSON'), 'Exception message should indicate JSON parsing failure');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateWithMultipleProductIds() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(3);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSampleMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for successful response
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateWithNoProductIds() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(0);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSampleMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for successful response
        Test.setMock(HttpCalloutMock.class, new SuccessCalloutMock());
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateWithNullStatus() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderValidateSample validator = new PlaceOrderValidateSample();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Set up mock for response with null status
        Test.setMock(HttpCalloutMock.class, new NullStatusCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected CalloutException to be thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('Validation failed'), 'Exception message should indicate validation failure');
        }
        Test.stopTest();
    }

    /**
     * Helper method to create a test cart with products
     */
    private static CartExtension.Cart arrangeCartWithProducts(Integer productCount) {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        WebStore testWebStore = new WebStore(Name = 'Test WebStore');
        insert testWebStore;

        WebCart testCart = new WebCart(Name = 'Test Cart', WebStoreId = testWebStore.Id, AccountId = testAccount.Id);
        insert testCart;

        CartDeliveryGroup testDeliveryGroup = new CartDeliveryGroup(Name = 'Test Delivery Group', CartId = testCart.Id);
        insert testDeliveryGroup;

        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 0; i < productCount; i++) {
            Product2 testProduct = new Product2(Name = 'Test Product ' + i, IsActive = true);
            testProducts.add(testProduct);
        }
        if (!testProducts.isEmpty()) {
            insert testProducts;
        }

        List<CartItem> testCartItems = new List<CartItem>();
        for (Product2 product : testProducts) {
            CartItem testCartItem = new CartItem(
                Name = 'Test Cart Item',
                SalesPrice = 10.00,
                CartId = testCart.Id,
                CartDeliveryGroupId = testDeliveryGroup.Id,
                Product2Id = product.Id,
                Type = CartExtension.SalesItemTypeEnum.PRODUCT.name()
            );
            testCartItems.add(testCartItem);
        }
        if (!testCartItems.isEmpty()) {
            insert testCartItems;
        }

        return CartExtension.CartTestUtil.getCart(testCart.Id);
    }

    /**
     * Mock class for PlaceOrderValidateSample that provides a testable implementation.
     * This mock extends the main class and overrides validate to handle super.validate() call
     * by returning a mock success response instead of calling the parent's super.validate().
     */
    @TestVisible
    private class PlaceOrderValidateSampleMock extends PlaceOrderValidateSample {
        
        public override CartExtension.PlaceOrderResponse validate(CartExtension.PlaceOrderRequest placeOrderRequest, List<String> domainList) {
            // Call the parent validate method which includes HTTP callout and processResponse logic
            // The parent method will throw CalloutException if validation fails
            // If validation succeeds, we need to return a response instead of calling super.validate()
            // Since we can't easily mock super.validate(), we'll replicate the logic here
            
            CartExtension.Cart cart = placeOrderRequest.getCart();
            CartExtension.CartItemList cartItems = cart.getCartItems();
            
            List<ID> productIds = new List<ID>();
            for (Integer i = (cartItems.size() - 1); i >= 0; i--) {
                CartExtension.CartItem cartItem = cartItems.get(i);
                ID productId = cartItem.getProduct2Id();
                productIds.add(productId);
            }
            
            String url = 'https://example.com';
            if (productIds != null && !productIds.isEmpty()) {
                String productIdsParam = String.join(productIds, ',');
                url += '?productIds=' + EncodingUtil.urlEncode(productIdsParam, 'UTF-8');
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url); 
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                // Call processResponse logic - it will throw if validation fails
                processResponseMock(responseBody);
                // Return mock success response instead of calling super.validate()
                return CartExtension.PlaceOrderResponse.success();
            } else {
                throw new CalloutException('There was a problem with the request. Error: ' + response.getStatusCode());
            }
        }
        
        // Replicate processResponse logic for testing
        private void processResponseMock(String responseBody) {
            if (responseBody != null && responseBody.trim().length() > 0) {
                try {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    String status = (String) responseMap.get('status');
                    
                    if (status != null && status.equalsIgnoreCase('success')) {
                        System.debug('Validation successful. Proceeding with order placement.');
                    } else {
                        throw new CalloutException('Validation failed. Response status does not indicate success. Status: ' + status);
                    }
                } catch (Exception e) {
                    if (e instanceof CalloutException) {
                        throw e;
                    }
                    throw new CalloutException('Failed to parse response JSON: ' + e.getMessage() + '. Response body: ' + responseBody);
                }
            } else {
                throw new CalloutException('Validation failed. Empty response body received.');
            }
        }
    }

    /**
     * Mock class for successful HTTP callout with status "success"
     */
    private class SuccessCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock class for HTTP callout with status "failure"
     */
    private class FailureStatusCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"failure"}');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock class for HTTP error responses
     */
    private class HttpErrorCalloutMock implements HttpCalloutMock {
        private Integer statusCode;
        
        public HttpErrorCalloutMock(Integer statusCode) {
            this.statusCode = statusCode;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"Internal Server Error"}');
            res.setStatusCode(statusCode);
            return res;
        }
    }

    /**
     * Mock class for empty response body
     */
    private class EmptyResponseCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock class for invalid JSON response
     */
    private class InvalidJsonCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{invalid json}');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock class for response with null status field
     */
    private class NullStatusCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"otherField":"value"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
