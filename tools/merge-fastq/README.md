# merge-fastq

`merge-fastq` merges original sequencing FASTQ files with resequencing or supplement FASTQ files, then validates gzip integrity and writes MD5 files.

This tool is available through the unified `rtoolkit` entry point:

```bash
rtoolkit merge-fastq -h
```

After running `bash install.sh`, it can also be called directly:

```bash
merge-fastq -h
```

## Package Layout

```text
rtoolkit/
  tools/
    merge-fastq/
      README.md
      bin/
        merge-fastq
      examples/
        manifest.simple.csv
        manifest.filename_out.csv
        manifest.sample_read.csv
      test/
        create_tiny_test_data.sh
```

Legacy handoff package layout:

```text
fq_datacombined_script/
  README.md
  merge_reseq_fastq
  examples/
    manifest.simple.csv
    manifest.filename_out.csv
    manifest.sample_read.csv
  test/
    create_tiny_test_data.sh
```

## Dependencies

Required runtime:

```text
bash 4+
awk
cat
cp
dirname
basename
gzip
md5sum
mkdir
stat
tail
tee
```

Optional but recommended for clean path display:

```text
realpath
```

If `realpath -m` is unavailable, the script tries `readlink -m`. If neither is available, paths are still usable but may be less clean in logs.

## Quick Start

Auto-discovery mode:

```bash
rtoolkit merge-fastq \
  --workdir ./ \
  --supp-dir MYSW-20260420-L-01-2026-04-221434 \
  --out-dir combined
```

Simple manifest mode:

```bash
rtoolkit merge-fastq --manifest tools/merge-fastq/examples/manifest.simple.csv
```

If `out_fq` contains only a filename or a relative path, add `--out-dir` to place outputs there:

```bash
rtoolkit merge-fastq \
  --manifest tools/merge-fastq/examples/manifest.filename_out.csv \
  --out-dir combined
```

Sample/read manifest mode:

```bash
rtoolkit merge-fastq \
  --manifest tools/merge-fastq/examples/manifest.sample_read.csv \
  --out-dir combined
```

Show help:

```bash
rtoolkit merge-fastq --help
```

## Input Modes

### 1. Auto-discovery Mode

The tool searches run directories under `--workdir` with `--run-pattern`, excludes `--supp-dir`, and processes sample directories matching `--sample-pattern`.

Default patterns:

```text
--run-pattern MYSW-*
--sample-pattern Sample_*
```

Output structure:

```text
combined/
  Sample_001/
    sample_R1.fastq.gz
    sample_R1.fastq.gz.md5
    sample_R2.fastq.gz
    sample_R2.fastq.gz.md5
  merge.log
  merge_summary.tsv
  md5sum.txt
```

### 2. Simple Manifest Mode

Required columns:

```csv
original_fq,supp_fq,out_fq
```

`out_fq` controls the output path, so all merged files can be placed in one directory if desired.

Path rules for `out_fq`:

```text
Absolute out_fq:
  /data/project/combined/A_R1.fastq.gz
  Used as-is, even if --out-dir is also provided.

Relative out_fq with --out-dir:
  A_R1.fastq.gz
  Written to --out-dir/A_R1.fastq.gz.

Relative out_fq without --out-dir:
  A_R1.fastq.gz
  Written relative to the manifest directory.
```

Relative `original_fq` and `supp_fq` paths in a manifest are also resolved relative to the manifest directory. For example, if the manifest is located at `/data/project/Lane00/manifest.simple.csv`, then `./A_R1.fastq.gz` is resolved as `/data/project/Lane00/A_R1.fastq.gz`.

In manifest mode, a relative `--out-dir` is also resolved relative to the manifest directory.

### 3. Sample/read Manifest Mode

Required columns:

```csv
sample,read,original_fq,supp_fq
```

When `out_fq` is absent, `--out-dir` is required. The output path is generated as:

```text
--out-dir/sample/basename(original_fq)
```

If a manifest contains `sample`, `read`, and `out_fq`, `out_fq` has priority.

## Important Options

```text
--dry-run          Write the plan/log/summary without creating FASTQ outputs.
--force            Allow overwriting existing output FASTQ and md5 files.
-j, --jobs INT     Number of concurrent merge jobs. Default: 1.
                   This is job-level parallelism, not multi-threaded
                   cat/gzip/md5sum.
--include-supp-only
                   In auto-discovery mode, also output FASTQ files that exist
                   only in the supplement directory.
```

## Behavior

- Merge order is always `original_fq` first, then `supp_fq`.
- If the supplement FASTQ is missing, the original FASTQ is copied and marked as `copied_original_only`.
- Every generated FASTQ is checked with `gzip -t`.
- Every generated FASTQ gets a `<fastq>.md5` file.
- A combined `md5sum.txt` and `merge_summary.tsv` are generated.
- Existing outputs are protected by default. Use `--force` to overwrite.
- When `--jobs/-j` is greater than 1, merge jobs run concurrently. Summary rows may be written in completion order instead of input order.

## Safe Test

Generate tiny gzip-compressed FASTQ test data and run the tool:

```bash
bash test/create_tiny_test_data.sh
bash bin/merge-fastq \
  --manifest test/work/manifest.simple.csv \
  --out-dir test/work/combined \
  -j 2
```

Expected outputs:

```text
test/work/combined/merged_R1.fastq.gz
test/work/combined/merged_R1.fastq.gz.md5
test/work/combined/merge.log
test/work/combined/merge_summary.tsv
test/work/combined/md5sum.txt
```

Dry-run test:

```bash
bash test/create_tiny_test_data.sh
bash bin/merge-fastq \
  --manifest test/work/manifest.simple.csv \
  --out-dir test/work/dry_run \
  --dry-run
```

## Migration Notes

- Old one-off scripts used hard-coded variables such as `SUPP_DIR` and `OUT_DIR`; this version is fully parameter-driven.
- The old script names `merge_reseq_fastq.sh` and `merge_reseq_fastq` are not kept as the primary command. Use `rtoolkit merge-fastq`.
- No real FASTQ data should be imported with this package. Use `test/create_tiny_test_data.sh` to generate tiny test inputs when needed.
