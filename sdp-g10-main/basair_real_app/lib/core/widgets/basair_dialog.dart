import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasairDialog {
  static void show({
    required BuildContext context,
    String title = 'Alert',
    String? message,
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.black,
    List<Map<String, VoidCallback?>>? actions,
    Padding? contentWidget,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: screenWidth * 0.85,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 5),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 70, color: iconColor),
                  SizedBox(height: 15),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 2.0,
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (message != null) ...[
                    SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (actions != null && actions.isNotEmpty
                            ? actions
                            : [
                                {'Ok': () => context.pop()}
                              ])
                        .map((action) {
                      final String text = action.keys.first;
                      final VoidCallback onPressed =
                          action.values.first ?? () => context.pop();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          width: 100,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: onPressed,
                            child: Text(
                              text,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
