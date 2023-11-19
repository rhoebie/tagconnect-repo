import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taguigconnect/constants/color_constant.dart';
import 'package:taguigconnect/models/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final ScrollController _scrollController = ScrollController();
  List<NewsModel> newsData = [];
  List<NewsModel> filteredNewsData = [];
  int currentPage = 1;
  int totalPage = 1;
  bool isLoadingMore = false;

  void filterNews(String query) {
    query = query.toLowerCase();
    setState(() {
      if (query.isEmpty || query == '') {
        // Show all contacts when the query is empty or null
        filteredNewsData = List.from(newsData);
      } else {
        // Filter based on the search query
        filteredNewsData = newsData
            .where((news) => news.title!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> fetchNewsData({int page = 1}) async {
    if (page > totalPage) {
      // No more data to fetch
      setState(() {
        isLoadingMore = false;
      });
      print('no more page');
      return;
    }

    try {
      final url = 'https://taguigconnect.online/api/get-news?page=$page';
      final response = await http.get(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        List<NewsModel> fetchNewsList =
            data.map((item) => NewsModel.fromJson(item)).toList();

        // Sort the list based on the date
        fetchNewsList.sort((a, b) => a.date!.compareTo(b.date!));
        setState(() {
          if (page == 1) {
            newsData = fetchNewsList;
            filteredNewsData = newsData;
          } else {
            newsData.addAll(fetchNewsList);
            filteredNewsData.addAll(fetchNewsList);
          }
          totalPage = responseData['meta']['total_page'];
          currentPage = page;
          isLoadingMore = false;
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNewsData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Reached the end of the list, load more data
        setState(() {
          isLoadingMore = true;
        });
        fetchNewsData(page: currentPage + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tcWhite,
      appBar: AppBar(
        leading: BackButton(),
        iconTheme: IconThemeData(color: tcBlack),
        backgroundColor: tcWhite,
        elevation: 0,
        title: Text(
          'NEWS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: tcBlack,
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final Uri launchUri =
                  Uri.parse('https://www.manilatimes.net/news');
              await launchUrl(launchUri);
            },
            icon: Icon(Icons.language_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: tcWhite,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) {
                              filterNews(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: tcGray,
                              ),
                              icon: Icon(
                                Icons.search,
                                color: tcGray,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return filteredNewsData[index]
                        .buildContactWidget(context, filteredNewsData[index]);
                  },
                  childCount: filteredNewsData.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 50,
                  margin: EdgeInsetsDirectional.symmetric(vertical: 15),
                  child: Center(
                    child: isLoadingMore
                        ? CircularProgressIndicator()
                        : Container(
                            child: Text(
                              'End of List',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: tcBlack,
                              ),
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
