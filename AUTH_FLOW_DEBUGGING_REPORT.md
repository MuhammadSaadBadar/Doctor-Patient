# Authentication Flow Debugging Report

## Verified API Contract

The API specification defines these public endpoints:

- `POST /api/v1/auth/register/`: creates a patient account and sends a verification email. Success is `201`; the account cannot log in until email verification.
- `POST /api/v1/auth/verify-email/`: consumes the six-digit OTP. Success is `200`; codes expire after the configured period.
- `POST /api/v1/auth/resend-verification/`: requests a fresh verification email. It intentionally returns a generic `200` response and must not be treated as proof that an account exists.
- `POST /api/v1/auth/login/`: returns JWT tokens for verified accounts and blocks unverified patients.

Expected state transition:

`No account -> Created/unverified -> OTP verification -> Verified -> Login allowed`

## Root Cause

The current `AuthRepository.register` implementation had been corrupted by an inserted JSON-like text block inside the Dio exception branch. The method did not contain a valid complete request/response/error flow.

There was also a dangerous design issue in the attempted repair: automatic retry of the registration request after a timeout or connection error. Registration is a non-idempotent create operation. If the backend creates the account but the client loses the response, retrying sends a second create request and produces the observed sequence:

`Unknown/network error -> retry -> email already exists -> login blocked until verification`

The login message is therefore consistent with the backend state: the first registration likely created an unverified account, while the client failed to complete the OTP navigation.

The logs alone cannot prove whether the original request committed server-side, but the duplicate-email response followed by the unverified-login response is strong evidence of that state.

## Implemented Fixes

- Restored `AuthRepository.register` to one request with the documented payload and `201` success handling.
- Removed automatic registration retries to prevent duplicate create requests.
- Registration now throws the mapped `ApiException` instead of returning only `false`, preserving `detail` and field-level `errors`.
- `ApiErrorMapper` now treats a Dio exception as a network failure only when no response is attached. Response bodies are preserved when Dio reports a timeout/connection exception with an HTTP response.
- Signup displays backend validation details such as duplicate email and weak password errors.
- A genuine no-response failure is presented as `Registration status unknown`, and the user is routed to the existing OTP verification screen rather than being encouraged to retry registration blindly.
- Duplicate-email responses provide a `Verify email` recovery action.
- Login uses the same response-preserving distinction, so backend messages such as `Please verify your email before login.` are not masked.

## Remaining Limitation

The resend endpoint deliberately returns a generic success response and does not expose an account-existence check. Therefore the client cannot prove whether an unknown registration request committed. OTP verification is the safest available recovery path supported by the documented API.

## Validation

Editor diagnostics pass for the updated registration controller, authentication repository, and shared API error mapper. A Flutter CLI test/analyze run was not available in the terminal environment, so end-to-end network scenarios still require execution with Flutter and the backend available.
