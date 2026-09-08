# Doctor Profile Image Upload & Display — Root Cause Analysis & Implementation Plan

---

## A. Root Cause Summary

The profile image upload succeeds at the API level (backend returns 200 with new `profile_picture_url`), but **the updated image never propagates to any screen** because:

### 1. **No Single Source of Truth for Doctor Profile Data**

Three **independent controllers** each maintain their own copy of doctor profile data:
| Controller | Data Source | Reactive Variable |
|------------|-------------|-------------------|
| `DoctorEditProfileController` | `DocEditProfileRepository.getProfile()` → `DoctorProfileResponse` | `profile.value` (Rx<DoctorProfileResponse?>) |
| `DoctorProfileController` | `DoctorProfileRepository.getUserProfile()` → `ProfileData` | `profileData.value` (Rx<ProfileData?>) |
| `DoctorDashboardController` | `DoctorProfileRepository.getUserProfile()` → `ProfileData` | `doctorName` (RxString) — name only |

**No controller shares state.** When `DoctorEditProfileController` uploads an image and updates its local `profile.value`, the other two controllers remain stale.

---

### 2. **Edit Profile Controller Updates Local State Only**

`DoctorEditProfileController.uploadAvatar()` (line 514):
```dart
final result = await _repository.uploadProfilePicture(bytes, fileName);
if (result != null) {
  _updateFormWithNewData(result);  // Updates ONLY controller.profile.value
  selectedImage.value = null;
}
```
It **never** calls:
- `DoctorProfileController.refreshProfile()`
- `DoctorDashboardController.refreshDashboard()`
- `AuthController.updateProfileImage()`

---

### 3. **Settings & Profile Screens Listen to Wrong Controller**

- `DoctorSettingsScreen` uses `DoctorProfileController` (`GetView<DoctorProfileController>`)
- `DoctorProfileScreen` uses `DoctorProfileController`
- `DoctorDashboardScreen` uses `DoctorDashboardController`
- `DoctorEditProfileScreen` uses `DoctorEditProfileController`

All three controllers fetch independently from API. No cross-controller notification.

---

### 4. **AuthController.currentUser Exists But Is Not Updated on Image Upload**

`AuthController.updateProfileImage()` was added (line 477) but **never called** after successful image upload in `DoctorEditProfileController`.

---

### 5. **Delete Button Conditional Logic Is Correct But Depends on Stale Data**

`DoctorSettingsScreen._buildAccountSection()` (line 242):
```dart
final hasProfilePicture =
    profile?.profilePictureUrl != null ||
    profile?.doctorProfile?.profilePictureUrl != null;

if (hasProfilePicture)
  SettingsTile(icon: 'delete', title: 'Delete Profile Picture', ...)
```
The condition is correct — it checks both `ProfileData.profilePictureUrl` (getter → `doctorProfile?.profilePictureUrl`) and `doctorProfile?.profilePictureUrl`. **The bug is that `profile` is stale** because `DoctorProfileController` wasn't refreshed after upload.

---

### 6. **Dashboard Shows Initials Instead of Avatar**

`DocDashboardScreen._buildWelcomeBanner()` (line 156) renders a **static decorative circle with `Icons.person_rounded`**, not `DoctorAvatar`. No image URL is passed.

---

### 7. **DoctorAvatar.reactive() Listens to AuthController But AuthController Is Never Updated**

`DoctorAvatar.reactive()` (line 88) correctly uses `Obx` to watch `Get.find<AuthController>().currentUser.value.profilePictureUrl`, but since `AuthController.updateProfileImage()` is never invoked, the reactive avatar never sees the new URL.

---

### 8. **API Response Structure**

Per `Mama Health API.yaml` (line 1099):
```yaml
POST /api/v1/accounts/me/doctor-profile/picture/
→ 200 OK → { "profile_picture_url": "https://.../accounts/doctors/4/profile-picture/" }
```
The upload endpoint returns **only the new URL** inside the full `DoctorProfile` object. `DocEditProfileRepository.uploadProfilePicture()` correctly parses this into `DoctorProfileResponse.doctorProfile.profilePictureUrl`.

---

## B. Flow Diagram

### Current (Broken) Flow
```
┌─────────────────────────────────────────────────────────────────┐
│ User picks image in Edit Profile Screen                         │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│ DoctorEditProfileController.uploadAvatar()                      │
│   → uploadProfilePicture(bytes) → API 200                       │
│   → _updateFormWithNewData(result) → updates LOCAL profile.value│
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
              ┌───────────┴───────────┐
              ▼                       ▼
┌─────────────────────┐   ┌─────────────────────────┐
│ DoctorProfileController    │ DoctorDashboardController  │
│ (UNCHANGED)               │ (UNCHANGED)                │
│ profileData.value stale   │ doctorName stale           │
└─────────────────────┘   └─────────────────────────┘
              │                       │
              ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│ Settings Screen → shows old image (or initials)                 │
│ Profile Screen  → shows old image (or initials)                 │
│ Dashboard       → shows static "Welcome Back, Dr. Name" + icon  │
└─────────────────────────────────────────────────────────────────┘
```

### Expected (Fixed) Flow
```
┌─────────────────────────────────────────────────────────────────┐
│ User picks image in Edit Profile Screen                         │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│ DoctorEditProfileController.uploadAvatar()                      │
│   → uploadProfilePicture(bytes) → API 200                       │
│   → _updateFormWithNewData(result)                              │
│   → AuthController.updateProfileImage(newUrl)  ← NEW            │
│   → DoctorProfileController.refreshProfile()  ← NEW             │
│   → DoctorDashboardController.refreshDashboard()  ← NEW         │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
              ┌───────────┴───────────┐
              ▼                       ▼
┌─────────────────────┐   ┌─────────────────────────┐
│ DoctorProfileController    │ DoctorDashboardController  │
│ profileData.value UPDATED  │ doctorName refreshed       │
└─────────────────────┘   └─────────────────────────┘
              │                       │
              ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│ Settings Screen → shows NEW image (DoctorAvatar.reactive)       │
│ Profile Screen  → shows NEW image (DoctorAvatar.reactive)       │
│ Dashboard       → shows NEW image (if avatar added)             │
└─────────────────────────────────────────────────────────────────┘
```

---

## C. Files Requiring Changes

| # | File | Change Type | Description |
|---|------|-------------|-------------|
| 1 | `lib/doctor/features/profile/controllers/doc_edit_profile_controller.dart` | **Modify** | After successful upload, call `AuthController.updateProfileImage()`, `DoctorProfileController.refreshProfile()`, `DoctorDashboardController.refreshDashboard()` |
| 2 | `lib/doctor/features/profile/controllers/doc_profile_controller.dart` | **Modify** | Ensure `refreshProfile()` properly fetches and emits updated `profileData` with new image URL |
| 3 | `lib/doctor/features/dashboard/controllers/doc_dashboard_controller.dart` | **Modify** | Add `refreshDashboard()` call trigger; optionally add avatar to welcome banner |
| 4 | `lib/doctor/features/auth/controllers/auth_controller.dart` | **Verify** | Confirm `updateProfileImage()` appends cache-busting timestamp (already done) |
| 5 | `lib/doctor/features/dashboard/screens/doc_dashboard_screen.dart` | **Modify** | Replace static avatar icon with `DoctorAvatar.reactive()` in welcome banner |
| 6 | `lib/doctor/features/settings/screens/doc_settings_screen.dart` | **Verify** | Confirm `DoctorAvatar.reactive()` used in profile summary card (already done) |
| 7 | `lib/doctor/features/profile/screens/doc_profile_screen.dart` | **Verify** | Confirm `DoctorAvatar.reactive()` used (already done) |
| 8 | `lib/doctor/features/profile/screens/doc_edit_profile_screen.dart` | **Verify** | Confirm avatar header uses local `selectedImage` during edit, then reactive after save |

---

## D. Phased Implementation Plan

### Phase 1 — Core Propagation Fix (Critical)

**Goal:** Make image upload update all doctor-side screens instantly.

#### 1.1 Update `DoctorEditProfileController.uploadAvatar()`
```dart
// In uploadAvatar(), after successful upload:
if (result != null) {
  _updateFormWithNewData(result);
  selectedImage.value = null;
  
  // NEW: Propagate to global and other controllers
  final newImageUrl = result.doctorProfile?.profilePictureUrl;
  if (newImageUrl != null && newImageUrl.isNotEmpty) {
    // Update global AuthController (triggers DoctorAvatar.reactive everywhere)
    Get.find<AuthController>().updateProfileImage(newImageUrl);
    
    // Refresh other doctor controllers so their local state syncs
    try {
      Get.find<DoctorProfileController>().refreshProfile();
    } catch (_) {}
    try {
      Get.find<DoctorDashboardController>().refreshDashboard();
    } catch (_) {}
  }
  
  Get.snackbar('Success', 'Profile picture updated', ...);
}
```
**Note:** Wrap `Get.find()` in try/catch because controllers may not be registered in all navigation flows.

#### 1.2 Verify `DoctorProfileController.refreshProfile()`
Already calls `loadProfile()` → `getUserProfile()` → fetches from `GET /api/v1/auth/me/` which includes `doctor_profile.profile_picture_url`. No change needed.

#### 1.3 Verify `DoctorDashboardController.refreshDashboard()`
Already calls `loadDashboardData()` → `_loadDoctorName()` → fetches from `GET /api/v1/auth/me/`. No change needed.

---

### Phase 2 — Dashboard Avatar Integration (High)

**Goal:** Show actual profile image in Dashboard welcome banner.

#### 2.1 Modify `DocDashboardScreen._buildWelcomeBanner()`
Replace static icon (lines 156–172) with `DoctorAvatar.reactive()`:
```dart
// Current: static decorative circle with Icons.person_rounded
// Replace with:
DoctorAvatar.reactive(
  size: 56,
),
```
This will listen to `AuthController.currentUser` and show the uploaded image (or initials fallback).

---

### Phase 3 — Delete Button & Consistency (Medium)

**Goal:** Ensure Delete Profile Picture button appears when image exists, and deletion works.

#### 3.1 Verify Delete Flow
- `DoctorSettingsScreen._showDeleteProfilePictureDialog()` → calls `controller.deleteProfilePicture()`
- `DoctorProfileController.deleteProfilePicture()` → calls repository `deleteProfilePicture()` → `DELETE /api/v1/accounts/me/doctor-profile/picture/`
- On success: calls `refreshProfile()` → re-fetches profile → `profilePictureUrl` becomes null
- `DoctorAvatar.reactive()` picks up null → shows initials ✅

**No code change needed** — the flow is correct. Just ensure `refreshProfile()` is called after delete (it is, line 395).

#### 3.2 Add Cache-Busting to Delete
In `AuthController`, add:
```dart
void clearProfileImage() {
  if (currentUser.value != null) {
    currentUser.value = currentUser.value!.copyWith(profilePictureUrl: null);
  }
}
```
Call this from `DoctorProfileController.deleteProfilePicture()` after successful API call:
```dart
Get.find<AuthController>().clearProfileImage();
```

---

### Phase 4 — Cross-App Consistency (Low)

**Goal:** Patient-facing screens show updated doctor images.

Currently, patient screens (`find_doctors_card`, `doctor_card`, `appointment_card`) use `DoctorAvatar` with `enableCacheBusting: true` but pass static `imageUrl` from doctor list API. They refresh on pull-to-refresh or navigation. **Acceptable for now** — full real-time sync would require WebSocket or polling.

---

### Phase 5 — Testing Checklist

| Test Case | Expected Result |
|-----------|-----------------|
| Upload image in Edit Profile → stay on screen | Avatar updates immediately |
| Upload image → navigate to Settings | Settings shows new image |
| Upload image → navigate to Profile | Profile shows new image |
| Upload image → navigate to Dashboard | Dashboard welcome banner shows new image |
| Upload image → navigate back to Edit Profile | Edit Profile shows new image (not initials) |
| Delete image in Settings → stay on screen | Avatar reverts to initials |
| Delete image → navigate to Edit Profile | Edit Profile shows initials |
| Delete image → navigate to Dashboard | Dashboard shows initials |
| Upload → close app → reopen | Image persists (cached by AuthController) |
| Network error during upload | Error snackbar, previous image remains |
| Upload large file (>5MB) | Validation error, no upload attempted |

---

## E. Implementation Priority

| Priority | Phase | Effort | Risk |
|----------|-------|--------|------|
| **P0** | Phase 1 (Core Propagation) | 30 min | Low |
| **P1** | Phase 2 (Dashboard Avatar) | 15 min | Low |
| **P2** | Phase 3 (Delete + Cache Clear) | 20 min | Low |
| **P3** | Phase 4 (Patient Screens) | Future | Medium |
| **P4** | Phase 5 (Testing) | 1 hour | — |

---

## F. Key Code Locations (Quick Reference)

| Logic | File | Line |
|-------|------|------|
| Edit Profile upload | `doc_edit_profile_controller.dart` | 514 |
| AuthController global state | `auth_controller.dart` | 98, 477 |
| Settings screen avatar | `doc_settings_screen.dart` | 181 |
| Profile screen avatar | `doc_profile_screen.dart` | (search `DoctorAvatar`) |
| Dashboard welcome banner | `doc_dashboard_screen.dart` | 156 |
| Delete image dialog | `doc_settings_screen.dart` | 581 |
| Delete API call | `doc_profile_controller.dart` | 388 |
| DoctorAvatar.reactive | `doctor_avatar.dart` | 30 |

---

## G. Summary

**The fix is minimal and surgical:**
1. **3 lines** in `DoctorEditProfileController.uploadAvatar()` to notify `AuthController`, `DoctorProfileController`, `DoctorDashboardController`
2. **1 widget swap** in `DocDashboardScreen` to use reactive avatar
3. **1 line** in `DoctorProfileController.deleteProfilePicture()` to clear global image

**No architectural changes, no new controllers, no breaking changes.** Leverages existing GetX reactive pattern and `AuthController.currentUser` as the single source of truth.