import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chatbot_page.dart'; // ✅ make sure this file exists

class TouristHomePage extends StatefulWidget {
  @override
  State<TouristHomePage> createState() => _TouristHomePageState();
}

class _TouristHomePageState extends State<TouristHomePage> {
  final TextEditingController _daysController = TextEditingController();
  String selectedCategory = "Nature";
  Map<String, dynamic>? itinerary;

  // Replace with your Flask server IP if running externally
  final String flaskUrl = "http://192.168.11.176:5000/itinerary";

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Itinerary Loaded!")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error fetching plan")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cannot connect to server")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tourist Guide Jharkhand"),
        backgroundColor: Colors.green.shade700,
        leading: Icon(Icons.menu), // ✅ three bar menu
      ),
      body: CustomScrollView(
        slivers: [
          // ✅ SliverAppBar replaced with clickable map card
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
                margin: EdgeInsets.all(12),
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                  image: DecorationImage(
                    image: AssetImage("assets/jharkhand_map.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Main content
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Welcome + chatbot logo
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
                                    builder: (context) => ChatbotPage()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.green.shade100,
                              backgroundImage:
                                  AssetImage("assets/chatbot.jpg"), // ✅ asset
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        "What are you planning today?",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),

                      // ✅ Itinerary Planner Section
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
                        label: Text("Generate",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                      SizedBox(height: 30),

                      // ✅ Display itinerary
                      if (itinerary != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: itinerary!.entries.map((entry) {
                            final day = entry.key;
                            final spots = entry.value as List<dynamic>;
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(day,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  ...spots.map((spot) => Text(
                                      "- ${spot['name']} (${spot['duration']} hrs)")),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      SizedBox(height: 30),

                      // ✅ Grid of sample places (perfect alignment)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1, // ✅ perfect squares
                        children: [
                          placeCard("Baidyanath Jyotirlinga Temple",
                              "assets/img1.jpg"),
                          placeCard("Parasnath Hills", "assets/img2.jpg"),
                          placeCard("Netarhat", "assets/img3.jpg"),
                          placeCard("Hundru Falls", "assets/img4.jpg"),
                        ],
                      ),

                      SizedBox(height: 30),

                      // ✅ Emergency & Tourism Helplines Section
                      Text(
                        "Emergency & Tourism Helplines",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          helplineCard("Tourist Information Center",
                              "0651-2400496"),
                          helplineCard(
                              "Jharkhand Tourism Office", "0651-2331828"),
                          helplineCard(
                              "Emergency Services (Dial 112)", "112"),
                          helplineCard("Police Helpline", "100"),
                          helplineCard("Ambulance", "102"),
                          helplineCard("Railway Enquiry", "139"),
                        ],
                      ),
                      SizedBox(height: 30),
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

  Widget placeCard(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.asset(imagePath,
              fit: BoxFit.cover, width: double.infinity, height: double.infinity),
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
              padding: EdgeInsets.all(8),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget helplineCard(String title, String number) {
    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.phone, color: Colors.pink),
              SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 4),
              Text(number, style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Separate full map page
class FullMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jharkhand Map"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 4,
          child: Image.asset("assets/jharkhand_map.jpg"),
        ),
      ),
    );
  }
}
