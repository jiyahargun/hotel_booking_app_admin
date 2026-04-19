import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final TextEditingController cityController = TextEditingController();

  List cityList = [];
  bool isLoading = false;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  // 🔹 FETCH CITY
  Future<void> fetchCities() async {
    final res = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_city.php"),
    );

    final data = jsonDecode(res.body);

    setState(() {
      cityList = data;
      isFetching = false;
    });
  }

  Future<void> addCity() async {
    String city = cityController.text.trim();

    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter city name")),
      );
      return;
    }

    setState(() => isLoading = true);

    final res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/insert_city.php"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "city_name": city,
      },
    );

    final data = jsonDecode(res.body);

    setState(() => isLoading = false);

    if (data["status"] == true) {
      cityController.clear();
      fetchCities();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City Added")),
      );
    }
  }

  // 🔹 DELETE CITY
  Future<void> deleteCity(String id) async {
    final res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_city.php"),
      body: {
        "id": id,
      },
    );

    final data = jsonDecode(res.body);

    if (data["status"] == true) {
      fetchCities();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City Deleted")),
      );
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Cities"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // 🔹 ADD CITY UI
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(
                      hintText: "Enter city name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : addCity,
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("Add"),
                )
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: isFetching
                  ? const Center(child: CircularProgressIndicator())
                  : cityList.isEmpty
                  ? const Center(child: Text("No Cities Found"))
                  : ListView.builder(
                itemCount: cityList.length,
                itemBuilder: (context, index) {
                  final city = cityList[index];

                  return Dismissible(
                    key: Key(city["id"]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete,
                          color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      deleteCity(city["id"]);
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(city["city_name"]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}