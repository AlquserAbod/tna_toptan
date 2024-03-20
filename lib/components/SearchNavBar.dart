import 'package:flutter/material.dart';
import 'package:tna_toptan/components/page_title.dart';


class SearchNavbar extends StatelessWidget {
  final String title;
  final Function? onSearch;

  const SearchNavbar({super.key, required this.title,this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 , vertical: 5),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PageTitle(title: title),
        IconButton(
        onPressed: () {
          if (onSearch != null) {
            onSearch!(); // Call the onSearch function if it's not null
          }
        },
        icon: Icon(Icons.search))
      ],
    ),
    );
  }
}