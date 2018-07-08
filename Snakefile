
rule all:
	input:
		"Outputs/RawData.csv",
		"Outputs/processed.tsv",
		"Outputs/bg-graph.png",

rule importCSV:
	input:
		CSV = "Inputs/DiaryU104408808.csv",
	output:
		"Outputs/RawData.csv",
	shell:
		"cp {input.CSV} {output}"

rule preprocess:
	input:
		script = "preprocess.sh",
		CSV = "Outputs/RawData.csv",
	output:
		"Outputs/processed.tsv",
	shell:
		"bash {input.script} {input.CSV} > {output}"

rule R:
	input:
#		data = "Outputs/processed.tsv"
		script = "bg-calc.R"
	output:
		"Outputs/bg-graph.png"
	script:
		"{input.script}"