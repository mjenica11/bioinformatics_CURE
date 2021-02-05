graph TD
  A[RNA seq data] --> B[fastqc_raw]
  B[fastqc_raw] --> C[multiqc_raw]
  A[RNA seq data] --> D[trimming]
  D[trimming] --> |test parameters|E[fastqc_trimmed]
  E[fastqc_trimmed] --> F[multiqc_trimmed]
  D[trimming] --> |test parameters|G[make_index]
  G[make_index] --> H[quantification]
  H[quantification] --> J[prepare_count_matrix]
  J[prepare_count_matrix] --> K[differential_expression]
  K[differential_expression] --> L[volcano_plot]
  K[differential_expression] --> M[mean_difference_plot]
  K[differential_expression] --> N[venn_diagram]