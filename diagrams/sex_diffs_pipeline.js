graph TD
  A[RNA seq data] --> B[fastqc_raw]
  B[fastqc_raw] --> C[multiqc_raw]
  A[RNA seq data] --> D[trimming]
  D[trimming] --> |test parameters|E[fastqc_trimmed]
  E[fastqc_trimmed] --> F[multiqc_trimmed]
  D[trimming] --> |test parameters|G[quantification]
  G[quantification] --> H[prepare_count_matrix]
  H[prepare_count_matrix] --> J[differential_expression]
  J[differential_expression] --> K[volcano_plot]
  J[differential_expression] --> L[mean_difference_plot]
  J[differential_expression] --> M[venn_diagram]