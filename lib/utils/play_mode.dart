enum PlaylistMode {
  ORDER,      // 顺序播放
  LIST_LOOP,  // 列表循环
  SINGLE_LOOP,// 单曲循环
  SHUFFLE,    // 随机播放
}

const Map<PlaylistMode, String> PLAY_MODE = {
  PlaylistMode.ORDER: '顺序',
  PlaylistMode.LIST_LOOP: '列表',
  PlaylistMode.SINGLE_LOOP: '单曲',
  PlaylistMode.SHUFFLE: '随机',
};

const Map<String, PlaylistMode> NAME_TO_PLAY_MODE = {
  '顺序': PlaylistMode.ORDER,
  '列表': PlaylistMode.LIST_LOOP,
  '单曲': PlaylistMode.SINGLE_LOOP,
  '随机': PlaylistMode.SHUFFLE,
};