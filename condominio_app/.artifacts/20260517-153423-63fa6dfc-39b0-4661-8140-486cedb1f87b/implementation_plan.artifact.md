# Modify Vigilante Section in All Profiles

The goal is to replace mock/dummy data with real data from the database (Supabase) in the "Vigilante en Turno" (Guard on Duty) section across all relevant screens.

## User Review Required

> [!IMPORTANT]
> - I will be replacing the `GuardModel` usage with `UserModel` in some places to maintain consistency with the database schema.
> - The "shift" information will be dynamically determined by the `shiftName` getter in `UserModel` (Matutino/Vespertino/Nocturno) unless a specific `shift` field is found in the database.

## Proposed Changes

### Data Layer

#### [user_service.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/data/services/user_service.dart)
- Add `getGuardOnDuty()` method to fetch the first user with `role == 'guard'` and `is_on_duty == true`.
- Add `getUserById(String userId)` to fetch a specific user.

#### [guard_provider.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/data/providers/guard_provider.dart)
- Remove `_mockGuard` and mock data.
- Update `_guard` type to `UserModel?`.
- Update `loadGuardData` to fetch real data using `UserService`.
- Add `guardOnDuty` fetcher that uses `UserService.getGuardOnDuty()`.

---

### UI Layer

#### [guard_on_duty_screen.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/presentation/screens/resident/guard_on_duty_screen.dart)
- Update to fetch the guard on duty from the provider when initialized.
- Update UI to use `UserModel` properties.
- Display a "No hay guardia en turno" message if none is found.
- Use `photoUrl` if available.

#### [guard_dashboard.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/presentation/screens/guard/guard_dashboard.dart)
- Ensure the shift info displayed comes from the real user data.

## Verification Plan

### Automated Tests
- I will check if there are existing tests, but since this is a UI/Data change in a Flutter app, I will mostly rely on manual verification via UI inspection and logs.

### Manual Verification
- **Resident Role**: Log in as a resident, go to "Vigilante en Turno", and verify it shows the guard currently marked as `is_on_duty` in the Supabase `profiles` table.
- **Guard Role**: Log in as a guard and verify the dashboard shows the correct name and shift.
- **Admin Role**: Change the "on duty" status of a guard in "Gestión de Perfiles" and verify that it updates in the Resident's "Vigilante en Turno" screen.
- **Logs**: Use `read_logcat` to verify database queries and data fetching.
