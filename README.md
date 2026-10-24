# My Dotfiles

My cross-platform dotfiles for Git and Bash. While this setup works perfectly on Linux and Mac, its primary focus is solving the notoriously tricky Windows environment. By pairing **GNU Stow** with **MSYS2**, it brings a seamless *NIX-style configuration management experience natively to Windows without relying on WSL.

## 🛠️ Configured Tools

Currently, this repository includes configurations for:

* **Bash** (`bash/`): Custom profiles, path definitions, and environment variables.
* **Git** (`git/`): Global configurations, default behaviors, and aliases.

## Setup

```bash
git clone https://github.com/jishnuteegala/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh   # requires GNU Stow (pacman/brew/apt)
```

## Machine-local overrides

Nothing machine-specific is committed:

* `~/.gitconfig.local` - included last by `.gitconfig`; override `signingkey`, `gpgsign`, or credential helpers per machine.
* `~/.agents/` - the private ai-config repo (agent rules, skills, harness config). `.bashrc` sources it through a single guarded include line, so this repo carries no private content.

## 🪟 Using Windows?
Want a native *NIX experience on Windows without WSL? Managing dotfiles on Windows using standard Git Bash is notoriously tricky because of how Windows handles symlinks and `AppData` paths. 

I have created a comprehensive guide on how to solve this by pairing **MSYS2** with the **Git for Windows** engine. 

👉 **[Read the Complete Windows / MSYS2 Setup Guide here](WINDOWS_SETUP.md)**

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
