import 'package:cloud_functions/cloud_functions.dart';

// Input a list of messages and user ID, returns AI response or recommendation.
Future<Map<String, dynamic>> recommendRestaurant(String userId, List<Map<String, dynamic>> messages) async {
  // Ensure each map in 'messages' has 'isUser' (bool) and 'text' (String) keys.
  // Example:
  // messages = [
  //   {'isUser': true, 'text': 'I want to eat noodles'},
  //   {'isUser': false, 'text': 'What type of noodles do you prefer?'},
  //   {'isUser': true, 'text': 'beef noodles'}
  // ];

  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('recommendRestaurant');
    final response = await callable.call({
      'userId': userId,
      'messages': messages,
    });
    final data = response.data as Map<String, dynamic>?; // Cast to nullable Map
    return data ?? {}; // Return empty map if data is null
  } catch (e) {
    print('Error calling recommendRestaurant flow: $e');
    // Consider how to handle errors more gracefully in the UI
    if (e is FirebaseFunctionsException) {
      print('FirebaseFunctionsException details: ${e.details}');
      print('FirebaseFunctionsException message: ${e.message}');
    }
    return {'error': e.toString()}; // Return an error object
  }
}