import 'api_service.dart';
import 'ayu_theme.dart';

class AnalysisPage extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  const AnalysisPage({super.key, required this.userProfile});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _timeRange = "Monthly"; // Monthly, 6-Month, Yearly
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await ApiService.getHistory(widget.userProfile['email'] ?? "");
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  List<FlSpot> _getSpots() {
    if (_history.isEmpty) return [const FlSpot(0, 5)];
    
    int count = _timeRange == "Monthly" ? 4 : (_timeRange == "6-Month" ? 6 : 12);
    // Take latest 'count' entries and reverse to show oldest to newest
    var subset = _history.take(count).toList();
    subset = subset.reversed.toList();

    return subset.asMap().entries.map((e) {
      double val = (e.value['risk'] ?? 5.0).toDouble();
      return FlSpot(e.key.toDouble(), val);
    }).toList();
  }

  List<String> _getLabels() {
    int count = _timeRange == "Monthly" ? 4 : (_timeRange == "6-Month" ? 6 : 12);
    var subset = _history.take(count).toList();
    subset = subset.reversed.toList();
    
    return subset.map((e) {
      String date = e['date'] ?? "";
      if (date.length > 5) {
        return date.substring(5); // Show MM-DD
      }
      return date;
    }).toList();
  }

  Map<String, double> _getStabilityStats() {
    if (_history.isEmpty) return {"Stable": 100};
    
    Map<String, int> counts = {"Stable": 0, "Fluctuating": 0, "Critical": 0};
    for (var entry in _history) {
      String stability = entry['stability'] ?? "Stable";
      counts[stability] = (counts[stability] ?? 0) + 1;
    }
    
    double total = _history.length.toDouble();
    return counts.map((key, value) => MapEntry(key, (value / total) * 100));
  }

  Widget _buildTrendChart() {
    final spots = _getSpots();
    final labels = _getLabels();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Risk Level Trend",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Analyzing History",
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(labels[index], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AyuTheme.primaryTeal,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: AyuTheme.primaryTeal.withOpacity(0.05)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    final stats = _getStabilityStats();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vital Stability Analysis",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(color: Colors.green, value: stats['Stable'] ?? 0, title: "${(stats['Stable'] ?? 0).toInt()}%", radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        PieChartSectionData(color: Colors.orange, value: stats['Fluctuating'] ?? 0, title: "${(stats['Fluctuating'] ?? 0).toInt()}%", radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        PieChartSectionData(color: Colors.red, value: stats['Critical'] ?? 0, title: "${(stats['Critical'] ?? 0).toInt()}%", radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem("Stable", Colors.green),
                    _buildLegendItem("Fluctuating", Colors.orange),
                    _buildLegendItem("Critical", Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Health History: ${widget.userProfile['email']?.split('@')[0] ?? 'User'}"),
        backgroundColor: Colors.white,
        foregroundColor: AyuTheme.textDark,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadHistory,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Time Range Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: ["Monthly", "6-Month", "Yearly"].map((range) {
                        bool isSelected = _timeRange == range;
                        return Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _timeRange = range),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AyuTheme.primaryTeal : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  range,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildTrendChart(),

                  const SizedBox(height: 20),

                  _buildPieChartCard(),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AyuTheme.headerGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                        const SizedBox(height: 12),
                        const Text(
                          "AI Personalized Health Insights",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Based on history for ${widget.userProfile['email']}, we notice a stability of ${(_getStabilityStats()['Stable'] ?? 0).toInt()}%. Your risk score is currently ${(_history.isNotEmpty ? _history.first['risk'] : 'N/A')}. Keep monitoring daily.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }
}
