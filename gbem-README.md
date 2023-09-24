# Ground Branch Enhanced Mod

## Pull the repo to your existing game directory (Linux)

Since git refuses to clone to a non-empty directory, this procedure has to be
used to pull the repo into your local game directory.

```sh
cd ~/.local/share/Steam/steamapps/common/Ground Branch
git init
git remote add origin git@github.com:Ninjamamia/ground-branch-enhanced-mod.git
git fetch
git checkout -t origin/main
```
