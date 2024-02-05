import 'package:flutter/material.dart';
import 'package:global_news_app/screens/DetailedNews.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/AppConfig.dart';

class SearchNewsScreen extends StatefulWidget {
  const SearchNewsScreen({super.key});

  @override
  State<SearchNewsScreen> createState() => _SearchNewsScreenState();
}

class _SearchNewsScreenState extends State<SearchNewsScreen> {
  List<Map<String, String>> dataList = [];
  bool isLoading = true;
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData('tesla');
  }

  Future<void> loadData(String search) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl}/top-headlines?q=$search&country=us&category=business&sortBy=publishedAt&apiKey=${AppConfig.apiKey}'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Search news"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchTextController,
                    decoration: const InputDecoration(
                      hintText: 'Search ...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      String searchTerm = searchTextController.text;
                      loadData(searchTerm);
                    },
                  ),
                ),
              ],
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(dataList[index]['image']!),
                          ),
                          title: Text(dataList[index]['title']!),
                          subtitle: Text(dataList[index]['subtitle']!),
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
                  ),
          ],
        ),
      ),
    );
  }
}
