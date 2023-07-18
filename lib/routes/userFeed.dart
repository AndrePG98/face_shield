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
        title: Text('User'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.pushNamed(context, '/contactInfo');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Welcome to FaceShield',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: Image.asset('assets/images/avatar.png').image,
                ),
                title: Text('Username'),
                subtitle: Text('user_email@example.com'),
              ),
            ),
            SizedBox(height: 16.0),
        GestureDetector(
          onTap: () {
            _launchInWebView('https://maxim-thomas.medium.com/how-to-implement-adaptive-authentication-using-machine-learning-52045219abf8');
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/1.webp',
                  fit: BoxFit.cover,
                  height: 200,
                ),
                Padding(
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
            SizedBox(height: 24,),
            GestureDetector(
              onTap: () {
                _launchInWebView('https://maxim-thomas.medium.com/passwordless-authenticaion-methods-4f169bdfedeb');
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/2.jpeg',
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                    Padding(
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
            SizedBox(height: 24,),
            GestureDetector(
              onTap: () {
                _launchInWebView('https://www.linkedin.com/pulse/machine-learning-only-identity-authentication-risky-marc-pickren/');
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/3.png',
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                    Padding(
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
            SizedBox(height: 24,),
            GestureDetector(
              onTap: () {
                _launchInWebView('https://www.csoonline.com/article/562373/article-32.html');
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/jpeg',
                      fit: BoxFit.cover,
                      height: 200,
                    ),
                    Padding(
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
            SizedBox(height: 24,),
        ]
      ),),
    );
  }
}

class WebsitePage extends StatelessWidget {
  final String url;

  WebsitePage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Website'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Open the website link in a browser
          },
          child: Text('Open Website'),
        ),
      ),
    );
  }
}
