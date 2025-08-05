import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:numberplatefinder/customs/custom_app_bar.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  final String appVersion = '1.0.1';

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Cannot open email client for $email");
    }
  }

  void _launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Cannot open website: $url");
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String email,
    required String website,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchEmail(email),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchWebsite(website),
              child: Row(
                children: [
                  const Icon(Icons.language_outlined, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    website,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'About Us'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Application Developed for Patni Auto',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,

                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Application Version: $appVersion',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),

            _buildInfoCard(
              title: 'Consulted by Karan Infosys',
              email: 'karan@karaninfosys.com',
              website: 'https://www.karaninfosys.com',
            ),

            _buildInfoCard(
              title: 'Developed by GM TECHNOSYS',
              email: 'info@gmtechnosys.com',
              website: 'https://www.gmtechnosys.com',
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2025 GM TECHNOSYS',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
