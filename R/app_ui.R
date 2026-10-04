# UI: built in a function so www/ resources are registered when the app starts
app_ui <- function() {
dashboardPage(

    header = dashboardHeader(title = "iMessage Browser - 1.0",
       
        titleWidth = 350
       
    ),
#------------------Sidebar    
    sidebar = dashboardSidebar(
        width = 350,
        minified = FALSE,
        
        fileInput("file","Select backup file", placeholder = "No file selected"),
        fileInput("abfile","Select Address Book file", placeholder = "No file selected"),
        hr(),
        textInput("contactFilter", NULL, placeholder = "Filter contacts"),
        div(id = "contactList", class = "contact-list", uiOutput("contactItems")),
        tags$head(
          tags$style(HTML("
            .contact-list { overflow-y: auto; max-height: calc(100vh - 420px); min-height: 150px; }
            .contact-item { padding: 8px 15px; cursor: pointer; white-space: nowrap;
                            overflow: hidden; text-overflow: ellipsis; color: #b8c7ce; }
            .contact-item:hover, .contact-item:focus { background: #1e282c; color: #fff; outline: none; }
            .contact-item.active { background: #2c3b41; color: #fff; border-left: 3px solid #f39c12; }
            .contact-item.hidden-by-filter { display: none; }
          ")),
          tags$script(HTML("
            $(document).on('click keydown', '.contact-item', function(e) {
              if (e.type === 'keydown' && e.key !== 'Enter') return;
              $('.contact-item.active').removeClass('active');
              $(this).addClass('active');
              Shiny.setInputValue('contact', this.dataset.handle, {priority: 'event'});
            });
            $(document).on('input', '#contactFilter', function() {
              var q = this.value.toLowerCase();
              $('.contact-item').each(function() {
                $(this).toggleClass('hidden-by-filter', this.dataset.search.indexOf(q) === -1);
              });
            });
          "))
        )
    ),
#-----------------Body    
body = dashboardBody(
      
      
      
      
  tabBox(width=12,
          id = "tabsetView",
          tabPanel("Chat View", 
                   fluidRow(  
                     box(title = "Chat view",id='messageBox', collapsible = TRUE, collapsed = TRUE,  solidHeader = FALSE,  status = "warning", 
                                    uiOutput("messageStream")),
                    box(title = "Contact", id='profile', collapsible = TRUE, collapsed = TRUE,
                                    boxProfile(
                                      image = "imb-assets/avatar-contact.svg",
                                      title = textOutput("name"),
                                        bordered = TRUE,
                                        boxProfileItem(
                                        title = "Number / handle",
                                        description = textOutput("handle")
                                          ),
                                        boxProfileItem(
                                        title = "Number of messages",
                                        description = textOutput("f")
                                          ),
                                        boxProfileItem(
                                        title = "First message",
                                        description = textOutput("firstDate")
                                          ),
                                        boxProfileItem(
                                        title = "Last message",
                                        description = textOutput("lastDate")
                                          )
                                        )
                          )
                   
                        )
          ),
          tabPanel("Export",
                   box(width = NULL, title = "Export chat as HTML",
                       solidHeader = TRUE, status = "warning",
                       p("Saves the conversation with the contact selected in the sidebar",
                         "as a single, self-contained HTML file (oldest message first)."),
                       uiOutput("exportInfo"),
                       downloadButton("exportHtml", "Download HTML"))),
          tabPanel("Search",
                   box(width = NULL, title = "Search messages (all contacts)",
                       solidHeader = TRUE, status = "warning",
                       textInput("keyword", "Keyword", placeholder = "Type a word or phrase"),
                       DT::DTOutput("searchResults")))
    )
        
        
        
        
),
    footer= dashboardFooter(left="By minesweeper106",
                            right= socialButton(href = "https://github.com/minesweeper106",icon = icon("github"))
    )
  
)
}
