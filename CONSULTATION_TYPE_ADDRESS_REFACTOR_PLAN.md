# Conditional In-Person Location Display — Refactor Plan

## Executive Summary

Refactor the **Book Appointment** and **Appointment Details** screens to conditionally render a formatted text address card (instead of any map widget) when the appointment type is **In-Person**. This reduces plugin overhead (no `google_maps_flutter` / `flutter_map` in the booking flow), improves readability, and ensures consistent location presentation across the appointment lifecycle.

---

## 1. Current State Audit

| Screen | Current Location Handling | Appointment Type Evaluation |
|--------|---------------------------|-----------------------------|
| **Book Appointment** (`book_appointment_screen.dart`) | No location UI at all. Only doctor name/specialty/rating in `BookingDoctorCard`. | `selectedType` observable (`'in_person' \| 'video_consultation'`). Reactive via `Obx`. |
| **Appointment Details** (`appointment_detail_screen.dart`) | No location section. Only type icon/label in doctor header (`appointment.typeIcon` / `appointment.typeLabel`). | Derived from `appointment.appointmentType` (`'in_person' \| 'video_consultation'`). |

**Doctor Address Data Available** (`DoctorProfile`):
- `area` — e.g., "DHA Phase 5" (nullable)
- `city` — e.g., "Karachi" (nullable)
- `latitude` / `longitude` — raw coordinates (nullable)
- **Missing**: clinic/hospital name, street address, floor/suite, zip code

**Existing Widget**: `DoctorLocationCard` (`lib/patient/features/doctors/widgets/doctor_location_card.dart`) — renders area + city + distance. Reusable base for the new address card.

**No map widgets exist in either screen today** — the refactor is **additive** (add text card for in-person) rather than replacement.

---

## 2. Backend & Data Model Alignment (API Verification)

| Endpoint | Method | Address Fields in Response | Status |
|----------|--------|----------------------------|--------|
| `/api/v1/doctors/{id}/` (Doctor Detail) | GET | `doctor_profile: { area, city, latitude, longitude, ... }` | ✅ **Verified** — maps to `DoctorProfile.area/city/lat/lng` |
| `/api/v1/appointments/{id}/` (Appointment Detail) | GET | Returns `appointment_type`, `doctor` (brief), `meeting_link`. **Does NOT include full doctor profile with address.** | ⚠️ **Gap** — need to enrich appointment detail with doctor's `area`/`city` or fetch separately |
| `POST /api/v1/appointments/` (Book Appointment) | POST | Payload: `doctor_id`, `appointment_type`, `scheduled_at`, `duration_minutes`, `reason?` | ✅ **Verified** — type sent correctly |

**Finding**: Appointment Detail API does **not** return the doctor's `area`/`city`. Two options:
1. **Enrich** `Appointment.fromJson` by joining with a cached `Doctor` (requires `DoctorRepository.getDoctorById` call in `AppointmentDetailController.loadAppointment`).
2. **Extend backend** to include `doctor_profile` (or `area`/`city`) in appointment detail response. — *Preferred but backend change.*

**Decision for this refactor**: Use Option 1 (client-side enrichment) to unblock UI. File a backend ticket for Option 2.

---

## 3. Target Screen & Component Analysis

### 3.1 Book Appointment Screen — `book_appointment_screen.dart`

**Insertion Point**: After `_buildTypeSelection` (line 179) and before `_buildDateSelection` (line 184).

**Behavior**:
- When `selectedType == 'in_person'` → render **DoctorAddressCard** with doctor's `area` + `city` (from `controller.doctor.value.doctorProfile`).
- When `selectedType == 'video_consultation'` → render nothing (or future: meeting link preview).
- Must be reactive (`Obx`) to toggle instantly on type change.

**Proposed Card Content**:
```
┌─────────────────────────────────────┐
│ 📍  Practice Location                │
├─────────────────────────────────────┤
│ [Facility Name]        ← if available (future)  │
│ [Area], [City]         ← e.g., "DHA Phase 5, Karachi" │
│ [Copy] [Navigate]        ← optional actions     │
└─────────────────────────────────────┘
```

### 3.2 Appointment Details Screen — `appointment_detail_screen.dart`

**Insertion Point**: In `_buildDetailsSection` (after Duration row, before Reason row — around line 279).

**Behavior**:
- If `appointment.appointmentType == 'in_person'` → render **DoctorAddressCard** using enriched `area`/`city`.
- If `appointment.appointmentType == 'video_consultation'` → render meeting link row (already exists via `meetingLink` getter; currently unused in UI).
- Suppress any future map widget entirely for in-person.

**Proposed Card Content** (same as booking, plus):
- "Address details will be shared upon confirmation" fallback if `area`/`city` both null.

---

## 4. Edge Case & Failure Analysis

| Scenario | Handling |
|----------|----------|
| **Null `area` & `city`** (in-person doctor) | Show fallback: `"Address details will be shared upon confirmation"` in muted text. |
| **Only `area` present** | Render `"Area, City not specified"` — avoid trailing comma. |
| **Only `city` present** | Render `"City"` — no leading comma. |
| **Exceptionally long address** | Use `Flexible`/`Expanded` wrapping; `TextOverflow.ellipsis` on single-line labels; allow multi-line for address body. |
| **Type switch (booking)** | `Obx` on `controller.selectedType` → instant toggle, no reload. |
| **Type switch (details)** | Not applicable — type is fixed per appointment. |
| **Localization** | Address concatenation via helper: `formatAddress({area, city})` → handles missing parts cleanly. |
| **External navigation** | "Open in Maps" button → `url_launcher` with `geo:` or `https://maps.google.com/?q=` using `lat/lng` if available, else `area+city` query. |
| **Copy address** | `Clipboard.setData` with formatted string. |

---

## 5. Files Requiring Modification

| File | Responsibility | Required Change | Priority |
|------|----------------|-----------------|----------|
| `lib/patient/features/appointments/screens/book_appointment_screen.dart` | Booking UI flow | Insert conditional `DoctorAddressCard` after type selection; bind to `controller.selectedType`. | 🔴 High |
| `lib/patient/features/appointments/controllers/book_appointment_controller.dart` | Selection state | Add `formattedClinicAddress` getter (computed from `doctor.value.doctorProfile`). | 🔴 High |
| `lib/patient/features/appointments/screens/appointment_detail_screen.dart` | Details UI flow | Insert conditional `DoctorAddressCard` in `_buildDetailsSection` for in-person type. | 🔴 High |
| `lib/patient/features/appointments/controllers/appointment_detail_controller.dart` | Detail data loading | Enrich appointment with doctor's `area`/`city` via `DoctorRepository.getDoctorById` in `loadAppointment`. Add `clinicAddress` getter. | 🔴 High |
| `lib/patient/features/doctors/widgets/doctor_location_card.dart` | Reusable location widget | **Rename → `DoctorAddressCard`**, generalize to accept `area`, `city`, `facilityName?`, `latitude?`, `longitude?`, `onCopy`, `onNavigate`. Make fully self-contained. | 🟠 Medium |
| `lib/patient/features/doctors/models/doctor_profile.dart` | Data model | Add `formattedAddress` getter (clean concatenation). Add `hasAddress` boolean. | 🟠 Medium |
| `lib/patient/features/appointments/widgets/booking_doctor_card.dart` | (Optional) | If facility name exists on doctor profile, show it here too for consistency. | 🟢 Low |

---

## 6. Prioritized Implementation Plan

### Phase 1 — Data & Model Verification (1–2 hrs)
1. Verify `DoctorProfile.area`/`city` population from Doctor Detail API (`doctor_repository.dart`).
2. Add `formattedAddress` + `hasAddress` getters to `DoctorProfile`.
3. Update `AppointmentDetailController.loadAppointment` to fetch full `Doctor` (for `doctorProfile`) when `appointmentType == 'in_person'`. Cache to avoid double-fetch.
4. Add `clinicAddress` computed getter to `AppointmentDetailController`.

### Phase 2 — Reusable Address Text Widget (2–3 hrs)
1. Rename `DoctorLocationCard` → `DoctorAddressCard` (new file or in-place).
2. Props: `area`, `city`, `facilityName?`, `latitude?`, `longitude?`, `onCopy`, `onNavigate`, `fallbackText?`.
3. Layout: `Column` with `CrossAxisAlignment.start`, `Flexible` on text children, `Row` for action icons (copy, navigate).
4. Styling: match existing card theme (`surfaceContainerLowest`, rounded 16, subtle shadow).
5. Unit test address formatting helper with null/empty combos.

### Phase 3 — Book Appointment Screen Integration (1–2 hrs)
1. In `BookAppointmentController`: add `String get formattedClinicAddress` using `doctor.value.doctorProfile?.formattedAddress`.
2. In `book_appointment_screen.dart`: after `_buildTypeSelection`, add:
   ```dart
   Obx(() => controller.selectedType.value == 'in_person'
       ? DoctorAddressCard(
           area: controller.doctor.value?.doctorProfile?.area,
           city: controller.doctor.value?.doctorProfile?.city,
           latitude: controller.doctor.value?.doctorProfile?.latitude,
           longitude: controller.doctor.value?.doctorProfile?.longitude,
         )
       : const SizedBox.shrink());
   ```
3. Verify reactive toggle on type change (no rebuild needed beyond `Obx`).

### Phase 4 — Appointment Details Screen Integration (1–2 hrs)
1. In `AppointmentDetailController`: after `loadAppointment`, if `appointmentType == 'in_person'`, call `_doctorRepository.getDoctorById(appointment.doctor.id)` to get `doctorProfile`. Store in `Rx<DoctorProfile?>`.
2. Add `clinicAddress` getter returning `doctorProfile?.formattedAddress ?? fallback`.
3. In `appointment_detail_screen.dart`: in `_buildDetailsSection`, after Duration row, add conditional `DoctorAddressCard` using controller's `clinicAddress` and lat/lng.
4. For video consultations: add meeting link row (reuse `_buildDetailRow` with `Icons.video_call_rounded`).

### Phase 5 — QA & Polish (1 hr)
- Test on mobile (iOS/Android) and desktop: text wrapping, overflow, theme light/dark.
- Verify copy/navigate actions work.
- Confirm no map assets bundled (bundle size check).

---

## 7. Strict Constraints (Non-Negotiable)

- ❌ **No map widget imports** (`google_maps_flutter`, `flutter_map`, `mapbox_maps_flutter`) in either screen.
- ❌ **No code changes** during planning phase.
- ✅ **Preserve GetX**: `Obx`, `Rx`, computed getters, controller separation.
- ✅ **Visual consistency**: reuse `colorScheme`, `textScale`, card decoration patterns from existing screens.
- ✅ **Accessibility**: semantic labels on action buttons; address text selectable.
- ✅ **Performance**: `const` constructors where possible; `ListView` not needed (single card).

---

## 8. Acceptance Criteria

| Criterion | Verification |
|-----------|--------------|
| In-person booking shows address card | Toggle to "In-Person Visit" → card appears instantly |
| Video booking hides address card | Toggle to "Video Consultation" → card disappears instantly |
| Appointment details (in-person) shows address | Open confirmed in-person appt → address card in details section |
| Appointment details (video) shows meeting link | Open video appt → meeting link row (no address) |
| Null address shows fallback | Doctor with no area/city → "Address details will be shared..." |
| Long address wraps cleanly | Resize window / small phone → no overflow |
| Copy/Navigate actions functional | Tap → clipboard / external maps app opens |

---

## 9. Future Enhancements (Out of Scope)

- Facility/clinic name field on `DoctorProfile` (backend + model).
- Multiple practice locations per doctor (list picker in booking).
- Static map image (Google Static Maps API) as *optional* visual aid — **only if product requests**, never as default.
- Calendar integration with location pre-fill.

---

## 10. Estimated Effort

| Phase | Hours |
|-------|-------|
| 1. Data & Model | 1.5 |
| 2. Reusable Widget | 2.5 |
| 3. Booking Integration | 1.5 |
| 4. Details Integration | 1.5 |
| 5. QA | 1 |
| **Total** | **~8 hrs** |

---

## 11. Approval Gate

**Plan approved by**: _______________  
**Date**: _______________  
**Implementation start**: Upon approval.

---

*End of Refactor Plan*