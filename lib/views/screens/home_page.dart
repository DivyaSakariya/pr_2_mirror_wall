import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

enum SampleItem { allBookmarks, searchEngine }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Connectivity? connectivityResult;
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  bool canBack = false;
  bool canForward = false;
  int visibleProgress = 0;
  String selectedUrl = "https://www.google.com/";
  SampleItem? selectedMenu;
  List<String> bookmarks = [];

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    refreshController = PullToRefreshController(
      onRefresh: () {
        webViewController!.reload();
      },
    );
  }

  checkConnectivity() async {
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.9),
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please connect to the internet and try again.'),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    String textData = '';
    String textUrl =
        "https://www.google.com/search?q=$textData&oq=$textData&aqs=chrome.0.69i59j69i60l3j69i65l3j69i60.1707j0j7&sourceid=chrome&ie=UTF-8";

    loadUrl(String url) {
      if (webViewController != null) {
        webViewController!.loadUrl(
          urlRequest: URLRequest(
            url: Uri.parse(url),
          ),
        );
      }
    }

    showModel() {
      showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bookmarks[index]),
                    IconButton(
                      onPressed: () {
                        bookmarks.remove(selectedUrl);
                      },
                      icon: const Icon(Icons.bookmark_remove),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    setSelectedUrl({required value}) {
      selectedUrl = value;
    }

    showSearchDialog({required BuildContext context}) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(
                child: Text("Search Engine"),
              ),
              actions: [
                RadioListTile(
                  title: const Text("Google"),
                  value: "https://www.google.com/",
                  groupValue: selectedUrl,
                  onChanged: (value) {
                    setSelectedUrl(value: value);
                    loadUrl(selectedUrl);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text("Yahoo"),
                  value: "https://in.search.yahoo.com/?fr2=inr",
                  groupValue: selectedUrl,
                  onChanged: (value) {
                    setSelectedUrl(value: value);
                    loadUrl(selectedUrl);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text("Bing"),
                  value: "https://www.bing.com/",
                  groupValue: selectedUrl,
                  onChanged: (value) {
                    setSelectedUrl(value: value);
                    loadUrl(selectedUrl);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text("Duck Duck Go"),
                  value: "https://duckduckgo.com/",
                  groupValue: selectedUrl,
                  onChanged: (value) {
                    setSelectedUrl(value: value);
                    loadUrl(selectedUrl);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }

    return WillPopScope(
      onWillPop: () async {
        bool willPS = await webViewController!.canGoBack();

        if (willPS) {
          webViewController!.goBack();
        }
        return !willPS;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Browser"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  selectedUrl = "https://www.google.com/";
                });
              },
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                var currentUrl = selectedUrl;
                bookmarks.add(currentUrl);
              },
              icon: const Icon(Icons.bookmark_add),
            ),
            Visibility(
              visible: canBack,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    webViewController!.goBack();
                  });
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
            IconButton(
              onPressed: () {
                webViewController!.reload();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
            Visibility(
              visible: canForward,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    webViewController!.goForward();
                  });
                },
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ),
            PopupMenuButton<SampleItem>(
              initialValue: selectedMenu,
              onSelected: (value) {
                if (value == SampleItem.allBookmarks) {
                  showModel();
                } else if (value == SampleItem.searchEngine) {
                  showSearchDialog(context: context);
                }
              },
              offset: const Offset(0, 50),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<SampleItem>>[
                  PopupMenuItem<SampleItem>(
                    value: SampleItem.allBookmarks,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.book),
                        Text("All Bookmarks"),
                      ],
                    ),
                  ),
                  PopupMenuItem<SampleItem>(
                    value: SampleItem.searchEngine,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.screen_search_desktop_outlined),
                        Text("Search Engine"),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Visibility(
              visible: visibleProgress != 100,
              child: LinearProgressIndicator(
                value: visibleProgress / 100,
              ),
            ),
            Expanded(
              child: InAppWebView(
                pullToRefreshController: refreshController,
                initialUrlRequest: URLRequest(url: Uri.parse(selectedUrl)),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() async {
                    canBack = await webViewController!.canGoBack();
                    canForward = await webViewController!.canGoForward();
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() async {
                    canBack = await webViewController!.canGoBack();
                    canForward = await webViewController!.canGoForward();
                  });
                  refreshController!.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    visibleProgress = progress;
                  });
                  if (visibleProgress == 100) {
                    refreshController!.endRefreshing();
                  }
                },
              ),
            ),
            TextField(
              controller: textEditingController,
              onChanged: (val) {
                textData = val;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Select or type web address",
                suffixIcon: IconButton(
                  onPressed: () {
                    var search = textEditingController.text;
                    webViewController!.loadUrl(
                      urlRequest: URLRequest(
                        url: Uri.parse(
                            "https://www.google.com/search?q=$search"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
