import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/theme_data.dart';

class NftDepositTile extends StatelessWidget {
  final NftData data;
  final bool selected;
  const NftDepositTile({Key key, this.data, this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String suffix = "";
    if (data.tokenBalance != null) {
      suffix = " (" + data.tokenBalance.toString() + "Tokens)";
    }
    var type;
    var url;
    try {
      url = data.externalData.image;
      var split = url.split(".");
      type = split.last;
    } catch (e) {
      url = "";
      type = "notFound";
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.42,
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.27,
              width: MediaQuery.of(context).size.width * 0.78,
              child: type == "svg"
                  ? SvgPicture.network(url)
                  : type == "notFound"
                      ? Image.asset(imageNotFoundIcon)
                      : Image.network(data.externalData.image,
                          errorBuilder: (context, _, __) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(imageNotFoundIcon),
                          );
                        }),
            ),
            ListTile(
              title: Text(data.externalData.name + suffix),
              subtitle: Text(
                data.externalData.description,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 24.0,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.circle,
                        size: 24.0,
                        color: Colors.white,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
