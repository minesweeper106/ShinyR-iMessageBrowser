generate <- function(data, id=NULL, ...) {
  
  parsed <- parser(data, id)
  index <- ""
  
  for (i in 1:nrow(parsed)) {
    
    data <- datacalc(parsed$date[i])
  
    if (parsed$sent[i]==0){
    index <- paste(index, tags$div(class="panel panel-default",tagList(
      div(class="panel-heading", h6(parsed$who[i]), span(class="label label-default", "received")),
      div(class="panel-body",p(parsed$text[i]), p(class="text-muted", data)),
      )),
                   sep = " ")
    }else{
      index <- paste(index, tags$div(class="panel panel-default",tagList(
        div(class="panel-heading", h6(parsed$who[i]), span(class="label label-primary", "sent")),
        div(class="panel-body",p(parsed$text[i]), p(class="text-muted", data)),
      )),
      sep = " ")
    }
    
  }
  index
}
