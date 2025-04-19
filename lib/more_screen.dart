import 'package:flutter/material.dart';
import 'package:invo/business_info_edit.dart';

class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("More"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection([
            _buildTile(
              icon: Icons.storefront,
              title: "New Business",
              subtitle: "Add Your Business Details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusinessInfoScreen()),
                );
              },
            ),
            _buildTile(
              icon: Icons.dashboard,
              title: "Dashboard",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.bar_chart,
              title: "Report",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.file_download,
              title: "Export",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.settings,
              title: "Settings",
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 10),
          _buildSection([
            _buildTile(
              icon: Icons.backup,
              title: "Backup & Restore",
              subtitle: "Backup your data regularly as a safety measure",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.share,
              title: "Share this App",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.support,
              title: "Support",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.star_rate,
              title: "Rate Us",
              onTap: () {},
            ),
            _buildTile(
              icon: Icons.info,
              title: "About Us",
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> tiles) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: tiles),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
