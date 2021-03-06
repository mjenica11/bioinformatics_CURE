# Purpose: Example sex-aware differential gene expression pipeline

# Dictionary of samples
configfile: <enter_path_here>

# Split samples by sex
XX_samples = config["XX_samples"]
XY_samples = config["XY_samples"]

# Set of all samples
sample = XX_samples + XY_samples 

# Process to be executed
rule all:
	input:
		<expected_output_here>

# Generate fastqc reports of the raw data
rule: fastqc_raw_data:
	input:
		fq1 = "data/raw_data/{sample}_1.fastq",
		fq2 = "data/raw_data/{sample}_2.fastq"
	output:
		fq1 = "quality_control/raw_data/{sample}_1.fastqc",
		fq2 = "quality_control/raw_data/{sample}_2.fastqc"
	params:
	shell:
		"fastqc {input.fq1} {input.fq2} -o {output.fq1} {output.fq2}"

# Generate an aggregate report of the individual reports of the raw data
rule multiQC_raw_data:
	input:
		fq1 = "quality_control/raw_data/{sample}_1_fastqc.html",
		fq2 = "quality_control/raw_data/{sample}_2_fastqc.html"
	output:
		mqc = "quality_control/raw_data/multiqc_report.html"
	params:
	shell:
		"multiqc {input.fq1} {input.fq2} -o {output.mqc}"

# Trim raw reads to generate processed reads
rule trimmomatic:
	input:
		fq1 = "trimmed_reads/{sample}_1.fastq",
		fq2 = "trimmed_reads/{sample}_2.fastq",
		adapters = "data/adapter_sequences.fa"
	output:
		paired_1 = "trimmed_reads/{sample}_paired_1.fastq.gz",
		paired_2 = "trimmed_reads/{sample}_paired_2.fastq.gz",
		unapired_1 = "trimmed_reads/{sample}_unpaired_1.fastq.gz",
		unapired_2 = "trimmed_reads/{sample}_unpaired_2.fastq.gz",
		logfile = "trimmed_reads/{sample}.log"
# Not sure if I need all these parameters;
# Including for now because this is the lab standard
	params:
		seed_mismatched = 2,
		palindrome_clip_threshold = 30,
		simple_clip_threshold = 10,
		leading = 3,
		trailing = 3,
		winsize = 4,
		winqual = 30,
		minlen = 50
	shell:
		"trimmomatic -trimlog {output.logfile} {input.fq1} {input.fq2} "
		"{output.paired_1} {output.paired_2} {output.unpaired_1} {output.unpaired_2} "
		"ILLUMINACLIP:{input.adapters}:{params.seed_mismatch}{params.palindrome_clip_threshold}:{params.simple_clip_threshold} "
		"LEADING:{params.leading} TRAILING:{params.trailing "
		"SLIDINGWINDOW:{params.winsize}:{params.winqual} MINLEN:{params.minlen}"

# Generate fastqc reports of trimmed reads
rule: fastqc_trimmed:
	input:
		fq1 = "data/raw_data/{sample}_1.fastq",
		fq2 = "data/raw_data/{sample}_2.fastq"
	output:
		fq1 = "quality_control/trimmed_data/{sample}_1.fastqc",
		fq2 = "quality_control/trimmed_data/{sample}_2.fastqc"
	params:
	shell:
		"fastqc {input.fq1} {input.fq2} -o {output.fq1} {output.fq2}"

# Generate an aggregate report of the individual reports of the trimmed data
rule multiQC_trimmed:
	input:
		fq1 = "quality_control/trimmed_data/{sample}_1_fastqc.html",
		fq2 = "quality_control/trimmed_data/{sample}_2_fastqc.html"
	output:
		mqc = "quality_control/trimmed_data/multiqc_report.html"
	params:
	shell:
		"multiqc {input.fq1} {input.fq2} -o {output.mqc}"

# Make XX index for quantification using a pseudo-aligner
rule XX_index:
	input:
		fq1  = "trimmed_reads/{XX_samples}_paired_1.fastq.gz",
		fq2  = "trimmed_reads/{XX_samples}_paired_2.fastq.gz"
	output:
		XX_index = "quantification/index/XX_index"
	params:
	shell:
		<make_XX_index>
	
# Make XY index for quantification using a pseudo-aligner
rule XY_index:
	input:
		fq1  = "trimmed_reads/{XY_samples}_paired_1.fastq.gz",
		fq2  = "trimmed_reads/{XY_samples}_paired_2.fastq.gz"
	output:
		XY_index = "quantification/index/XY_index"
	params:
	shell:
		<make_XY_index>

# Perform quantification of trimmed reads using XX index
rule XX_quantification:
	input:
		fq1  = "trimmed_reads/{XX_samples}_paired_1.fastq.gz",
		fq2  = "trimmed_reads/{XX_samples}_paired_2.fastq.gz"
	output:
		counts = "quantification/female_samples/{XX_samples}.quant.sf"
	params:
		index = "quantification/index/XX_index" 
		libtype = A # Automatically detect the library type
	shell: # example code if I were to use salmon
		"salmon quant -i {params.index} -l {params.libtype} -1 {input.fq1} {input.fq2} "
		"-o {output.counts}"

# Perform quantification of trimmed reads using XY index
rule XY_quantification:
	input:
		fq1  = "trimmed_reads/{XY_samples}_paired_1.fastq.gz",
		fq2  = "trimmed_reads/{XY_samples}_paired_2.fastq.gz"
	output:
		counts = "quantification/male_samples/{XY_samples}.quant.sf"
	params:
		index = "quantification/index/XY_index" 
		libtype = A # Automatically detect the library type
	shell:
		"salmon quant -i {params.index} -l {params.libtype} -1 {input.fq1} {input.fq2} "

# Combine sample counts into one matrix for each sex 
rule prepare_count_matrix:
	input:
		metadata = "data/metadata.csv",
		female_counts = "quantification/female_samples/{XX_samples}.quant.sf"
		male_counts = "quantification/male_samples/{XY_samples}.quant.sf"
	output:
		female_counts = "quantification/female_counts.csv",
		male_counts = "quantification/male_counts.csv"
	script:
		"scripts/combine_counts.R"

# Perform differential expression using limma-voom
rule differential_expression:
	input:
		metadata = "data/metadata.csv",
		female_counts = "quantification/female_counts.csv",
		male_counts = "quantification/male_counts.csv"
	output:
		results = "differential_expression/default.csv"
	script:
		"scripts/differential_expression.R"

# Generate volcano plot of differential expression results
rule volcano_plot:
	input:
		results = "differential_expression/default.csv"
	output:
		volcano = "differential_expression/default/volcano.pdf",
		md = "differential_expression/default/mean_difference.pdf"
	script:
		"scripts/volcano_plot.R"

# Generate mean-difference plot of differential expression results
rule mean_difference_plot:
	input:
		results = "differential_expression/default.csv"
	output:
		mean_difference = "differential_expression/mean_difference.pdf",
		md = "differential_expression/mean_difference.pdf"
	script:
		"scripts/mean_difference_plot.R"

# Generate venn plot of differential expression results
rule venn_diagram:
	input:
		results = "differential_expression/default.csv"
	output:
		venn = "differential_expression/venn_diagram.pdf",
	script:
		"scripts/venn_diagram.R"
