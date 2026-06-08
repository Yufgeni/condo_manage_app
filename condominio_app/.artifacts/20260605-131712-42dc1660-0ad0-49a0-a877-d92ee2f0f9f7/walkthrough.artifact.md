# Walkthrough - Bug Fix: User Already Exists & Profile Management

I have addressed the issue where creating a new 'Vigilante' (Guard) profile would fail silently with a generic error when the email was already registered.

## 1. Clear Error Identification
The error `user_already_exists` in Supabase Auth means that the email address provided is already linked to an account in the system (perhaps as a Resident or an Admin).

- **Improvement**: I updated the `AdminProvider` and `UserService` to capture this specific error. Now, instead of a generic "Error", the administrator will see:
  > "El correo electrónico ya está registrado en el sistema. Si desea cambiar el rol de este usuario, use la pestaña 'Modificar perfil'."

## 2. Profile Management Logic
- **Prevention**: This change prevents administrators from creating duplicate accounts for the same person and encourages them to use the **Modify Profile** tab to assign the 'Vigilante' role to existing users.
- **Consistency**: Verified that the "Modify Profile" tab correctly lists all users from the `profiles` table, including Admins and Residents, allowing their roles to be changed to 'Vigilante' if needed.

## 3. Support for Admins Living in the Condo
Confirmed that Administrators who live in the condo are correctly treated as residents for financial purposes:
- **Finance Integration**: They appear in the resident selection list for manual payments.
- **Payment History**: Their payments are correctly registered and linked to their profile, just like any other resident.

## Verification Summary
- **Error Handling**: The app now explicitly tells the user when an email is already taken.
- **Database Consistency**: The role modification logic works as intended, ensuring that one email corresponds to exactly one profile with one or more roles (modeled as a single role field in this version).
- **Admin-Resident Mapping**: Confirmed that the `lives_in_condo` flag in the `profiles` table and the corresponding entry in the `residents` table are correctly handled for Admin profiles.
