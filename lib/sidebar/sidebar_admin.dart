import 'package:flutter/material.dart';
import 'package:flutter_ios/app_details/about_page.dart';
import 'package:flutter_ios/app_details/contact_page.dart';
import 'package:flutter_ios/app_details/faqs_page.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/auth/forgot_pass.dart';
import 'package:flutter_ios/auth/login_screen.dart';
import 'package:flutter_ios/calendar.dart';
import 'package:flutter_ios/user_admin/all_activities.dart';
import 'package:flutter_ios/user_admin/create_event.dart';
import 'package:flutter_ios/user_admin/dashboard_admin.dart';
import 'package:flutter_ios/user_admin/degree_program.dart';
import 'package:flutter_ios/user_admin/organization_list.dart';
import 'package:flutter_ios/user_admin/profile.dart';

class CollapsibleSidebarAdmin extends StatelessWidget {
  const CollapsibleSidebarAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/osa.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: null//Text('Admin'), // You can add child widgets here if needed
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.lightGreen,),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            },
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Administration'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.lock_outlined),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPassword(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_pin),
                title: const Text('Sub-Admin'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO Navigate to the Sub-Admin page
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messaging'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO Navigate to the Messaging page
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.group),
            title: const Text('Organizations'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Organization List'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrganizationList()
                    ),
                  );
                }
              ),
              ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Degree Program List'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DegreeProgramPage()
                      ),
                    );
                  }
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.event),
            title: const Text('Events and Activities'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Create Event'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateEventPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notification_important),
                title: const Text('For Approval'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO Navigate to the For Approval page
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Approved Activities'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO Navigate to the Approved Activities page
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Calendar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalendarPage(sidebar: CollapsibleSidebarAdmin(),)
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_activity_outlined),
                title: const Text('All Activities'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllActivities()
                    ),
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminProfilePage()
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              await auth.signout(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "about",
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(sidebar: CollapsibleSidebarAdmin(),),
                          ),
                        );
                      },
                      child: const Icon(Icons.info),
                    ),
                    const SizedBox(height: 4.0),
                    const Text('About'),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "contact",
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactPage(sidebar: CollapsibleSidebarAdmin(),),
                          ),
                        );
                      },
                      child: const Icon(Icons.contact_phone),
                    ),
                    const SizedBox(height: 4.0),
                    const Text('Contact'),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "faqs",
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQsPage(sidebar: CollapsibleSidebarAdmin(),),
                          ),
                        );
                      },
                      child: const Icon(Icons.help),
                    ),
                    const SizedBox(height: 4.0),
                    const Text('FAQs'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
