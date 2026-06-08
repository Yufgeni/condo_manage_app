# Implementation Plan - Visitor Tracking System (Refined)

Develop a robust visitor tracking system focusing on entry/exit management, photo capture, and multi-role history consultation.

## User Review Required

- **Supabase Storage**: A bucket named `visitor_ids` must be created manually in Supabase.
- **RLS Policies**: I will provide the SQL to update the table, but you might need to adjust RLS policies if you have strict security enabled.
- **WhatsApp**: Uses `url_launcher`. Ensure the number is in international format if possible.

## 1. Database & Supabase Setup

### SQL Update Script
Run this in the Supabase SQL Editor:

```sql
-- 1. Add new columns to visitors table
ALTER TABLE public.visitors
ADD COLUMN guard_id uuid REFERENCES public.profiles(id),
ADD COLUMN id_image_url text,
ADD COLUMN comments text,
ADD COLUMN unit_number text,
ADD COLUMN car_model text;

-- 2. Rename 'date' to 'entry_at' if your current schema uses 'date'
-- (The provided schema already uses 'entry_at', so this is just a check)

-- 3. Ensure exit_at exists (it was in your provided schema)
-- ALTER TABLE public.visitors ADD COLUMN exit_at timestamp with time zone;

-- 4. Set default for entry_at if not present
ALTER TABLE public.visitors ALTER COLUMN entry_at SET DEFAULT timezone('utc'::text, now());
```

### Supabase UI Steps:
1.  **SQL Editor**: Copy and run the script above.
2.  **Storage**:
    *   Create a new bucket called `visitor_ids`.
    *   Set it to **Public** (or configure appropriate RLS so Admin/Guard can read/write).
3.  **Authentication/Profiles**: Ensure the `guard` role is correctly assigned to your guard users in the `profiles` table.

## 2. Updated Process Logic

### Guard: Entry & Exit Management
- **Registration**: Guard creates a record. `entry_at` is set automatically. `exit_at` remains NULL.
- **Active Visits**: A new view for Guards will show a list of "Visitantes en el Condominio" (where `exit_at` IS NULL).
- **Marking Exit**: When a visitor leaves, the Guard finds them in this list and taps "Registrar Salida". This updates `exit_at` to `now()`.

### Resident: Global History
- Residents can now see **all** visits to the condominium.
- Filters by date range.
- **Privacy**: The ID photo is hidden for this role.

### Admin: Global History + Photo
- Same as Resident, but with a "View ID" button.
- "Share via WhatsApp" functionality for the ID photo link.

## Proposed Changes (Code)

### [visitor_model.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/data/models/visitor_model.dart)
- Include all new fields and helper for `isActive` (entry but no exit).

### [visitor_service.dart](file:///C:/Users/ovvid/Desktop/App_Acacias/condo_manage_app/condominio_app/lib/data/services/visitor_service.dart)
- `getActiveVisitors()`: Query `exit_at.is.null`.
- `markExit(id)`: Update `exit_at`.
- `getGlobalHistory(startDate, endDate)`: Query with date range.

### UI Screens
- **Guard**: `GuardVisitorRegistrationScreen` and `ActiveVisitorsScreen`.
- **Resident/Admin**: Shared `VisitorHistoryScreen` with conditional rendering for the photo and WhatsApp button based on user role.

---

## Verification Plan

### Manual Verification
1.  **Full Flow**: Register visitor -> Check Resident history -> Check Admin history (view photo) -> Mark Exit (Guard) -> Check history shows exit time.
2.  **Date Filtering**: Verify date range correctly limits results.
3.  **Role Permissions**: Confirm Resident CANNOT see the photo button, while Admin CAN.
