package term

import "os"

var IsRepl = os.Getenv("PLANTO_REPL") != ""

func SetIsRepl(value bool) {
	IsRepl = value
}
