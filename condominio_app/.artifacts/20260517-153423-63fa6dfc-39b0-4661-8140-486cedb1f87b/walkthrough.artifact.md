# Walkthrough - Vigilante Section Update

I have updated the "Vigilante en Turno" (Guard on Duty) section across all profiles to use real data from the database instead of mock data.

## Changes Made

### Data Layer
- **UserService**: Added `getGuardOnDuty()` to fetch the active guard from Supabase and `getUserById()` for specific profile lookups.
- **GuardProvider**: Removed mock data ("Carlos López"). It now fetches real `UserModel` data from `UserService`.
- **UserModel**: Leveraged the `shiftName` getter to dynamically determine the shift based on the current time.

### UI Layer
- **GuardOnDutyScreen (Resident)**: Now shows a loading indicator while fetching the real guard on duty. It displays the guard's real name, dynamic shift, phone number, and photo (if available).
- **GuardDashboard (Guard)**: Displays the logged-in guard's real name and dynamic shift.
- **GuardProfiles**: Unified the data model to use `UserModel` everywhere.

### Cleanup
- Deleted the obsolete `guard_model.dart` as it was replaced by the more comprehensive `UserModel`.

## Verification Results

### Automated Checks
- Ran `analyze_file` on all modified files; no errors or warnings were found.

### Manual Verification
- Verified that the `GuardProvider` no longer contains hardcoded strings for the guard.
- Verified that `UserService` correctly queries the `profiles` table filtering by `role = 'guard'` and `is_on_duty = true`.
- Verified that the UI screens now handle null states (e.g., when no guard is on duty) gracefully.
