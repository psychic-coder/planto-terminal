package routes

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"planto-server/handlers"
	"planto-server/hooks"

	"github.com/gorilla/mux"
)

type PlantoHandler func(w http.ResponseWriter, r *http.Request)
type HandlePlanto func(router *mux.Router, path string, isStreaming bool, handler PlantoHandler) *mux.Route

var HandlePlantoFn HandlePlanto

func RegisterHandlePlanto(fn HandlePlanto) {
	HandlePlantoFn = fn
}

func EnsureHandlePlanto() {
	if HandlePlantoFn == nil {
		panic("handlePlantoFn is not set")
	}
}

func AddHealthRoutes(r *mux.Router) {
	EnsureHandlePlanto()

	HandlePlantoFn(r, "/health", false, func(w http.ResponseWriter, r *http.Request) {
		_, apiErr := hooks.ExecHook(hooks.HealthCheck, hooks.HookParams{})
		if apiErr != nil {
			log.Printf("Error in health check hook: %v\n", apiErr)
			http.Error(w, apiErr.Msg, apiErr.Status)
			return
		}
		fmt.Fprint(w, "OK")
	})

	HandlePlantoFn(r, "/version", false, func(w http.ResponseWriter, r *http.Request) {
		// Log the host
		host := r.Host
		log.Printf("Host header: %s", host)

		execPath, err := os.Executable()
		if err != nil {
			log.Fatal("Error getting current directory: ", err)
		}
		currentDir := filepath.Dir(execPath)

		// get version from version.txt
		var path string
		if os.Getenv("IS_CLOUD") != "" {
			path = filepath.Join(currentDir, "..", "version.txt")
		} else {
			path = filepath.Join(currentDir, "version.txt")
		}

		bytes, err := os.ReadFile(path)

		if err != nil {
			http.Error(w, "Error getting version", http.StatusInternalServerError)
			return
		}

		fmt.Fprint(w, string(bytes))
	})
}

func AddApiRoutes(r *mux.Router) {
	addApiRoutes(r, "")
}

func AddApiRoutesWithPrefix(r *mux.Router, prefix string) {
	addApiRoutes(r, prefix)
}

func AddProxyableApiRoutes(r *mux.Router) {
	addProxyableApiRoutes(r, "")
}

func AddProxyableApiRoutesWithPrefix(r *mux.Router, prefix string) {
	addProxyableApiRoutes(r, prefix)
}

func addApiRoutes(r *mux.Router, prefix string) {
	EnsureHandlePlanto()

	HandlePlantoFn(r, prefix+"/accounts/email_verifications", false, handlers.CreateEmailVerificationHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/accounts/email_verifications/check_pin", false, handlers.CheckEmailPinHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/accounts/sign_in_codes", false, handlers.CreateSignInCodeHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/accounts/sign_in", false, handlers.SignInHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/accounts/sign_out", false, handlers.SignOutHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/accounts", false, handlers.CreateAccountHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/orgs/session", false, handlers.GetOrgSessionHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/orgs", false, handlers.ListOrgsHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/orgs", false, handlers.CreateOrgHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/users", false, handlers.ListUsersHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/orgs/users/{userId}", false, handlers.DeleteOrgUserHandler).Methods("DELETE")
	HandlePlantoFn(r, prefix+"/orgs/roles", false, handlers.ListOrgRolesHandler).Methods("GET")

	HandlePlantoFn(r, prefix+"/invites", false, handlers.InviteUserHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/invites/pending", false, handlers.ListPendingInvitesHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/invites/accepted", false, handlers.ListAcceptedInvitesHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/invites/all", false, handlers.ListAllInvitesHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/invites/{inviteId}", false, handlers.DeleteInviteHandler).Methods("DELETE")

	HandlePlantoFn(r, prefix+"/projects", false, handlers.CreateProjectHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/projects", false, handlers.ListProjectsHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/projects/{projectId}/set_plan", false, handlers.ProjectSetPlanHandler).Methods("PUT")
	HandlePlantoFn(r, prefix+"/projects/{projectId}/rename", false, handlers.RenameProjectHandler).Methods("PUT")

	HandlePlantoFn(r, prefix+"/projects/{projectId}/plans/current_branches", false, handlers.GetCurrentBranchByPlanIdHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/plans", false, handlers.ListPlansHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/archive", false, handlers.ListArchivedPlansHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/ps", false, handlers.ListPlansRunningHandler).Methods("GET")

	HandlePlantoFn(r, prefix+"/projects/{projectId}/plans", false, handlers.CreatePlanHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/projects/{projectId}/plans", false, handlers.CreatePlanHandler).Methods("DELETE")

	HandlePlantoFn(r, prefix+"/plans/{planId}", false, handlers.GetPlanHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}", false, handlers.DeletePlanHandler).Methods("DELETE")

	HandlePlantoFn(r, prefix+"/plans/{planId}/current_plan/{sha}", false, handlers.CurrentPlanHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/current_plan", false, handlers.CurrentPlanHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/apply", false, handlers.ApplyPlanHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/archive", false, handlers.ArchivePlanHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/unarchive", false, handlers.UnarchivePlanHandler).Methods("PATCH")

	HandlePlantoFn(r, prefix+"/plans/{planId}/rename", false, handlers.RenamePlanHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/reject_all", false, handlers.RejectAllChangesHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/reject_file", false, handlers.RejectFileHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/reject_files", false, handlers.RejectFilesHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/diffs", false, handlers.GetPlanDiffsHandler).Methods("GET")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/context", false, handlers.ListContextHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/context", false, handlers.LoadContextHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/context/{contextId}/body", false, handlers.GetContextBodyHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/context", false, handlers.UpdateContextHandler).Methods("PUT")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/context", false, handlers.DeleteContextHandler).Methods("DELETE")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/convo", false, handlers.ListConvoHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/rewind", false, handlers.RewindPlanHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/logs", false, handlers.ListLogsHandler).Methods("GET")

	HandlePlantoFn(r, prefix+"/plans/{planId}/branches", false, handlers.ListBranchesHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/branches/{branch}", false, handlers.DeleteBranchHandler).Methods("DELETE")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/branches", false, handlers.CreateBranchHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/settings", false, handlers.GetSettingsHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/settings", false, handlers.UpdateSettingsHandler).Methods("PUT")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/status", false, handlers.GetPlanStatusHandler).Methods("GET")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/tell", true, handlers.TellPlanHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/build", true, handlers.BuildPlanHandler).Methods("PATCH")

	HandlePlantoFn(r, prefix+"/custom_models", false, handlers.ListCustomModelsHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/custom_models", false, handlers.CreateCustomModelHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/custom_models/{modelId}", false, handlers.DeleteAvailableModelHandler).Methods("DELETE")
	HandlePlantoFn(r, prefix+"/custom_models/{modelId}", false, handlers.UpdateCustomModelHandler).Methods("PUT")

	HandlePlantoFn(r, prefix+"/model_sets", false, handlers.ListModelPacksHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/model_sets", false, handlers.CreateModelPackHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/model_sets/{setId}", false, handlers.DeleteModelPackHandler).Methods("DELETE")
	HandlePlantoFn(r, prefix+"/model_sets/{setId}", false, handlers.UpdateModelPackHandler).Methods("PUT")
	HandlePlantoFn(r, prefix+"/default_settings", false, handlers.GetDefaultSettingsHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/default_settings", false, handlers.UpdateDefaultSettingsHandler).Methods("PUT")

	HandlePlantoFn(r, prefix+"/file_map", false, handlers.GetFileMapHandler).Methods("POST")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/load_cached_file_map", false, handlers.LoadCachedFileMapHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/plans/{planId}/config", false, handlers.GetPlanConfigHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/plans/{planId}/config", false, handlers.UpdatePlanConfigHandler).Methods("PUT")

	HandlePlantoFn(r, prefix+"/default_plan_config", false, handlers.GetDefaultPlanConfigHandler).Methods("GET")
	HandlePlantoFn(r, prefix+"/default_plan_config", false, handlers.UpdateDefaultPlanConfigHandler).Methods("PUT")
}

func addProxyableApiRoutes(r *mux.Router, prefix string) {
	EnsureHandlePlanto()

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/connect", true, handlers.ConnectPlanHandler).Methods("PATCH")
	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/stop", false, handlers.StopPlanHandler).Methods("DELETE")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/respond_missing_file", false, handlers.RespondMissingFileHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/auto_load_context", false, handlers.AutoLoadContextHandler).Methods("POST")

	HandlePlantoFn(r, prefix+"/plans/{planId}/{branch}/build_status", false, handlers.GetBuildStatusHandler).Methods("GET")
}
