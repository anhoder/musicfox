import 'package:musicfox/ui/bottom_out_content.dart';
import 'package:colorful_cmd/component.dart';
import 'package:musicfox/ui/menu_content/artist_albums.dart';
import 'package:musicfox/ui/menu_content/artist_songs.dart';
import 'package:musicfox/ui/menu_content/i_menu_content.dart';

class Artist implements IMenuContent {

  final int _artistId;

  Artist(this._artistId);

  @override
  Future<BottomOutContent> bottomOut(WindowUI ui) => null;

  @override
  Future<String> getContent(WindowUI ui) => null;

  @override
  Future<IMenuContent> getMenuContent(WindowUI ui, int index) {
    switch (index) {
      case 0:
        return Future.value(ArtistSongs(_artistId));
      case 1:
        return Future.value(ArtistAlbums(_artistId));
    }
    return null;
  }

  @override
  String getMenuId() => 'Artist()';

  @override
  Future<List<String>> getMenus(WindowUI ui) {
    return Future.value([
      '热门歌曲',
      '热门专辑',
    ]);
  }

  @override
  bool get isPlayable => false;

  @override
  bool get isResetPlaylist => false;
  
  @override
  bool get isDjMenu => false;
}