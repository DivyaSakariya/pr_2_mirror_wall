import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Browser"),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.home),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.bookmark_add),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.arrow_back_ios_new_outlined),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.refresh_outlined),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.arrow_forward_ios_outlined),
//           ),
//         ],
//       ),
//     );
//   }
// }
//

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Connectivity connectivityResult = Connectivity();

  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          bool willPS = await webViewController!.canGoBack();

          if (willPS) {
            webViewController!.goBack();
          }
          return !willPS;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Netflix"),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmarks),
              ),
              Visibility(
                // visible: ,
                child: IconButton(
                  onPressed: () {
                    provider.backBtn();
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              IconButton(
                onPressed: () {
                  provider.webViewController!.reload();
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
              Visibility(
                visible: provider.canForward,
                child: IconButton(
                  onPressed: () {
                    provider.forwardBtn();
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: connectivityResult.onConnectivityChanged,
            builder: (context, snapShot) {
              if (snapShot.hasData) {
                ConnectivityResult result = snapShot.data!;

                if (result == ConnectivityResult.none) {
                  return const Center(
                    child: Text('No internet connection'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return InAppWebView(
                pullToRefreshController: pullToRefreshController,
                initialUrlRequest:
                    URLRequest(url: Uri.parse("https://www.google.com/")),
                onWebViewCreated: (controller) {},
                onLoadStart: (controller, url) {},
                onLoadStop: (controller, url) {},
              );
            },
          ),
        ),
      ),
    );
  }
}
