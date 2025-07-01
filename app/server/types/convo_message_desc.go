package types

import (
	"planto-server/db"

	shared "planto-shared"
)

func HasPendingBuilds(planDescs []*db.ConvoMessageDescription) bool {
	apiDescs := make([]*shared.ConvoMessageDescription, len(planDescs))
	for i, desc := range planDescs {
		apiDescs[i] = desc.ToApi()
	}

	return shared.HasPendingBuilds(apiDescs)
}
