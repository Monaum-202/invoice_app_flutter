import 'package:flutter/material.dart';
import 'package:invo/business_info_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'services/BusinessInfoService.dart';
import 'models/business_info.dart';
import 'login_screen.dart';
import 'screens/dashboard_screen.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  BusinessInfo? _businessInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessInfo();
  }

  Future<void> _loadBusinessInfo() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        final service = BusinessInfoService();

        final business = await service.getBusinessInfoByUser(
          userData['userName'],
        );
        if (mounted) {
          setState(() {
            _businessInfo = business;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading business info: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: ${e.toString()}'))
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More"), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection([
                  _buildTile(
                    icon: Icons.storefront,
                    title: _businessInfo != null ? "My Business" : "New Business",
                    subtitle: _businessInfo != null
                        ? _businessInfo!.businessName
                        : "Add Your Business Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessInfoScreen(),
                        ),
                      ).then((_) => _loadBusinessInfo());
                    },
                  ),
                  _buildTile(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(),
                        ),
                      );
                    },
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
                const SizedBox(height: 10),
                _buildSection([
                  _buildTile(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: _logout,
                  ),
                ]),
              ],
            ),
    );
  }
}
