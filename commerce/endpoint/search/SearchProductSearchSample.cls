/**
 * Sample extension provider for the legacy POST-based product search endpoint.
 * This corresponds to the endpoint /commerce/webstores/${webstoreId}/search/product-search (POST)
 * and is identified by the EPN Commerce_Endpoint_Search_ProductSearch for registration/mapping.
 * Note: This is an older endpoint that does not receive new development. Consider using the GET variant,
 * Commerce_Endpoint_Search_Products.
 */
public with sharing class SearchProductSearchSample extends ConnectApi.BaseEndpointExtension {

    // Define a constant for the search term prefix
    private static final String SEARCH_TERM_PREFIX = 'beforeGet executed';

    // Define a constant for the product name prefix
    private static final String PRODUCT_NAME_PREFIX = 'afterGet executed';

    /**
     * Overrides the beforePost method to modify the search term before executing the search.
     *
     * @param request The endpoint extension request containing search parameters.
     * @return The modified endpoint extension request with updated search term.
     */
    public override ConnectApi.EndpointExtensionRequest beforePost(ConnectApi.EndpointExtensionRequest request) {
        System.debug('Entering the beforePost method of Commerce_Endpoint_Search_ProductSearch extension');

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
     * Overrides the afterPost method to modify product names in the search results.
     *
     * @param response The endpoint extension response containing search results.
     * @param request The endpoint extension request.
     * @return The modified endpoint extension response with updated product names.
     */
    public override ConnectApi.EndpointExtensionResponse afterPost(
            ConnectApi.EndpointExtensionResponse response,
            ConnectApi.EndpointExtensionRequest request) {
        System.debug('Entering the afterPost method of Commerce_Endpoint_Search_ProductSearch extension');

        // Retrieve the results from the response
        ConnectApi.ProductSearchResults searchResults =
            (ConnectApi.ProductSearchResults)response.getResponseObject();

        // Check if searchResults is not null
        if (searchResults == null) {
            System.debug('No search results found');
            return response;
        }

        ConnectApi.ProductSummaryPage productsPage = searchResults.productsPage;

        // Check if products page and products list are not null and not empty
        if (productsPage == null || productsPage.products == null || productsPage.products.isEmpty()) {
            System.debug('No products to modify');
            return response;
        }

        List<ConnectApi.ProductSummary> products = productsPage.products;
        System.debug('Processing ' + products.size() + ' products');

        List<ConnectApi.ProductSummary> updatedProducts = new List<ConnectApi.ProductSummary>();

        // Reverse the order of products and modify product names to demonstrate the extension is executing
        for (Integer i = products.size() - 1; i >= 0; i--) {
            ConnectApi.ProductSummary product = products[i];

            // Modify the Name field to add a prefix
            if (product.fields != null && product.fields.containsKey('Name')) {
                String originalName = (String)product.fields.get('Name').value;
                String newName = PRODUCT_NAME_PREFIX + ' ' + originalName;
                product.fields.get('Name').value = newName;
                System.debug('Modified product name: ' + originalName + ' -> ' + newName);
            }

            updatedProducts.add(product);
        }

        // Update the products list with the modified list
        searchResults.productsPage.products = updatedProducts;

        return response;
    }
}