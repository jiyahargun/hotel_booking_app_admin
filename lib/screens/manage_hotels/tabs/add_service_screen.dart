import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddServiceScreen extends StatefulWidget {
  final String hotelName;

  const AddServiceScreen({super.key, required this.hotelName});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  List services = [];
  Set selected = {};
  bool isLoading = true;
  String? hotelId;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      print(" Getting Hotel ID...");

      hotelId = await getHotelId();

      print("Hotel ID: $hotelId");

      await fetchServices();
    } catch (e) {
      print(" INIT ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Future<String?> getHotelId() async {
    var res = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
    );

    print("HOTEL API: ${res.body}");

    var data = jsonDecode(res.body);

    if (data['status'] == true) {
      for (var h in data['data']) {
        if (h['hotel_name'].toString().toLowerCase().trim() ==
            widget.hotelName.toLowerCase().trim()) {
          return h['id'].toString();
        }
      }
    }

    return null;
  }

  Future<void> fetchServices() async {
    try {
      var res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_service.php"),
      );

      print("SERVICES API: ${res.body}");

      var data = jsonDecode(res.body);

      if (data['status'] == true) {
        services = data['data'];
      }
    } catch (e) {
      print(" SERVICE ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> add(String serviceId) async {
    if (hotelId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hotel ID not found")));
      return;
    }

    var res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/insert_hotel_service.php"),
      body: {"hotel_id": hotelId!, "service_id": serviceId},
    );

    var data = jsonDecode(res.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));
  }

  Future<void> save() async {
    for (var id in selected) {
      await add(id.toString());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Services")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotelId == null
          ? const Center(child: Text(" Hotel not found"))
          : services.isEmpty
          ? const Center(child: Text("No Services Found"))
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                var item = services[index];

                return CheckboxListTile(
                  title: Text(item['service_name']),
                  value: selected.contains(item['id']),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selected.add(item['id']);
                      } else {
                        selected.remove(item['id']);
                      }
                    });
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: save,
        child: const Icon(Icons.check),
      ),
    );
  }
}
