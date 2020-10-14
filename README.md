# AutoAlignmentCanvas
#### iOS App / A canvas where shapes can align automatically

![](demo/demo.gif)

### Auto-align Rule

There is an object the user is trying to move, and some other objects on the canvas.

We should go through all the other objects to check if the moving object is close enough to another object's boundary.

If an object moves vertically and the distance between the left or right boundary of the moving object and another object is less than a given value, the moving object would align the object directly. The same logic for an object moves horizontally.

Meanwhile, an auxilary line connecting from the aligning object to the aligned object would be displayed.

Detailed implementation is shown in `private func autoAlign(aligningView: UIView, alignedView: UIView)` in [this file](https://github.com/yi-chin-huang/AutoAlignmentCanvas/blob/main/AutoAlignmentCanvas/ViewController.swift)
