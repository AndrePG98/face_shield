import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserFeed extends StatelessWidget {
  Future<void> _launchInWebView(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.pushNamed(context, '/contactInfo');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          const Text(
            'Welcome to FaceShield',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://www.pngmart.com/files/22/User-Avatar-Profile-PNG-Isolated-Transparent-Picture.png'),
              ),
              title: Text('Username'),
              subtitle: Text('user_email@example.com'),
            ),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              _launchInWebView(
                  'https://maxim-thomas.medium.com/how-to-implement-adaptive-authentication-using-machine-learning-52045219abf8');
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    'https://miro.medium.com/v2/resize:fit:720/format:webp/1*E4Yjtipel8NocTqS7a66EQ.jpeg',
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'How to Implement Adaptive Authentication Using Machine Learning',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () {
              _launchInWebView(
                  'https://maxim-thomas.medium.com/passwordless-authenticaion-methods-4f169bdfedeb');
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    'https://miro.medium.com/v2/resize:fit:1100/format:webp/1*N0PH-U3LjWgaMqIKiHFfVw.jpeg',
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Passwordless Authenticaion Methods',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () {
              _launchInWebView(
                  'https://www.linkedin.com/pulse/machine-learning-only-identity-authentication-risky-marc-pickren/');
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    'https://media.licdn.com/dms/image/D5612AQEY4jqRscAzkw/article-cover_image-shrink_720_1280/0/1678392748229?e=1694649600&v=beta&t=WuUw1Rjv-PukgBAi1SlH7obvNNgRTwvWRaYE4GCcNE4',
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Machine Learning Only Identity Authentication is Risky for Businesses and Corporations',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () {
              _launchInWebView(
                  'https://www.csoonline.com/article/562373/article-32.html');
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    'https://www.csoonline.com/wp-content/uploads/2023/06/rsa_bp_article-6_istock-457795741-copy-100729880-orig.jpg?resize=2048%2C1536&quality=50&strip=all',
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Authentication and Machine Learning: Taking Behavior Recognition to a New Level',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
        ]),
      ),
    );
  }
}

class WebsitePage extends StatelessWidget {
  final String url;

  WebsitePage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Website'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Open the website link in a browser
          },
          child: const Text('Open Website'),
        ),
      ),
    );
  }
}
