import 'package:flutter/material.dart';
import 'package:sdp_quran_navigator/display/quran_viewer_screen.dart';

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
            builder: (context) => QuranViewerScreen(pageNumber: page),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid page number (1 to 604).',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'CrimsonText',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red[300],
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
            cursorColor: Colors.black,
            controller: _searchController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'CrimsonText',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "Page Number",
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'CrimsonText',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.black,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(70),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              filled: true,
              fillColor: Colors.indigo[100],
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: _navigateToPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(70),
            ),
          ),
          child: Text(
            "Go",
            style: TextStyle(
              color: Colors.black,
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
