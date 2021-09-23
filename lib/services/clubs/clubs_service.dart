import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kick_chat/models/club_model.dart';

class ClubService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Club>> getClubs(String country, String league) async {
    List<Club> _clubsList = [];
    QuerySnapshot result =
        await firestore.collection(country.toLowerCase()).where('league', isEqualTo: league).get();
    await Future.forEach(result.docs, (DocumentSnapshot club) {
      try {
        Club clubModel = Club.fromJson(club.data() as Map<String, dynamic>);
        _clubsList.add(clubModel);
      } catch (e) {
        throw e;
      }
    });
    return _clubsList;
  }
}
