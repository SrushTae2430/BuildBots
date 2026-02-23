import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'ayu_theme.dart';
import 'dart:math';

class DoctorsPage extends StatefulWidget {
  final String? specialty;
  const DoctorsPage({super.key, this.specialty});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;
  String? _error;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndDoctors();
  }

  Future<void> _fetchLocationAndDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      // 2. Get current position
      // For Windows/Desktop, this might return a default or use IP-based location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() => _currentPosition = position);

      // 3. Fetch from backend
      final docs = await ApiService.getNearbyDoctors(
        position.latitude,
        position.longitude,
        specialty: widget.specialty,
      );

      setState(() {
        _doctors = docs;
        _isLoading = false;
      });
    } catch (e) {
      // For Demo/Dev: If location fails (like on Windows without hardware), use a fallback mock location (Delhi)
      final mockLat = 28.6139;
      final mockLon = 77.2090;
      final docs = await ApiService.getNearbyDoctors(mockLat, mockLon, specialty: widget.specialty);
      
      setState(() {
        _doctors = docs;
        _isLoading = false;
        _error = "Using fallback location (Device location unavailable)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Recommended Doctors"),
        backgroundColor: Colors.white,
        foregroundColor: AyuTheme.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocationAndDoctors,
          )
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _doctors.isEmpty 
                  ? const Center(child: Text("No doctors found nearby."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        final item = _doctors[index];
                        final doc = item['doctor'];
                        final dist = item['distance_km'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AyuTheme.primaryTeal.withOpacity(0.1),
                                      child: const Icon(Icons.person, color: AyuTheme.primaryTeal, size: 30),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          Text(
                                            "${doc['specialty']} • ${doc['hospital']}",
                                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${doc['rating']} Rating",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${dist} km away",
                                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {}, // Mock Call
                                        icon: const Icon(Icons.phone),
                                        label: const Text("Call"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {}, // Mock Message
                                        icon: const Icon(Icons.message),
                                        label: const Text("Message"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AyuTheme.primaryTeal,
                                          side: const BorderSide(color: AyuTheme.primaryTeal),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
