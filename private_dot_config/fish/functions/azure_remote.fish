function update_azure_origin_url
    # The function receives a PAT as argument, and updates the remote named "origin"
    # on the current folder to make use of the PAT for authentication.
    set -l pat $argv[1]
    if test -z "$pat"
        echo "Usage: update_azure_origin_url <PAT>"
        return 1
    end

    # Get the current origin URL
    set -l origin_url (git remote get-url origin)

    # Parse company, project, repo using awk
    # Azure DevOps URL format: https://dev.azure.com/{company}/{project}/_git/{repo}
    set -l parsed (echo $origin_url | awk -F'/' '
      /dev\.azure\.com/ {
        company=$(NF-3)
        project=$(NF-2)
        repo=$(NF)
        print company, project, repo
      }
    ')

    set -l company (echo $parsed | awk '{print $1}')
    set -l project (echo $parsed | awk '{print $2}')
    set -l repo (echo $parsed | awk '{print $3}')

    if test -z "$company" -o -z "$project" -o -z "$repo"
        echo "Could not parse Azure DevOps remote URL."
        return 1
    end

    # Construct new URL with PAT
    set -l new_url "https://$pat@dev.azure.com/$company/$project/_git/$repo"

    echo "New remote URL: $new_url"

    # Set the new origin URL
    git remote set-url origin $new_url
end
