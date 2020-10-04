
source("global.R")



ui = dashboardPage(

    header = dashboardHeader(title = "iMessage Browser - 0.03",
       
        titleWidth = 350
       
    ),
#------------------Sidebar    
    sidebar = dashboardSidebar(
        width = 350,
        minified = FALSE,
        
        fileInput("file","Select backup file", placeholder = "No file selected"),
        hr(),
        selectInput("contact", 'Select Contact', choices = NULL)
       
       
    ),
#-----------------Body    
body = dashboardBody(
      
      
      
      
  tabBox(width=12,
          id = "tabsetView",
          tabPanel("Chat View", 
                   fluidRow(  
                     box(title = "Chat view",id='messageBox', collapsible = TRUE, collapsed = TRUE,  solidheader = FALSE,  status = "warning", 
                                    userMessages(
                                      width = NULL,
                                      status = "danger",
                                      id = "messageStream")),
                    box(title = "Contact", id='profile', collapsible = TRUE, collapsed = TRUE,
                                    boxProfile(
                                      image = "https://avatars.dicebear.com/api/bottts/example.svg",
                                      title = textOutput("name"),
                                        bordered = TRUE,
                                        boxProfileItem(
                                        title = "Number of messages",
                                        description = textOutput("f")
                                          ),
                                        boxProfileItem(
                                        title = "Other",
                                        description = "N/a"
                                                      )
                                        )
                          )
                   
                        )
          ),
          tabPanel("Raw Table", 
                   box(width = NULL, title= "table", solidheader = TRUE,collapsible = TRUE, collapsed = TRUE, status = "warning", DT::DTOutput('ov')))
    )
        
        
        
        
),
#-----------Right Panel
    controlbar = dashboardControlbar(skin = "dark", controlbarMenu(
              id = "menu",
              controlbarItem( "Themes","Change Color theme",br(),hr()),
              controlbarItem( "Tab 2" )
    ) ),
    footer= dashboardFooter(left="By minesweeper106",
                            right= socialButton(href = "https://github.com/minesweeper106",icon = icon("github"))
    )
  
)
#------------------------------------
#-----------SERVER-------------------
#------------------------------------
#------------------------------------
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
    # #Uncollapsing views on input
    # observeEvent(input$file,{ 
    #   updateBox("messageBox", 
    #             action = "toggle"
    #   )        
    #   updateBox("messageBox", 
    #             action = "update",
    #             options = list(collapsible=FALSE )
    #   )
    #   updateBox("profile", 
    #             action = "toggle"
    #   )   
    #   
    #   
    #   })
    
    output$ov <- DT::renderDT({
        req(input$file)
        tabledb<-isolate(getDB(file=input$file$datapath))
        colnames(tabledb)<-c("Epoch","Date", "Message","sent(1)/received(0)", "Contact")
        tabledb[2:5]
        })

    observeEvent(input$contact,{
      req(input$file)
      req(input$contact)
      a<-getDB(file=input$file$datapath)
      parsed <- parser(a, input$contact)
      output$name <- renderText({input$contact})
      while (messages_per_contact>0) {
        updateUserMessages("messageStream", 
                         action = "remove", index = messages_per_contact )
        messages_per_contact<-messages_per_contact-1
        }
      f<-0
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
                             date = as.character(parsed$xdate[i]),
                             image  = avatar_r,
                             type = model,
                             text = parsed$text[i]
                           ))
        f<-f+1
      }
      output$f<-renderText({f})
      if (input$messageBox$collapsed) {updateBox("messageBox", 
                action = "toggle" ) }
      if (input$profile$collapsed) {updateBox("profile", 
                action = "toggle" ) }
      assign("messages_per_contact", f, envir = .GlobalEnv)
     
    })
}
# Run the application
shinyApp(ui = ui, server = server)
