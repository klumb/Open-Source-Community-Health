#install.packages("httr")
#install.packages("devtools")
#install.packages("jsonlite")
#install.packages("stringr")
######install.packages("data.table")
#devtools::install_github("ropensci/ghql")
#sessionInfo()
library("stringr")
library("ghql")
library("jsonlite")
library("httr")
#library(rjsonpath)
library(dplyr)
#######library(data.table)

# Create Token

#token <- '' # write your github token
cli <- GraphqlClient$new(
  url = "https://api.github.com/graphql",
  headers = list(Authorization = paste0("Bearer ", token))
)

# Load Schema
cli$load_schema()

#Make a Query class object
qry <- Query$new()

# Create query
#repository(owner: "grpc", name: "grpc"){
#repository(owner: "zephyrproject-rtos", name: "zephyr"){

ghquery <- paste0('{
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
          }
          changedFiles
          additions
          deletions
        } 
      }
    }
  }
}')

qry$query('list', ghquery)
qry
qry$queries$list

# Execute query

listextraction <- cli$exec(qry$queries$list)

# Extract list from query

str(listextraction)
View(listextraction)

listextraction_text <- fromJSON(listextraction, flatten=TRUE) ###need to convert from a character list to a text object

#str(listextraction_text)
#View(listextraction_text)

listextraction_df <- as.data.frame(listextraction_text)

#str(listextraction_df)
#View(listextraction_df)

# Find end cursor
endCursor<- tail(listextraction_df, n=1L)[1,2]

# Find next page
hasNextPage<-tail(listextraction_df, n=1L)[1,1]

#repository(owner: "zephyrproject-rtos", name: "zephyr"){ 
#repository(owner: "grpc", name: "grpc"){

# Running loop for list extraction
while (hasNextPage==TRUE){
  # Write query for loop
ghquery <- paste0('{
repository(owner: "kubernetes", name: "kubernetes"){
    pullRequests(first: 10, after:"',endCursor,'"){
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
          }
          changedFiles
          additions
          deletions
        } 
      }
    }
  }
}')
  qry <- Query$new()
  qry$query('list', ghquery)
  qry$queries$list
  listextraction_loop<- cli$exec(qry$queries$list)
  listextraction_text_loop <- fromJSON(listextraction_loop, flatten=TRUE)
  listextraction_df_loop <- as.data.frame(listextraction_text_loop)
  listextraction_df <- rbind(listextraction_df, listextraction_df_loop)
  #View(listextraction_df)
  endCursor<- tail(listextraction_df, n=1L)[1,2]
  hasNextPage<-tail(listextraction_df, n=1L)[1,1]
}

View(listextraction_df)

#View(listextraction_df_loop)

# Rename the repository list column
#names(listextraction_df)[1]<- "HasNextPage"
#names(listextraction_df)[2]<- "EndCurser"
#names(listextraction_df)[3]<-"URL"
#names(listextraction_df)[4]<-"Title"
#names(listextraction_df)[5]<-"Status"
#names(listextraction_df)[6]<-"CreatedAt"
#names(listextraction_df)[7]<-"ClosedAt"
#names(listextraction_df)[8]<-"ChangedFiles"
#names(listextraction_df)[9]<-"Additions"
#names(listextraction_df)[10]<-"Deletions"
#names(listextraction_df)[11]<-"Participants"


#View(listextraction_df)

#setwd("C:/My Directory") # path to location where you want to save file
#write.csv(listextraction_df, file = "Zephyr.PR.1.12.21.csv")
#write.csv(listextraction_df, file = "GRPC.PR.1.12.21.csv")
#write.csv(listextraction_df, file = "Kubernetes.PR.1.12.21.csv")

#getwd()
#setwd("/Users/kevin/desktop")


#str_replace_all()
#stri_extract_all()
#str_detect()
#https://regexr.com/

#listextraction_df = read.csv("Zephyr.PR.1.12.21.csv")
#View(listextraction_df)

#listextraction_df$CreatedAt <- str_replace_all(listextraction_df$CreatedAt, 'T', ' ')
#listextraction_df$CreatedAt <- str_replace_all(listextraction_df$CreatedAt, 'Z', '')

#listextraction_df$ClosedAt <- str_replace_all(listextraction_df$ClosedAt, 'T', ' ')
#listextraction_df$ClosedAt <- str_replace_all(listextraction_df$ClosedAt, 'Z', '')

#View(listextraction_df)