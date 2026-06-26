import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class KioskDashboardScreen extends StatefulWidget {
  final String kioskId;

  const KioskDashboardScreen({
    super.key,
    required this.kioskId,
  });

  @override
  State<KioskDashboardScreen> createState() => _KioskDashboardScreenState();
}

class _KioskDashboardScreenState extends State<KioskDashboardScreen> {
  List jobs = [];

  bool loading = true;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    fetchJobs();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchJobs(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchJobs() async {
    try {
      final response = await ApiService().getKioskJobs(
        widget.kioskId,
      );

      if (!mounted) return;

      setState(() {
        jobs = response.data["jobs"];
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> startPrinting(
    String jobId,
  ) async {
    await ApiService().startPrinting(jobId);

    fetchJobs();
  }

  Future<void> completePrinting(
    String jobId,
  ) async {
    await ApiService().completePrinting(jobId);

    fetchJobs();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kiosk Dashboard",
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchJobs,
        child: ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job["fileName"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pages: ${job["pages"]}",
                    ),
                    Text(
                      "Copies: ${job["copies"]}",
                    ),
                    Text(
                      "Price: ₹${job["price"]}",
                    ),
                    Text(
                      "Status: ${job["status"]}",
                    ),
                    const SizedBox(height: 10),
                    if (job["status"] == "QUEUED")
                      ElevatedButton(
                        onPressed: () => startPrinting(
                          job["id"],
                        ),
                        child: const Text(
                          "Start Printing",
                        ),
                      ),
                    if (job["status"] == "PRINTING")
                      ElevatedButton(
                        onPressed: () => completePrinting(
                          job["id"],
                        ),
                        child: const Text(
                          "Complete Printing",
                        ),
                      ),
                    if (job["status"] == "COMPLETED")
                      const Chip(
                        label: Text(
                          "Completed",
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
