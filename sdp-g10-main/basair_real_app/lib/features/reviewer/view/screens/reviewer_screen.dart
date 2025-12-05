import 'package:basair_real_app/features/reviewer/view/screens/surah_resources_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basair_real_app/features/sign_in/view/screens/signin_screen.dart';

final supabase = Supabase.instance.client;

class ReviewerScreen extends StatelessWidget {
  const ReviewerScreen({super.key});

  // You can expand this to all 114 surahs later
  static const Map<int, String> _surahNames = {
    1: 'Al-Fatiha',
    2: 'Al-Baqarah',
    3: 'Aal Imran',
    4: 'An-Nisa',
    5: 'Al-Ma\'idah',
    6: 'Al-An\'am',
    7: 'Al-A\'raf',
    8: 'Al-Anfal',
    9: 'At-Tawbah',
    10: 'Yunus',
    11: 'Hud',
    12: 'Yusuf',
    13: 'Ar-Ra\'d',
    14: 'Ibrahim',
    15: 'Al-Hijr',
    16: 'An-Nahl',
    17: 'Al-Isra',
    18: 'Al-Kahf',
    19: 'Maryam',
    20: 'Ta-Ha',
    21: 'Al-Anbiya',
    22: 'Al-Hajj',
    23: 'Al-Mu\'minun',
    24: 'An-Nur',
    25: 'Al-Furqan',
    26: 'Ash-Shu\'ara',
    27: 'An-Naml',
    28: 'Al-Qasas',
    29: 'Al-Ankabut',
    30: 'Ar-Rum',
    31: 'Luqman',
    32: 'As-Sajdah',
    33: 'Al-Ahzab',
    34: 'Saba',
    35: 'Fatir',
    36: 'Ya-Sin',
    37: 'As-Saffat',
    38: 'Sad',
    39: 'Az-Zumar',
    40: 'Ghafir',
    41: 'Fussilat',
    42: 'Ash-Shura',
    43: 'Az-Zukhruf',
    44: 'Ad-Dukhan',
    45: 'Al-Jathiyah',
    46: 'Al-Ahqaf',
    47: 'Muhammad',
    48: 'Al-Fath',
    49: 'Al-Hujurat',
    50: 'Qaf',
    51: 'Adh-Dhariyat',
    52: 'At-Tur',
    53: 'An-Najm',
    54: 'Al-Qamar',
    55: 'Ar-Rahman',
    56: 'Al-Waqi\'ah',
    57: 'Al-Hadid',
    58: 'Al-Mujadila',
    59: 'Al-Hashr',
    60: 'Al-Mumtahanah',
    61: 'As-Saff',
    62: 'Al-Jumu\'ah',
    63: 'Al-Munafiqun',
    64: 'At-Taghabun',
    65: 'At-Talaq',
    66: 'At-Tahrim',
    67: 'Al-Mulk',
    68: 'Al-Qalam',
    69: 'Al-Haqqah',
    70: 'Al-Ma\'arij',
    71: 'Nuh',
    72: 'Al-Jinn',
    73: 'Al-Muzzammil',
    74: 'Al-Muddathir',
    75: 'Al-Qiyamah',
    76: 'Al-Insan',
    77: 'Al-Mursalat',
    78: 'An-Naba',
    79: 'An-Nazi\'at',
    80: 'Abasa',
    81: 'At-Takwir',
    82: 'Al-Infitar',
    83: 'Al-Mutaffifin',
    84: 'Al-Inshiqaq',
    85: 'Al-Buruj',
    86: 'At-Tariq',
    87: 'Al-A\'la',
    88: 'Al-Ghashiyah',
    89: 'Al-Fajr',
    90: 'Al-Balad',
    91: 'Ash-Shams',
    92: 'Al-Layl',
    93: 'Adh-Dhuha',
    94: 'Ash-Sharh',
    95: 'At-Tin',
    96: 'Al-Alaq',
    97: 'Al-Qadr',
    98: 'Al-Bayyinah',
    99: 'Az-Zalzalah',
    100: 'Al-Adiyat',
    101: 'Al-Qari\'ah',
    102: 'At-Takathur',
    103: 'Al-Asr',
    104: 'Al-Humazah',
    105: 'Al-Fil',
    106: 'Quraysh',
    107: 'Al-Ma\'un',
    108: 'Al-Kawthar',
    109: 'Al-Kafirun',
    110: 'An-Nasr',
    111: 'Al-Masad',
    112: 'Al-Ikhlas',
    113: 'Al-Falaq',
    114: 'An-Nas',
  };

  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.indigo[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _executeLogout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeLogout(BuildContext context) async {
    // Sign out from Supabase Auth
    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Auth signout error: $e');
    }

    // Navigate to signin screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _surahNames.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.indigo[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Assalam O Alaikum',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Reviewer – Choose a Surah',
                      key: ValueKey('reviewer_screen_title'),
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'CrimsonText',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _performLogout(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final surahNumber = entries[index].key;
                final surahName = entries[index].value;

                return Card(
                  color: const Color.fromARGB(255, 173, 181, 223),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  child: ListTile(
                    key: ValueKey('reviewer_surah_$surahNumber'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        '$surahNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      surahName,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: const Text(
                        'Review',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahResourcesReviewScreen(
                            surahId: surahNumber,
                            surahName: surahName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
