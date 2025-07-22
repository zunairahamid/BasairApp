import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart' as custom_user;


final supabase = Supabase.instance.client;
class ShellScreen extends StatefulWidget {
  final Widget? child;
  final custom_user.User? user;
  const ShellScreen({super.key, this.child, this.user});

  @override
  _ShellScreenState createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            const Center(child: Text("بصائر ")),
                      ]),
              ),
      body: widget.child,
    );
  }
}
