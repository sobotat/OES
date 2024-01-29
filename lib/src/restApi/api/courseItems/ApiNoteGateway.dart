
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Note.dart';
import 'package:oes/src/restApi/interface/courseItems/NoteGateway.dart';

class ApiNoteGateway extends NoteGateway {

  @override
  Future<Note?> get(int courseId, int id) {
    return Future.delayed(Duration(milliseconds: 200),() {
      return Note(
          id: id,
          name:'Programing 1',
          created: DateTime.now(),
          createdById: AppSecurity.instance.user!.id,
          isVisible: true,
          data: """          
- First
- Second
- Third
                   
Some **more** *text*
              
## Types    
1. Vars
2. Functions
3. Classes

> some info

---
### Code
```java
public static void main(String args[]) {  
  System.out.println("Hello World");  
}
```
```bash
  ./something
```
---

# Image
![Image](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfjL9xNhvpuUtKH9v-a1X_FD0BRg7lrFBTIo0Fz7reTywPZwVMRVkYrzVp1q0v-BlVrnw&usqp=CAU)

                """
      );
    });
  }

  @override
  Future<Note?> create(int courseId, Note note) async {
    // TODO: implement create
    print("Creating -> ${note.toMap()}");
    return note;
  }

  @override
  Future<Note?> update(int courseId, Note note) async {
    // TODO: implement update
    print("Updating -> ${note.toMap()}");
    return note;
  }

  @override
  Future<bool> delete(int courseId, int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

}