package cmd

import (
	"planto-cli/api"
	"planto-cli/auth"
	"planto-cli/lib"
	"planto-cli/plan_exec"
	"planto-cli/term"
	"planto-cli/types"
	shared "planto-shared"

	"github.com/spf13/cobra"
)

var autoCommit, skipCommit, autoExec bool

func init() {
	initApplyFlags(applyCmd, false)
	initExecScriptFlags(applyCmd)
	RootCmd.AddCommand(applyCmd)

	applyCmd.Flags().BoolVar(&fullAuto, "full", false, "Apply the plan and debug in full auto mode")
}

var applyCmd = &cobra.Command{
	Use:     "apply",
	Aliases: []string{"ap"},
	Short:   "Apply a plan to the project",
	Run:     apply,
}

func apply(cmd *cobra.Command, args []string) {
	auth.MustResolveAuthWithOrg()
	lib.MustResolveProject()

	var config *shared.PlanConfig
	if fullAuto {
		term.StartSpinner("")
		var apiErr *shared.ApiError
		config, apiErr = api.Client.GetPlanConfig(lib.CurrentPlanId)
		if apiErr != nil {
			term.OutputErrorAndExit("Error getting plan config: %v", apiErr)
		}
		_, updatedConfig, printFn := resolveAutoModeSilent(config)
		config = updatedConfig
		term.StopSpinner()
		printFn()
	}

	mustSetPlanExecFlagsWithConfig(cmd, config)

	if lib.CurrentPlanId == "" {
		term.OutputNoCurrentPlanErrorAndExit()
	}

	applyFlags := types.ApplyFlags{
		AutoConfirm: true,
		AutoCommit:  autoCommit,
		NoCommit:    skipCommit,
		AutoExec:    autoExec,
		NoExec:      noExec,
		AutoDebug:   autoDebug,
	}

	tellFlags := types.TellFlags{
		TellBg:      tellBg,
		TellStop:    tellStop,
		TellNoBuild: tellNoBuild,
		AutoContext: tellAutoContext,
		ExecEnabled: !noExec,
		AutoApply:   tellAutoApply,
	}

	lib.MustApplyPlan(lib.ApplyPlanParams{
		PlanId:     lib.CurrentPlanId,
		Branch:     lib.CurrentBranch,
		ApplyFlags: applyFlags,
		TellFlags:  tellFlags,
		OnExecFail: plan_exec.GetOnApplyExecFail(applyFlags, tellFlags),
	})
}
