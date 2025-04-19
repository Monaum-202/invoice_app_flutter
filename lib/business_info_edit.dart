import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/AuthService.dart';
import 'services/BusinessInfoService.dart';
import 'models/business_info.dart';

class BusinessInfoScreen extends StatefulWidget {
  @override
  _BusinessInfoScreenState createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  XFile? _logoFile;
  bool _isLoading = false;
  Uint8List? _logoBytes;

  final _controllers = {
    'businessName': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'address': TextEditingController(),
    'website': TextEditingController(),
    'taxId': TextEditingController(),
  };

  Map<String, dynamic>? _userData;
  BusinessInfo? _businessInfo;
  final _service = BusinessInfoService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson == null) return;

    _userData = jsonDecode(userJson);
    _loadBusinessInfo(_userData!['userName']);
  }

Future<void> _loadBusinessInfo(String userName) async {
  setState(() => _isLoading = true);

  try {
    try {
      final business = await _service.getBusinessInfoByUser(userName);
      _businessInfo = business;
      _populateForm();
      return;
    } catch (e) {
      // Handle if it's just that no business info was found
      if (!e.toString().contains('No business info found for user')) {
        rethrow;
      }
    }

    // No business info found: initialize a new one
    _businessInfo = BusinessInfo(
      businessName: '',
      address: '',
      phone: '',
      email: '',
      website: '',
      createdBy: userName,
    );
    _populateForm();

    _showMessage(
      'Welcome! Please fill in your business information.',
      Colors.blue,
    );
  } catch (e) {
    _showMessage('Failed to load data: $e', Colors.red);
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  void _populateForm() {
    _controllers['businessName']!.text = _businessInfo?.businessName ?? '';
    _controllers['email']!.text = _businessInfo?.email ?? '';
    _controllers['phone']!.text = _businessInfo?.phone ?? '';
    _controllers['address']!.text = _businessInfo?.address ?? '';
    _controllers['website']!.text = _businessInfo?.website ?? '';
    _controllers['taxId']!.text = _businessInfo?.taxId ?? '';
  }

  Future<void> _pickLogo() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _logoFile = pickedFile;
          _logoBytes = bytes;
        });
        if (_businessInfo?.id != null) await _uploadLogo();
      }
    } catch (e) {
      _showMessage('Failed to pick image: $e', Colors.red);
    }
  }

  Future<void> _uploadLogo() async {
    if (_logoFile == null || _logoBytes == null) return;
    
    try {
      final updated = await _service.uploadLogo(
        _businessInfo!,
        _logoBytes!,
        _logoFile!.name,
      );
      setState(() => _businessInfo = updated);
    } catch (e) {
      _showMessage('Logo upload failed: $e', Colors.red);
    }
  }

  Future<void> _saveBusinessInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare the business info object with form data
      final businessData = BusinessInfo(
        id: _businessInfo?.id, // This will be null for new business info
        businessName: _controllers['businessName']!.text,
        email: _controllers['email']!.text,
        phone: _controllers['phone']!.text,
        address: _controllers['address']!.text,
        website: _controllers['website']!.text,
        taxId: _controllers['taxId']!.text,
        createdBy: _userData?['userName'] ?? '',
      );

      // If there's no ID, it's a new business info
      final saved = businessData.id == null
          ? await _service.createBusinessInfo(businessData)
          : await _service.updateBusinessInfo(businessData);

      setState(() => _businessInfo = saved);

      if (_logoFile != null) await _uploadLogo();

      _showMessage('Business info saved successfully', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Save failed: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
    ));
  }

  Widget _buildTextField(String label, String key, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: OutlineInputBorder(),
        ),
        validator: required
            ? (value) => (value == null || value.isEmpty) ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _buildLogoUploader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickLogo,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _logoBytes != null ? MemoryImage(_logoBytes!) : null,
            child: _logoBytes == null
                ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600])
                : null,
          ),
        ),
        SizedBox(height: 8),
        Text('Tap to add logo', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Information'),
        actions: [
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(icon: Icon(Icons.save), onPressed: _saveBusinessInfo),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLogoUploader(),
              SizedBox(height: 20),
              _buildTextField('Business Name', 'businessName', required: true),
              _buildTextField('Email', 'email'),
              _buildTextField('Phone', 'phone'),
              _buildTextField('Address', 'address'),
              _buildTextField('Website', 'website'),
              _buildTextField('Tax ID', 'taxId'),
            ],
          ),
        ),
      ),
    );
  }
}


class MyBusinessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Business'),
        leading: Icon(Icons.arrow_back),
        actions: [
          Icon(Icons.check),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Selected Business
            Container(
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.yellow,
                  child: Icon(Icons.storefront, color: Colors.white),
                ),
                title: Text('Jersey tenda'),
                trailing: Icon(Icons.edit),
              ),
            ),
            SizedBox(height: 16),
            // Add New Business (PRO)
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                    title: Text('Add New Business'),
                  ),
                ),
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
