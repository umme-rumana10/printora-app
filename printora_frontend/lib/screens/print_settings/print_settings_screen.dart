import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../models/print_option.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../../order/order_submitted_screen.dart';

class PrintSettingsScreen extends StatefulWidget {
  final List<File> files;

  const PrintSettingsScreen({
    super.key,
    required this.files,
  });

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  late List<PrintOption> options;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    options = List.generate(
      widget.files.length,
      (index) => PrintOption(),
    );
  }

  double getTotalCost() {
    double total = 0;

    for (var option in options) {
      total += option.color ? option.copies * 10 : option.copies * 2;
    }

    return total;
  }

  Future<void> uploadOrder() async {
    try {
      setState(() {
        isUploading = true;
      });

      final formData = FormData();

      // Add files
      for (final file in widget.files) {
        formData.files.add(
          MapEntry(
            "files",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      // Build settings array
      final settings = <Map<String, dynamic>>[];

      for (final option in options) {
        settings.add({
          "pages": 1,
          "copies": option.copies,
          "color": option.color,
          "pageRange": option.allPages ? "all" : option.pageRange,
        });
      }

      formData.fields.add(
        MapEntry(
          "settings",
          jsonEncode(settings),
        ),
      );

      formData.fields.add(
        MapEntry(
          "kioskId",
          AppState.kioskId ?? "",
        ),
      );

      debugPrint("KIOSK ID: ${AppState.kioskId}");
      debugPrint("FILES COUNT: ${widget.files.length}");
      debugPrint("SETTINGS COUNT: ${settings.length}");

      final response = await ApiService().uploadMultipleFiles(
        formData,
      );

      debugPrint(response.data.toString());

      final orderId = response.data["orderId"];
      final totalPrice = response.data["totalPrice"];

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSubmittedScreen(
            orderId: orderId,
            totalPrice: totalPrice.toDouble(),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      if (e is DioException) {
        debugPrint("STATUS CODE: ${e.response?.statusCode}");
        debugPrint("RESPONSE DATA: ${e.response?.data}");
      }

      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Configuration"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                final file = widget.files[index];
                final option = options[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.path.split('/').last,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Copies",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (option.copies > 1) {
                                  setState(() {
                                    option.copies--;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.remove_circle,
                              ),
                            ),
                            Text(
                              "${option.copies}",
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  option.copies++;
                                });
                              },
                              icon: const Icon(
                                Icons.add_circle,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: Text(
                            option.color ? "Color" : "Black & White",
                          ),
                          value: option.color,
                          onChanged: (value) {
                            setState(() {
                              option.color = value;
                            });
                          },
                        ),
                        const Divider(),
                        CheckboxListTile(
                          title: const Text(
                            "All Pages",
                          ),
                          value: option.allPages,
                          onChanged: (value) {
                            setState(() {
                              option.allPages = value!;
                            });
                          },
                        ),
                        if (!option.allPages)
                          TextField(
                            decoration: const InputDecoration(
                              hintText: "Example: 1-5",
                            ),
                            onChanged: (value) {
                              option.pageRange = value;
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Estimated Cost : ₹${getTotalCost().toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isUploading ? null : uploadOrder,
                    child: isUploading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Confirm Print",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
