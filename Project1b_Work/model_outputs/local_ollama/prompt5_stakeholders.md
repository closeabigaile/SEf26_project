Model: Llama 3 8B (Ollama, local)
Runner: Satwi
Date: 2026-09-06
Prompt ID: 5 (Stakeholders)

Prompt used:
Our stakeholders so far: customer, staff, admin.

Our product is a WIC-focused grocery shopping assistant designed to help shoppers manage WIC-eligible grocery purchases. Users can identify grocery products through barcode scanning or manual UPC entry, view product and nutrition information, compare healthier alternatives, and add products to a basket while tracking benefit-category allowances. The system can also scan receipts using OCR to identify approved products, restore saved shopping sessions, show remaining benefit balances, distinguish benefit-covered quantities from shopper-paid quantities when appropriate, and generate a QR-code representation of the basket for checkout.

That list is lazy. Extend it. Consider: who pays, who profits, who is harmed, who is ignored, who regulates, who maintains this at 3 a.m., who gets sued when it fails, whose job changes because it exists.

For each new stakeholder: what they fear about our product, and one design decision that would win them over. Output as a table.

Hard constraint: we are four graduate students with one month to build AND test the next version of this product.

Model output:
| Stakeholder | What they fear about our product | One design decision that would win them over |
| --- | --- | --- |
| Customer | WIC program changes or limitations | Implement automatic notifications for WIC program updates and changes |
| Staff | Increased workload or new tasks | Integrate the app with existing WIC program management systems for streamlined data entry |
| Admin | Loss of control or oversight | Allow administrators to set custom WIC program rules and restrictions for specific users or stores |
| Merchant | Decreased sales or profitability | Offer in-app rewards or loyalty programs for merchants who participate in the WIC program |
| Parent | Child's access to unhealthy products | Implement a "healthy choices" feature that highlights nutritious products and provides recipes and meal planning ideas |
| Non-profit | Funding cuts or decreased support | Collaborate with non-profit organizations to integrate their services and resources into the app |
| Regulator | Lack of transparency or compliance | Provide detailed reporting and analytics for WIC program administrators and regulators |
| Lawyer | Liability or lawsuits | Develop a comprehensive user agreement and terms of service that clearly outline responsibilities and liabilities |
| IT | Security or infrastructure concerns | Implement robust security measures, such as encryption and access controls, to protect user data |
| Marketing | Limited reach or visibility | Develop a comprehensive marketing plan that targets WIC program participants and healthcare professionals |
| Store Manager | Inventory management or logistics issues | Integrate the app with existing point-of-sale systems and inventory management software |
| WIC Coordinator | Additional responsibilities or workload | Provide training and support for WIC coordinators to help them effectively use the app |
| Parent Organization | Funding or resource constraints | Offer discounts or promotions for parent organizations that promote the WIC program and the app |
| Data Analyst | Incomplete or inaccurate data | Ensure that the app collects and analyzes accurate and complete data, and provide regular reporting and analytics |
| Maintenance Engineer | Technical issues or downtime | Develop a robust maintenance and support system to minimize technical issues and downtime |

Initial Analysis Notes

- Ollama produced a broader raw count of stakeholders (15) than Terra, but many are generic corporate roles (IT, Marketing, Data Analyst, Maintenance Engineer) that are not clearly justified by the prompt's specific framing ("who pays, who is harmed, who maintains this at 3 a.m.").
- By contrast, Terra's stakeholder list was sharper and more specific to this product's actual risks — e.g., "OCR/AI service provider" (receipt-image privacy), "infants and children receiving WIC benefits," and "legal counsel/insurer" (liability if eligibility advice fails) — none of which Ollama identified.
- Ollama's "what they fear" and "design decision" columns are also more generic and less tied to the product's actual described features (OCR, QR checkout, benefit-category tracking) than Terra's, which repeatedly referenced specific product mechanics (e.g., QR output as "basket summary, not payment authorization").
- Overall: broader in raw count, but shallower in relevance and specificity compared to Terra's output.