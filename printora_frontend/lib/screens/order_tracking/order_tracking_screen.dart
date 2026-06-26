import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:async';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? orderData;

  bool loading = true;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    fetchOrder();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchOrder(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchOrder() async {
    try {
      final response = await ApiService().getOrder(
        widget.orderId,
      );

      debugPrint("Refreshing order...");
      debugPrint(response.data.toString());

      if (!mounted) return;

      setState(() {
        orderData = response.data;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  String getOrderStatus() {
    if (orderData == null) return "Loading";

    final jobs = List<Map<String, dynamic>>.from(
      orderData!["printJobs"],
    );

    if (jobs.isEmpty) {
      return "No Jobs";
    }

    final allCompleted = jobs.every(
      (job) => job["status"] == "COMPLETED",
    );

    if (allCompleted) {
      return "READY FOR PICKUP";
    }

    final anyPrinting = jobs.any(
      (job) => job["status"] == "PRINTING",
    );

    if (anyPrinting) {
      return "PRINTING";
    }

    return "QUEUED";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final jobs = List<Map<String, dynamic>>.from(
      orderData?["printJobs"] ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Order"),
        actions: [
          IconButton(
            onPressed: fetchOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrder,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Order ID",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(widget.orderId),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Current Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getOrderStatus(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Print Jobs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            ...jobs.map(
              (job) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                  ),
                  title: Text(
                    job["fileName"] ?? "",
                  ),
                  subtitle: Text(
                    "Status: ${job["status"]}",
                  ),
                  trailing: Text(
                    "${job["copies"] ?? 1}x",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
