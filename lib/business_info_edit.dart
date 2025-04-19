import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BusinessInfoScreen extends StatefulWidget {
  @override
  _BusinessInfoScreenState createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Widget _buildLogoUploader() {
    return Column(
      children: [
        InkWell(
          onTap: _pickLogo,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              image: _logoFile != null
                  ? DecorationImage(
                      image: FileImage(_logoFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _logoFile == null
                ? Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add logo',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Business Info"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // save logic here
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLogoUploader(),
              const SizedBox(height: 20),
              _buildTextField("Business Name *"),
              _buildTextField("Email Address"),
              _buildTextField("Phone Number"),
              _buildTextField("Billing Address"),
              _buildTextField("Business Website"),
              _buildTextField("Tax Name (e.g. GSTIN, VAT, TIN etc.)"),
              _buildTextField("Tax ID"),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessInfoEdit extends StatefulWidget {
  final Map<String, String> initialBusinessInfo;
  final File? initialLogo;
  final Function(Map<String, String>, File?) onSave;

  const BusinessInfoEdit({
    Key? key,
    required this.initialBusinessInfo,
    this.initialLogo,
    required this.onSave,
  }) : super(key: key);

  @override
  State<BusinessInfoEdit> createState() => _BusinessInfoEditState();
}

class _BusinessInfoEditState extends State<BusinessInfoEdit> {
  late Map<String, String> businessInfo;
  File? _logoFile;

  @override
  void initState() {
    super.initState();
    businessInfo = Map.from(widget.initialBusinessInfo);
    _logoFile = widget.initialLogo;
  }

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Business Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(businessInfo, _logoFile);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _logoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _logoFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.business,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickLogo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Business Info Fields
            TextFormField(
              initialValue: businessInfo['businessName'],
              decoration: InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              onChanged: (value) => businessInfo['businessName'] = value,
            ),
            SizedBox(height: 16),

            TextFormField(
              initialValue: businessInfo['address'],
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              onChanged: (value) => businessInfo['address'] = value,
            ),
            SizedBox(height: 16),

            TextFormField(
              initialValue: businessInfo['phone'],
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => businessInfo['phone'] = value,
            ),
            SizedBox(height: 16),

            TextFormField(
              initialValue: businessInfo['email'],
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => businessInfo['email'] = value,
            ),
            SizedBox(height: 16),

            TextFormField(
              initialValue: businessInfo['taxId'],
              decoration: InputDecoration(
                labelText: 'Tax ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
              onChanged: (value) => businessInfo['taxId'] = value,
            ),
            SizedBox(height: 16),

            TextFormField(
              initialValue: businessInfo['website'],
              decoration: InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web),
              ),
              keyboardType: TextInputType.url,
              onChanged: (value) => businessInfo['website'] = value,
            ),
          ],
        ),
      ),
    );
  }
}
