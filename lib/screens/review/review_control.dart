import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  List reviews = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future fetchReviews() async {
    setState(() => isLoading = true);

    try {
      var res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_review.php"),
      );

      var data = jsonDecode(res.body);

      if (data['code'] == 200) {
        reviews = data['data'];
      } else {
        reviews = [];
      }
    } catch (e) {
      reviews = [];
    }

    setState(() => isLoading = false);
  }

  Future deleteReview(String id) async {
    var res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_review.php"),
      body: {"id": id},
    );

    print(res.body);

    fetchReviews();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "1":
        return Colors.green;
      case "0":
        return Colors.orange;
      case "2":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case "1":
        return "Approved";
      case "0":
        return "Pending";
      case "2":
        return "Rejected";
      default:
        return "Unknown";
    }
  }

  Widget buildStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchReviews),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
          ? const Center(child: Text("No Reviews Found"))
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index];

                double rating =
                    double.tryParse(review['rating'].toString()) ?? 0;

                return Dismissible(
                  key: Key(review['id'].toString()),
                  direction: DismissDirection.endToStart,

                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Review?"),
                        content: const Text(
                          "Are you sure you want to delete this review?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (_) async {
                    var id = review['id'].toString();

                    setState(() {
                      reviews.removeAt(index);
                    });

                    await deleteReview(id);
                  },

                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(review['hotel_name'] ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("User: ${review['user_name']}"),
                          buildStars(rating),
                          Text(review['review'] ?? ""),
                          const SizedBox(height: 5),
                          Text(
                            getStatusText(review['review_status']),
                            style: TextStyle(
                              color: getStatusColor(review['review_status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
