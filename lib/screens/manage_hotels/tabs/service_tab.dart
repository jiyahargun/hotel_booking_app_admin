import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_service_screen.dart';
import 'update_service_screen.dart';

class HotelServiceScreen extends StatefulWidget {
  final String hotelName;

  const HotelServiceScreen({super.key, required this.hotelName});

  @override
  State<HotelServiceScreen> createState() => _HotelServiceScreenState();
}

class _HotelServiceScreenState extends State<HotelServiceScreen> {
  List services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      setState(() => isLoading = true);

      var response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_hotel_service.php"),
      );

      var data = jsonDecode(response.body);

      if (data['status'] == true) {
        List all = data['data'];

        services = all.where((item) {
          return item['hotel_name'].toString().toLowerCase().trim() ==
              widget.hotelName.toLowerCase().trim();
        }).toList();
      } else {
        services = [];
      }
    } catch (e) {
      print(e);
      services = [];
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteService(String id) async {
    var res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_hotel_service.php"),
      body: {"id": id},
    );

    var data = jsonDecode(res.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Services"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UpdateServiceScreen(hotelName: widget.hotelName),
                ),
              );

              if (result == true) {
                fetchServices();
              }
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
          ? const Center(child: Text("No Services Found"))
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                var item = services[index];

                return Dismissible(
                  key: Key(item['id'].toString()),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (direction) async {
                    await deleteService(item['id'].toString());

                    fetchServices();
                  },

                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.room_service),
                      title: Text(item['service_name']),
                      subtitle: Text(item['hotel_name']),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddServiceScreen(hotelName: widget.hotelName),
            ),
          );

          if (result == true) {
            fetchServices();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
