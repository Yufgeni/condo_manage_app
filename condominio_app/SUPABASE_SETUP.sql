-- SQL Script for Condominio App - Visitor Tracking System Setup
-- Run this script in the Supabase SQL Editor.

-- 1. Table Schema Updates
ALTER TABLE public.visitors
ADD COLUMN IF NOT EXISTS guard_id uuid REFERENCES public.profiles(id),
ADD COLUMN IF NOT EXISTS id_image_url text,
ADD COLUMN IF NOT EXISTS comments text,
ADD COLUMN IF NOT EXISTS unit_number text,
ADD COLUMN IF NOT EXISTS car_model text;

ALTER TABLE public.visitors ALTER COLUMN entry_at SET DEFAULT timezone('utc'::text, now());

-- 2. Row Level Security (RLS) Policies
ALTER TABLE public.visitors ENABLE ROW LEVEL SECURITY;

-- Policy for INSERT (Guards and Admins)
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.visitors;
CREATE POLICY "Enable insert for authenticated users only"
ON public.visitors
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy for SELECT (History)
DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON public.visitors;
CREATE POLICY "Enable read access for all authenticated users"
ON public.visitors
FOR SELECT
TO authenticated
USING (true);

-- Policy for UPDATE (Mark Exit)
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.visitors;
CREATE POLICY "Enable update for authenticated users"
ON public.visitors
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 3. Trigger for Automatic User Deletion from Supabase Auth
CREATE OR REPLACE FUNCTION delete_user_from_auth()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM auth.users WHERE id = OLD.id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_delete_user_auth ON public.profiles;
CREATE TRIGGER trigger_delete_user_auth
AFTER DELETE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION delete_user_from_auth();

-- NOTE: Ensure you create a public bucket named 'visitor_ids' in Supabase Storage.
