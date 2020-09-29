
source("global.R")



ui = dashboardPage(

    header = dashboardHeader(title = "iMessage Browser - 0.03",
       
        titleWidth = 350
       
    ),
    sidebar = dashboardSidebar(
        width = 350,
        fileInput("file","Select backup file", placeholder = "No file selected"),
        selectInput("contact", 'Select Contact', choices = NULL),
        textOutput("f")
    ),
    body = dashboardBody(
        box(width = 12,title = "Chat view",id='messageBox',  solidheader = TRUE,  status = "warning", 
            userMessages(
              width = 12,
              status = "danger",
              id = "messageStream")),
        box(width = 12, title= "Raw data", solidheader = TRUE,collapsible = TRUE, collapsed = TRUE, status = "warning", DT::DTOutput('ov'))
        
    ),
    controlbar = dashboardControlbar(skin = "dark", skinSelector())
  
)

server <- function(input, output, session) {
    
    whogen <- reactive({
        req(input$file)
        tabledb<-getDB(file=input$file$datapath)
        wholist <- unique(tabledb$who)
    })
    observeEvent(whogen(), {
        choices <- whogen()
        updateSelectInput(session, "contact", choices = choices)
    })
   
    
    output$ov <- DT::renderDT({
        req(input$file)
        tabledb<-getDB(file=input$file$datapath)
        colnames(tabledb)<-c("Epoch","Date", "Message","sent(1)/received(0)", "Contact")
        tabledb[2:5]
        })
    
        
    
    # output$test<-renderUI({
    #   userMessages(
    #   width = 12,
    #   status = "danger",
    #   id = "messageStream2")})
    # 
    observeEvent(input$contact,{
      req(input$file)
      req(input$contact)
      a<-getDB(file=input$file$datapath)
      parsed <- parser(a, input$contact)
      
      #for (j in f) (updateUserMessages("messageStream", 
      #                   action = "remove", index = j ))
      
      for (i in 1:nrow(parsed)) {
        
        if (parsed$sent[i] == 0) 
        {
          model<-"received"
          avatar_r<-"https://avatars.dicebear.com/api/bottts/example.svg"
        } else {
          model<-"sent"
          avatar_r<-"https://media-exp1.licdn.com/dms/image/C4D03AQEKIBvmAlQifw/profile-displayphoto-shrink_100_100/0?e=1606953600&v=beta&t=Sf2xc9Q61iZnZdnFpNQP9-RS6VMCjckt7zNnIaeWDIg"
        }
      
        
        
        updateUserMessages("messageStream", 
                           action = "add", 
                           content = list(
                             author = parsed$who[i],
                             date = as.character(parsed$date[i]),
                             image  = avatar_r,
                             type = model,
                             text = parsed$text[i]
                           ))
        f<-i+1
      }
      output$f<-renderText({f})
      return(f)
     
    })
}
# Run the application
shinyApp(ui = ui, server = server)
