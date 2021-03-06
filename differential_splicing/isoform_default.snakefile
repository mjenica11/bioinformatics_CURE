# TO-DO:
# 1) Add sex chromosome complement refence to quantification step
# 2) Complete differential expression steps

# Dictionary of samples
configfile: <enter_path_here>

# Process to be executed
rule all:
	input:
		<expected_output_here>

# Generate fastqc reports of the raw data
rule: fastqc_raw:
	input:
		fq1 = "data/raw/{sample}_1.fastq",
		fq2 = "data/raw/{sample}_2.fastq"
	output:
		fq1 = "quality_control/raw/{sample}_1.fastqc",
		fq2 = "quality_control/raw/{sample}_2.fastqc"
	params:
	shell:
		"fastqc {input.fq1} {input.fq2} -o {output.fq1} {output.fq2}"

# Generate an aggregate report of the individual reports of the raw data
rule multiqc_raw:
	input:
		fq1 = "quality_control/raw/{sample}_1_fastqc.html",
		fq2 = "quality_control/raw/{sample}_2_fastqc.html"
	output:
		mqc = "quality_control/raw/multiqc_report.html"
	params:
	shell:
		"multiqc {input.fq1} {input.fq2} -o {output.mqc}"

# Trim raw reads to generate processed reads
rule trimmomatic:
	input:
		fq1 = "data/raw/{sample}_1.fastq",
		fq2 = "data/raw/{sample}_2.fastq",
		adapters = "data/adapter_sequences.fa"
	output:
		paired_1 = "data/trimmed/{sample}_paired_1.fastq.gz",
		paired_2 = "data/trimmed/{sample}_paired_2.fastq.gz",
		unapired_1 = "data/trimmed/{sample}_unpaired_1.fastq.gz",
		unapired_2 = "data/trimmed/{sample}_unpaired_2.fastq.gz",
		logfile = "data/trimmed/{sample}.log"
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
		fq1 = "data/trimmed/{sample}_1.fastq",
		fq2 = "data/trimmed/{sample}_2.fastq"
	output:
		fq1 = "quality_control/trimmed/{sample}_1.fastqc",
		fq2 = "quality_control/trimmed/{sample}_2.fastqc"
	params:
	shell:
		"fastqc {input.fq1} {input.fq2} -o {output.fq1} {output.fq2}"

# Generate an aggregate report of the individual reports of the trimmed data
rule multiQC_trimmed:
	input:
		fq1 = "quality_control/trimmed/{sample}_1_fastqc.html",
		fq2 = "quality_control/trimmed/{sample}_2_fastqc.html"
	output:
		mqc = "quality_control/trimmed/multiqc_report.html"
	params:
	shell:
		"multiqc {input.fq1} {input.fq2} -o {output.mqc}"

# Perform quantification of trimmed reads using salmon
rule quantification:
	input:
		fq1  = "data/trimmed/{sample}_paired_1.fastq.gz",
		fq2  = "data/trimmed/{sample}_paired_2.fastq.gz"
	output:
		counts = "quantification/samples/{sample}.quant.sf"
	params:
		index = "data/salmon_hg38_transcriptome_index" #whatever the file type is...
		libtype = A # Automatically detect the library type
	shell:
		"salmon quant -i {params.index} -l {params.libtype} -1 {input.fq1} {input.fq2} "
		"-o {output.counts}"

# Combine sample counts into one matrix for each sex 
rule prepare_count_matrix:
	input:
		metadata = "data/metadata.csv",
		counts = "quantification/samples/{sample}.quant.sf"
	output:
		counts = "quantification/count_matrix.csv",
	script:
		"scripts/combine_counts.R"

# Perform differential expression using limma-voom
rule differential_expression:
	input:
		metadata = "data/metadata.csv",
		female_counts = "quantification/female_counts.csv",
	output:
		results = "differential_expression/results.csv"
		isoforms = "differential_expression/isoforms.pdf"
		venn = "differential_expression/venn.pdf"
		switch_hist = "differential_expression/switch_hist.pdf"
		line_plot = "differential_expression/line_plot.pdf"
		volcano = "differential_expression/volcano.pdf"
		switch_gene = "differential_expression/switch_gene.pdf"
		violin = "differential_expression/violin.pdf"
	script:
		"scripts/differential_expression.R"
