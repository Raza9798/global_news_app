import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_news_app/screens/DetailedNews.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  List<String> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final pref = await SharedPreferences.getInstance();
    List<String>? bookmarkList = pref.getStringList('bookmarks');

    if (bookmarkList != null) {
      setState(() {
        bookmarks = bookmarkList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Bookmarks"),
        ),
        body: ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            print(bookmarks[index]);
            Map<String, dynamic> bookmark = jsonDecode(bookmarks[index]);
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(bookmark['image']!),
              ),
              title: Text(bookmark['title']),
              subtitle: Text(bookmark['subtitle']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  setState(() {
                    bookmarks.removeAt(index);
                  });
                  final pref = await SharedPreferences.getInstance();
                  pref.setStringList('bookmarks', bookmarks);
                },
              ),
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedNews(
                      title: bookmark['title'],
                      image: bookmark['image'],
                      source: bookmark['subtitle'],
                      content: bookmark['content'],
                    ),
                  ),
                )
              },
            );
          },
        ));
  }
}
