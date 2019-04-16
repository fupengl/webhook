package gitlab

//GitlabRepository represents repository information from the webhook
type GitlabRepository struct {
	Name        string
	URL         string
	Description string
	Home        string
}

type GitLabProject struct {
	Name              string
	Description       string
	PathWithNamespace string `json:"path_with_namespace"`
	Namespace         string
}

//Commit represents commit information from the webhook
type Commit struct {
	ID        string
	Message   string
	Timestamp string
	URL       string
	Author    Author
}

//Author represents author information from the webhook
type Author struct {
	Name  string
	Email string
}

//Webhook represents push information from the webhook
type Webhook struct {
	Before            string
	After             string
	Ref               string
	Username          string
	UserID            int
	ProjectID         int
	Repository        GitlabRepository
	Commits           []Commit
	Project           GitLabProject
	EventName         string
	TotalCommitsCount int
}

//ConfigRepository represents a repository from the config file
type ConfigRepository struct {
	Name     string
	Alias    string
	Commands []string
}

//Config represents the config file
type Config struct {
	Logfile      string
	Address      string
	Port         int64
	Repositories []ConfigRepository
}