enum Status {
  STOPPED,
  PAUSED,
  PLAYING,
}

Map<Status, int> STATUS_VALUES = {
  Status.STOPPED: 0,
  Status.PAUSED: 1,
  Status.PLAYING: 2,
};

Map<int, Status> VALUE_STATUS = {
  0: Status.STOPPED,
  1: Status.PAUSED,
  2: Status.PLAYING,
};

class PlayerStatus {
  Status status = Status.STOPPED;
  int statusValue = 0;

  void setStatus(int statusValue) {
    this.statusValue = statusValue;
    status = VALUE_STATUS[statusValue];
  }
}