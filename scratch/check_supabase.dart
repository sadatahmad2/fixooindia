import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://dhvcetaohokhcvtjvymq.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRodmNldGFvaG9raGN2dGp2eW1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5Mjk3MzQsImV4cCI6MjA5MjUwNTczNH0.FM3mWB3_MOMrzfMC5pquUbCU0jVLD4aUJo3zDHcveZM',
  );

  try {
    print('Checking profiles table...');
    final response = await supabase.from('profiles').select().limit(1);
    print('Sample Profile Data: $response');
    
    if (response.isNotEmpty) {
      final keys = (response.first as Map).keys.toList();
      print('Available columns: $keys');
      if (keys.contains('membership_type')) {
        print('SUCCESS: membership_type column exists!');
      } else {
        print('ERROR: membership_type column is MISSING!');
      }
    } else {
      print('Profiles table is empty. Cannot verify columns easily via select.');
    }
  } catch (e) {
    print('Error checking Supabase: $e');
  }
}
