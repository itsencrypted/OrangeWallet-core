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

class CovalentApiWrapper {
  static const baseUrl = "https://staking.api.matic.network/";

  static Future<Validators> validatorsList() async {
    Validators ctl;
    String url = baseUrl + 'api/v1/validators';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = Validators.fromJson(json);
    return ctl;
  }

  static Future<StakedCount> getStakedCount() async {
    StakedCount ctl;
    String url = baseUrl + 'api/v1/validators/metadata/stakedCount';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = StakedCount.fromJson(json);
    return ctl;
  }

  static Future<ValidatorDetail> validatorsDetail(int id) async {
    ValidatorDetail ctl;
    String url = baseUrl + 'api/v1/validators/' + id.toString();
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = ValidatorDetail.fromJson(json);
    return ctl;
  }

  static Future<ValidatorReward> getValidatorsReward(int id) async {
    ValidatorReward ctl;
    String url = baseUrl + 'api/v1/validators/' + id.toString() + 'rewards';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = ValidatorReward.fromJson(json);
    return ctl;
  }

  static Future<Delegators> delegatorsList() async {
    Delegators ctl;
    String url = baseUrl + 'api/v1/delegators';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = Delegators.fromJson(json);
    return ctl;
  }

  static Future<DelegatorDetail> delegatorDetails(String address) async {
    DelegatorDetail ctl;
    String url = baseUrl + 'api/v1/delegators' + address;
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = DelegatorDetail.fromJson(json);
    return ctl;
  }

  static Future<RewardsSummary> getRewardsSummary() async {
    RewardsSummary ctl;
    String url = baseUrl + 'api/v1/rewards/summary';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = RewardsSummary.fromJson(json);
    return ctl;
  }

  static Future<MaticStakingRatio> getMaticStakingRatio() async {
    MaticStakingRatio ctl;
    String url = baseUrl + 'api/v1/monitor/matic-staking-ratio';
    var resp = await http.get(url);
    var json = jsonDecode(resp.body);
    ctl = MaticStakingRatio.fromJson(json);
    return ctl;
  }
}
