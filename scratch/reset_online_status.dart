import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fixoo/config/supabase_config.dart';

void main() async {
  final client = SupabaseClient(SupabaseConfig.supabaseUrl, SupabaseConfig.supabaseAnonKey);
  
  print('Setting all users to offline...');
  try {
    await client.from('profiles').update({'is_online': false}).neq('id', '00000000-0000-0000-0000-000000000000');
    print('SUCCESS: All users set to offline.');
  } catch (e) {
    print('ERROR: $e');
  }
}
