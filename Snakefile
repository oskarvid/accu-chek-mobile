rule all:
	input:
		"Outputs/RawData.csv",
		"Outputs/processed.tsv",
		"Outputs/bg-graph.png",

rule importCSV:
	input:
		CSV = "Inputs/test.csv",
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
		script = "bg-calc.R"
	output:
		"Outputs/bg-graph.png",
	script:
		"{input.script}"