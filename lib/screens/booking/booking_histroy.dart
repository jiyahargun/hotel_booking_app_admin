import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final res = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_all_booking.php"),
    );

    final data = jsonDecode(res.body);

    if (data["status"] == true) {
      setState(() {
        bookings = data["bookings"];
        isLoading = false;
      });
    }
  }

  Color getPaymentColor(int status) {
    return status == 1 ? Colors.green : Colors.grey;
  }

  String getPaymentText(int status) {
    return status == 1 ? "Paid" : "Unpaid";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking History")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text("No Bookings Found"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final item = bookings[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Text(
                      item["hotel_name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item["user_name"]} • ₹${item["total_price"]}",
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: getPaymentColor(
                          item["payment_status"],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getPaymentText(item["payment_status"]),
                        style: TextStyle(
                          color: getPaymentColor(item["payment_status"]),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            "Check-in: ${item["check_in"]}  |  Check-out: ${item["check_out"]}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Rooms:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Column(
                        children: List.generate(item["rooms"].length, (i) {
                          final room = item["rooms"][i];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${room["room_category"]} (Room ${room["room_number"]})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹${room["price_per_night"]} x ${room["total_nights"]} nights",
                                ),
                                Text("Qty: ${room["quantity"]}"),
                                Text(
                                  "Total: ₹${room["room_total"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
