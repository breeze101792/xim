# vim-ide

A comprehensive IDE setup for Vim and Neovim, designed to enhance productivity with a rich set of plugins and configurations.

## Features

This IDE setup integrates a variety of powerful plugins to provide a modern development experience:

*   **File Navigation & Exploration:**
    *   **NERDTree:** A tree explorer plugin for Vim.
    *   **CtrlP:** A full path fuzzy file, buffer, mru, tag, etc. finder.
    *   **BufExplorer:** Quickly and easily switch between buffers.
*   **Code Editing & Completion:**
    *   **OmniCppComplete:** C/C++ autocompletion.
    *   **ALE (Asynchronous Linting Engine):** Provides linting and fix support for various languages (C, C++, Python, Shell).
    *   **Supertab:** Tab completion for Vim.
    *   **Vim Visual Multi:** Multiple cursors for simultaneous editing.
    *   **Vim Surround:** Quickly add/delete/change surroundings (parentheses, quotes, etc.).
    *   **TComment:** Easy commenting/uncommenting of code.
    *   **Vim Cpp Enhanced Highlight:** Improved syntax highlighting for C/C++.
    *   **Vim Python PEP8 Indent:** PEP8 compliant indentation for Python.
*   **Version Control Integration:**
    *   **GitGutter:** Shows git diff signs in the sign column.
    *   **Vim Fugitive:** A powerful Git wrapper for Vim.
*   **Code Navigation & Analysis:**
    *   **Tagbar:** Displays tags in a sidebar, providing an outline of the current file.
    *   **CCTree:** Call tree and cross-reference tool.
    *   **Cscope maps (Neovim):** Cscope integration for Neovim.
    *   **Nvim LSP (Neovim):** Language Server Protocol integration with configurations for `clangd` and `ccls` for C/C++/CUDA/Proto.
*   **User Interface & Experience:**
    *   **Lightline.vim:** A light and configurable statusline/tabline plugin.
    *   **Vim Bookmarks:** Manage bookmarks in your code.
    *   **Vim EasyGrep:** Easy grep integration.
    *   **Vim Highlighter:** Highlight words.
    *   **QFEnter:** Enhancements for the quickfix window.
    *   **Colorizer:** Colorizes CSS-like colors in Vim.
    *   **Tabular:** Align text by a regular expression.
    *   **Customizable Themes:** Support for cached colorschemes and `lightline` themes.
    *   **Smart Indentation & Formatting:** `smartindent`, `expandtab`, `tabstop`, `shiftwidth` settings.
    *   **Autocommands:** For tasks like removing trailing spaces, syntax highlighting TODOs/FIXMEs.

## Installation

The `setup.sh` script automates the installation process for both Vim and Neovim.

### Prerequisites

*   `ctags` and `cscope` are recommended for full functionality.
    *   **Note for Darwin users:** Avoid using the built-in `ctags` as it may cause issues. Install a modern version (e.g., `brew install ctags`).
*   `git` for cloning plugins.
*   `curl` or `aria2c` for downloading `ccglue` (if used).

### Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/xim.git ~/.vim-ide # Or wherever you prefer
    cd ~/.vim-ide
    git submodule update --init --recursive
    ```
2.  **Run the setup script:**

    *   **For Vim:**
        ```bash
        ./setup.sh -s
        ```
        This will set up Vim configurations in `~/.vim` and create/update `~/.vimrc` to source `vim-ide.vim`.

    *   **For Neovim:**
        ```bash
        ./setup.sh -n
        ```
        This will set up Neovim configurations in `~/.config/nvim` and link `init.lua` and `lua` directory.

    *   **For both Vim and Neovim:**
        ```bash
        ./setup.sh -a
        ```

3.  **Generate Custom Configuration (Optional but Recommended):**
    ```bash
    ./setup.sh -c
    ```
    This command will create or update `~/.vim/ConfigCustomize.vim` (or `~/.config/nvim/ConfigCustomize.vim` for Neovim) with default values for various `g:IDE_CFG_` variables. You can then modify this file to personalize your setup without altering the core project files.

4.  **Install `xim` command (Optional):**
    ```bash
    ./setup.sh -c # This also installs the xim command
    ```
    This will create a symbolic link `~/.usr/bin/xim` pointing to `xim.sh` (which is `setup.sh` itself).

## Usage

### Reloading Settings

After making changes to your Vim/Neovim configuration, you can reload the settings without restarting the editor:

*   **In Vim/Neovim:**
    ```vim
    :Reload
    ```
    or
    ```vim
    :Refresh
    ```

### Lite Mode

For a minimal and faster startup, you can enable "lite" mode by setting the `VIDE_SH_IDE_LITE` environment variable:

```bash
export VIDE_SH_IDE_LITE="y"
vim # or nvim
```

In lite mode, a reduced set of core scripts and modules are loaded, skipping most plugins. You can also release a standalone `vimlite.vim` file:

```bash
./setup.sh -r # Generates tools/vimlite.vim
./setup.sh -l # Copies vimlite.vim to ~/.vimrc
```

### Customization

User-specific configurations should be placed in `~/.vim/ConfigCustomize.vim` (for Vim) or `~/.config/nvim/ConfigCustomize.vim` (for Neovim). This file is sourced early in the initialization process.

### Environment Variables

*   `VIMRUNTIME`: If using an older Vim version, you might need to export this:
    ```bash
    export VIMRUNTIME=/usr/share/vim/vim73
    ```
*   `VIDE_SH_IDE_LITE`: Set to "y" to enable lite mode.

## Configuration Options (from `Config.vim` and `Environment.vim`)

You can customize various aspects of the IDE by setting global variables in your `ConfigCustomize.vim` file. Here are some notable ones:

*   `g:IDE_ENV_ROOT_PATH`: Root path for the IDE configuration (default: `~/.vim` for Vim, `~/.config/nvim` for Neovim).
*   `g:IDE_CFG_PLUGIN_ENABLE`: "y" to enable plugins, "n" to disable.
*   `g:IDE_CFG_CACHED_COLORSCHEME`: "y" to use a cached colorscheme for faster startup.
*   `g:IDE_CFG_COLORSCHEME_NAME`: The name of the colorscheme to use (e.g., "default", "wombat_lab").
*   `g:IDE_CFG_SPECIAL_CHARS`: "y" to enable special UTF-8 characters for UI elements (e.g., `lightline` separators, `bookmark` signs).
*   `g:IDE_CFG_HIGH_PERFORMANCE_HOST`: "y" to enable `cursorcolumn` (can slow down Vim).
*   `g:IDE_ENV_IDE_TITLE`: Title displayed in the `lightline` tabline.
*   `g:IDE_ENV_COLORSCHEME_TABLINE`: Colorscheme for `lightline` tabline.
*   `g:IDE_ENV_DEF_PAGE_WIDTH`: Default page width for UI elements.
*   `g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD`: File size threshold for certain operations.

