import 'package:collegenet/models/users.dart';
import 'package:collegenet/pages/add_globalfiles.dart';
import 'package:collegenet/pages/add_localfiles.dart';
import 'package:collegenet/pages/homepage.dart';
import 'package:collegenet/services/auth.dart';
import 'package:collegenet/services/loading.dart';
import 'package:flutter/material.dart';
import 'package:collegenet/widgets/filepost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/loading.dart';

enum PageType {
  localPage,
  globalPage,
  editPage,
}
PageType status;
String pageName;
QuerySnapshot snapshot;
String init = "";
int cnt = 0;

class GlobalFiles extends StatefulWidget {
  GlobalFiles({
    this.auth,
    this.onSignedOut,
    this.user,
  });
  final AuthImplementation auth;
  final VoidCallback onSignedOut;
  final User user;
  @override
  _GlobalFilesState createState() => _GlobalFilesState();
}

class _GlobalFilesState extends State<GlobalFiles> {
  String college = currentUser.college;
  bool isLoading = false;
  List<FilePost> posts = [];
  TextEditingController searchControl = TextEditingController();
  rebuildfileposts() {
    print("working");
    switch (status) {
      case PageType.localPage:
        getLocalFileposts();
        break;
      case PageType.editPage:
        getMyFileposts();
        break;
      case PageType.globalPage:
        getGlobalFileposts();
        break;
      default:
        getLocalFileposts();
    }
    print("ok here");
    setState(() {
      init = "";
    });
    print(snapshot.documents);
  }

  buildfileposts(String query) {
    posts.clear();
    query = query.toLowerCase();
    List<Widget> fileposts = [];
    List<DocumentSnapshot> list = [], l = snapshot.documents;
    print("ok2");
    if (query != "") {
      list.clear();
      String cap;
      for (var i = 0; i < l.length; i++) {
        cap = l[i].data['caption'].toString().toLowerCase();
        if (cap.contains(query)) {
          list.add(l[i]);
        }
      }
    } else {
      list = l;
    }
    print("ok3");
    fileposts.clear();
    for (var i = 0; i < list.length; i++) {
      posts.add(FilePost(
        caption: list[i].data['caption'],
        college: list[i].data['college'],
        content: list[i].data['content'],
        fileExtension: list[i].data['fileExtension'],
        isFile: list[i].data['isFile'],
        isLocal: list[i].data['isLocal'],
        mediaUrl: list[i].data['mediaUrl'],
        postId: list[i].data['postId'],
        userId: list[i].data['userId'],
        username: list[i].data['username'],
        rebuild: rebuildfileposts,
      ));
    }
    if (posts.length == 0) {
      fileposts.add(SizedBox(
        height: 40,
      ));
      fileposts.add(Center(
        child: Text(
          "No Results found for the query",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20.0,
          ),
        ),
      ));
    } else {
      fileposts.add(SizedBox(
        height: 20,
      ));
      fileposts.add(Text(
        "Post Count:" + (posts.length).toString(),
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 20.0,
        ),
      ));
    }
    for (var i = 0; i < posts.length; i++) {
      if (posts[i] != null) {
        fileposts.add(posts[i]);
        // print(posts[i].caption);
      }
    }
    print("ok4");
    return Column(
      children: fileposts,
    );
  }

  handlePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(15),
            // backgroundColor: Color(0xffe2ded3),
            // shape: ShapeBorder().dimensions
            title: Center(
              child: Text(
                "Type of Upload",
                style: TextStyle(fontSize: 24, fontFamily: 'Lora'),
              ),
            ),

            children: <Widget>[
              Center(
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddGlobalFile(
                          rebuild: rebuildfileposts,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Add Globally",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              Center(
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLocalFile(
                          rebuild: rebuildfileposts,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Add in College",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              Center(
                child: SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        });
  }

  getGlobalFileposts() async {
    setState(() {
      isLoading = true;
    });
    snapshot =
        await localPostsRef.where("isLocal", isEqualTo: false).getDocuments();
    setState(() {
      isLoading = false;
      init = "";
    });
  }

  getMyFileposts() async {
    setState(() {
      isLoading = true;
    });
    snapshot = await localPostsRef
        .where("userId", isEqualTo: currentUser.id)
        .getDocuments();
    setState(() {
      isLoading = false;
      init = "";
    });
  }

  getLocalFileposts() async {
    setState(() {
      isLoading = true;
    });
    snapshot = await localPostsRef
        .where("college", isEqualTo: currentUser.college)
        .getDocuments();
    setState(() {
      isLoading = false;
      init = "";
    });
  }

  @override
  void initState() {
    super.initState();
    cnt = 0;
    getLocalFileposts();
    status = PageType.localPage;
    pageName = "College Files";
  }

  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text(
    "Files",
    style: TextStyle(
      fontFamily: 'Chelsea',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe2ded3),
      appBar: AppBar(
        backgroundColor: Color(0xff1a2639),
        title: this.cusSearchBar,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: this.cusIcon,
              onPressed: () {
                if (this.cusIcon.icon == Icons.search) {
                  setState(() {
                    this.cusIcon = Icon(Icons.cancel);
                    this.cusSearchBar = TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search here",
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      controller: searchControl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        setState(() {
                          init = value;
                        });
                      },
                      style: TextStyle(color: Colors.black, fontFamily: 'Lato'),
                    );
                  });
                } else {
                  setState(() {
                    searchControl.clear();
                    init = '';
                    this.cusIcon = Icon(Icons.search);
                    this.cusSearchBar = Text(
                      pageName,
                      style: TextStyle(
                        fontFamily: 'Chelsea',
                      ),
                    );
                  });
                }
              }),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Color(0xff1a2639),
              title: Text('Resource Manager'),
              automaticallyImplyLeading: false,
            ),
            // Divider(),
            ListTile(
              leading: Icon(Icons.business, size: 30),
              title: Text(
                'College Files',
                style: TextStyle(fontSize: 17),
              ),
              onTap: () {
                setState(() {
                  pageName = "College Files";
                  this.cusIcon = Icon(Icons.search);
                  this.cusSearchBar = Text(
                    pageName,
                    style: TextStyle(
                      fontFamily: 'Chelsea',
                    ),
                  );
                  status = PageType.localPage;
                  getLocalFileposts();
                  Navigator.pop(context);
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.blur_circular, size: 30),
              title: Text(
                'Global Files',
                style: TextStyle(fontSize: 17),
              ),
              onTap: () {
                setState(() {
                  pageName = "Global Files";
                  this.cusIcon = Icon(Icons.search);
                  this.cusSearchBar = Text(
                    pageName,
                    style: TextStyle(
                      fontFamily: 'Chelsea',
                    ),
                  );
                  status = PageType.globalPage;
                  getGlobalFileposts();
                  Navigator.pop(context);
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.library_books, size: 30),
              title: Text(
                'My files',
                style: TextStyle(fontSize: 17),
              ),
              onTap: () {
                setState(() {
                  pageName = "My Files";
                  this.cusIcon = Icon(Icons.search);
                  this.cusSearchBar = Text(
                    pageName,
                    style: TextStyle(
                      fontFamily: 'Chelsea',
                    ),
                  );
                  status = PageType.editPage;
                  getMyFileposts();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? circularProgress()
          : Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: buildfileposts(init),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 28,
        ),
        backgroundColor: Color(0xf408050a),
        foregroundColor: Colors.orange,
        onPressed: () {
          handlePost(context);
        },
      ),
    );
  }
}
