token <- Sys.getenv("TOKEN")

#### Set-up API requests

url <- "https://classic.warcraftlogs.com/api/v2"

WCL_API2_request <- function(request) {

  tryCatch({

    response_formated <- fromJSON(content(POST(url,
                                               add_headers("Content-Type" = "application/json",
                                                           "Authorization"= paste0("Bearer ",
                                                                                   token)),
                                               body = jsonlite::toJSON(list(query=request),
                                                                       auto_unbox=TRUE,
                                                                       bigint_as_char=F),
                                               content_type_json(),
                                               encode = "json"),
                                          as = "text",
                                          encoding="UTF-8"),
                                  bigint_as_char=TRUE)

    return(response_formated)
  }, error = function(e) {

    cat("Error in WCL_API2_request:", e$message, " Request: ",request,"\n")

    return(NULL)

  })
}




request_logs_str <- '{
    reportData {
        report(code: "%s") {
            events(dataType:All
                  killType:Encounters
                  hostilityType:Friendlies
                  startTime: 0
                  endTime: 999999999999
                  filterExpression:"%s"){
              data
              nextPageTimestamp
              }
            }
        }
        }'



request_player_str <-     '{
    reportData {
        report(code: "%s") {
            masterData(translate: true) {
                actors(type: "player"){

                gameID
                id
                name
                server
                subType

                }
        }
    }
}}'

request_casts_str <- '{
    reportData {
        report(code: "%s") {
            events(dataType:Casts
                  killType:Encounters
                  hostilityType:Friendlies
                  startTime: 0
                  endTime: 999999999999
                  fightIDs: %i
                  sourceID: %i
                  includeResources: true){
              data
              nextPageTimestamp
              }
            }
        }
        }'




WCL_API2_request_v2 <- function(request) {
  tryCatch({
    # Convert the request object to a JSON character string
    json_request <- jsonlite::toJSON(request, auto_unbox = TRUE, bigint_as_char = FALSE)

    # Make the API request using the shared connection pool
    response <- POST(url,
                     add_headers("Content-Type" = "application/json",
                                 "Authorization" = paste0("Bearer ", token)),
                     body = json_request,
                     content_type_json())

    # Parse the response as JSON
    response_formatted <- content(response, as = "text", encoding = "UTF-8")
    return(fromJSON(response_formatted, bigint_as_char = TRUE))
  }, error = function(e) {
    cat("Error in WCL_API2_request:", e$message, " Request: ", request, "\n")
    return(NULL)
  })
}
