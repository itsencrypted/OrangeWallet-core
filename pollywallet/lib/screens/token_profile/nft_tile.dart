import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/send_token_model/send_token_data.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
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

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
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
              title: Text(data.externalData.name),
              subtitle: Text(
                data.externalData.description,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
