import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter_clone/resources/auth_method.dart';
import 'package:instagram_flutter_clone/screens/login_screen.dart';

import '../utils/colors.dart';
import '../widgets/follow_button.dart';
import '../resources/firestore_methods.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  var postLen = 0;
  var followers = [];
  var following = [];
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    // try {
    DocumentSnapshot userSnap = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.uid)
        .get();

    // Get posts length
    var postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: (userSnap.data() as Map)['uid'])
        .get();
    postLen = postSnap.docs.length;

    // Followers
    followers = (userSnap.data() as Map)['folowers'];

    // Following
    following = (userSnap.data() as Map)['folowing'];

    isFollowing = (userSnap.data() as Map)['folowers']
        .contains(FirebaseAuth.instance.currentUser!.uid);

    userData = userSnap.data() as Map;

    setState(() {});
    // } catch (err) {
    //   showSnackBar(err.toString(), context);
    // }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username'] ?? 'username'),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: userData['photoUrl'] != null
                                ? NetworkImage(userData['photoUrl'])
                                : null,
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, 'Posts'),
                                    buildStatColumn(
                                        followers.length, 'Followers'),
                                    buildStatColumn(
                                        following.length, 'Following'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: 'Sign out',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await AuthMethods().signOut();
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen()));
                                            },
                                          )
                                        : userData == {}
                                            ? CircularProgressIndicator()
                                            : isFollowing
                                                ? FollowButton(
                                                    text: 'Unfollow',
                                                    backgroundColor:
                                                        Colors.white,
                                                    textColor: Colors.black,
                                                    borderColor: Colors.grey,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .followUser(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              userData['uid']);
                                                      var followersNew = [
                                                        ...followers
                                                      ];
                                                      followersNew.removeWhere(
                                                          (item) =>
                                                              item ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid);
                                                      setState(() {
                                                        isFollowing = false;
                                                        followers =
                                                            followersNew;
                                                      });
                                                    },
                                                  )
                                                : FollowButton(
                                                    text: 'Follow',
                                                    backgroundColor:
                                                        Colors.blue,
                                                    textColor: Colors.white,
                                                    borderColor: Colors.blue,
                                                    function: () async {
                                                      await FirestoreMethods()
                                                          .followUser(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              userData['uid']);
                                                      var followersNew = [
                                                        ...followers
                                                      ];
                                                      followersNew.add(
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid);
                                                      setState(() {
                                                        isFollowing = true;
                                                        followers =
                                                            followersNew;
                                                      });
                                                    },
                                                  )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'] ?? 'username',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'] ?? 'bio...',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return Container(
                          child: Image(
                            image: NetworkImage(
                              (snap.data() as dynamic)['postUrl'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
