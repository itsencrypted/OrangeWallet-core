import 'dart:convert';

import 'package:pollywallet/models/staking_models/delegator_details.dart';
import 'package:pollywallet/models/staking_models/delegators.dart';
import 'package:pollywallet/models/staking_models/matic_staking_ratio.dart';
import 'package:pollywallet/models/staking_models/rewards_summary.dart';
import 'package:pollywallet/models/staking_models/staked_count.dart';
import 'package:pollywallet/models/staking_models/validator_details.dart';
import 'package:pollywallet/models/staking_models/validator_rewards.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:http/http.dart' as http;
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';

class StakingApiWrapper {
  static const baseUrl = "https://staking.api.matic.network/";

  static Future<Validators> validatorsList() async {
    Validators ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.stakingEndpoint + '/validators';
    var resp = await http.get(url);
    //print(resp.body);

    if (resp.statusCode != 200) {
      print("Status code vlist: ${resp.statusCode}");
    }
    var json = jsonDecode(resp.body);
    ctl = Validators.fromJson(json);
    return ctl;
  }

  static Future<StakedCount> getStakedCount() async {
    StakedCount ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.stakingEndpoint + '/validators/metadata/stakedCount';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = StakedCount.fromJson(json);
    return ctl;
  }

  static Future<ValidatorDetail> validatorsDetail(int id) async {
    ValidatorDetail ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.stakingEndpoint + '/validators/' + id.toString();
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = ValidatorDetail.fromJson(json);
    return ctl;
  }

  static Future<ValidatorReward> getValidatorsReward(int id) async {
    ValidatorReward ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url =
        config.stakingEndpoint + '/validators/' + id.toString() + 'rewards';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = ValidatorReward.fromJson(json);
    return ctl;
  }

  static Future<DelegationsList> delegationsList() async {
    DelegationsList ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.stakingEndpoint + '/delegators';

    var resp = await http.get(url);
    //print(resp.body);

    var json = jsonDecode(resp.body);
    ctl = DelegationsList.fromJson(json);
    return ctl;
  }

  static Future<DelegationsPerAddress> delegationDetails(String address) async {
    DelegationsPerAddress ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    var address = await CredentialManager.getAddress();
    String url = config.stakingEndpoint + '/delegators/' + address;
    //print(url);
    var resp = await http.get(url);
    //print(resp.body);
    if (resp.statusCode != 200) {
      print("Status code dlist: ${resp.statusCode}");
    }
    var json = jsonDecode(resp.body);
    ctl = DelegationsPerAddress.fromJson(json);
    return ctl;
  }

  static Future<RewardsSummary> getRewardsSummary() async {
    RewardsSummary ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.stakingEndpoint + '/rewards/summary';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = RewardsSummary.fromJson(json);
    return ctl;
  }

  static Future<MaticStakingRatio> getMaticStakingRatio() async {
    MaticStakingRatio ctl;
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String url = config.stakingEndpoint + '/monitor/matic-staking-ratio';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = MaticStakingRatio.fromJson(json);
    return ctl;
  }
}
