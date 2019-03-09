

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
    this.priority = TaskPriority.Middle,
    this.state = TaskState.StandBy,
    this.createDate = 0,
    this.startDate = 0,
    this.dueDate = 0,
    this.time = '',
    this.allDay = 1,
    //this.cycleDate,
    this.subTasks = '',
    this.context = '',
    this.tags = '',
    this.remindPlan = 0,
    this.shareTo = '',
    this.author = 0,
    this.delegate = 0,
  });

  TaskItem.copyWith(TaskItem other){
    this.boxId = other.boxId;
    this.focusItemId = other.focusItemId;
    this.title = other.title;
    this.comment = other.comment;
    this.placeItemId = other.placeItemId;
    this.priority = other.priority;
    this.state = other.state;
    this.createDate = other.createDate;
    this.startDate = other.startDate;
    this.dueDate = other.dueDate;
    this.time = other.time;
    this.allDay = other.allDay;
    //this.cycleDate,
    this.subTasks = other.subTasks;
    this.context = other.context;
    this.tags = other.tags;
    this.remindPlan = other.remindPlan;
    this.shareTo = other.shareTo;
    this.author = other.author;
    this.delegate = other.delegate;
  }

  int boxId;
  int focusItemId;
  String title;
  String comment;
  int placeItemId;
  TaskPriority priority;
  TaskState state;
  int createDate;
  int startDate;
  int dueDate;
  String time;
  int allDay;
  //CycleDate cycleDate;
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
      createDate: json['createDate'],
      startDate: json['startDate'],
      dueDate: json['dueDate'],
      time: json['time'],
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
    'createDate': createDate,
    'startDate': startDate,
    'dueDate': dueDate,
    'time': time,
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