import 'package:flutter/material.dart';

class PageDisplay extends StatefulWidget {
  const PageDisplay({super.key});

  @override
  _PageDisplayState createState() => _PageDisplayState();
}

class _PageDisplayState extends State<PageDisplay> {
  final TextEditingController _searchController = TextEditingController();

  void _navigateToPage() {
    String pageNumber = _searchController.text.trim();

    if (pageNumber.isNotEmpty) {
      int? page = int.tryParse(pageNumber);
      if (page != null && page <= 604 && page >= 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceholderScreen(pageNumber: page),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid page number (1 to 604).',
              style: TextStyle(
                color: const Color.fromARGB(213, 3, 22, 11),
                fontFamily: 'CrimsonText',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            showCloseIcon: true,
            closeIconColor: const Color.fromARGB(213, 3, 22, 11),
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 160,
              left: 10,
              right: 10,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            cursorColor: const Color.fromARGB(213, 3, 22, 11),
            controller: _searchController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: const Color.fromARGB(255, 197, 213, 198),
              fontFamily: 'CrimsonText',
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: "Page Number",
              hintStyle: TextStyle(
                color: const Color.fromARGB(255, 197, 213, 198),
                fontFamily: 'CrimsonText',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              filled: true,
              fillColor: const Color.fromARGB(136, 119, 183, 140),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: _navigateToPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(136, 119, 183, 140),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(70),
            ),
          ),
          child: Text(
            "Go",
            style: TextStyle(
              color: const Color.fromARGB(255, 197, 213, 198),
              fontFamily: 'CrimsonText',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final int pageNumber;

  const PlaceholderScreen({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quran Viewer')),
      body: Center(
        child: Text('Displaying Quran Page $pageNumber Through Quran Viewer'),
      ),
    );
  }
}
