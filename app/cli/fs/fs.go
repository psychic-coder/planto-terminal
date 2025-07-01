package fs

import (
	"os"
	"os/exec"
	"path/filepath"
	"planto-cli/term"
)

var Cwd string
var PlantoDir string
var ProjectRoot string
var HomePlantoDir string
var CacheDir string

var HomeDir string
var HomeAuthPath string
var HomeAccountsPath string

func init() {
	var err error
	Cwd, err = os.Getwd()
	if err != nil {
		term.OutputErrorAndExit("Error getting current working directory: %v", err)
	}

	home, err := os.UserHomeDir()
	if err != nil {
		term.OutputErrorAndExit("Couldn't find home dir: %v", err.Error())
	}
	HomeDir = home

	if os.Getenv("PLANTO_ENV") == "development" {
		HomePlantoDir = filepath.Join(home, ".planto-home-dev-v2")
	} else {
		HomePlantoDir = filepath.Join(home, ".planto-home-v2")
	}

	// Create the home planto directory if it doesn't exist
	err = os.MkdirAll(HomePlantoDir, os.ModePerm)
	if err != nil {
		term.OutputErrorAndExit(err.Error())
	}

	CacheDir = filepath.Join(HomePlantoDir, "cache")
	HomeAuthPath = filepath.Join(HomePlantoDir, "auth.json")
	HomeAccountsPath = filepath.Join(HomePlantoDir, "accounts.json")

	err = os.MkdirAll(filepath.Join(CacheDir, "tiktoken"), os.ModePerm)
	if err != nil {
		term.OutputErrorAndExit(err.Error())
	}
	err = os.Setenv("TIKTOKEN_CACHE_DIR", CacheDir)
	if err != nil {
		term.OutputErrorAndExit(err.Error())
	}

	FindPlantoDir()
	if PlantoDir != "" {
		ProjectRoot = Cwd
	}
}

func FindOrCreatePlanto() (string, bool, error) {
	FindPlantoDir()
	if PlantoDir != "" {
		ProjectRoot = Cwd
		return PlantoDir, false, nil
	}

	// Determine the directory path
	var dir string
	if os.Getenv("PLANTO_ENV") == "development" {
		dir = filepath.Join(Cwd, ".planto-dev-v2")
	} else {
		dir = filepath.Join(Cwd, ".planto-v2")
	}

	err := os.Mkdir(dir, os.ModePerm)
	if err != nil {
		return "", false, err
	}
	PlantoDir = dir
	ProjectRoot = Cwd

	return dir, true, nil
}

func ProjectRootIsGitRepo() bool {
	if ProjectRoot == "" {
		return false
	}

	return IsGitRepo(ProjectRoot)
}

func IsGitRepo(dir string) bool {
	isGitRepo := false

	if isCommandAvailable("git") {
		// check whether we're in a git repo
		cmd := exec.Command("git", "rev-parse", "--is-inside-work-tree")

		cmd.Dir = dir

		err := cmd.Run()

		if err == nil {
			isGitRepo = true
		}
	}

	return isGitRepo
}

func FindPlantoDir() {
	PlantoDir = findPlanto(Cwd)
}

func findPlanto(baseDir string) string {
	var dir string
	if os.Getenv("PLANTO_ENV") == "development" {
		dir = filepath.Join(baseDir, ".planto-dev-v2")
	} else {
		dir = filepath.Join(baseDir, ".planto-v2")
	}
	if _, err := os.Stat(dir); !os.IsNotExist(err) {
		return dir
	}

	return ""
}

func isCommandAvailable(name string) bool {
	cmd := exec.Command(name, "--version")
	if err := cmd.Run(); err != nil {
		return false
	}
	return true
}
