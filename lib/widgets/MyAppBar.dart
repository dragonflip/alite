import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
  final String title;

  MyAppBar([this.title = 'ABillS']);

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final showBackButton = route != '/' && route != '/tariffs' && route != '/profile' && route != '/more';

    return AppBar(
      title: this.title == 'ABillS' ? RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 26),
          children: [
            TextSpan(text: 'A', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            TextSpan(text: 'BillS', style: TextStyle(color: Colors.black54)),
          ]
        ),
      ) : Text(this.title, style: TextStyle(color: Colors.black87)),

      backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      centerTitle: true,

      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black54),

      automaticallyImplyLeading: showBackButton,
      actions: [
        this.title == 'ABillS' ? IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
          icon: Icon(Icons.notifications),
          tooltip: 'Сповіщення',
        ) : Wrap(),
        SizedBox(width: 4),
      ],
    );
  }
}