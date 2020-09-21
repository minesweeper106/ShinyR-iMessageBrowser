
source("global.R")



#------------------------------UI
ui <- fluidPage(
        fluidRow(navbarPage("SMS Backup Browser - ios v0.01", collapsible = TRUE, inverse = TRUE)),
                            setBackgroundColor(
                                                color = c("#b6c5cf", "#020024"),
                                                gradient = "radial",
                                                direction = c("top", "left")),
    
    
        sidebarLayout(
        
            sidebarPanel(
        
                fileInput("file","Select backup file", placeholder = "No file selected"),
                selectInput("contact", 'Select Contact', choices = NULL)
                
          
            ),
            mainPanel(
                tabsetPanel(
                    tabPanel('Chat View',bootstrapPage(
                        
                        includeCSS("chat2.css"),
                        htmlOutput("nex")
                    )
                    ),
                    tabPanel('Search',
                             
                             DT::DTOutput('ov')
                             
                             )
                    
              
                ))))

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
   
    
    output$ov <- DT::renderDT({
        req(input$file)
        tabledb<-getDB(file=input$file$datapath)
        colnames(tabledb)<-c("Epoch","Date", "Message","sent(1)/received(0)", "Contact")
        tabledb[2:5]
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
