/**
 * Sample extension provider for modifying search suggestions and their associated products.
 * This corresponds to the endpoint /commerce/webstores/${webstoreId}/search/suggestions
 * and is identified by the EPN Commerce_Endpoint_Search_Suggestions for registration/mapping.
 */
public with sharing class SearchSuggestionsSample extends ConnectApi.BaseEndpointExtension {

    // Define a constant for the search term prefix
    private static final String SEARCH_TERM_PREFIX = 'beforeGet executed';

    // Define a constant for the product name prefix
    private static final String PRODUCT_NAME_PREFIX = 'afterGet executed';

    /**
     * Overrides the beforeGet method to modify the search term and enable suggested products.
     *
     * @param request The endpoint extension request containing search parameters.
     * @return The modified endpoint extension request with updated search term.
     */
    public override ConnectApi.EndpointExtensionRequest beforeGet(ConnectApi.EndpointExtensionRequest request) {
        System.debug('Entering the beforeGet method of Commerce_Endpoint_Search_Suggestions extension');

        // Retrieve the search term from the request
        String searchTerm = (String)request.getParam('searchTerm');
        System.debug('Original searchTerm: ' + searchTerm);

        // Modify the search term to demonstrate the extension is executing
        String updatedSearchTerm = SEARCH_TERM_PREFIX + searchTerm;
        request.setParam('searchTerm', updatedSearchTerm);

        System.debug('Modified searchTerm to: ' + updatedSearchTerm);

        // Modify another param for demonstration; enable suggested products
        request.setParam('includeSuggestedProducts', true);

        return request;
    }

    /**
     * Overrides the afterGet method to modify product names in search suggestions.
     *
     * @param response The endpoint extension response containing search suggestions.
     * @param request The endpoint extension request.
     * @return The modified endpoint extension response with updated product names.
     */
    public override ConnectApi.EndpointExtensionResponse afterGet(ConnectApi.EndpointExtensionResponse response, ConnectApi.EndpointExtensionRequest request) {
        System.debug('Entering the afterGet method of Commerce_Endpoint_Search_Suggestions extension');

        // Retrieve the results from the response
        ConnectApi.ProductSearchSuggestionsResults suggestionsResults =
            (ConnectApi.ProductSearchSuggestionsResults)response.getResponseObject();

        if (suggestionsResults == null) {
            System.debug('No suggestions results found');
            return response;
        }

        List<ConnectApi.AbstractSearchSuggestion> suggestions = suggestionsResults.recentSearchSuggestions;

        if (suggestions == null || suggestions.isEmpty()) {
            System.debug('No suggestions to modify');
            return response;
        }

        System.debug('Processing ' + suggestions.size() + ' suggestions');

        // Iterate through suggestions and modify product names for those with suggested products.
        for (Integer i = 0; i < suggestions.size(); i++) {
            ConnectApi.AbstractSearchSuggestion suggestion = suggestions[i];

            if (suggestion instanceof ConnectApi.SearchSuggestionWithProductSuggestion) {
                ConnectApi.SearchSuggestionWithProductSuggestion productSuggestion =
                    (ConnectApi.SearchSuggestionWithProductSuggestion)suggestion;

                if (productSuggestion.suggestedProducts != null && !productSuggestion.suggestedProducts.isEmpty()) {

                    // Update each product name in this suggestion
                    for (Integer j = 0; j < productSuggestion.suggestedProducts.size(); j++) {
                        ConnectApi.ProductSummary product = productSuggestion.suggestedProducts[j];

                        // Access the product fields map and modify the Name field
                        if (product.fields != null && product.fields.containsKey('Name')) {
                            String originalName = (String)product.fields.get('Name').value;
                            String newName = PRODUCT_NAME_PREFIX + ' ' + originalName;
                            product.fields.get('Name').value = newName;
                            System.debug('Modified product name: ' + originalName + ' -> ' + newName);
                        }
                    }
                }
            }
        }

        return response;
    }
}