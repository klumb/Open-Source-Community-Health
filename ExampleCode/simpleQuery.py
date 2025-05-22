import requests

url = 'https://api.github.com/graphql'
api_token = "" # Replace with your actual token
query = '''{
repository(owner: "kubernetes", name: "kubernetes"){
    pullRequests(first: 100) {
      pageInfo{
        hasNextPage
        endCursor
      }
      edges {
        node {
          url
          title
          state
          createdAt
          closedAt
          participants{
            totalCount
          } changedFiles additions deletions
        } 
      }
    }
  }
}''' 

json = { 'query' : query}
headers = {'Authorization': 'token %s' % api_token}
r = requests.post(url=url, json=json, headers=headers)
print (r.text)