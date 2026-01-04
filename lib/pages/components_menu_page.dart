import 'package:flutter/material.dart';
// Impor 'dart:math' untuk demo Chart sederhana
import 'dart:math' as math; 

class ComponentsMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Components', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10),
        children: [
          // Bagian 1
          _buildComponentItem(
            context,
            icon: Icons.notifications_active,
            iconColor: Color(0xFFFF8A5B),
            title: 'Alert',
            onTap: () {
              _showAlertDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.account_circle,
            iconColor: Color(0xFFFF8A5B),
            title: 'Avatar',
            onTap: () {
              _showAvatarDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.add_box, // Ikon 'Button' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Button',
            onTap: () {
              _showButtonDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.radio_button_checked,
            iconColor: Color(0xFFFF8A5B),
            title: 'Radio Button',
            onTap: () {
              _showRadioButtonDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.verified, // Ikon 'Badge' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Badge',
            onTap: () {
              _showBadgeDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.hub, // Ikon 'Button Group' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Button Group',
            onTap: () {
              _showButtonGroupDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.credit_card, // Ikon 'Card' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Card',
            onTap: () {
              _showCardDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.pie_chart, // Ikon 'Charts' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Charts',
            onTap: () {
              _showChartsDemo(context); // Diperbarui
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.arrow_downward, // Ikon 'Dropdown' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Dropdown',
            onTap: () {
              _showDropdownDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.input, // Ikon 'Input' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Input',
            onTap: () {
              _showInputDemo(context);
            },
          ),

          // Bagian 2
          _buildComponentItem(
            context,
            icon: Icons.list_alt, // Ikon 'List Group' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'List Group',
            onTap: () {
              _showListGroupDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.crop_square, // Ikon 'Modal' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Modal',
            onTap: () {
              _showModalDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.reorder, // Ikon 'Progressbar' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Progressbar',
            onTap: () {
              _showProgressbarDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.share, // Ikon 'Social' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Social',
            onTap: () {
              _showSocialDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.text_fields, // Ikon 'Typography' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Typography',
            onTap: () {
              _showTypographyDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.wb_sunny, // Ikon 'Toast' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Toast',
            onTap: () {
              _showToastDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.schema, // Ikon 'Treeview' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Treeview',
            onTap: () {
              _showTreeviewDemo(context); // Diperbarui
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.toggle_on, // Ikon 'Switch' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Switch',
            onTap: () {
              _showSwitchDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.linear_scale, // Ikon 'Stepper' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Stepper',
            onTap: () {
              _showStepperDemo(context); // Diperbarui
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.autorenew, // Ikon 'Spinner' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Spinner',
            onTap: () {
              _showSpinnerDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.tune, // Ikon 'RangeSlider' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'RangeSlider',
            onTap: () {
              _showRangeSliderDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.photo_library, // Ikon 'Lightgallery' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Lightgallery',
            onTap: () {
              _showLightgalleryDemo(context); // Diperbarui
            },
          ),

          // Bagian 3
          _buildComponentItem(
            context,
            icon: Icons.horizontal_rule, // Ikon 'Divider' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Divider',
            onTap: () {
              _showDividerDemo(context);
            },
          ),
          _buildComponentItem(
            context,
            icon: Icons.language, // Ikon 'Language' di gambar
            iconColor: Color(0xFFFF8A5B),
            title: 'Language',
            onTap: () {
              _showLanguageDemo(context);
            },
          ),

          // Dari kode asli Anda
          _buildComponentItem(
            context,
            icon: Icons.timeline,
            iconColor: Color(0xFFFF8A5B),
            title: 'Timeline',
            onTap: () {
              _showTimelineDemo(context); // Diperbarui
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComponentItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  // --- DEMO YANG SUDAH ADA ---
  // ... (Demo untuk Alert, Avatar, Button, Radio, Badge, ButtonGroup, Dropdown, Input) ...
  // ... (Kode demo ini sama seperti sebelumnya, saya akan langsung ke demo yang diperbarui)

  // --- DEMO YANG SUDAH ADA (Saya sertakan untuk kelengkapan) ---
  void _showAlertDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFFF8A5B)),
            SizedBox(width: 10),
            Text('Alert Component'),
          ],
        ),
        content: Text('This is an example of Alert component in Flutter!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showAvatarDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Avatar Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child:
                      Text('A', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage('https://randomuser.me/api/portraits/women/1.jpg'),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text('Different avatar styles', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showButtonDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Button Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8A5B),
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Elevated Button', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFFFF8A5B)),
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  Text('Outlined Button', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
              ),
              child: Text('Text Button', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

   void _showRadioButtonDemo(BuildContext context) {
    int selectedValue = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Radio Button Component'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text('Option 1'),
                value: 1,
                groupValue: selectedValue,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (value) =>
                    setState(() => selectedValue = value as int),
              ),
              RadioListTile(
                title: Text('Option 2'),
                value: 2,
                groupValue: selectedValue,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (value) =>
                    setState(() => selectedValue = value as int),
              ),
              RadioListTile(
                title: Text('Option 3'),
                value: 3,
                groupValue: selectedValue,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (value) =>
                    setState(() => selectedValue = value as int),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Badge Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  clipBehavior: Clip.none, // Agar badge terlihat di luar ikon
                  children: [
                    Icon(Icons.notifications, size: 40, color: Colors.grey),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text('5',
                            style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart, size: 40, color: Colors.grey),
                    Positioned(
                       right: -4,
                      top: -4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text('12',
                            style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.mail, size: 40, color: Colors.grey),
                    Positioned(
                       right: -4,
                      top: -4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text('3',
                            style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showButtonGroupDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Button Group Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF8A5B),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(10)),
                      ),
                    ),
                    child: Text('Left', style: TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                       side: BorderSide(color: Colors.grey[400]!),
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text('Center', style: TextStyle(color: Colors.black)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                    ),
                    child: Text('Right', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showDropdownDemo(BuildContext context) {
    String selectedValue = 'Option 1';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Dropdown Component'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: ['Option 1', 'Option 2', 'Option 3']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() => selectedValue = newValue!);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Input Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Color(0xFFFF8A5B)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFFF8A5B), width: 2),
                ),
                prefixIcon: Icon(Icons.person, color: Color(0xFFFF8A5B)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                 labelStyle: TextStyle(color: Color(0xFFFF8A5B)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFFF8A5B), width: 2),
                ),
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF8A5B)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

   void _showCardDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Card Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Title',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('This is the content of the card component.'),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text('Action',
                            style: TextStyle(color: Color(0xFFFF8A5B))),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showListGroupDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('List Group Component'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Color(0xFFFF8A5B)),
                title: Text('Profile'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Color(0xFFFF8A5B)),
                title: Text('Settings'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Color(0xFFFF8A5B)),
                title: Text('Logout'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showModalDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modal Bottom Sheet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text('This is a modal bottom sheet. It slides up from the bottom.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8A5B),
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Close Modal', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressbarDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Progressbar Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Linear Progress'),
            SizedBox(height: 10),
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A5B)),
              backgroundColor: Color(0xFFFF8A5B).withOpacity(0.2),
            ),
            SizedBox(height: 25),
            Text('Circular Progress'),
            SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A5B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showSocialDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Social Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Social Media Icons'),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.facebook, color: Colors.blue, size: 30),
                Icon(Icons.camera_alt, color: Colors.purple, size: 30), 
                Icon(Icons.public, color: Colors.lightBlue, size: 30),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showTypographyDemo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Typography Component'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Headline 5', style: textTheme.headlineSmall),
              SizedBox(height: 5),
              Text('Headline 6', style: textTheme.titleLarge),
              SizedBox(height: 5),
              Text('Subtitle 1', style: textTheme.titleMedium),
              SizedBox(height: 5),
              Text('Body Text 1', style: textTheme.bodyLarge),
              SizedBox(height: 5),
              Text('Body Text 2 (Default)', style: textTheme.bodyMedium),
              SizedBox(height: 5),
              Text('Caption', style: textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showToastDemo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This is a Toast (SnackBar) notification!'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(15),
        duration: Duration(seconds: 2),
      ),
    );
  }

   void _showSwitchDemo(BuildContext context) {
    bool isSwitched = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Switch Component'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: isSwitched,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (bool value) {
                  setState(() => isSwitched = value);
                },
              ),
              SwitchListTile(
                title: Text('Dark Mode'),
                value: !isSwitched,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (bool value) {
                  setState(() => isSwitched = !value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
          ],
        ),
      ),
    );
  }

   void _showSpinnerDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Spinner Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Loading data...'),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A5B)),
              strokeWidth: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showRangeSliderDemo(BuildContext context) {
    RangeValues currentRange = RangeValues(20, 80);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('RangeSlider Component'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Selected range: ${currentRange.start.round()} - ${currentRange.end.round()}'),
              RangeSlider(
                values: currentRange,
                min: 0,
                max: 100,
                divisions: 10,
                labels: RangeLabels(
                  currentRange.start.round().toString(),
                  currentRange.end.round().toString(),
                ),
                activeColor: Color(0xFFFF8A5B),
                inactiveColor: Color(0xFFFF8A5B).withOpacity(0.2),
                onChanged: (RangeValues values) {
                  setState(() => currentRange = values);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDividerDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Divider Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Item A'),
            SizedBox(height: 10),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
            SizedBox(height: 10),
            Text('Item B'),
            SizedBox(height: 10),
            Divider(
              color: Color(0xFFFF8A5B),
              thickness: 3,
              height: 20,
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(height: 10),
            Text('Item C'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  void _showLanguageDemo(BuildContext context) {
    String selectedLang = 'en';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Language Selection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text('English'),
                value: 'en',
                groupValue: selectedLang,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (value) =>
                    setState(() => selectedLang = value as String),
              ),
              RadioListTile(
                title: Text('Bahasa Indonesia'),
                value: 'id',
                groupValue: selectedLang,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (value) =>
                    setState(() => selectedLang = value as String),
              ),
              RadioListTile(
                title: Text('Español'),
                value: 'es',
                groupValue: selectedLang,
                activeColor: Color(0xFFFF8A5B),
                onChanged: (value) =>
                    setState(() => selectedLang = value as String),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
            ),
          ],
        ),
      ),
    );
  }

  // --- DEMO BARU & YANG DIPERBARUI ---

  // Demo untuk Charts (Diperbarui dari SnackBar)
  void _showChartsDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Charts Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Simple Pie Chart Demo'),
            SizedBox(height: 15),
            // Ini adalah demo Pie Chart sederhana menggunakan CustomPaint
            // Untuk chart nyata, gunakan package seperti fl_chart
            SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: SimplePieChartPainter(),
              ),
            ),
            SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: Colors.red, size: 14), Text(' Data A'),
                 SizedBox(width: 10),
                 Icon(Icons.circle, color: Colors.blue, size: 14), Text(' Data B'),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  // Demo untuk Treeview (Diperbarui dari SnackBar)
  void _showTreeviewDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Treeview Component'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ini adalah demo TreeView sederhana menggunakan ListTile
              // Untuk treeview nyata, gunakan ExpansionTile atau package
              ExpansionTile(
                leading: Icon(Icons.folder, color: Color(0xFFFF8A5B)),
                title: Text('Root Folder'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      leading: Icon(Icons.description, color: Colors.grey),
                      title: Text('File 1.txt'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ExpansionTile(
                       leading: Icon(Icons.folder_open, color: Color(0xFFFF8A5B)),
                       title: Text('Subfolder A'),
                       children: [
                         Padding(
                           padding: const EdgeInsets.only(left: 32.0),
                           child: ListTile(
                            leading: Icon(Icons.image, color: Colors.grey),
                            title: Text('Image.png'),
                           ),
                         ),
                       ],
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      leading: Icon(Icons.description, color: Colors.grey),
                      title: Text('File 2.txt'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  // Demo untuk Stepper (Diperbarui dari SnackBar)
  void _showStepperDemo(BuildContext context) {
    int currentStep = 0;
    showDialog(
      context: context,
      // Gunakan Dialog yang lebih besar agar Stepper muat
      builder: (context) => Dialog( 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text('Stepper Component', style: Theme.of(context).textTheme.titleLarge),
                 SizedBox(height: 10),
                // Stepper perlu ruang, jadi gunakan SingleChildScrollView
                SingleChildScrollView(
                  child: Stepper(
                    currentStep: currentStep,
                    onStepTapped: (step) => setState(() => currentStep = step),
                    onStepContinue: () {
                      if (currentStep < 2) {
                        setState(() => currentStep += 1);
                      } else {
                        // Selesai
                         Navigator.pop(context);
                      }
                    },
                    onStepCancel: () {
                      if (currentStep > 0) {
                        setState(() => currentStep -= 1);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    steps: [
                      Step(
                        title: Text('Step 1'),
                        subtitle: Text('Informasi Pribadi'),
                        content: Text('Isi data diri Anda di sini.'),
                        isActive: currentStep >= 0,
                        state: currentStep > 0 ? StepState.complete : StepState.indexed,
                      ),
                      Step(
                        title: Text('Step 2'),
                         subtitle: Text('Alamat'),
                        content: Text('Masukkan alamat lengkap.'),
                        isActive: currentStep >= 1,
                         state: currentStep > 1 ? StepState.complete : StepState.indexed,
                      ),
                      Step(
                        title: Text('Step 3'),
                         subtitle: Text('Konfirmasi'),
                        content: Text('Periksa kembali data Anda.'),
                        isActive: currentStep >= 2,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Demo untuk Lightgallery (Diperbarui dari SnackBar)
  void _showLightgalleryDemo(BuildContext context) {
    // Daftar URL gambar untuk galeri
    final List<String> imageUrls = [
      'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?q=80&w=2070&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?q=80&w=2070&auto=format&fit=crop',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Lightgallery Component'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tap an image to view'),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: imageUrls.map((url) {
                return GestureDetector(
                  onTap: () {
                    // Saat gambar diketuk, tampilkan dalam dialog penuh
                    _showFullImage(context, url);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      // Tampilkan loading spinner saat gambar dimuat
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Center(child: CircularProgressIndicator(color: Color(0xFFFF8A5B)));
                      },
                      // Tampilkan ikon error jika gagal
                      errorBuilder: (context, error, stackTrace) {
                         return Icon(Icons.error, color: Colors.red);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  // Fungsi helper untuk menampilkan gambar penuh
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context), // Tutup dialog saat gambar diketuk
          child: InteractiveViewer( // Memungkinkan zoom dan pan
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : Center(child: CircularProgressIndicator(color: Colors.white));
              },
               errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.error, color: Colors.red, size: 50));
               },
            ),
          ),
        ),
      ),
    );
  }


  // Demo untuk Timeline (Diperbarui dari SnackBar)
  void _showTimelineDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Timeline Component'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ini adalah demo Timeline sederhana menggunakan Row, Column, dan Icon
              // Untuk timeline nyata, gunakan package seperti timeline_tile
              _buildTimelineStep(
                icon: Icons.check_circle,
                iconColor: Color(0xFFFF8A5B),
                title: 'Order Placed',
                subtitle: 'Nov 7, 2025, 02:00 AM',
                isLast: false,
              ),
              _buildTimelineStep(
                icon: Icons.local_shipping,
                 iconColor: Color(0xFFFF8A5B),
                title: 'Shipped',
                subtitle: 'Nov 7, 2025, 02:10 AM',
                isLast: false,
              ),
               _buildTimelineStep(
                icon: Icons.home,
                iconColor: Colors.grey,
                title: 'Delivered',
                subtitle: 'Pending...',
                isLast: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF8A5B))),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk Timeline
  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: iconColor),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget CustomPainter untuk Pie Chart Sederhana
class SimplePieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    Paint paintA = Paint()..color = Colors.red;
    Paint paintB = Paint()..color = Colors.blue;

    // Data A (60%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Mulai dari atas
      (2 * math.pi) * 0.60, // 60%
      true,
      paintA,
    );

    // Data B (40%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      (-math.pi / 2) + (2 * math.pi) * 0.60, // Mulai dari akhir Data A
      (2 * math.pi) * 0.40, // 40%
      true,
      paintB,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}