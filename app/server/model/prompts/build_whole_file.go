package prompts

import shared "planto-shared"

func GetWholeFilePrompt(filePath string, preBuildStateWithLineNums shared.LineNumberedTextType, changesWithLineNumsType shared.LineNumberedTextType, changesDesc string, comments string) (string, int) {
	s := getBuildPromptHead(filePath, preBuildStateWithLineNums, changesDesc, changesWithLineNumsType)

	headNumTokens := shared.GetNumTokensEstimate(s)

	s += "## Comments\n\n"

	if comments != "" {
		s += comments + "\n\n"
	} else {
		s += CommentClassifierPrompt + "\n\n"
	}

	s += WholeFilePrompt

	return s, headNumTokens
}

const WholeFilePrompt = `
## Whole File 

Output the *entire merged file* with the *proposed updates* correctly applied. ALL reference comments will be replaced by the appropriate code from the *original file*. You will correctly merge the code from the *original file* with the *proposed updates* and output the entire file.

ALL identified reference comments MUST be replaced by the appropriate code from the *original file*. You MUST correctly merge the code from the *original file* with the *proposed updates* and output the *entire* resulting file. The resulting file MUST NOT include any reference comments.

The resulting file MUST be syntactically and semantically correct. All code structures must be properly balanced.

The full resulting file should be output within a <PlantoWholeFile> element, like this:

<PlantoWholeFile>
  package main

  import "logger"

  function main() {
    logger.info("Hello, world!");
    exec()
  }
</PlantoWholeFile>

Do NOT include line numbers in the <PlantoWholeFile> element. Do NOT include reference comments in the <PlantoWholeFile> element. Output the ENTIRE file, no matter how long it is, with NO EXCEPTIONS. Include the resulting file *only* with no other text. Do NOT wrap the file output in triple backticks or any other formatting, except for the <PlantoWholeFile> element tags.

Do NOT include any additional text after the <PlantoWholeFile> element. The output must end after </PlantoWholeFile>. DO NOT use the string <PlantoWholeFile> anywhere else in the output. ONLY use it to start the <PlantoWholeFile> element.

Do NOT UNDER ANY CIRCUMSTANCES *remove or change* any code that is not part of the changes in the *proposed updates*. ALL OTHER code from the *original file* must be reproduced *exactly* as it is in the *original file*. Do NOT remove comments, logging statements, commented out code, or anything else that is not part of the changes in the *proposed updates*. Your job is *only* to *apply* the changes in the *proposed updates* to the *original file*, not to make additional changes of *any kind*.

The ABSOLUTE MOST IMPORTANT THING is to leave all existing code that is not DIRECTLY part of the changes in the *proposed updates* *exactly* as it is in the *original file*. Do NOT remove any code that is not part of the changes in the *proposed updates*. Do NOT include any reference comments in the output; replace them with the appropriate code from the *original file*. Be ABSOLUTELY CERTAIN you have not left anything out which belongs in the final result.
`
