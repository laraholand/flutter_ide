import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:fide/pages/ide_page.dart';
import 'package:fide/util/booleans.dart';
import 'package:fide/util/strings.dart';
import 'package:permission_handler/permission_handler.dart';

class SetUpPage extends StatefulWidget {
  const SetUpPage({Key? key}) : super(key: key);

  @override
  State<SetUpPage> createState() => _SetUpPageState();
}

class _SetUpPageState extends State<SetUpPage> {
  int pageIndex = 0;
  List<Widget> welcomePage() {
  return [
    Image.asset("assets/icons/flutter.png", height: 100),
    const SizedBox(height: 24),
    Text(
      setupTitle(),
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 16),
    Text(
      setupMessage(),
      style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
      textAlign: TextAlign.center,
    ),
  ];
}
  List<Widget> secondPage() {
    return [
      const Text(
        "Permissions",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        "These permissions are required for proper IDE functionality.",
        style: TextStyle(color: Colors.white60, fontSize: 13),
      ),

      const SizedBox(height: 24),

      _permissionTile(
        title: "Notifications",
        description: notificationPermission(),
        value: notificationEnabled,
        onChanged: (value) {
          setState(() {
            notificationEnabled = value;
          });
          // TODO: Permission.notification.request();
        },
      ),

      const SizedBox(height: 16),

      _permissionTile(
        title: "Storage Access",
        description: storagePermission(),
        value: storageEnabled,
        onChanged: (value) {
          setState(() {
            storageEnabled = value;
          });
          // TODO: Permission.storage.request();
        },
      ),

      const SizedBox(height: 16),

      _permissionTile(
        title: "Install Packages",
        description: appInstallPermission(),
        value: installEnabled,
        onChanged: (value) {
          setState(() {
            installEnabled = value;
          });
          // TODO: Permission.requestInstallPackages.request();
        },
      ),
    ];
  }
  List<Widget> thirdPage() {
    return [
      const Text(
        "Development Tools",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      const SizedBox(height: 16),

      // SDK Description
      _infoBox(
        icon: Icons.info_outline,
        color: Colors.blueAccent,
        text: sdkDescription(),
      ),

      const SizedBox(height: 16),

      // Wi-Fi warning
      if (usingMobileData)
        _infoBox(
          icon: Icons.wifi_off,
          color: Colors.orangeAccent,
          text: wifiSuggestion(),
        ),

      const SizedBox(height: 16),

      // Storage warning (Red)
      if (lowStorage)
        _infoBox(
          icon: Icons.warning_amber_rounded,
          color: Colors.redAccent,
          text: storageMessage(),
        ),

      const SizedBox(height: 24),

      // Flutter SDK
      _sdkSwitchTile(
        title: "Flutter SDK",
        value: flutterSDKEnabled,
        enabled: false,
        description: "Required. Cannot be turned off.",
      ),

      const SizedBox(height: 12),

      // Android SDK
      _sdkSwitchTile(
        title: "Android SDK",
        value: androidSDKEnabled,
        enabled: true,
        description: "Optional. Required for building Android apps.",
        onChanged: (val) {
          setState(() {
            androidSDKEnabled = val;
          });
        },
      ),

      // Android Modules (nested)
      if (androidSDKEnabled)
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 12),
          child: Column(
            children: androidModules.entries.map((entry) {
              return _sdkSwitchTile(
                title: entry.key,
                value: entry.value,
                enabled: true,
                description: "",
                onChanged: (val) {
                  setState(() {
                    androidModules[entry.key] = val;
                  });
                },
              );
            }).toList(),
          ),
        ),

      const SizedBox(height: 32),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup IDE'),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (pageIndex == 0) ...welcomePage(),
                    if (pageIndex == 1) ...secondPage(),
                    if (pageIndex == 2) ...thirdPage(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: pageIndex == 0
                  ? null
                  : () {
                      setState(() {
                        pageIndex--;
                      });
                    },
              child: const Text(
                "Back",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                if (pageIndex >= 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdePage(),
                    ),
                  );
                } else {
                  setState(() {
                    pageIndex++;
                  });
                }
              },
              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}



Widget _permissionTile({
  required String title,
  required String description,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF353839),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.tealAccent,
        ),
      ],
    ),
  );
}

Widget _infoBox({
  required IconData icon,
  required Color color,
  required String text,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF353839),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _sdkSwitchTile({
  required String title,
  required bool value,
  required bool enabled,
  String description = "",
  ValueChanged<bool>? onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF353839),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: Colors.tealAccent,
        ),
      ],
    ),
  );
}
