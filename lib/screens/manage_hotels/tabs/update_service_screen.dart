import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateServiceScreen extends StatefulWidget {
  final String hotelName;

  const UpdateServiceScreen({super.key, required this.hotelName});

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  List hotelServices = [];
  List allServices = [];

  String? hotelId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    hotelId = await getHotelId();
    await fetchHotelServices();
    await fetchAllServices();
    setState(() => isLoading = false);
  }

  Future<String?> getHotelId() async {
    var res = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
    );

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

  Future<void> fetchHotelServices() async {
    var res = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_hotel_service.php"),
    );

    var data = jsonDecode(res.body);

    if (data['status'] == true) {
      hotelServices = data['data']
          .where(
            (e) =>
                e['hotel_name'].toString().toLowerCase().trim() ==
                widget.hotelName.toLowerCase().trim(),
          )
          .toList();
    }
  }

  Future<void> fetchAllServices() async {
    var res = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_service.php"),
    );

    var data = jsonDecode(res.body);

    if (data['status'] == true) {
      allServices = data['data'];
    }
  }

  Future<void> updateService(String id, String serviceId) async {
    var res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/update_hotel_service.php"),
      body: {"id": id, "hotel_id": hotelId!, "service_id": serviceId},
    );

    var data = jsonDecode(res.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Services")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hotelServices.length,
              itemBuilder: (context, index) {
                var item = hotelServices[index];

                String? selectedServiceId;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current: ${item['service_name']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          hint: const Text("Select New Service"),
                          value: selectedServiceId,
                          items: allServices.map<DropdownMenuItem<String>>((s) {
                            return DropdownMenuItem(
                              value: s['id'].toString(),
                              child: Text(s['service_name']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            selectedServiceId = val;
                          },
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () {
                            if (selectedServiceId != null) {
                              updateService(
                                item['id'].toString(),
                                selectedServiceId!,
                              );
                            }
                          },
                          child: const Text("Update"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
