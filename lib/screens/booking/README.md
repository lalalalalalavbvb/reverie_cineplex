# Person 2: Booking + Admin Frontend

Run `flutter run`. The app starts on person 1's Home page. Select a movie, then choose **เลือกรอบฉาย / จองตั๋ว** to enter person 2's booking flow. Open **โปรไฟล์ → แอดมิน (ตัวอย่าง)** for Admin. Previewed tickets appear in **ตั๋วของฉัน** for the current session. At the QR screen, choose **ดูตั๋วตัวอย่าง** to preview the current booking's ticket without pretending a payment succeeded.

## Files

- `booking_flow.dart`: owns shared booking state, navigation, theme and shared widgets.
- `showtime_page.dart`: cinema search, favorites, dates and showtimes.
- `seat_page.dart`: seat map, price calculation and phone validation.
- `food_page.dart`: concessions and quantities.
- `summary_page.dart`: booking summary and optional email.
- `payment_page.dart`: payment method UI.
- `qr_payment_page.dart`: countdown and non-payable QR placeholder.
- `ticket_page.dart`: standalone `TicketPage(booking: BookingModel(...))`.
- `../admin/admin_page.dart`: standalone `AdminPage(service: BookingService)`.
- `../../models/booking_model.dart`: booking display data and demo admin item contract.
- `../../services/booking_service.dart`: injectable service interface and in-memory demo implementation.

The six booking page builders are Dart `part` files sharing one state owner. Import `booking_flow.dart` to open the flow; don't import its part files directly. Ticket and Admin are independent widgets.

## Admin preview

Supports searching, adding, editing and deleting demo showtimes and food, required-field/price validation, deletion confirmation, and inspecting a sample booking's ticket. Records persist only while this app instance's booking flow is alive. Admin edits intentionally use a separate sample catalog and do not update the booking flow's fixed reference data. There is no role enforcement or production login in this preview.

## Handoff to person 3

Implement `BookingService` with the team's API and inject it into `AdminPage`. Its mutation methods are asynchronous; the UI disables mutations while saving and displays failures. Supply refreshed item/booking lists and notify listeners when data changes. Showtimes currently use a free-text display description; agree structured cinema/theater/date/time fields with the backend before integration.

Replace the fixed booking catalog and seat availability with backend results. The backend must provide seat locks, authoritative prices, booking IDs, verified payment status, ticket payloads and admin authorization. Never treat the sample ticket button or countdown as payment verification. `TicketPage` deliberately remains marked as a sample until that integration is completed.

Person 1's Home/Movie/Profile pages are connected through `screens/app_shell.dart`. Without `TMDB_API_KEY`, the movie service returns an explicitly labeled demo catalog. To use TMDB, run `flutter run --dart-define=TMDB_API_KEY=YOUR_KEY`. API failures with a configured key remain visible as errors; they do not silently become demo results.

## Assets and validation

Bundled reference screenshots supply photographic regions through `ReferenceRegion`; controls are native Flutter widgets. Replace these screenshots with original poster/product assets for production.

Run `flutter analyze` and `flutter test`. Tests cover booking totals through ticket preview and the Admin create/edit/delete workflow.

## Local TMDB setup

The private key is in `config/tmdb.local.json`, excluded by `.gitignore`. Run `flutter run --dart-define-from-file=config/tmdb.local.json`, or choose **Reverie Cineplex — TMDB** in VS Code Run and Debug. Running without this option uses the demo catalog. Do not add the local config to Git.
