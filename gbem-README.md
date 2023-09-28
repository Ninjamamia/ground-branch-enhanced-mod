# Ground Branch Enhanced Mod (gbme)

The goal of this mod is to provide drop in replacements for vanilla game modes, with added
functionality to bring some more variety and fun to the game.

The only existing replacement game mode provided for now is *intel retrieval*.

The only added function is the actor *group randomiser* which allows map editors to control the
visibility of a actor, or group of actors, using the tag system directly in the mission editor.

## Usage

### Link the replacement script

First you need to link the the replacement _script_ provided from the _mission_ you want to edit.
To do that, load the said mission in the mission editor. Then click the sort of notepad icon on the
top left corner of the screen and in the drop down menu click on _select_.

A window will pop up where you can select the wanted script, those provided by this mod are grouped
under the `gbme/` directory (make sure to save your mission once you select the appropriate script).

### Group randomiser tags

To control the visibility of an actor, you need to set up some tags on the said actor. Here is the
list of available tags:

**`GroupRnd`**  
Mandatory for all actors you want to control using this randomiser.

**`group=<group_name>`**  
Arbitrary string used to group actors.  
Actors in the same group are processed together, some parameters only make sense in a group context.

**`act=<action>`**  
String `enable` or `disable`, defaults to `enable`.  
The state we want the actors to be set to. All actors not set to this state (because of the impact
of other parameters) will be set to the opposite state.

**`prob=<probability>`**  
Integer between `0` and `100`, defaults to `100`.  
Defines the probability (in percent) that the state is applied to the target actor(s).

**`num=<exact_number>`**  
Integer greater than `0`, defaults to the number of actors in the group.  
Used with the group parameter to control the number of actors to apply the state to. Selected actors
are chosen randomly. If this parameter is explicitly provided, max and min parameters will be
disregarded.

**`min=<minimum_number>`**  
Integer greater than `0`, defaults to `0`.  
Used with the group parameter to control the minimum number of actors to apply the state to. The
`num` parameter will be randomly chosen between the min value and the max value. Disregarded when
the `num` parameter is explicitly provided.

**`max=<maximum_number>`**  
Integer greater than `0`, defaults to the number of actors in the group.  
Used with the group parameter to control the maximum number of actors to apply the state to. The
`num` parameter will be randomly chosen between the min value and the max value. Disregarded when
the `num` parameter is explicitly provided.

### Example: at least one entry

A popular demand answered by this randomiser is to have meshes blocking all possible path to a
specific place and make sure at least one path is available during the game.

If you set up 3 meshes to block all entry points to a room, here is the tags you need to use:

mesh #1 tags
```
GroupRnd  
group=TheRoom  
act=disable  
min=1  
```
mesh #2 tags
```
GroupRnd  
group=TheRoom  
```
mesh #3 tags
```
GroupRnd  
group=TheRoom  
```

The tags of the first mesh can read like this: "disable at least 1 actor in this group".

As you can see, only one of the actors need to have all the tags, only the `GroupRnd` and `group=...`
tags are needed for the rest of them. This means that once you set up the group, it is extremely
easy to extend the group by just copy/pasting one it's actors (but the control actor).

Tags are merged in the group, and if duplicates parameters have different values then one of them
will overwrite the other (you want to avoid that).

### Naming convention

As you can guess from the example above, it is quite important to keep your actors tidy if you want
to keep track of what actor contains the tags to actually control the group. To achieve that it is
strongly advised to stick to a strong convention when it comes to naming your actors.

> You can rename an actor by pressing the F2 key while having one or more actor selected. If you
> rename multiple of them at the same time they will have the same name, followed by a unique number.

As a recommendation, all concerned actors names should follow this pattern: `GroupRnd_<name>_[ctrl_]<number>`.

Where:  
- `GroupRnd` is a flag to find all managed actors
- `<name>` is the group name / unique name if not part of a group
- `ctrl`: is only for the actor wearing the tags to control the group
- `<number>` is just the item number

Building on our previous example, this is what this should look like:

- mesh #1: `GroupRnd_TheRoom_ctrl_0`  
- mesh #2: `GroupRnd_TheRoom_0`  
- mesh #3: `GroupRnd_TheRoom_1`  

## Install

Choose a release from [this page](https://github.com/Ninjamamia/ground-branch-enhanced-mod/releases),
and download the source code archive of your choice.

Extract all files to your Ground Branch directory. This should not overwrite any local files since
the archive does not contain any files of the original game.

### Tested server provider

- [Citadel Servers](https://citadelservers.com/game-servers/ground-branch-game-server-hosting)

## Uninstall

The only currently existing way to uninstall is to manually delete all installed files.

List of installed files can be obtained by listing the release archive content.

## Development

### Pull the repo to your existing game directory (Linux)

Since git refuses to clone to a non-empty directory, this procedure has to be
used to pull the repo into your local game directory.

```sh
cd ~/.local/share/Steam/steamapps/common/Ground Branch
git init
git remote add origin git@github.com:Ninjamamia/ground-branch-enhanced-mod.git
git fetch
git checkout -t origin/main
```
