import 'package:flutter/material.dart';
import 'package:flutter_ios/app_details/about_page.dart';
import 'package:flutter_ios/app_details/contact_page.dart';
import 'package:flutter_ios/app_details/faqs_page.dart';
import 'package:flutter_ios/auth/auth_service.dart';
import 'package:flutter_ios/auth/login_screen.dart';
import 'package:flutter_ios/calendar.dart';
import 'package:flutter_ios/user_organization/announcements.dart';
import 'package:flutter_ios/user_organization/dashboard_org.dart';
import 'package:flutter_ios/user_organization/profile.dart';
import 'package:flutter_ios/user_organization/report_event.dart';
import 'package:flutter_ios/user_organization/request_event.dart';

class CollapsibleSidebarOrganization extends StatelessWidget {
  const CollapsibleSidebarOrganization({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Organization'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.lightGreen,),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrganizationUserDashboard()),
              );
            },
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Request Events'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestEventPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Report Event'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportEventPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Calendar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarPage(sidebar: CollapsibleSidebarOrganization(),)),
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Announcements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnnouncementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrgProfilePage()),
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
                            builder: (context) => const AboutPage(sidebar: CollapsibleSidebarOrganization()),
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
                            builder: (context) => const ContactPage(sidebar: CollapsibleSidebarOrganization()),
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
                            builder: (context) => const FAQsPage(sidebar: CollapsibleSidebarOrganization()),
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
