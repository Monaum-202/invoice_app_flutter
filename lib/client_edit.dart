import 'package:flutter/material.dart';
import 'package:invo/services/ClientService.dart';
import 'models/client_model.dart';

class EditClientPage extends StatefulWidget {
  final Client client;

  const EditClientPage({super.key, required this.client});

  @override
  _EditClientPageState createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nidController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _emailController = TextEditingController(text: widget.client.email);
    _phoneController = TextEditingController(text: widget.client.phone);
    _nidController = TextEditingController(text: widget.client.nid);
    _addressController = TextEditingController(text: widget.client.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      try {
        Client updatedClient = Client(
          id: widget.client.id,
          name: _nameController.text.trim(),
          email: widget.client.email,
          phone: widget.client.phone,
          nid: widget.client.nid,
          address: widget.client.address,

          
        );

        final result = await _clientService.updateClient(updatedClient);
        Navigator.pop(context, result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating client: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Client Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a client name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _nidController,
                decoration: InputDecoration(labelText: 'NID'),
                keyboardType: TextInputType.text,
                validator: (value) => value!.isEmpty ? 'Please enter a NID' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveClient,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
