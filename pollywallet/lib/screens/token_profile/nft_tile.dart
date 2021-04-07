import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/theme_data.dart';

class NftTile extends StatelessWidget {
  final NftData data;

  const NftTile({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.43,
        child: Card(
          shape: AppTheme.cardShape,
          elevation: AppTheme.cardElevations,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
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
              ),
              ListTile(
                title: Text(data.externalData.name),
                subtitle: Text(
                  data.externalData.description,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
