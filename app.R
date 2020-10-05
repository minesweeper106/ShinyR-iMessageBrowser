
source("global.R")



#------------------------------UI
ui <- fluidPage(
    theme = shinytheme("cosmo"),
    tags$h1("iMessageBrowser"),
    tags$hr(),
    tags$footer(title="Footer", align = "left", style = "position:fixed;
  bottom:0;
  right:0;
  left:0;
  padding:10px;
  box-sizing:border-box;", p(class="float-left","by minesweeper106")),
        sidebarLayout(
        
            sidebarPanel(
        
                fileInput("file","Select backup file", placeholder = "No file selected"),
                selectInput("contact", 'Select Contact', choices = NULL)
                
          
            ),
            mainPanel(bootstrapPage(
                        htmlOutput("nex")
                    
              
                ))
            
            ))

#------------------------------SRV
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

    output$nex <- renderText({
        req(input$file)
        req(input$contact)
        a<-getDB(file=input$file$datapath)
        generate(a, input$contact)
    })
    
}
# Run the application
shinyApp(ui = ui, server = server)
