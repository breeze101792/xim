# scripts/module/test

Test scripts for the modules in `scripts/module/`. Conventions:

- One module, one script (only if needed): `Module.vim` is tested by
  `Module_test.vim`, `LLMAgent.vim` by `LLMAgent_test.vim`, and so on.
- Do not create test scripts for modules that do not have one yet.
- Each test script is self-contained: its own test harness, no external test
  framework, Vim/Neovim built-ins only.
- Tests cover pure-logic helpers that run without external services
  (LLM server, ACP process, network). Live paths are exercised manually.

## Running

From the project root (`/mnt/projects/tools/xim`):

```sh
vim -e -s -u NONE -S scripts/module/test/<Module>_test.vim
```

A summary is written to `_test_summary.txt` in the project root; the exit
status is non-zero when any test fails. Neovim needs swap directories that
exist, so prefer `--cmd 'set noswapfile'`:

```sh
nvim --headless -u NONE --cmd 'set noswapfile' -S scripts/module/test/<Module>_test.vim
```

## Adding a new test script

1. Copy the harness block (state vars, `s:Assert`, `s:AssertEq`, runner loop,
   `_test_summary.txt` writer) from an existing `<Module>_test.vim`.
2. Name each test `s:Test_<name>` and register it in the `s:all_tests` list.
3. Keep tests independent of each other; reset any shared state at the end.