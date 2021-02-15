import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/io_client.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:share/share.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExportMnemonic extends StatefulWidget {
  @override
  _ExportMnemonicState createState() => _ExportMnemonicState();
}

class _ExportMnemonicState extends State<ExportMnemonic> {
  String mnemonic;
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);
  GoogleSignInAccount googleSignInAccount;
  ga.FileList list;
  final storage = new FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var signedIn = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loginWithGoogle() async {
    signedIn = await storage.read(key: "signedIn") == "true" ? true : false;
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount googleSignInAccount) async {
      if (googleSignInAccount != null) {
        _afterGoogleLogin(googleSignInAccount);
      }
    });
    if (signedIn) {
      try {
        googleSignIn.signInSilently().whenComplete(() => () {});
      } catch (e) {
        storage.write(key: "signedIn", value: "false").then((value) {
          setState(() {
            signedIn = false;
          });
        });
      }
    } else {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      _afterGoogleLogin(googleSignInAccount);
    }
  }

  Future<void> _afterGoogleLogin(GoogleSignInAccount gSA) async {
    googleSignInAccount = gSA;
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');

    storage.write(key: "signedIn", value: "true").then((value) {
      setState(() {
        signedIn = true;
      });
    });
  }

  _uploadFileToGoogleDrive() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/mnemonic.txt");
    await file.writeAsString('$mnemonic');
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();
    fileToUpload.name = path.basename(file.absolute.path);
    var response = await drive.files.create(
      fileToUpload,
      uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
    );
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    mnemonic = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        brightness: Brightness.light,
        title: Text("Receive Payment"),
      ),
      body: mnemonic == null
          ? Center(
              child: SpinKitFadingFour(
                size: 40,
                color: AppTheme.primaryColor,
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight20),
                    child: Text(
                      mnemonic,
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      style: AppTheme.title,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(AppTheme.paddingHeight / 2),
                            child: RawMaterialButton(
                              fillColor: AppTheme.primaryColor,
                              elevation: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.all(AppTheme.paddingHeight20),
                                child: Icon(Icons.file_copy_outlined),
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                    new ClipboardData(text: mnemonic));
                                Fluttertoast.showToast(
                                  msg: "Mnemonic copied",
                                );
                              },
                              shape: CircleBorder(),
                            ),
                          ),
                          Text(
                            "Copy",
                            style: AppTheme.body1,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(AppTheme.paddingHeight),
                            child: RawMaterialButton(
                              fillColor: AppTheme.primaryColor,
                              elevation: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.all(AppTheme.paddingHeight20),
                                child: Icon(Icons.cloud_upload),
                              ),
                              onPressed: () async {
                                // await _loginWithGoogle();
                                // await _uploadFileToGoogleDrive();
                              },
                              shape: CircleBorder(),
                            ),
                          ),
                          Text(
                            "Export",
                            style: AppTheme.body1,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
