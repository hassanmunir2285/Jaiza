import 'package:flutter/material.dart';

import 'PrayerCardUI.dart';

// Data model for each feature tile
class Feature {
  final String title;
  final String urduTitle;
  final IconData icon;
  final Color color;

  const Feature({
    required this.title,
    required this.urduTitle,
    required this.icon,
    required this.color,
  });
}

// Full list of features categorized and mapped to icons/colors
final List<Feature> appFeatures = [
  // --- Core Utilities ---
  Feature(
    title: 'Zakat Calculator',
    urduTitle: 'زكوة كلكوليثر',
    icon: Icons.calculate,
    color: Colors.teal,
  ),
  Feature(
    title: 'Qibla Finder',
    urduTitle: 'قبلة',
    icon: Icons.explore,
    color: Colors.blueAccent,
  ),
  Feature(
    title: 'Islamic Calendar',
    urduTitle: 'اسلامى كلنشر',
    icon: Icons.calendar_month,
    color: Colors.amber,
  ),
  Feature(
    title: 'Islamic Names',
    urduTitle: 'بچوں کے اسلامی نام',
    icon: Icons.people_alt,
    color: Colors.pink,
  ),
  Feature(
    title: 'Nikah Form/Format',
    urduTitle: 'نكاح فوم',
    icon: Icons.favorite,
    color: Colors.redAccent,
  ),
  Feature(
    title: 'Dar al-Ifta (Fatwas)',
    urduTitle: 'دار الافتاء',
    icon: Icons.gavel,
    color: Colors.indigo,
  ),
  Feature(
    title: 'Hijri Date Widget',
    urduTitle: 'اسلامى تاريخ/گهنرى',
    icon: Icons.widgets,
    color: Colors.orange,
  ),

  // --- Reminders & Trackers ---
  Feature(
    title: 'Du\'a Reminder',
    urduTitle: 'دعايىReminder',
    icon: Icons.access_alarm,
    color: Colors.lightGreen,
  ),
  Feature(
    title: 'Adhkar Reminder',
    urduTitle: 'اذكارReminder',
    icon: Icons.alarm_on,
    color: Colors.green,
  ),
  Feature(
    title: 'Muraqaba Reminder',
    urduTitle: 'مراقبہReminder',
    icon: Icons.self_improvement,
    color: Colors.cyan,
  ),
  Feature(
    title: 'Duty Tracker',
    urduTitle: 'فرض نماز +...',
    icon: Icons.check_circle,
    color: Colors.deepPurple,
  ),
  Feature(
    title: 'Monthly Result Report',
    urduTitle: 'monthly رزلٹ',
    icon: Icons.leaderboard,
    color: Colors.brown,
  ),
  Feature(
    title: 'Self-Assessment',
    urduTitle: 'جائزه',
    icon: Icons.assessment,
    color: Colors.blueGrey,
  ),
  Feature(
    title: 'Ayyam-e-Beez Reminder',
    urduTitle: 'ايام بيض كا ريمانر',
    icon: Icons.nights_stay,
    color: Colors.purple,
  ),

  // --- Practical & Learning ---
  Feature(
    title: 'Wudu & Salah Guide',
    urduTitle: 'وضو + غسل + نماز',
    icon: Icons.volunteer_activism,
    color: Colors.teal.shade700,
  ),
  Feature(
    title: 'Akhlaqiaat (Ethics)',
    urduTitle: 'اخلاقیات',
    icon: Icons.handshake,
    color: Colors.lime,
  ),

  // --- Short Courses/Knowledge Modules ---
  Feature(
    title: 'Seerat (Prophet\'s Life)',
    urduTitle: 'سيرت',
    icon: Icons.person_pin_circle,
    color: Colors.teal.shade300,
  ),
  Feature(
    title: 'Tafseer Course',
    urduTitle: 'تفسير كوررس',
    icon: Icons.menu_book,
    color: Colors.blue.shade300,
  ),
  Feature(
    title: 'Islamic History',
    urduTitle: 'تاريخ اسلام',
    icon: Icons.history_edu,
    color: Colors.amber.shade300,
  ),
  Feature(
    title: 'Islamic Business',
    urduTitle: 'اسلامک بزنس',
    icon: Icons.business_center,
    color: Colors.pink.shade300,
  ),
  Feature(
    title: 'Arabic Language Course',
    urduTitle: 'عربي كوررس',
    icon: Icons.language,
    color: Colors.red.shade300,
  ),
  Feature(
    title: 'Fiqh (Jurisprudence)',
    urduTitle: 'فقہ',
    icon: Icons.balance,
    color: Colors.indigo.shade300,
  ),
  Feature(
    title: 'Usool al-Hadith',
    urduTitle: 'اصول حديث',
    icon: Icons.book,
    color: Colors.orange.shade300,
  ),
  Feature(
    title: 'Donation',
    urduTitle: 'ڈونیشن',
    icon: Icons.attach_money,
    color: Colors.lightGreen.shade300,
  ),
];

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic Feature App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF0D47A1), // Deep Blue for a rich feel
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Islamic App Features',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            PrayerCardScreen(),
            SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                // MANDATORY requirement: 2 features per row
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.9, // Adjust height of the card slightly
                ),
                itemCount: appFeatures.length,
                itemBuilder: (context, index) {
                  final feature = appFeatures[index];
                  return FeatureCard(feature: feature);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Feature feature;

  const FeatureCard({required this.feature, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Placeholder action: You will implement navigation here later
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on: ${feature.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, size: 40, color: feature.color),
              ),

              const Spacer(),

              // Titles Section (English and Urdu)
              Text(
                feature.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              // Urdu/Arabic title for context
              Text(
                feature.urduTitle,
                textAlign: TextAlign.center,
                // Using a custom font for better Arabic/Urdu display is recommended in a real app
                style: TextStyle(
                  fontSize: 14,
                  color: feature.color,
                  fontFamily: 'Amiri', // Placeholder for an appropriate font
                ),
                textDirection:
                    TextDirection.rtl, // Ensure right-to-left display
              ),
            ],
          ),
        ),
      ),
    );
  }
}
