import 'package:flutter/material.dart';
import 'package:responsi/pages/change_password_page.dart';
import 'package:responsi/pages/create_account_screen.dart';
import 'package:responsi/pages/enter_code_page.dart';
import 'package:responsi/pages/error_page.dart';
import 'package:responsi/pages/explore_page.dart';
import 'package:responsi/pages/forgot_password_page.dart';
import 'package:responsi/pages/search_page.dart';
import 'package:responsi/pages/settings_page.dart';
import 'package:responsi/pages/welcome_page.dart';
import 'package:responsi/pages/comments_page.dart';
import 'package:responsi/pages/notifications_page.dart';
import 'package:responsi/pages/sign_in_screen.dart';

class PagesMenuPage extends StatelessWidget {
  final Function(int)? onNavigateToIndex;

  const PagesMenuPage({Key? key, this.onNavigateToIndex}) : super(key: key);

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
          'Pages',
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
          _buildMenuItem(
            context,
            icon: Icons.home,
            iconColor: Color(0xFFFF8A5B),
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToIndex != null) {
                onNavigateToIndex!(0);
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite,
            iconColor: Color(0xFFFF8A5B),
            title: 'Welcome',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person,
            iconColor: Color(0xFFFF8A5B),
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToIndex != null) {
                onNavigateToIndex!(3); // Index Profile di bottom nav
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.grid_on,
            iconColor: Color(0xFFFF8A5B),
            title: 'Timeline',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.explore,
            iconColor: Color(0xFFFF8A5B),
            title: 'Explore',
            onTap: () {
              Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExplorePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info,
            iconColor: Color(0xFFFF8A5B),
            title: 'Comments',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please open comments from a post'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            iconColor: Color(0xFFFF8A5B),
            title: 'Setting',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.login,
            iconColor: Color(0xFFFF8A5B),
            title: 'Login',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (route) => false,
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.chat_bubble,
            iconColor: Color(0xFFFF8A5B),
            title: 'Chat List',
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToIndex != null) {
                onNavigateToIndex!(2); // Index Chat di bottom nav
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.send,
            iconColor: Color(0xFFFF8A5B),
            title: 'Chat',
            onTap: () {
              Navigator.pop(context);
              if (onNavigateToIndex != null) {
                onNavigateToIndex!(2); // Index Chat di bottom nav
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.notifications,
            iconColor: Color(0xFFFF8A5B),
            title: 'Notification',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.app_registration,
            iconColor: Color(0xFFFF8A5B),
            title: 'Sign Up',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAccountScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.key,
            iconColor: Color(0xFFFF8A5B),
            title: 'Forgot Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.password,
            iconColor: Color(0xFFFF8A5B),
            title: 'Otp',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnterCodePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.lock_reset,
            iconColor: Color(0xFFFF8A5B),
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.error,
            iconColor: Color(0xFFFF8A5B),
            title: 'Error Page',
            onTap: () {
              Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ErrorPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
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
}