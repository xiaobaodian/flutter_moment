

enum TaskState {
  StandBy,
  Complete,
  Delete,
  Execute,
  Await,
  Archive,
}

enum TaskPriority {
  Higher,
  High,
  Middle,
  Lower,
  Low,
}

class CycleDate {
  int cycleUnit;
  int cycleTime;
  int cycleYear;
  int cycleMonth;
  int cycleDay;
  int cycleWeek;
  int cycleWeekDay;
}

class TaskItem {
  TaskItem({
    this.boxId = 0,
    this.focusItemId = 0,
    this.title = '',
    this.comment = '',
    this.placeItemId = 0,
    this.priority,
    this.state = TaskState.StandBy,
    this.createDateTime,
    this.startDateTime,
    this.dueDateTime,
    this.allDay = 1,
    this.cycleDate,
    this.subTasks = '',
    this.context = '',
    this.tags = '',
    this.remindPlan = 0,
    this.shareTo = '',
    this.author = 0,
    this.delegate = 0,
  });

  int boxId;
  int focusItemId;
  String title;
  String comment;
  int placeItemId;
  TaskPriority priority;
  TaskState state;
  DateTime createDateTime;
  DateTime startDateTime;
  DateTime dueDateTime;
  int allDay;
  CycleDate cycleDate;
  String subTasks;
  String context;
  String tags;
  int remindPlan;
  String shareTo;
  int author;
  int delegate;

  String getTimeString() {
    return '8:30 - 11:15';
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      boxId: json['boxId'],
      focusItemId: json['focusItemId'],
      title: json['title'],
      comment: json['comment'],
      placeItemId: json['placeItemId'],
      priority: TaskPriority.values[json['priority']],
      state: TaskState.values[json['state']],
      createDateTime: DateTime.parse(json['createDateTime']),
      startDateTime: DateTime.parse(json['startDateTime']),
      dueDateTime: DateTime.parse(json['dueDateTime']),
      allDay: json['allDay'],
      //cycleDate: json['cycleDate'],
      subTasks: json['subTasks'],
      context: json['context'],
      tags: json['tags'],
      remindPlan: json['remindPlan'],
      shareTo: json['shareTo'],
      author: json['author'],
      delegate: json['delegate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'boxId': boxId,
    'focusItemId': focusItemId,
    'title': title,
    'comment': comment,
    'placeItemId': placeItemId,
    'priority': priority.index,
    'state': state.index,
    'createDateTime': createDateTime.toIso8601String(),
    'startDateTime': startDateTime.toIso8601String(),
    'dueDateTime': dueDateTime.toIso8601String(),
    'allDay': allDay,
    //'cycleDate': cycleDate,
    'subTasks': subTasks,
    'context': context,
    'tags': tags,
    'remindPlan': remindPlan,
    'shareTo': shareTo,
    'author': author,
    'delegate': delegate,
  };
}