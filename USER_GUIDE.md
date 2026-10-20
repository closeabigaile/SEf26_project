# WolfBite user guide

WolfBite helps shoppers look up products in an imported North Carolina WIC
Authorized Product List (APL), organize a basket, compare available nutrition
information, and read checkout guidance. This guide describes the current
Project 2 application. For installation, start with [INSTALL.md](INSTALL.md).

The imported catalog, the app's demo allowances, and official WIC benefits
are different things. A catalog match is not a guarantee of payment at the
register. WolfBite is a class-project prototype; it does not connect to a
participant's official benefit account or process payments.

## Sign in and navigate

1. Launch the app using the installation guide. Authentication and catalog
   lookups need an internet connection and a working Firebase configuration.
2. Enter your **Email** and **Password**, then select **Sign In**. If you need
   an account, choose **Create account**, fill in the requested fields, and
   select **Sign Up**. The password must contain at least six characters.
3. Use the bottom navigation to move between **Scan**, **Cart**, and **Benefits**.
   The Cart tab opens the **My Basket** screen.
4. Use the logout icon when finished. Basket and allowance state is saved to
   your signed-in account. Signing out is not the same as clearing your basket.

## Look up a product and add it

1. Open **Scan** and enter the product's UPC in **UPC Code**, preserving leading
   zeros. Select **Check**. Manual entry is useful when camera scanning is
   unavailable; **Scan with Camera** requires camera access on your device.
2. Check the returned product name, UPC, and category against your product.
   If the app reports that the UPC was not found in the APL, check the digits.
   A missing match only describes the imported catalog; it does not establish
   an official eligibility decision.
3. Select **Add**, then open **Cart** to confirm the item and quantity.
   **Category limit reached** disables this Add button when the app's saved
   category allowance is exhausted.
4. Open **Benefits** to review the app's category usage and remaining amounts.
   These values describe demo allowances, not an official account balance.

For a concrete example, the repository's shopping-journey fixture includes
UPC `011110717894`. Enter it as twelve digits, including the initial zero.
Its availability in your running app depends on the catalog loaded into
Firebase. If it is absent, use a product confirmed in your team's current
catalog instead. The automated example uses a local test database, not a live
account; see [verification scope](#verification-scope).

## Manage your basket

- Use **+** and **−** on an item to adjust its quantity. Removing the last unit
  removes that line. Removing an allowance-covered unit releases its allocation.
  If the same UPC also has a PAID line, **−** removes those extra units first.
- Adding another unit with **+** after a category is full creates a separate
  **PAID** line. This differs from the disabled Add button on the Scan screen.
  PAID means the app expects you to pay for that item yourself; it does **not**
  mean a payment has happened.
- Select **Clear Cart**, then **Clear All**, to remove the basket and release
  its allowance allocations. **Cancel** leaves the basket unchanged.
- Select **Show Nutritional Info** on a basket item to read **Nutrition Facts**.
  Read the units and serving basis alongside each value. **Unknown** means
  missing information, not zero. Nutrition icons provide brief labels in
  their tooltips.

## Compare alternatives and basket nutrition

On the Scan result, **View … healthier alternatives** appears when alternatives
are available. Open it to compare the listed products and add a chosen option.
The word “healthier” reflects the app's comparison rules and available data;
it is not a personalized recommendation. No alternatives may be available for
a particular product.

For a basket-wide comparison:

1. In **Cart**, select **Check basket balance**.
2. Read the average nutrient values, example targets, and any missing-data
   messages. The sheet compares averages per serving, not a complete diet.
3. If suggested swaps appear, review the product names, before/after values,
   and listed tradeoffs. Previewing a suggestion does not change your basket.
4. Select **Not now** to dismiss a suggestion, or **Confirm swap** to apply it.
   Confirming replaces the selected product line, including its quantity,
   and recalculates the report. Review your basket afterward.

Suggestions depend on the products and nutrition records available to the app.
If loading fails, use **Retry**. An empty suggestion list does not mean all
products have complete nutrition data or that the basket meets personal goals.

## Get checkout help

Use **Get checkout help** on a basket item to read the app's explanation and
suggested next step. For example, a PAID line may be explained by a full saved
category allowance. When the evidence is incomplete, the app may be unable to
confirm the reason. Opening and closing help does not change your basket.

To explore the separate synthetic demonstrations, select the flask icon
(**Try sample checkout help**) in the My Basket toolbar. The **Sample basket**
contains example checkout scenarios. Open **Get checkout help** on a sample,
read the explanation, then select **Close**. These examples are not actual
retailer rejections or participant results and do not alter your own basket.

## Import product codes from a receipt image

1. From the Scan toolbar, select **Scan Receipt**, then **Select Image**.
2. Choose **Gallery / Upload** or **Camera**. This feature sends the selected
   image to OCR.space for text recognition, so use a sample receipt without
   personal details when demonstrating it.
3. Review the recognized catalog matches. The scanner looks for 12–14 digit
   codes and checks candidates against the imported APL. Receipts without
   printed product codes may produce no matches; OCR can also misread digits.
4. Select **Add … Items to Basket** to attempt to add the displayed matches.
   The confirmation reports how many were added; app allowance rules can limit
   additions. Review the resulting basket and quantities.

Repeated occurrences of the same UPC are combined into one recognized match;
the receipt workflow does not reconstruct purchased quantities. Use **Scan
Another Receipt** to try a different image, or return to Scan for manual entry.

## Show the basket QR code

From **Cart**, select **Ready to Checkout** to open **QR Code Checkout**.
The QR code contains the basket data. Retailer acceptance and payment
integration are not established by this prototype.

Select **Finish Transaction** only when you want to complete the app's demo
transaction: it clears the basket, retains the recorded allowance usage, and
returns to Scan. Viewing the QR code alone does not complete the transaction.
To abandon a basket and release its allocations, use **Clear Cart** instead.

## Troubleshooting

| What you see | What to try |
| --- | --- |
| Sign-in or catalog error | Check connectivity and the account details. For setup problems, see [Firebase setup](Project3/FIREBASE_SETUP.md). |
| Camera unavailable | Use manual UPC entry, or upload an existing receipt image. Check device/browser camera permissions. |
| Product not found | Preserve leading zeros, check the full code, and confirm that the product exists in the loaded catalog. |
| Add disabled or an extra PAID line | Review Benefits and basket quantities; the app may have reached its saved category limit. |
| Missing nutrition or no swaps | Review missing-data messages. Another product may have data; missing values are not zero. |
| Receipt produces no matches | Try a clearer image with printed product codes, or enter a UPC manually. |
| Unexpected state after signing back in | Review the saved basket and Benefits. The app resets usage and clears a carried-over basket when it detects a new month. |

For a reproducible problem, report the steps, platform, app commit, and observed
result through [GitHub Issues](https://github.com/closeabigaile/SEf26_project/issues).

## Verification scope

These instructions were checked against the current screen implementations
and [automated shopping journeys](Project3/test/e2e/shopping_journeys_e2e_test.dart).
Those tests use real widgets and repository product/nutrition fixtures with
fake Firebase services. They do not establish that a feature works against
every live catalog or on every device.

The [installation check](Project2_Work/installation/2026-10-19/README.md)
separately records a human live check of sign-in, product lookup, and adding to
the basket. Camera, receipt OCR, native platforms, and every workflow above
were not all covered by that live check. Teammates should record their final
feature verification separately before submission.
