import 'package:flutter/material.dart';
import 'package:global_news_app/screens/Bookmark.dart';
import 'package:global_news_app/screens/DetailedNews.dart';
import 'package:global_news_app/screens/SearchNewsScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/AppConfig.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> dataList = [];
  bool isLoading = true;
  String selectedSortOption = 'publishedAt';
  String _tempSortOption = 'publishedAt';
  String selectedCategory = 'business';
  List<String> existingBookmarks = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadData(selectedCategory, selectedSortOption);
    final pref = await SharedPreferences.getInstance();
    existingBookmarks = pref.getStringList('bookmarks') ?? [];
  }

  Future<void> loadData(String category, String sortBy) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl}/top-headlines?country=us&category=${category}&sortBy=${sortBy}&apiKey=${AppConfig.apiKey}'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> articles = jsonData['articles'];

        setState(() {
          dataList = articles
              .where((item) => item['content'] != null)
              .where((item) => item['urlToImage'] != null)
              .map((item) => {
                    'title': item['title'].toString(),
                    'subtitle': item['source']['name'].toString(),
                    'image': item['urlToImage'].toString(),
                    'content': item['content'].toString(),
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void sort() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Sort By'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: _tempSortOption,
                      items: const [
                        DropdownMenuItem(
                          value: 'relevancy',
                          child: Text('Relevancy'),
                        ),
                        DropdownMenuItem(
                          value: 'popularity',
                          child: Text('Popularity'),
                        ),
                        DropdownMenuItem(
                          value: 'publishedAt',
                          child: Text('Published At'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _tempSortOption = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSortOption = _tempSortOption;
                        });
                        loadData(selectedCategory, selectedSortOption);
                        Navigator.of(context).pop();
                      },
                      child: Text('Sort'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            items: const [
              DropdownMenuItem(
                value: 'business',
                child: Text('Business'),
              ),
              DropdownMenuItem(
                value: 'entertainment',
                child: Text('Entertainment'),
              ),
              DropdownMenuItem(
                value: 'health',
                child: Text('Health'),
              ),
              DropdownMenuItem(
                value: 'science',
                child: Text('Science'),
              ),
              DropdownMenuItem(
                value: 'sports',
                child: Text('Sports'),
              ),
              DropdownMenuItem(
                value: 'technology',
                child: Text('Technology'),
              ),
            ],
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
              loadData(selectedCategory, selectedSortOption);
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                bool isBookmarked =
                    existingBookmarks.contains(jsonEncode(dataList[index]));

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(dataList[index]['image']!),
                  ),
                  title: Text(dataList[index]['title']!),
                  subtitle: Text(dataList[index]['subtitle']!),
                  trailing: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.blue : null,
                    ),
                    onPressed: () async {
                      final pref = await SharedPreferences.getInstance();
                      String jsonBookmark = jsonEncode(dataList[index]);

                      setState(() {
                        if (existingBookmarks.contains(jsonBookmark)) {
                          existingBookmarks.remove(jsonBookmark);
                        } else {
                          existingBookmarks.add(jsonBookmark);
                        }
                      });

                      pref.setStringList('bookmarks', existingBookmarks);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedNews(
                          title: dataList[index]['title']!,
                          image: dataList[index]['image']!,
                          source: dataList[index]['subtitle']!,
                          content: dataList[index]['content']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Bookmark()),
              )
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            heroTag: 'bookmark',
            child: const Icon(Icons.bookmark_add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: sort,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            heroTag: 'sort',
            child: const Icon(Icons.sort, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SearchNewsScreen()),
              )
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            heroTag: 'search',
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
