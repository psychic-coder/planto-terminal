package auth

import (
	"fmt"
	"planto-cli/term"
	"strings"

	shared "planto-shared"
)

func resolveOrgAuth(orgs []*shared.Org, isLocalMode bool) (*shared.Org, error) {
	var org *shared.Org
	var err error

	if len(orgs) == 0 {
		if isLocalMode {
			org, err = createOrg(isLocalMode)
		} else {
			org, err = promptNoOrgs()
		}

		if err != nil {
			return nil, fmt.Errorf("error prompting no orgs: %v", err)
		}

	} else if len(orgs) == 1 {
		org = orgs[0]
	} else {
		org, err = selectOrg(orgs, isLocalMode)

		if err != nil {
			return nil, fmt.Errorf("error selecting org: %v", err)
		}
	}

	return org, nil
}

func promptNoOrgs() (*shared.Org, error) {
	fmt.Println("🧐 You don't have access to any orgs yet.\n\nTo join an existing org, ask an admin to either invite you directly or give your whole email domain access.\n\nOtherwise, you can go ahead and create a new org.")

	shouldCreate, err := term.ConfirmYesNo("Create a new org now?")

	if err != nil {
		return nil, fmt.Errorf("error prompting create org: %v", err)
	}

	if shouldCreate {
		return createOrg(false)
	}

	return nil, nil
}

func createOrg(isLocalMode bool) (*shared.Org, error) {
	var err error
	var name string
	var autoAddDomainUsers bool

	if isLocalMode {
		name = "Local Org"
	} else {
		name, err = term.GetRequiredUserStringInput("Org name:")
	}
	if err != nil {
		return nil, fmt.Errorf("error prompting org name: %v", err)
	}

	if !isLocalMode {
		autoAddDomainUsers, err = promptAutoAddUsersIfValid(Current.Email)
		if err != nil {
			return nil, fmt.Errorf("error prompting auto add domain users: %v", err)
		}
	}

	term.StartSpinner("")
	res, apiErr := apiClient.CreateOrg(shared.CreateOrgRequest{
		Name:               name,
		AutoAddDomainUsers: autoAddDomainUsers,
	})
	term.StopSpinner()

	if apiErr != nil {
		return nil, fmt.Errorf("error creating org: %v", apiErr.Msg)
	}

	return &shared.Org{Id: res.Id, Name: name}, nil
}

func promptAutoAddUsersIfValid(email string) (bool, error) {
	userDomain := strings.Split(email, "@")[1]
	var autoAddDomainUsers bool
	var err error
	if !shared.IsEmailServiceDomain(userDomain) {
		fmt.Println("With domain auto-join, you can allow any user with an email ending in @"+userDomain, "to auto-join this org.")
		autoAddDomainUsers, err = term.ConfirmYesNo(fmt.Sprintf("Enable auto-join for %s?", userDomain))

		if err != nil {
			return false, err
		}
	}
	return autoAddDomainUsers, nil
}

const CreateOrgOption = "Create a new org"

func selectOrg(orgs []*shared.Org, isLocalMode bool) (*shared.Org, error) {
	var options []string
	for _, org := range orgs {
		options = append(options, org.Name)
	}
	options = append(options, CreateOrgOption)

	selected, err := term.SelectFromList("Select an org:", options)

	if err != nil {
		return nil, fmt.Errorf("error selecting org: %v", err)
	}

	if selected == CreateOrgOption {
		return createOrg(isLocalMode)
	}

	var selectedOrg *shared.Org
	for _, org := range orgs {
		if org.Name == selected {
			selectedOrg = org
			break
		}
	}

	if selectedOrg == nil {
		return nil, fmt.Errorf("error selecting org: org not found")
	}

	return selectedOrg, nil
}
