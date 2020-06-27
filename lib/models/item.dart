class Item {
    String title;
    bool isCompleted;

    Item({this.title, this.isCompleted = false});

    Item.fromJson(Map<String, dynamic> json) {
        title = json['title'];
        isCompleted = json['isCompleted'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['title'] = this.title;
        data['isCompleted'] = this.isCompleted;
        return data;
    }
}