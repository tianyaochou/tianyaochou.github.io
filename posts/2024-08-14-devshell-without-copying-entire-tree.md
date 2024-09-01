---
title: Devshell in flake without copying entire tree
draft: true
---

If your devshell does not rely on project files, put `flake.nix` in a sub-folder, say `.flake`. Then use `path:.flake` instead of `.flake` to direct nix to find files through filesystem instead of git. This helps avoid copying the entire project to nix store and save spaces.

This copying can also be avoided by using shell.nix instead of flakes.
