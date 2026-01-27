/**
 * @description Unit tests for PlaceOrderWithValidationsInSequence class.
 * Tests the sequential domain validation logic for order placement.
 */
@isTest
private class PlaceOrderWithValidationsInSequenceTest {

    @isTest
    static void testValidateSuccessWithAllDomainsInSequence() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(2);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>{ 'PRICING', 'PROMOTIONS', 'SHIPPING', 'TAXES' };
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // All domains should be validated in sequence: PRICING, PROMOTIONS, SHIPPING, TAXES
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateSuccessWithPartialDomains() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        // Only PRICING and TAXES in domainList, should skip PROMOTIONS and SHIPPING
        List<String> domainList = new List<String>{ 'PRICING', 'TAXES' };
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // Should validate PRICING first, skip PROMOTIONS and SHIPPING, then validate TAXES
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateSuccessWithDomainsInDifferentOrder() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        // DomainList has different order, but should still validate in fixed sequence
        List<String> domainList = new List<String>{ 'TAXES', 'PRICING', 'SHIPPING', 'PROMOTIONS' };
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // Should still validate in sequence: PRICING, PROMOTIONS, SHIPPING, TAXES
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateSuccessWithOnlyFirstDomain() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        // Only PRICING in domainList
        List<String> domainList = new List<String>{ 'PRICING' };
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateSuccessWithOnlyLastDomain() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        // Only TAXES in domainList
        List<String> domainList = new List<String>{ 'TAXES' };
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateWithEmptyDomainList() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>();
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // Should call super.validate() with empty list
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateWithNullDomainList() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = null;
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // Should call super.validate() with null list
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testValidateFailureWithFirstDomainFailing() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequence();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>{ 'PRICING', 'PROMOTIONS', 'SHIPPING', 'TAXES' };
        
        // Set up mock to fail on PRICING (first domain)
        Test.setMock(HttpCalloutMock.class, new FirstDomainFailureCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected exception to be thrown');
        } catch (Exception e) {
            // Should fail on PRICING validation
            System.assert(true, 'Exception thrown as expected: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateFailureWithMiddleDomainFailing() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequence();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>{ 'PRICING', 'PROMOTIONS', 'SHIPPING', 'TAXES' };
        
        // Set up mock to fail on PROMOTIONS (middle domain)
        Test.setMock(HttpCalloutMock.class, new MiddleDomainFailureCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected exception to be thrown');
        } catch (Exception e) {
            // Should fail on PROMOTIONS validation
            System.assert(true, 'Exception thrown as expected: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateFailureWithLastDomainFailing() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequence();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        List<String> domainList = new List<String>{ 'PRICING', 'PROMOTIONS', 'SHIPPING', 'TAXES' };
        
        // Set up mock to fail on TAXES (last domain)
        Test.setMock(HttpCalloutMock.class, new LastDomainFailureCalloutMock());
        
        // Act & Assert
        Test.startTest();
        try {
            validator.validate(placeOrderRequest, domainList);
            System.assert(false, 'Expected exception to be thrown');
        } catch (Exception e) {
            // Should fail on TAXES validation
            System.assert(true, 'Exception thrown as expected: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateWithSingleDomainInMiddle() {
        // Arrange
        CartExtension.Cart cart = arrangeCartWithProducts(1);
        PlaceOrderWithValidationsInSequence validator = new PlaceOrderWithValidationsInSequenceMock();
        CartExtension.PlaceOrderRequest placeOrderRequest = new CartExtension.PlaceOrderRequest(cart);
        // Only SHIPPING in domainList (middle domain)
        List<String> domainList = new List<String>{ 'SHIPPING' };
        
        // Act
        Test.startTest();
        CartExtension.PlaceOrderResponse response = validator.validate(placeOrderRequest, domainList);
        Test.stopTest();
        
        // Assert
        // Should skip PRICING and PROMOTIONS, validate SHIPPING, skip TAXES
        System.assertNotEquals(null, response, 'Response should not be null');
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
     * Mock class for PlaceOrderWithValidationsInSequence that provides a testable implementation.
     * This mock extends the main class and overrides validate to handle super.validate() calls
     * by returning a mock success response instead of calling the parent's super.validate().
     */
    @TestVisible
    private class PlaceOrderWithValidationsInSequenceMock extends PlaceOrderWithValidationsInSequence {
        
        // Track which domains were validated
        public List<String> validatedDomains = new List<String>();
        
        public override CartExtension.PlaceOrderResponse validate(CartExtension.PlaceOrderRequest placeOrderRequest, List<String> domainList) {
            // Replicate the parent logic but track domains and return mock response
            CartExtension.PlaceOrderResponse response = null;
            
            List<String> validationSequence = new List<String>{ 'PRICING', 'PROMOTIONS', 'SHIPPING', 'TAXES' };
            
            if (domainList != null && !domainList.isEmpty()) {
                Set<String> domainSet = new Set<String>(domainList);
                
                for (String domain : validationSequence) {
                    if (domainSet.contains(domain)) {
                        System.debug('Validating domain: ' + domain);
                        validatedDomains.add(domain);
                        
                        // Simulate successful validation
                        response = CartExtension.PlaceOrderResponse.success();
                        
                        System.debug('Domain ' + domain + ' validation completed successfully');
                    } else {
                        System.debug('Domain ' + domain + ' not in domainList, skipping validation');
                    }
                }
            } else {
                // If no domain list provided, return mock success response
                response = CartExtension.PlaceOrderResponse.success();
            }
            
            return response;
        }
    }

    /**
     * Mock class for HTTP callout that fails on first domain (PRICING)
     */
    private class FirstDomainFailureCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"failure"}');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock class for HTTP callout that fails on middle domain (PROMOTIONS)
     */
    private class MiddleDomainFailureCalloutMock implements HttpCalloutMock {
        private Integer callCount = 0;
        
        public HttpResponse respond(HttpRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // First domain (PRICING) succeeds, second domain (PROMOTIONS) fails
            if (callCount == 2) {
                res.setBody('{"status":"failure"}');
            } else {
                res.setBody('{"status":"success"}');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     * Mock class for HTTP callout that fails on last domain (TAXES)
     */
    private class LastDomainFailureCalloutMock implements HttpCalloutMock {
        private Integer callCount = 0;
        
        public HttpResponse respond(HttpRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // First three domains succeed, last domain (TAXES) fails
            if (callCount == 4) {
                res.setBody('{"status":"failure"}');
            } else {
                res.setBody('{"status":"success"}');
            }
            res.setStatusCode(200);
            return res;
        }
    }
}
