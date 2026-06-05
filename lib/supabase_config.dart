/// Supabase project credentials.
/// Project URL: Settings → API → Project URL
/// Anon key: Settings → API → anon public
class SupabaseConfig {
  static const String url = 'https://socqwbntqjssociflrhz.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvY3F3Ym50cWpzc29jaWZscmh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MDY4NzIsImV4cCI6MjA5NjE4Mjg3Mn0.DksDHHCQBj63UMJ2j8dO_bYHCnHvTFBIHiSkkcokjj4';

  /// Must match your Storage bucket name in Supabase dashboard.
  static const String storageBucket = 'voice';
}
