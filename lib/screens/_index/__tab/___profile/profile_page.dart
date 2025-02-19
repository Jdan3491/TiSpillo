import 'package:flutter/material.dart';
import '../../../../core/widgets/full_button_ts.dart';
import 'settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileSettings profileSettings = ProfileSettings();

  @override
  void initState() {
    super.initState();
    profileSettings.fetchEmployeeData(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage:
                            profileSettings.profileImageUrl.isNotEmpty
                                ? NetworkImage(profileSettings.profileImageUrl)
                                : null, // Se l'immagine è disponibile, usala
                        child: profileSettings.profileImageUrl.isEmpty
                            ? Icon(Icons.person,
                                size: 80, color: Colors.white70)
                            : null, // Se non c'è immagine, mostra l'icona
                      ),
                      const SizedBox(height: 20),
                      Text(
                        profileSettings.currentUser?.email ??
                            'In caricamento....',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      FullButtonTs(
                        onPressed: () => profileSettings.logout(context),
                        child: Text('Disconnetti'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
