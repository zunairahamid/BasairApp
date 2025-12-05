import 'package:basair_real_app/features/quran_viewer/view/screens/quran_viewer_screen.dart';
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
            builder: (context) => QuranViewerScreen(pageNumber: page),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 70, color: Colors.black),
                    const SizedBox(height: 15),
                    const Text(
                      'Wrong Page Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 2.0,
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter a page number between\n 1 & 604.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Ok',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                color: Colors.black,
                fontFamily: 'CrimsonText',
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search_outlined,
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
