# Implementation Plan - The "Masterpiece" Finale

This plan adds the final three high-end features to the Cyber Store: Wallet-based payments, Map-based delivery precision, and Smart Inventory management for product variants.

## User Review Required

> [!IMPORTANT]
> - **Google Maps**: Precise map delivery requires a **Google Maps API Key**. I will set up the code, but you will need to enable the Maps SDK in your Google Cloud Console.
> - **Inventory Shift**: We will move from simple "In Stock" booleans to real numbers per variant (e.g., specific stock for Red 128GB vs. Black 256GB).

## Proposed Changes

### 1. 💰 Pay with Wallet (The Reward Loop)
- **[MODIFY] Backend**: Update `orders` table to include `wallet_deduction`.
- **[MODIFY] Backend**: Update `OrderController` to check user balance and subtract the requested amount from the total.
- **[MODIFY] Frontend**: Add a "Use Wallet Balance" toggle in the Checkout Payment screen.
- **Impact**: Users can apply their referral earnings to reduce the final price of their order.

### 2. 📍 Precise Map-Based Delivery
- **[MODIFY] Backend**: Add `latitude` and `longitude` to the `addresses` table.
- **[MODIFY] Frontend**: Add `google_maps_flutter` package.
- **[NEW] Map Picker**: A new screen where users can drag a map and "Drop a Pin" to set their exact delivery location.
- **Impact**: Zero delivery errors and faster shipping.

### 3. 📉 Smart Inventory & Variant Stock
- **[NEW] Backend**: Create a `product_variants` table (`product_id`, `color`, `storage`, `price`, `stock`).
- **[MODIFY] Backend**: Update `Product` model to include a relationship to `variants`.
- **[MODIFY] Frontend**: Update Product Details to disable "Add to Cart" if a specific color/storage combination is out of stock.
- **[MODIFY] Admin**: Update Admin Form to allow setting stock numbers for each variant.

## Verification Plan

### Manual Verification
- **Wallet Test**: Refer a fake friend, earn 50 ETB, and verify that you can use that 50 ETB to lower the price of your next order.
- **Map Test**: Add a new address, use the map to pick a location in Addis, and verify the coordinates are saved in the database.
- **Inventory Test**: Set a product variant (e.g., Blue 128GB) to 0 stock as an Admin, then verify the customer cannot add that specific version to their cart.
