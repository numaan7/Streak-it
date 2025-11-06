import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  print('🔍 Testing SharedPreferences persistence...\n');
  
  // Test 1: Write data
  print('Test 1: Writing test data...');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('test_key', 'test_value');
  print('✅ Write complete\n');
  
  // Test 2: Read data immediately
  print('Test 2: Reading data immediately...');
  final value1 = prefs.getString('test_key');
  print('Value: $value1');
  print(value1 == 'test_value' ? '✅ Immediate read SUCCESS' : '❌ Immediate read FAILED');
  print('');
  
  // Test 3: Read existing habits data
  print('Test 3: Checking existing habits data...');
  final habitsJson = prefs.getString('habits');
  if (habitsJson != null) {
    print('✅ Habits data exists');
    print('Length: ${habitsJson.length} characters');
    print('First 100 chars: ${habitsJson.substring(0, habitsJson.length > 100 ? 100 : habitsJson.length)}');
  } else {
    print('❌ No habits data found');
  }
  print('');
  
  // Test 4: List all keys
  print('Test 4: All keys in SharedPreferences:');
  final keys = prefs.getKeys();
  for (var key in keys) {
    print('  - $key');
  }
  print('');
  
  print('🏁 Test complete!');
}
