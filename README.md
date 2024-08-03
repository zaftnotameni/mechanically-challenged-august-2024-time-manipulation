# Time Manipulation - Mechanically Challenged August 2024

This is a simple project to exercise a time rewind mechanic in godot.

## Structure

- `/mechanically-challenged` - the isolated implementation of the mechanic
- `/game` - an example little scene using the mechanic

## Instructions

**Setup**:

- Copy the contents of the `/mechanically-challenged` folder to your project (anywhere).
- Define an action in your project's input map called `rewind`.

**Usage**:

- Add the `MechanicallyChallengedRewinder` node as a child of anything you want to rewind.
  - Binds itself to the scene root (`owner`) by default.
    - An alternative target can be setup via the `target` export.
  - Can define a resolution FPS via export (i.e.: how often data is collected).
  - Can define a maximum time to record for via export.
- Pressing the `rewind` action will rewind time in all rewinders.

## Approach

Drop in script that defines a new type of node and requires **zero** changes in your code to use it.

The `MechanicallyChallengedRewinder` will keep track of parameters from its `target` and playback on `rewind`.

While performing the playback, the game will be `paused`, which disables processing by default.
That means: physics, collisions, input, etc is all disabled while the playback takes place.

When the first rewinder enters the tree, a central controller node (internal API) is automatically
added to the root of the current scene. The controller node orchestrates the rewinding process on all
rewinder nodes (you can technically have as many as you want on your scene - of course _too_ many would cause performance issues).


## Limitations

Only the following aspects of your object can be tracked/rewinded:

- Position
- Rotation
- Skew
- Scale

No creation/destruction of objects.

The rewinder will use physics updates to keep track of data,
which should suffice for most character/enemy/object movement.

If the target object is affected by something else that runs outside of the physics udpate (e.g.: Tweens),
trying to record the affected data will be off by 1 frame.

