/**
 * BuyerGroupShareableURLSample
 *
 * This class is a sample implementation of the {@code commercebuygrp.BuyerGroupEvaluationService}.
 * It demonstrates how to extend the default buyer group evaluation logic to include custom criteria
 * based on request context parameters. In this case, the custom criterion is the user's region, which
 * is passed as a URL parameter (e.g., in a shareable URL for the storefront).
 *
 * Use Case:
 * - Retrieve default buyer groups based on standard rules (account, market, and data cloud segments).
 * - Additionally, include buyer groups associated with the user's region (if provided via request context).
 *
 * Notes:
 * - This example demonstrates extensibility for shareable URLs in the commerce storefront.
 * - To use this, the region parameter must be explicitly set in the request context via URL.
 * - When implementing real logic, replace the placeholder region-based filtering with actual mapping logic.
 *
 * Limitations:
 * - Maximum allowed buyer groups is controlled by {@link #MAX_BUYER_GROUPS} (currently set to 30).
 * - If the number exceeds this limit, an error response is returned instead of the list.
 *
 * SECURITY CONSIDERATIONS (Secure by Default - Apex v67.0+):
 * - This class explicitly declares WITHOUT SHARING because buyer group evaluation must access
 *   all necessary data regardless of the current user's sharing rules.
 * - The base implementation (super.getBuyerGroupIds) handles all data access with appropriate
 *   security modes, so no additional WITH SYSTEM_MODE clauses are needed in this class.
 * - This is intentional: buyer group evaluation is a system-level operation that should
 *   not be limited by individual user permissions, especially for guest users.
 */
public without sharing class BuyerGroupShareableURLSample extends commercebuygrp.BuyerGroupEvaluationService {

    /** Maximum number of buyer groups that can be associated with a single user request. */
    private static final Integer MAX_BUYER_GROUPS = 30;

    /**
     * Retrieves buyer group IDs for a user, including:
     *  - Default buyer groups (account, market, data cloud segments).
     *  - Region-based buyer groups (if region parameter is provided).
     *
     * @param request The {@link commercebuygrp.BuyerGroupRequest} containing context parameters.
     * @return A {@link commercebuygrp.BuyerGroupResponse} with buyer group IDs or an error if the limit is exceeded.
     */
    public override commercebuygrp.BuyerGroupResponse getBuyerGroupIds(commercebuygrp.BuyerGroupRequest request) {
        // Extract context parameters from the incoming request
        Map<String, Object> requestParameters = request.getRequestContextParameters();

        // Retrieve the custom region parameter passed via shareable URL (e.g., &region=asia)
        String region = (String) requestParameters.get('region');

        // Get default out-of-the-box buyer groups using base implementation
        commercebuygrp.BuyerGroupResponse defaultBuyerGroupResponse = super.getBuyerGroupIds(request);
        Set<String> buyerGroupIds = new Set<String>(defaultBuyerGroupResponse.getBuyerGroupIds());

        // If region is provided and equals "asia", add region-specific buyer groups
        if (region != null && region.equalsIgnoreCase('asia')) {
            // Add logic to fetch additional buyer groups for Asia region.
            // Example: buyerGroupIds.addAll(getRegionSpecificGroups(region));
        }

        // Enforce maximum limit for buyer groups
        if (buyerGroupIds.size() > MAX_BUYER_GROUPS) {
            // Create error response when limit exceeds
            commercebuygrp.BuyerGroupResponse response = new commercebuygrp.BuyerGroupResponse();
            String errorMessage = 'More than ' + MAX_BUYER_GROUPS + ' buyer groups retrieved for the user. Contact Store Administrator.';
            response.setError(errorMessage, errorMessage);
            return response;
        }


        // Return final response with allowed buyer group IDs
        return new commercebuygrp.BuyerGroupResponse(buyerGroupIds);
    }
}
