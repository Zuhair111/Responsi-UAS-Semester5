-- Storage policies for stories in avatars bucket

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can upload stories" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view stories" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own stories" ON storage.objects;

-- Allow authenticated users to upload their own stories
CREATE POLICY "Users can upload stories"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = 'stories'
  AND auth.uid()::text = (storage.foldername(name))[2]
);

-- Allow anyone to view stories
CREATE POLICY "Anyone can view stories"
ON storage.objects FOR SELECT
TO public
USING (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = 'stories'
);

-- Allow users to delete their own stories
CREATE POLICY "Users can delete their own stories"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = 'stories'
  AND auth.uid()::text = (storage.foldername(name))[2]
);
