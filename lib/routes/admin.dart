import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the FaceShield admin panel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage('https://www.pngmart.com/files/22/User-Avatar-Profile-PNG-Isolated-Transparent-Picture.png'),
                ),
                title: Text('Username'),
                subtitle: Text('email@example.com'),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Total Number of Users',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '123',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Last Sign Up Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '01/07/2023',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/listusers');
              },
              child: Text('List Users'),
            ),
          ],
        ),
      ),
    );
  }
}
