package cmd

import (
	"planto-cli/auth"
	"planto-cli/term"

	"github.com/spf13/cobra"
)

var pin string

var signInCmd = &cobra.Command{
	Use:   "sign-in",
	Short: "Sign in to a Planto account",
	Args:  cobra.NoArgs,
	Run:   signIn,
}

func init() {
	RootCmd.AddCommand(signInCmd)

	signInCmd.Flags().StringVar(&pin, "pin", "", "Sign in with a pin from the Planto Cloud web UI")
}

func signIn(cmd *cobra.Command, args []string) {
	if pin != "" {
		err := auth.SignInWithCode(pin, "")

		if err != nil {
			term.OutputErrorAndExit("Error signing in: %v", err)
		}

		return
	}

	err := auth.SelectOrSignInOrCreate()

	if err != nil {
		term.OutputErrorAndExit("Error signing in: %v", err)
	}
}
