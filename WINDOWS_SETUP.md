# 🪟 The Ultimate Windows Dotfiles Guide (MSYS2 + Stow)

This guide adapts [bashbunni's dotfiles philosophy](https://github.com/bashbunni/dotfiles) for a Windows environment. We use **MSYS2** to get a blazing-fast, native Windows Git engine combined with a real Linux package manager (`pacman`) to install GNU Stow, all while keeping the familiar Windows `$HOME` directory (`C:\Users\YourName`).

## Part 1: Prerequisites & Environment Setup

Before touching your dotfiles, we need to configure Windows and MSYS2 to play nicely together so that `stow` can create real Windows symlinks in your actual user folder.

### 1. Turn on Windows Developer Mode
* Navigate to **Settings** -> **Privacy & Security** -> **For developers**.
* Toggle **Developer Mode** ON. 
*(Without this, Windows blocks standard users from creating the symlinks that `stow` relies on).*

### 2. Install MSYS2
* Download and install the latest release from [msys2.org](https://www.msys2.org/).
* Open the **MSYS2 UCRT64** terminal from your Start Menu.

### 3. Fix the `$HOME` Directory Path
By default, MSYS2 isolates its home directory (e.g., `C:\msys64\home\user`). We need to tell it to use your actual Windows profile (`C:\Users\user`) just like Git Bash does.
1. Open the configuration file by running: `nano /etc/nsswitch.conf`
2. Find the line that says `db_home: cygwin desc`.
3. Comment out the old line instead of deleting it, then add the Windows version directly below it so you can easily revert later if needed.
4. Your file should look like this:
    ```text
    # Begin /etc/nsswitch.conf

    passwd: files db
    group: files db

    db_enum: cache builtin

    # db_home: cygwin desc

    db_home: windows cygwin desc
    db_shell: cygwin desc
    db_gecos: cygwin desc

    # End /etc/nsswitch.conf
    ```
5. Save the file (`Ctrl+O`, `Enter`, `Ctrl+X`).
6. **Restart the MSYS2 UCRT64 terminal.** When you reopen it, type `pwd` and ensure it outputs your Windows user folder (e.g., `/c/Users/your_username`).

### 4. Enable Windows PATH Inheritance
By default, MSYS2 aggressively hides your Windows tools (like Node.js, VS Code, Python, etc.) to prevent conflicts. Git Bash doesn't do this, which is why things often break in MSYS2 but work in Git Bash.
To fix this, we need to instruct MSYS2 to inherit your Windows PATH. 

Run this command in **CMD or PowerShell** (not inside the MSYS terminal yet) to set it permanently for your user profile:
```powershell
setx MSYS2_PATH_TYPE inherit
```

> **⚠️ Note on Environment Isolation:** MSYS2 defaults to isolation to prevent your Windows tools (like a global Windows Python or CMake installation) from conflicting with MSYS2 packages. If you prefer to keep MSYS2 strictly isolated as a pure POSIX/Linux-like sandbox, **skip this step**. However, you will need to manually alias or export specific Windows tools (like `code` or `node`) in your `~/.bashrc` if you want to use them.

### 5. Install Git and Stow
Now that you are in the right folder, update the package manager and install our tools:
```bash
pacman -Syu
pacman -S stow mingw-w64-ucrt-x86_64-git
```
*(Installing `mingw-w64-ucrt-x86_64-git` ensures you get the exact, highly optimized "Git for Windows" engine natively inside MSYS2).*

### 6. Force Native Symlinks
By default, MSYS2 tries to fake symlinks. We need real ones that Windows GUI apps (like VS Code) can read. Run this exact command to make strict native symlinks the default:
```bash
echo 'export MSYS=winsymlinks:nativestrict' >> ~/.bashrc
```
*Close and reopen your terminal one last time to apply this change.*

### 7. Make VS Code's MSYS Terminal Find Git and Apps
VS Code may open an `MSYS` terminal instead of `UCRT64`, which can hide `git` and other tools from the PATH. The included `bash/.bashrc` handles this automatically by adding the common MSYS2 Git locations.

That means:
* `git` works in both `UCRT64` and `MSYS` shells.

---

## Part 2: Quick Start - Install These Dotfiles

Now that the environment is ready, you can clone and stow my repository.

1. Clone this repository into your home directory:
   ```bash
   git clone https://github.com/jishnuteegala/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```
2. Run the setup script:
   ```bash
   ./setup.sh
   ```

---

## Part 3: Understanding the Folder Structure

If you want to manage your own dotfiles, GNU Stow works by mirroring the folder structure of your `dotfiles` repository directly into your `$HOME` directory. 

If your dotfiles repository is located at `~/dotfiles`, running `stow` will link files to the parent directory (which is `~` or `/c/Users/your_username`).

Here is how you structure your repository to handle both standard Linux configs (`.bashrc`) and deeply nested Windows configs (`AppData`):

```text
~/dotfiles/
├── bash/                 <-- The "package" name for bash
│   ├── .bashrc           <-- Will link to ~/.bashrc
│   └── .bash_profile     <-- Will link to ~/.bash_profile
├── git/                  <-- The "package" name for git
│   └── .gitconfig        <-- Will link to ~/.gitconfig
└── vscode/               <-- The "package" name for VS Code
    └── AppData/          <-- You must mimic the exact Windows path!
        └── Roaming/
            └── Code/
                └── User/
                    └── settings.json <-- Will link to ~/AppData/Roaming/Code/User/settings.json
```
When you run `stow vscode`, it maps `settings.json` exactly to `~/AppData/Roaming/Code/User/settings.json`.

---

## Part 4: Step-by-Step Manual Implementation

If you are building your own dotfiles from scratch instead of cloning, here is how you move your existing files into a repository and stow them.

**1. Create your repository:**
```bash
mkdir ~/dotfiles
cd ~/dotfiles
git init
```

**2. Back up your existing configs first:**
```bash
# Create a simple backup folder inside your dotfiles repo
mkdir -p ~/dotfiles/.backups

# Back up the configs you already have before moving or adopting them
cp ~/.bashrc ~/dotfiles/.backups/.bashrc.bak
cp ~/.bash_profile ~/dotfiles/.backups/.bash_profile.bak
cp ~/.gitconfig ~/dotfiles/.backups/.gitconfig.bak
cp ~/AppData/Roaming/Code/User/settings.json ~/dotfiles/.backups/settings.json.bak
```
Only run the backup commands for files that already exist on your machine.

**3. Preferred option: adopt the configs you already have on disk**
If you already have configs in place on this machine, the easiest path is to let Stow absorb them into the repo and create the links for you:
```bash
cd ~/dotfiles
stow bash --adopt
stow git --adopt
stow vscode --adopt
```
> **Important:** `--adopt` copies the existing machine config into the repo first. If you want to keep the repo version instead, run `git restore .` immediately after adopting so the repo goes back to the checked-in version while the symlink stays in place.

**4. Manual option: move your Unix-style configs into the repo:**
```bash
# Create the package folders
mkdir -p ~/dotfiles/bash
mkdir -p ~/dotfiles/git

# Move the actual files into the dotfiles folder
mv ~/.bashrc ~/dotfiles/bash/
mv ~/.bash_profile ~/dotfiles/bash/
mv ~/.gitconfig ~/dotfiles/git/
```

**5. Manual option: move your Windows-style configs (VS Code):**
```bash
# Create the mirrored AppData path inside your dotfiles folder
mkdir -p ~/dotfiles/vscode/AppData/Roaming/Code/User/

# Move your VS Code settings.json into the dotfiles folder
mv ~/AppData/Roaming/Code/User/settings.json ~/dotfiles/vscode/AppData/Roaming/Code/User/
```

**6. Stow them!**
From inside your `~/dotfiles` directory, tell `stow` to create the symlinks back to their original locations:
```bash
cd ~/dotfiles
stow bash
stow git
stow vscode
```

> **If you hit "target already exists"**
> If a file is already present at the destination, use the backup you made in step 2 or run `stow --adopt` to absorb the existing config into the repo and create the symlink.

**7. Clean up and Commit:**
Once everything is linked and working, you can safely ignore or remove your `.backups` folder. (The `.gitignore` in this repo already ignores `.backups/` and `*.bak` files).

```bash
git add .
git commit -m "Initial dotfiles commit"
git branch -M main
# git remote add origin <your-github-repo-url>
# git push -u origin main
```

---

## Alternative Windows Dotfile Managers

If managing MSYS2 paths isn't your preference, here are the best alternative approaches for Windows users:

| Tool | Description | Best For |
| :--- | :--- | :--- |
| **[WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install)** | Runs a full Ubuntu environment natively inside Windows. | Users who want to follow Linux terminal tutorials exactly 1:1 without Windows file-path headaches. |
| **[Chezmoi](https://www.chezmoi.io/)** | A cross-platform dotfile manager written in Go. It acts like a templating engine rather than relying on symlinks. | Users managing a mix of Windows, Mac, and Linux machines who need complex, platform-specific logic. |
| **[Winstow](https://github.com/MathiasCodes/winstow)** | A literal clone of GNU Stow compiled as a native Windows `.exe`. | Users who absolutely want to stick to the standard "Git Bash" installer without using MSYS2. |

---

## References & Reading
* **Bashbunni's Dotfiles:** [github.com/bashbunni/dotfiles](https://github.com/bashbunni/dotfiles)
* **MSYS2 Official Site:** [msys2.org](https://www.msys2.org/)
* **Git for Windows inside MSYS2:** [Git for Windows Wiki](https://gitforwindows.org/install-inside-msys2-proper.html)
* **Reddit: MSYS2 Git vs Git for Windows:** [Comment 1](https://www.reddit.com/r/git/comments/r6pkxp/comment/hmwqxs2/), [Comment 2](https://www.reddit.com/r/git/comments/r6pkxp/comment/ljnzhs3/)
* **Reddit: Avoiding MSYS2 Conflicts:** [Comment Thread](https://www.reddit.com/r/git/comments/ama1j0/comment/efktpdx/)
