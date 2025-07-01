package plan_exec

import (
	"planto-cli/types"
	shared "planto-shared"
)

type ExecParams struct {
	CurrentPlanId        string
	CurrentBranch        string
	ApiKeys              map[string]string
	CheckOutdatedContext func(maybeContexts []*shared.Context, projectPaths *types.ProjectPaths) (bool, bool, error)
}
