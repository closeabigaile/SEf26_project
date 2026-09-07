Model: Llama 3 8B (Ollama, local)
Runner: Satwi
Date: 2026-09-06
Prompt ID: 2 (Mine the Complaints)

Prompt used:
Below are real user complaints about products like ours: top issues from their trackers, review excerpts, forum posts.

Product: WIC2Go
Complaint: Users report recurring login failures, "user not found" errors, and having to re-register with different email addresses.
Source: Apple App Store reviews

Product: WIC2Go
Complaint: Users report barcode scans saying products are not WIC-approved even when they actually are.
Source: Apple App Store reviews

Product: WIC Connect (Michigan)
Complaint: Users report frequent login failures and unreliable app behavior.
Source: Google Play reviews

Product: WIC Connect (Michigan)
Complaint: Users report products being marked approved by the app but denied at checkout.
Source: Google Play reviews

Product: WICShopper
Complaint: Users report benefits or balances displaying incorrectly at the beginning of the month until the card is used.
Source: Apple App Store reviews

Product: Indiana WIC
Complaint: Users report the scanner failing to read barcodes or incorrectly marking covered products as ineligible.
Source: Apple App Store reviews

Cluster these complaints into themes. Rank the themes by frequency times severity. For each theme: quote one complaint verbatim as evidence, and say whether any current product has fixed it. The unfixed themes are our opportunity list.

Hard constraint: we are four graduate students with one month to build AND test this new thing.

Model output:
After clustering the complaints, I've identified the following themes:

Theme 1: Login and Registration Issues (Frequency: 3, Severity: 7)
Complaint: "I've been having issues logging in. It says 'user not found' every time I try to access my account. I've tried resetting my password and re-registering with a different email address, but nothing works." (Source: Apple App Store reviews for WIC2Go)
Status: Not fixed by any current product.

Theme 2: Barcode Scanning Errors (Frequency: 2, Severity: 6)
Complaint: "The app says a product is not WIC-approved when it actually is. I've tried scanning it multiple times, but the result is the same." (Source: Apple App Store reviews for WIC2Go)
Status: Not fixed by any current product.

Theme 3: Benefits and Balances Display Issues (Frequency: 1, Severity: 5)
Complaint: "The app shows my benefits and balances incorrectly at the beginning of the month. It only corrects itself after I use my WIC card for the first time. It's really frustrating." (Source: Apple App Store reviews for WICShopper)
Status: Not fixed by any current product.

Theme 4: Scanner Issues (Frequency: 1, Severity: 4)
Complaint: "The scanner fails to read barcodes or incorrectly marks covered products as ineligible. It's really inconvenient when I'm trying to shop with my WIC benefits." (Source: Apple App Store reviews for Indiana WIC)
Status: Not fixed by any current product.

Theme 5: Unreliable App Behavior (Frequency: 2, Severity: 3)
Complaint: "The app is really unreliable. It freezes, crashes, or doesn't load properly. I've tried restarting my phone, but nothing works." (Source: Google Play reviews for WIC Connect (Michigan))
Status: Some current products (e.g., WIC Connect) have fixed this issue, but it's still a problem for other products.

Ranking by frequency times severity:
1. Theme 1: Login and Registration Issues (Frequency: 3, Severity: 7)
2. Theme 2: Barcode Scanning Errors (Frequency: 2, Severity: 6)
3. Theme 5: Unreliable App Behavior (Frequency: 2, Severity: 3)
4. Theme 4: Scanner Issues (Frequency: 1, Severity: 4)
5. Theme 3: Benefits and Balances Display Issues (Frequency: 1, Severity: 5)

The unfixed themes (Themes 1, 2, and 4) are our opportunity list.

Initial Analysis Notes

- The prompt explicitly required quoting complaints "verbatim," but Ollama's "quotes" (e.g., "I've been having issues logging in. It says 'user not found' every time...") are paraphrased, first-person narratives invented by the model — not verbatim excerpts from the one-line complaint data actually provided. This is a real, documentable violation of the prompt's explicit instruction.
- Theme 5 states "Some current products (e.g., WIC Connect) have fixed this issue," but the source complaint data was specifically about WIC Connect exhibiting unreliable behavior — the model's claim directly contradicts the input it was given, a logical inconsistency worth flagging.
- Despite these issues, the thematic clustering itself (login/registration, barcode accuracy, balance display, scanner reliability, general app stability) is reasonable and roughly matches the actual complaint categories provided.