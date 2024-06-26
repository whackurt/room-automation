import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:micro_room_automation/services/preferences.services.dart';
import 'package:micro_room_automation/utils/format_time.dart';
import 'package:micro_room_automation/widgets/time_picker.dart';

class EditBalconyLight extends StatefulWidget {
  const EditBalconyLight({super.key});

  @override
  State<EditBalconyLight> createState() => _EditBalconyLightState();
}

class _EditBalconyLightState extends State<EditBalconyLight> {
  DatabaseReference balconyLightRef =
      FirebaseDatabase.instance.ref('preferences/light/balcony');
  PrefServices ps = PrefServices();

  String? timeON;
  String? timeOFF;
  Map<String, String> updates = {};

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    balconyLightRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;

      if (mounted) {
        setState(() {
          timeON = formatTime(data["on"].toString());
          timeOFF = formatTime(data["off"].toString());
        });
      }

      updates["on"] = data["on"];
      updates["off"] = data["off"];
    });
  }

  void saveUpdate() async {
    if (updates.isNotEmpty) {
      var updated = await ps.updateLightSchedule(balconyLightRef, updates);

      if (updated) {
        Fluttertoast.showToast(
            msg: 'Preference saved',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        updates.clear();
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to save preference',
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        updates.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Balcony Light Schedule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Current',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time ON'),
                Text('Time OFF'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeON.toString(),
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                Text(
                  timeOFF.toString(),
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            const Divider(
              height: 30.0,
            ),
            const Row(
              children: [
                Text(
                  'Update',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Time ON: ',
                  style: TextStyle(fontSize: 16.0),
                ),
                TimePickerWidget(
                  label: 'Select Time ON',
                  initialTime: TimeOfDay.now().replacing(hour: 0, minute: 0),
                  onTimeSelected: (time) {
                    updates["on"] =
                        "${time?.hour}:${time!.minute < 10 ? '0${time.minute}' : time.minute}";
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Time OFF: ',
                  style: TextStyle(fontSize: 16.0),
                ),
                TimePickerWidget(
                  label: 'Select Time OFF',
                  initialTime: TimeOfDay.now().replacing(hour: 0, minute: 0),
                  onTimeSelected: (time) {
                    updates["off"] =
                        "${time?.hour}:${time!.minute < 10 ? '0${time.minute}' : time.minute}";
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
              onPressed: saveUpdate,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Button background color
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // Add padding around text
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
