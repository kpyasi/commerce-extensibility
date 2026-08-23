/**
 * ContractPricingService
 *
 * Commerce pricing contract-resolution extension (resolveContracts, API v264+).
 * - Authoritative: calls disableDefaultResolution() so any line this extension does not resolve
 *   prices to LIST (the platform does NOT back-fill).
 * - Overlap handling: when a product has multiple ContractItemPrice rows, the one with the
 *   latest StartDate wins (CreatedDate breaks same-day ties).
 *
 * NOTE: disableDefaultResolution() exists only on 264-patch / 266+ builds. Deploy to such an org.
 */
public without sharing class ContractPricingService extends commercestorepricing.PricingService {

  public override commercestorepricing.ContractResolutionResponse resolveContracts(
    commercestorepricing.ContractResolutionRequest request
  ) {
    commercestorepricing.ContractResolutionResponse response = request.newResponse();

    // Make this extension authoritative: unresolved lines price to list, no platform back-fill.
    response.enableDefaultResolution();

    try {
      String accountId       = request.getAccountId();
      String currencyIsoCode = request.getCurrencyIsoCode();
      Datetime effectiveDate = (request.getEffectiveDate() == null)
        ? System.now()
        : request.getEffectiveDate();

      List<commercestorepricing.ContractPricingRequestItem> items = request.getRequestItems();
      if (items == null || items.isEmpty() || String.isBlank(accountId)) {
        return response;
      }

      // 1) Collect all product Ids from the batch.
      Set<String> productIds = new Set<String>();
      for (commercestorepricing.ContractPricingRequestItem item : items) {
        if (String.isNotBlank(item.getProductId())) {
          productIds.add(item.getProductId());
        }
      }
      if (productIds.isEmpty()) {
        return response;
      }

      // 2) ONE bulkified query. WITH SYSTEM_MODE reads contract data the buyer may not see.
      //    ORDER BY StartDate DESC, CreatedDate DESC => latest-dated contract price is the first
      //    row per product, so we keep it and skip the rest (overlap/conflict resolution).
      Map<String, ContractDataFromExternalService> contractsByProduct =
        new Map<String, ContractDataFromExternalService>();
      for (ContractItemPrice cip : [
          SELECT Id, ContractId, ItemId, ProductSellingModelId, Price, StartDate
          FROM ContractItemPrice
          WHERE Contract.AccountId = :accountId
            AND ItemId IN :productIds
            AND StartDate <= :effectiveDate
            AND (EndDate = null OR EndDate >= :effectiveDate)
            AND CurrencyIsoCode = :currencyIsoCode
          WITH SYSTEM_MODE
          ORDER BY ItemId, StartDate DESC, CreatedDate DESC
      ]) {
        // First row for each ItemId wins => the latest-starting contract price.
        if (!contractsByProduct.containsKey(cip.ItemId)) {
          contractsByProduct.put(
            cip.ItemId,
            new ContractDataFromExternalService(cip.ContractId, cip.Id)
          );
        }
      }

      // 3) Record the resolved contract for each line.
      for (commercestorepricing.ContractPricingRequestItem item : items) {
        ContractDataFromExternalService c = contractsByProduct.get(item.getProductId());
        if (c != null) {
          response.putContractForLine(
            item.getProductId(),
            item.getPsmId(),
            c.getContractId(),
            c.getContractItemPriceId()
          );
        }
        // Unresolved lines are left off => they price to list (disableDefaultResolution).
      }

    } catch (Exception e) {
      // Fail safe: never let an exception escape (that would force platform default resolution).
      System.debug(LoggingLevel.ERROR, 'resolveContracts failed: ' + e.getMessage());
    }

    return response;
  }

  // Holds the contract data resolved for a line.
  public class ContractDataFromExternalService {
    private String contractId;
    private String contractItemPriceId;
    public ContractDataFromExternalService(String inputContractId, String inputContractItemPriceId) {
      this.contractId = inputContractId;
      this.contractItemPriceId = inputContractItemPriceId;
    }
    public String getContractId() {
      return contractId;
    }
    public String getContractItemPriceId() {
      return contractItemPriceId;
    }
  }
}
