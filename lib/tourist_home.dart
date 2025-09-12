import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chatbot_page.dart'; // ✅ chatbot UI

class TouristHomePage extends StatefulWidget {
  @override
  State<TouristHomePage> createState() => _TouristHomePageState();
}

class _TouristHomePageState extends State<TouristHomePage> {
  final TextEditingController _daysController = TextEditingController();
  String selectedCategory = "Nature";
  Map<String, dynamic>? itinerary;

  // Replace with your server URL
  final String flaskUrl = "http://127.0.0.1:5000/itinerary";

  Future<void> fetchItinerary() async {
    int days = int.tryParse(_daysController.text) ?? 1;

    try {
      final response = await http.post(
        Uri.parse(flaskUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "days": days,
          "categories": [selectedCategory.toLowerCase()]
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          itinerary = jsonDecode(response.body);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Itinerary Loaded!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching plan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot connect to server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jharkhand Travel Guide"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Menu clicked")),
            );
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ✅ Top Jharkhand Map Section
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullMapPage(),
                  ),
                );
              },
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                ),
                margin: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/jharkhand_map.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Rest of the body
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Welcome + Chatbot logo FIXED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Welcome!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatbotPage(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.green.shade100,
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/chatbot.jpg",
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "What are you planning today?",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 25),

                      // ✅ Plan Itinerary Section
                      Text(
                        "Plan Your Itinerary",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Number of Days",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon:
                              Icon(Icons.calendar_today, color: Colors.green),
                        ),
                      ),
                      SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Select Category",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ["Nature", "Spiritual", "Wildlife", "Culture"]
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: fetchItinerary,
                        icon: Icon(Icons.map, color: Colors.white),
                        label: Text("Generate Plan",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                      SizedBox(height: 30),

                      // ✅ Display the generated itinerary
                      if (itinerary != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: itinerary!.entries.map((entry) {
                            final day = entry.key;
                            final spots = entry.value as List<dynamic>;
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                color: Colors.green[50],
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(day,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 6),
                                      ...spots.map((spot) => Text(
                                          "• ${spot['name']} (${spot['duration']} hrs)",
                                          style: TextStyle(fontSize: 14))),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      SizedBox(height: 30),

                      // ✅ Popular Places Grid
                      Text(
                        "Popular Destinations",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: [
                          placeCard("Baidyanath Jyotirlinga Temple",
                              "assets/img1.jpg"),
                          placeCard("Parasnath Hills", "assets/img2.jpg"),
                          placeCard("Netarhat", "assets/img3.jpg"),
                          placeCard("Hundru Falls", "assets/img4.jpg"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reusable Place Card
  Widget placeCard(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  shadows: [
                    Shadow(
                        blurRadius: 6,
                        color: Colors.black,
                        offset: Offset(2, 2))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ✅ Full Map Page
class FullMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jharkhand Map"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.asset("assets/jharkhand_map.jpg"),
        ),
      ),
    );
  }
}
