import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/components/profile-avatar.dart';
import 'package:myapp/helpers/db-helper.dart';
import 'package:myapp/login.dart';
import 'package:myapp/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.currentUser});

  final User currentUser;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;
  ImageSource _imageSource = ImageSource.camera;

  Future<void> _changeProfilePicture() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Media Selection'),
          content: const Text(
            'Select the source for your new profile picture.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _imageSource = ImageSource.camera;
                Navigator.of(context).pop();
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                _imageSource = ImageSource.gallery;
                Navigator.of(context).pop();
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: _imageSource);

    // User cancelled image selection
    if (image == null) {
      return;
    }

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (croppedFile == null) {
      return;
    }

    final imageBytes = await croppedFile.readAsBytes();

    if (!mounted) return;

    setState(() {
      _image = imageBytes;
    });
  }

  Future<void> _logout() async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text(
            'You will need to log in again to access your account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ],
        );
      },
    );

    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   (route) => false,
    // );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final dbHelper = DBHelper();

    final deleted = await dbHelper.deleteUser(widget.currentUser.id);

    if (!mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete account')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            ProfileAvatar(imagePath: _image),

            const SizedBox(height: 20),

            ListTile(
              title: const Text('Edit Profile'),
              leading: const Icon(Icons.edit),
              onTap: _changeProfilePicture,
            ),

            ListTile(
              title: const Text('Change Password'),
              leading: const Icon(Icons.lock),
              onTap: () {
                // TODO: Implement change password
              },
            ),

            ListTile(
              title: const Text('Terms and Conditions'),
              leading: const Icon(Icons.description),
              onTap: () async {
                await launchUrl(
                  Uri.parse(
                    'https://www.termsfeed.com/blog/sample-terms-and-conditions-template/',
                  ),
                );
              },
            ),

            ListTile(
              title: const Text('Contact Us'),
              leading: const Icon(Icons.message),
              onTap: () async {
                final Uri whatsappUrl = Uri.parse(
                  'https://wa.me/2348134567890'
                  '?text=Hello%20MyTrain%20Support%20Team',
                );

                await launchUrl(whatsappUrl);
              },
            ),

            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: _logout,
            ),

            ListTile(
              title: const Text('Delete Account'),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
