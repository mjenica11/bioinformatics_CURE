graph LR
  A[snakefile] --> B[scripts]
  A[snakefile] --> C[data]
  A[snakefile] --> D[quality_control]
  A[snakefile] --> E[quantification]
  A[snakefile] --> F[differential_expression]
  C[data] --> adapter_sequences.fa
  C[data] --> h{{samples.config}}
  C[data] --> G[raw]
  C[data] --> H[trimmed]
  D[quality_control] --> I[raw]
  D[quality_control] --> J[trimmed]
  E[quantification] --> K[index]
  E[quantification] --> L[samples]
  L[samples] --> Q{{sample quant.sf files}}
  L[samples] --> R{{count_matrix.csv}}
  F[differential_expression] --> N{{results.csv}}
  F[differential_expression] --> O{{volcano_plot.pdf}}
  F[differential_expression] --> P{{md_plot.pdf}}
  B[scripts] --> T{{combine_counts.R}}
  B[scripts] --> U{{differential_expression.R}}
  B[scripts] --> V{{volcano_plot.R}}
  B[scripts] --> b{{md_plot.R}}
  G[raw] --> W{{raw fastas}}
  H[trimmed] --> X{{trimmed fastas}}
  J[trimmed] --> c[sample]
  c[sample] --> Z{{individual html reports}}
  I[raw] --> d[sample]
  d[sample] --> e{{individual html reports}}
  I[raw] --> f{{multiqc report}}
  J[trimmed] --> g{{multiqc report}}
