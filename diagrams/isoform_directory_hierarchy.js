graph TD
  A[snakefile] --> B[scripts]
  A[snakefile] --> C[data]
  A[snakefile] --> D[quality_control]
  A[snakefile] --> E[quantification]
  A[snakefile] --> F[differential_expression]
  C[data] --> G[raw]
  C[data] --> H[trimmed]
  D[quality_control] --> I[raw]
  D[quality_control] --> J[trimmed]
  E[quantification] --> K[index]
  E[quantification] --> L[samples]
  L[samples] --> Q{{sample quant.sf files}}
  L[samples] --> R{{count_matrix.csv}}
  F[differential_expression] --> N{{DE_genes}}
  F[differential_expression] --> O{{Volcano plot}}
  F[differential_expression] --> P{{MD plot}}
  B[scripts] --> T{{combine_counts.R}}
  B[scripts] --> U{{differential_expression.R}}
  B[scripts] --> V{{plots.R}}
  G[raw] --> W{{raw fastas}}
  H[trimmed] --> X{{trimmed fastas}}
  J[trimmed] --> Z{{sample and aggregate html reports}}
  I[raw] --> a{{sample and aggregate html reports}}
