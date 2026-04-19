import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RoomImageApiService {
  Future<List<Map<String, dynamic>>> viewRoomImages() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_rooms_images.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print("View Room Images Error: $e");
      return [];
    }
  }

  Future<bool> addRoomImage({
    required String roomCategoryId,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://prakrutitech.xyz/jiya/insert_rooms_images.php"),
      );

      request.fields['room_category_id'] = roomCategoryId;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      print("Add Room Image Error: $e");
      return false;
    }
  }

  Future<bool> deleteRoomImage(String id) async {
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/delete_room_images.php"),
        body: {'id': id},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      print("Delete Room Image Error: $e");
      return false;
    }
  }
}
