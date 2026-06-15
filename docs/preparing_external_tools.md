# Preparing External Tools

Most tools may be developed outside `rtoolkit` first. Before copying a finished
tool into `rtoolkit`, shape it into a small handoff package so it can be merged
cleanly.

This document can be copied into a new tool project during development. It is a
checklist for writing tool code in a structure that can later be imported into
`rtoolkit` with minimal redesign.

## Recommended Package

```text
<tool_project>/
  README.md
  <main_script>
  examples/
    example_input_or_manifest
  test/
    tiny_test_input
```

## Minimum Handoff Rules

1. Keep one clear main script

   The tool should have one obvious entry script. Its name should be close to
   the intended `rtoolkit <command>` name. Avoid spreading core behavior across
   many unnamed temporary scripts.

2. Make the script parameter-driven

   Do not require editing variables inside the script for normal use. Paths,
   samples, thresholds, output directories, and modes should be provided through
   command-line options, config files, or manifest tables.

3. Include a working help page

   The main script should support `-h` or `--help` before being merged. The help
   page should include usage, important options, required inputs, outputs, and
   at least one realistic example.

4. Avoid machine-specific paths

   Hard-coded paths such as `/mnt/project/...`, `/home/user/...`, or Windows
   local paths should appear only in examples, not in the tool logic. Defaults
   should be relative paths or values derived from the current working directory.

5. Provide small examples

   Include tiny manifest/config examples that explain the input format. They do
   not need to contain real project data, but column names and path behavior
   should match real usage.

6. Separate real data from code

   Do not copy FASTQ, BAM, result tables, customer data, or large intermediate
   files into the handoff package. Use small mock files or documented examples
   instead.

7. State dependencies clearly

   The README or help page should list required commands or environments, such
   as `bash`, `awk`, `md5sum`, `gzip`, `python3`, `Rscript`, or a conda
   environment.

8. Keep outputs controlled

   The tool should write outputs to an explicit `--out-dir` or documented
   default location. It should not scatter files across the input directories
   unless that is the purpose of the tool.

9. Add a safe test command

   Provide one command that can be run after merging to confirm the tool works.
   Prefer `--dry-run` or tiny test data. If no safe dry run is possible, explain
   the smallest safe test.

10. Write migration notes when needed

    If the external script already has old command names, old directory
    assumptions, or known limitations, write them down before merging. This
    helps preserve compatibility or decide whether an alias is needed.

## Import Process

When importing such a package into `rtoolkit`, the expected merge process is:

```text
1. Move the main executable into tools/<tool_name>/bin/
2. Move examples into tools/<tool_name>/examples/
3. Move or rewrite the README as tools/<tool_name>/README.md
4. Add one registry entry to bin/rtoolkit
5. Confirm rtoolkit list and rtoolkit <command> -h
6. Commit the import as one focused Git commit
```
