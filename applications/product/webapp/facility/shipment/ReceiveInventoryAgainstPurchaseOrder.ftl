<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

    <#-- JS to populate the quantity_o_# field required by the chained issueOrderItemToShipment service -->
    <@script>
      function populateQuantities(rowCount) {
        for (var x = 0; x <= rowCount; x++) {
          var quantityAcceptedInput = document.getElementById('quantityAccepted_o_' + x);
          var quantityInput = document.getElementById('quantity_o_' + x);
          if (quantityAcceptedInput != null && quantityInput != null) {
            quantityInput.value = quantityAcceptedInput.value;
          }
        }
      }
    </@script>

    <#assign productId = parameters.productId!/>

<@section title="${uiLabelMap.ProductReceiveInventoryAgainstPurchaseOrder}">

<#if shipment??>
    <#if !isPurchaseShipment>
        <div class="errorMessage">
            <#assign uiLabelWithVar=uiLabelMap.ProductErrorShipmentNotPurchaseShipment?interpret><@uiLabelWithVar/>
        </div>
    <#elseif orderId?has_content && !orderHeader??>
        <div class="errorMessage">
            <#assign uiLabelWithVar=uiLabelMap.ProductErrorOrderIdNotFound?interpret><@uiLabelWithVar/>
        </div>
    <#elseif orderHeader?? && orderHeader.orderTypeId != "PURCHASE_ORDER">
        <div class="errorMessage">
            <#assign uiLabelWithVar=uiLabelMap.ProductErrorOrderNotPurchaseOrder?interpret><@uiLabelWithVar/>
        </div>
    <#elseif ProductReceiveInventoryAgainstPurchaseOrderProductNotFound??>
        <div class="errorMessage">
            <#assign uiLabelWithVar=uiLabelMap.ProductReceiveInventoryAgainstPurchaseOrderProductNotFound?interpret><@uiLabelWithVar/>
            <@script>window.onload=function(){showErrorAlert("${uiLabelMap.CommonErrorMessage2}","<@uiLabelWithVar/>");};</@script>
        </div>
    <#elseif ProductReceiveInventoryAgainstPurchaseOrderQuantityExceedsAvailableToReceive??>
        <div class="errorMessage">
            <#assign uiLabelWithVar=uiLabelMap.ProductReceiveInventoryAgainstPurchaseOrderQuantityExceedsAvailableToReceive?interpret><@uiLabelWithVar/>
            <@script>window.onload=function(){showErrorAlert("${uiLabelMap.CommonErrorMessage2}","<@uiLabelWithVar/>");};</@script>
        </div>
    </#if>
    <#if ProductReceiveInventoryAgainstPurchaseOrderQuantityGoesToBackOrder??>
        <div class="errorMessage" class="${styles.text_color_success!}">
            <#assign uiLabelWithVar=uiLabelMap.ProductReceiveInventoryAgainstPurchaseOrderQuantityGoesToBackOrder?interpret><@uiLabelWithVar/>
            <@script>window.onload=function(){showErrorAlert("${uiLabelMap.CommonErrorMessage2}","<@uiLabelWithVar/>");};</@script>
        </div>
    </#if>
</#if>

<form name="ReceiveInventoryAgainstPurchaseOrder" action="<@ofbizUrl>ReceiveInventoryAgainstPurchaseOrder</@ofbizUrl>">
    <input type="hidden" name="clearAll" value="Y"/>
    <div>
        <span>${uiLabelMap.ProductShipmentId}</span>&nbsp;<input type="text" size="20" name="shipmentId" value="${shipmentId!}"/>
        <span>${uiLabelMap.ProductOrderId}</span>&nbsp;
        <span>
            <@htmlTemplate.lookupField value="${orderId!}" formName="ReceiveInventoryAgainstPurchaseOrder" name="purchaseOrderId" id="purchaseOrderId" fieldFormName="LookupOrderHeaderAndShipInfo"/>
        </span>
        <span>${uiLabelMap.ProductOrderShipGroupId}</span>&nbsp;<input type="text" size="20" name="shipGroupSeqId" value="${shipGroupSeqId!}"/>
        <input type="submit" value="${uiLabelMap.CommonSelect}" class="${styles.link_run_sys!} ${styles.action_select!}"/>
    </div>
</form>

<#if shipment??>
    <#if isPurchaseShipment>

        <#assign itemsAvailableToReceive = totalAvailableToReceive?default(0) &gt; 0/>
        <#if orderItemDatas??>
            <br />
            <#assign rowCount = 0>
            <#assign totalReadyToReceive = 0/>
            <form action="<@ofbizUrl>issueOrderItemToShipmentAndReceiveAgainstPO?clearAll=Y</@ofbizUrl>" method="post" name="selectAllForm">
                <input type="hidden" name="facilityId" value="${facilityId}"/>
                <input type="hidden" name="purchaseOrderId" value="${orderId}"/>
                <input type="hidden" name="shipmentId" value="${shipmentId}" />
                <input type="hidden" name="_useRowSubmit" value="Y"/>
                <@table type="data-list" autoAltRows=true> <#-- orig: class="basic-table" --> <#-- orig: cellspacing="0" -->
                    <@thead>
                    <@tr class="header-row">
                        <@th>${uiLabelMap.ProductProduct}</@th>
                        <#-- Must use the uiLabelMap[""] notation since the label key has . in it -->
                        <@th>${uiLabelMap["GoodIdentificationType.description.UPCA"]}</@th>
                        <@th>${uiLabelMap.OrderOrder}</@th>
                        <@th>${uiLabelMap.OrderCancelled}</@th>
                        <@th>${uiLabelMap.OrderBackOrdered}</@th>
                        <@th>${uiLabelMap.CommonReceived}</@th>
                        <@th>${uiLabelMap.ProductOpenQuantity}</@th>
                        <@th>${uiLabelMap.ProductBackOrders}</@th>
                        <#if itemsAvailableToReceive>
                            <@th>${uiLabelMap.CommonReceive}</@th>
                            <@th>${uiLabelMap.ProductInventoryItemType}</@th>
                            <@th colspan="2" align="right">${uiLabelMap.CommonAll}<input type="checkbox" name="selectAll" value="${uiLabelMap.CommonY}" onclick="javascript:toggleAll(this, 'selectAllForm');highlightAllRows(this, 'orderItemData_tableRow_', 'selectAllForm');" />
                            </@th>
                        </#if>
                    </@tr>
                    </@thead>
                    <#list orderItemDatas! as orderItemData>
                        <#assign orderItem = orderItemData.orderItem>
                        <#assign product = orderItemData.product!>
                        <#assign itemShipGroupSeqId = orderItemData.shipGroupSeqId!>
                        <#assign totalQuantityReceived = orderItemData.totalQuantityReceived?default(0)>
                        <#assign availableToReceive = orderItemData.availableToReceive?default(0)>
                        <#assign backOrderedQuantity = orderItemData.backOrderedQuantity?default(0)>
                        <#assign fulfilledReservations = orderItemData.fulfilledReservations>
                        <@tr id="orderItemData_tableRow_${rowCount}" valign="middle">
                            <@td>${(product.internalName)!} [${orderItem.productId?default("N/A")}]</@td>
                            <@td>
                                    <#assign upcaLookup = Static["org.ofbiz.base.util.UtilMisc"].toMap("productId", product.productId, "goodIdentificationTypeId", "UPCA")/>
                                    <#assign upca = delegator.findOne("GoodIdentification", upcaLookup, true)!/>
                                    <#if upca?has_content>
                                        ${upca.idValue!}
                                    </#if>
                            </@td>
                            <@td>${orderItem.quantity}</@td>
                            <@td>${orderItem.cancelQuantity?default(0)}</@td>
                            <@td>
                                <div ${(backOrderedQuantity &gt; 0)?string(" errorMessage","")}">
                                    ${backOrderedQuantity}
                                </div>
                            </@td>
                            <@td>${totalQuantityReceived}</@td>
                            <@td>${orderItem.quantity - orderItem.cancelQuantity?default(0) - totalQuantityReceived}</@td>
                            <@td>
                                    <#if fulfilledReservations?has_content>
                                        <#list fulfilledReservations?sort_by("orderId") as fulfilledReservation>
                                            ${fulfilledReservation.orderId}<br />
                                        </#list>
                                    </#if>
                            </@td>
                            <#if (availableToReceive > 0)>
                                <@td>
                                    <input type="hidden" name="productId_o_${rowCount}" value="${(product.productId)!}"/>
                                    <input type="hidden" name="facilityId_o_${rowCount}" value="${facilityId}"/>
                                    <input type="hidden" name="shipmentId_o_${rowCount}" value="${shipmentId}"/>
                                    <input type="hidden" name="orderId_o_${rowCount}" value="${orderItem.orderId}"/>
                                    <input type="hidden" name="shipGroupSeqId_o_${rowCount}" value="${itemShipGroupSeqId!}"/>
                                    <input type="hidden" name="orderItemSeqId_o_${rowCount}" value="${orderItem.orderItemSeqId}"/>
                                    <input type="hidden" name="unitCost_o_${rowCount}" value="${orderItem.unitPrice?default(0)}"/>
                                    <input type="hidden" name="currencyUomId_o_${rowCount}" value="${currencyUomId?default("")}"/>
                                    <input type="hidden" name="ownerPartyId_o_${rowCount}" value="${(facility.ownerPartyId)!}"/>
                                    <input type="hidden" name="datetimeReceived_o_${rowCount}" value="${now}"/>
                                    <input type="hidden" name="quantityRejected_o_${rowCount}" value="0"/>
                                    <#-- quantity field required by the chained issueOrderItemToShipment service -->
                                    <input type="hidden" name="quantity_o_${rowCount}" id="quantity_o_${rowCount}" value=""/>
                                    <#if itemQuantitiesToReceive?? && itemQuantitiesToReceive.get(orderItem.orderItemSeqId)??>
                                        <#assign quantityToReceive = itemQuantitiesToReceive.get(orderItem.orderItemSeqId)>
                                    <#else>
                                        <#assign quantityToReceive = 0>
                                    </#if>
                                    <#assign totalReadyToReceive = totalReadyToReceive + quantityToReceive/>
                                    <input type="text" size="5" name="quantityAccepted_o_${rowCount}" id="quantityAccepted_o_${rowCount}" value="${quantityToReceive}"/>
                                </@td>
                                <@td>
                                    <select name="inventoryItemTypeId_o_${rowCount}">
                                      <#list inventoryItemTypes as inventoryItemType>
                                      <option value="${inventoryItemType.inventoryItemTypeId}"
                                          <#if (facility.defaultInventoryItemTypeId?has_content) && (inventoryItemType.inventoryItemTypeId == facility.defaultInventoryItemTypeId)>
                                              selected="selected"
                                          </#if>
                                      >${inventoryItemType.get("description",locale)?default(inventoryItemType.inventoryItemTypeId)}</option>
                                      </#list>
                                    </select>
                                </@td>
                                <@td align="right">
                                    <a href="<@ofbizUrl>ReceiveInventoryAgainstPurchaseOrder?shipmentId=${shipmentId}&amp;purchaseOrderId=${orderId}&amp;productId=${product.productId}</@ofbizUrl>" class="${styles.link_run_local!} ${styles.action_clear!}">${uiLabelMap.CommonClear}</a>
                                </@td>
                                <@td align="right">
                                  <input type="checkbox" name="_rowSubmit_o_${rowCount}" value="Y" onclick="javascript:checkToggle(this, 'selectAllForm');highlightRow(this,'orderItemData_tableRow_${rowCount}');" />
                                </@td>
                                <#assign rowCount = rowCount + 1>
                            </#if>
                        </@tr>
                    </#list>
                    <#if itemsAvailableToReceive>
                      <@tfoot>
                        <@tr>
                            <@td colspan="11" align="right">
                                <a href="<@ofbizUrl>ReceiveInventoryAgainstPurchaseOrder?shipmentId=${shipmentId}&amp;purchaseOrderId=${orderId}&amp;clearAll=Y</@ofbizUrl>" class="${styles.link_run_local!} ${styles.action_clear!}">${uiLabelMap.CommonClearAll}</a>
                            </@td>
                            <@td align="right">
                                <a class="${styles.link_run_sys!} ${styles.action_receive!}" href="javascript:populateQuantities(${rowCount - 1});document.selectAllForm.submit();">${uiLabelMap.ProductReceiveItem}</a>
                            </@td>
                        </@tr>
                        <@tr>
                            <@td colspan="12" align="right">
                                <a class="${styles.link_run_sys!} ${styles.action_update!}" href="<@ofbizUrl>completePurchaseOrder?orderId=${orderId}&amp;facilityId=${facilityId}&amp;shipmentId=${shipmentId}</@ofbizUrl>">${uiLabelMap.OrderForceCompletePurchaseOrder}</a>
                            </@td>
                        </@tr>
                      </@tfoot>
                    </#if>
                </@table>
                <input type="hidden" name="_rowCount" value="${rowCount}" />
            </form>
            <@script>selectAll('selectAllForm');</@script>
        </#if>
        <#if itemsAvailableToReceive && totalReadyToReceive < totalAvailableToReceive>
            <@heading>${uiLabelMap.ProductReceiveInventoryAddProductToReceive}</@heading>
            <form name="addProductToReceive" method="post" action="<@ofbizUrl>ReceiveInventoryAgainstPurchaseOrder</@ofbizUrl>">
                <input type="hidden" name="shipmentId" value="${shipmentId}"/>
                <input type="hidden" name="purchaseOrderId" value="${orderId}"/>
                <div>
                    <span>${uiLabelMap.ProductProductId}/${uiLabelMap.ProductGoodIdentification}</span>
                    <input type="text" size="20" id="productId" name="productId" value=""/>
                        @
                    <input type="text"  name="quantity" size="6" maxlength="6" value="1" tabindex="0"/>
                    <input type="submit" value="${uiLabelMap.CommonAdd}" class="${styles.link_run_sys!} ${styles.action_add!}"/>
                </div>
            </form>
            <@script>
                document.getElementById('productId').focus();
            </@script>
        </#if>
    </#if>
<#elseif parameters.shipmentId?has_content>
  <@commonMsg type="error">${uiLabelMap.ProductShipmentNotFoundId}: [${shipmentId!}]</@commonMsg>
</#if>

</@section>
