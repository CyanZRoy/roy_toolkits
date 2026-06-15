# rtoolkit

Personal Linux server toolkits for frequently used commands and small workflows.

This repository is not meant to collect every temporary command. Its purpose is
to turn repeated, error-prone, or overly long operations into simple tools that
can be cloned from GitHub and used directly on different Linux servers.

## Install

Clone the repository and run the installer:

```bash
git clone https://github.com/CyanZRoy/roy_toolkits.git ~/rtoolkit
cd ~/rtoolkit
bash install.sh
```

Use it in the current shell:

```bash
export PATH="$HOME/rtoolkit/bin:$PATH"
```

Or add it to `~/.bashrc`:

```bash
bash install.sh --modify-shellrc
```

## Available Tools

```text
merge-fastq    Merge original and resequenced FASTQ files.
```

## Toolkit Interface

`rtoolkit` is the unified command entry point for this repository.

Expected usage:

```bash
rtoolkit
rtoolkit list
rtoolkit <command> -h
rtoolkit <command> [options]
```

Design rules:

- Running `rtoolkit` or `rtoolkit list` should show all available tools.
- Running `rtoolkit <command> -h` should show the help page for that tool.
- Each tool can still have its own executable entry point when useful, but
  `rtoolkit <command>` should be the stable interface.
- Tool names should be short, lowercase, and task-oriented, for example
  `merge-fastq`, `make-md5`, or `rename-samples`.
- A new tool is not considered integrated until it appears in `rtoolkit list`
  and has a working help page.

## Tool Principles

1. Solve one repeated real task

   A tool should come from an operation that is used more than once, is easy to
   mistype, or is too long to remember. One-off project commands should stay in
   project notes instead of becoming toolkit scripts.

2. Be usable after clone

   A server should be able to run the tool after cloning this repository, with
   only common Linux utilities or clearly documented dependencies. Avoid
   absolute paths tied to one machine.

3. Keep inputs explicit

   Prefer command-line arguments, config files, or manifest tables over editing
   the script body. A user should not need to open the script to change samples,
   paths, output directories, thresholds, or modes.

4. Support help and dry checks

   Each executable tool should provide `-h` or `--help`. When practical, add a
   dry-run or validation mode so inputs can be checked before changing files.

5. Make output predictable

   Output paths, file names, logs, and temporary files should follow stable
   rules. Important generated files should be easy to find, and logs should make
   it clear what command was run and where results were written.

6. Fail safely

   Tools should stop on errors, report missing inputs clearly, and avoid
   overwriting existing files unless the user explicitly requests it. Destructive
   operations should require an explicit option such as `--force`.

7. Prefer portable shell, add stronger languages when useful

   Small file operations can use Bash. Use Python, R, or other languages when
   parsing, validation, reporting, or complex logic would become fragile in
   shell.

8. Keep tools independent

   A tool should be understandable and runnable by itself. Shared helpers are
   fine when they remove real duplication, but hidden cross-tool dependencies
   should be avoided.

9. Document the minimal example

   Every tool should include at least one copy-pasteable example in its help text
   or README section, using realistic input and output paths.

10. Version changes through Git

    Changes should be committed with clear messages. Tools that may affect
    analysis results should record behavior changes in the README or a changelog
    so older project results remain interpretable.

## Growing The Toolkit

This toolkit is expected to grow gradually. New tools should be added in a way
that does not break existing commands.

1. Keep one stable command registry

   The `rtoolkit` entry point should contain or load a single registry of tool
   names, descriptions, and script paths. Adding a tool should mean adding one
   registry entry, not rewriting the dispatcher logic.

2. Add tools as independent units

   Each new tool should live under its own directory in `tools/<tool_name>/`,
   with examples and documentation kept beside the implementation. Shared code
   should be introduced only when at least two tools genuinely need it.

3. Preserve old command names

   Once a command name has been used, avoid renaming it. If a better name is
   needed, keep the old name as an alias and mark it as deprecated before
   removing it.

4. Normalize imported command names

   External scripts often start with implementation-style names such as
   `merge_reseq_fastq`. When importing a tool, choose a short user-facing command
   name with lowercase words separated by hyphens, such as `merge-fastq`.
   Document the mapping from the old script name to the new command name in the
   tool README. Keep the old name as an alias only when backward compatibility is
   needed.

5. Make updates easy on servers

   Existing server installs should be updated with:

   ```bash
   cd ~/rtoolkit
   git pull
   bash install.sh
   ```

   `install.sh` should be idempotent, so running it multiple times is safe.

6. Separate user inputs from tool code

   Tool-specific examples, templates, and manifests should be versioned under
   `examples/` or `tools/<tool_name>/examples/`. Real project data should stay
   outside this repository.

7. Test before merging

   Every new tool should pass at least:

   ```bash
   rtoolkit list
   rtoolkit <command> -h
   ```

   The tool README should also provide the safest real test command. Prefer
   `--dry-run` or tiny test data.

8. Commit and push after integration

   After a tool is imported, documented, and checked, commit the integration as
   one focused Git commit and push it to GitHub. This keeps server installs able
   to update with `git pull` immediately after the merge is complete.

## Preparing External Tools

Most tools may be developed outside this repository first. Before copying a
finished tool into `rtoolkit`, follow the handoff checklist in
[`docs/preparing_external_tools.md`](docs/preparing_external_tools.md). This
document can be copied into a new tool project to guide its structure.

## Suggested Layout

```text
rtoolkit/
  README.md
  install.sh
  bin/
    rtoolkit           # unified dispatcher
  tools/
    <tool_name>/
      README.md
      bin/             # optional direct executable scripts
      examples/        # small example manifests or configs
  docs/                # longer usage notes when needed
```

For very small tools, the implementation can be a single script under
`tools/<tool_name>/bin/`. The root `bin/rtoolkit` dispatcher should expose it
through `rtoolkit <command>`.
