import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/invite/invite_model.dart';

class InviteBloc {
  String myIdentity;
  ChatClient chatClient;
  ChannelDescriptor channelDescriptor;
  late BehaviorSubject<InviteModel> _inviteSubject;
  late ValueStream<InviteModel> inviteStream;

  InviteBloc({
    required this.myIdentity,
    required this.chatClient,
    required this.channelDescriptor,
  }) {
    _inviteSubject = BehaviorSubject<InviteModel>();
    _inviteSubject.add(InviteModel());
    inviteStream = _inviteSubject.stream;
    _getUsers();
  }

  Future inviteToChannel(Member member) async {
    var channel = await channelDescriptor.getChannel();
    await channel?.members.invite(member);
  }

  Future _getUsers() async {
    _inviteSubject.add(_inviteSubject.value.copyWith(isLoading: true));
    var currentChannel = await channelDescriptor.getChannel();
    var membersOfCurrentChannel = await currentChannel?.members.getMembersList();
    if (membersOfCurrentChannel != null) {
      var memberIdsForCurrentChannel = membersOfCurrentChannel.map((m) => m.identity).toList();
      var userChannels = await chatClient.channels.getUserChannelsList();
      var membersMap = await _handlePagination(userChannels, memberIdsForCurrentChannel, {});

      _inviteSubject.add(_inviteSubject.value.copyWith(isLoading: false, membersMap: membersMap));
    }
  }

  Future<Map<String, Member>> _handlePagination(
    Paginator<ChannelDescriptor> paginator,
    List<String?> membersIdsForCurrentChannel,
    Map<String, Member> membersMap,
  ) async {
    for (var channelDescriptor in paginator.items) {
      var uMembersCount = channelDescriptor.membersCount;
      if (uMembersCount == null || uMembersCount <= 0) {
        continue;
      }
      var channel = await channelDescriptor.getChannel();
      var members = await channel?.members.getMembersList();
      if (members != null) {
        for (var member in members) {
          var uIdentity = member.identity;
          if (uIdentity != null && uIdentity != myIdentity && !membersIdsForCurrentChannel.contains(uIdentity) && !membersMap.keys.contains(uIdentity)) {
            membersMap[uIdentity] = member;
          }
        }
      }
    }

    if (paginator.hasNextPage) {
      var nextPage = await paginator.requestNextPage();
      return _handlePagination(nextPage, membersIdsForCurrentChannel, membersMap);
    } else {
      return membersMap;
    }
  }

  Future dispose() async {
    await _inviteSubject.close();
  }
}
