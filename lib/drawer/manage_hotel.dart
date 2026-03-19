import 'package:flutter/material.dart';

class ManageHotelDetailsScreen extends StatefulWidget {
  final String? hotelId;
  final String? hotelName;

  const ManageHotelDetailsScreen({
    super.key,
    this.hotelId,
    this.hotelName,
  });

  @override
  State<ManageHotelDetailsScreen> createState() =>
      _ManageHotelDetailsScreenState();
}

class _ManageHotelDetailsScreenState
    extends State<ManageHotelDetailsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName ?? "Manage Hotel"),
      ),

      body: Column(
        children: [

          // 🏨 Hotel Header
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "https://via.placeholder.com/100",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        widget.hotelName ?? "Hotel Name",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "Active",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),

                Switch(
                  value: true,
                  onChanged: (value) {},
                )
              ],
            ),
          ),

          // 🔽 Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Rooms"),
              Tab(text: "Services"),
              Tab(text: "Offers"),
              Tab(text: "Images"),
            ],
          ),

          // 🔽 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                // 🛏 ROOMS
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    roomCard("Standard Room", "₹2000/night", "15", "8"),
                    roomCard("Deluxe Room", "₹3500/night", "20", "12"),
                    roomCard("Premium Room", "₹5000/night", "10", "6"),
                  ],
                ),

                // 🧰 SERVICES
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    serviceTile("Free WiFi"),
                    serviceTile("Parking"),
                    serviceTile("AC Rooms"),
                    serviceTile("Room Service"),
                  ],
                ),

                // 💸 OFFERS
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    offerTile("10% Off", "Valid till 30 Sept"),
                    offerTile("Flat ₹500 Off", "On Deluxe Rooms"),
                  ],
                ),

                // 🖼 IMAGES
                GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "https://via.placeholder.com/150",
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 🛏 Room Card
  Widget roomCard(String title, String price, String total, String available) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Image.network("https://via.placeholder.com/60"),
        title: Text(title),
        subtitle: Text("Total Rooms: $total | Available: $available"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(price,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: () {}, child: const Text("Edit"))
          ],
        ),
      ),
    );
  }

  // 🧰 Service Tile
  Widget serviceTile(String name) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }

  // 💸 Offer Tile
  Widget offerTile(String title, String subtitle) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }
}