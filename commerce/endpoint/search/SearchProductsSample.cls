/**
 * Sample extension provider for modifying product search requests and results.
 * This corresponds to the endpoint /commerce/webstores/${webstoreId}/search/products
 * and is identified by the EPN Commerce_Endpoint_Search_Products for registration/mapping.
 */
public with sharing class SearchProductsSample extends ConnectApi.BaseEndpointExtension {

    // Define a constant for the search term prefix
    private static final String SEARCH_TERM_PREFIX = 'beforeGet executed';

    // Define a constant for the product name prefix
    private static final String PRODUCT_NAME_PREFIX = 'afterGet executed';

    /**
     * Overrides the beforeGet method to transform the search term before executing the search.
     *
     * @param request The endpoint extension request containing search parameters.
     * @return The modified endpoint extension request with transformed search term.
     */
    public override ConnectApi.EndpointExtensionRequest beforeGet(ConnectApi.EndpointExtensionRequest request) {
        System.debug('Entering the beforeGet method of Commerce_Endpoint_Search_Products extension');

        // Retrieve the search term from the request
        String searchTerm = (String)request.getParam('searchTerm');
        System.debug('Original searchTerm: ' + searchTerm);

        // Modify the search term to demonstrate the extension is executing
        String updatedSearchTerm = SEARCH_TERM_PREFIX + searchTerm;
        request.setParam('searchTerm', updatedSearchTerm);

        System.debug('Modified searchTerm to: ' + updatedSearchTerm);

        return request;
    }

    /**
     * Overrides the afterGet method to modify product names and reverse the order of search results.
     *
     * @param response The endpoint extension response containing search results.
     * @param request The endpoint extension request.
     * @return The modified endpoint extension response with updated products.
     */
    public override ConnectApi.EndpointExtensionResponse afterGet(ConnectApi.EndpointExtensionResponse response, ConnectApi.EndpointExtensionRequest request) {
        System.debug('Entering the afterGet method of Commerce_Endpoint_Search_Products extension');

        // Retrieve the results from the response
        ConnectApi.CommerceProductSearchResults searchResults =
            (ConnectApi.CommerceProductSearchResults)response.getResponseObject();

        // Check if searchResults is not null
        if (searchResults == null) {
            System.debug('No search results found');
            return response;
        }

        ConnectApi.CommerceProductSummaryPage productsPage = searchResults.productsPage;

        // Check if products page and products list are not null and not empty
        if (productsPage == null || productsPage.products == null || productsPage.products.isEmpty()) {
            System.debug('No products to modify');
            return response;
        }

        List<ConnectApi.CommerceProductSummary> products = productsPage.products;
        System.debug('Processing ' + products.size() + ' products (reversing order and modifying names)');

        List<ConnectApi.CommerceProductSummary> updatedProducts = new List<ConnectApi.CommerceProductSummary>();

        // Reverse the order of products and modify product names to demonstrate the extension is executing
        for (Integer i = products.size() - 1; i >= 0; i--) {
            ConnectApi.CommerceProductSummary product = products[i];

            // Modify the Name field to add a prefix
            if (product.fields != null && product.fields.containsKey('Name')) {
                String originalName = (String)product.fields.get('Name').value;
                String newName = PRODUCT_NAME_PREFIX + ' ' + originalName;
                product.fields.get('Name').value = newName;
                System.debug('Modified product name: ' + originalName + ' -> ' + newName);
            }

            updatedProducts.add(product);
        }

        // Update the products list with the modified and reversed list
        searchResults.productsPage.products = updatedProducts;

        return response;
    }
}