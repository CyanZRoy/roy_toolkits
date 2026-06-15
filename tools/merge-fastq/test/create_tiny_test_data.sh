#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/original" "${WORK_DIR}/supplement"

cat > "${WORK_DIR}/original/original_R1.fastq" <<'EOF'
@original_read_1
ACGT
+
IIII
EOF

cat > "${WORK_DIR}/supplement/supplement_R1.fastq" <<'EOF'
@supplement_read_1
TGCA
+
IIII
EOF

gzip -c "${WORK_DIR}/original/original_R1.fastq" > "${WORK_DIR}/original/original_R1.fastq.gz"
gzip -c "${WORK_DIR}/supplement/supplement_R1.fastq" > "${WORK_DIR}/supplement/supplement_R1.fastq.gz"

cat > "${WORK_DIR}/manifest.simple.csv" <<'EOF'
original_fq,supp_fq,out_fq
original/original_R1.fastq.gz,supplement/supplement_R1.fastq.gz,merged_R1.fastq.gz
EOF

cat > "${WORK_DIR}/manifest.sample_read.csv" <<'EOF'
sample,read,original_fq,supp_fq
Sample_001,R1,original/original_R1.fastq.gz,supplement/supplement_R1.fastq.gz
EOF

printf 'Tiny test data written to %s\n' "${WORK_DIR}"
