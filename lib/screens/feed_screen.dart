import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_flutter_clone/utils/global_variables.dart';

import '../utils/colors.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: width > webScreenSize
                  ? webBackgroundColor
                  : mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/images/ic_instagram.svg',
                color: primaryColor,
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.messenger_outline,
                  ),
                ),
              ],
            ),
      body: StreamBuilder(
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width > 2 * webScreenSize
                      ? width * 0.3
                      : width > webScreenSize
                          ? width * 0.15
                          : 0),
              child: PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            ),
          );
        },
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      ),
    );
  }
}
