import 'package:flutter/material.dart';

class DetailedNews extends StatefulWidget {
  const DetailedNews(
      {super.key,
      required this.title,
      required this.image,
      required this.source,
      required this.content});

  final String title;
  final String image;
  final String source;
  final String content;

  @override
  State<DetailedNews> createState() => _DetailedNewsState();
}

class _DetailedNewsState extends State<DetailedNews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.image),
              SizedBox(height: 16.0),
              Text(
                widget.content,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ));
  }
}
