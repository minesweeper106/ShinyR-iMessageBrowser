source("global.R")




ui = dashboardPage(

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
                                      image = "avatar-contact.svg",
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
#------------------------------------
#-----------SERVER-------------------
#------------------------------------
#------------------------------------
server <- function(input, output, session) {
  
  
    db <- reactive({
        req(input$file)
        getDB(file = input$file$datapath)
    })
    whogen <- reactive({
        unique(db()$who)
    })
    # Address Book (optional): handle -> friendly name, NA when not matched
    ab <- reactive({
        req(input$abfile)
        tryCatch(getAddressBook(input$abfile$datapath), error = function(e) {
            showNotification("Could not read the Address Book file", type = "error")
            NULL
        })
    })
    contactNames <- reactive({
        handles <- whogen()
        if (is.null(input$abfile) || is.null(ab())) {
            data.frame(who = handles, name = NA_character_, stringsAsFactors = FALSE)
        } else {
            matchContacts(handles, ab())
        }
    })

    # Scrollable contact list shows friendly names (when an Address Book is
    # loaded); each row carries the handle. The current selection is kept
    # highlighted when names arrive later.
    output$contactItems <- renderUI({
        ch <- contactChoices(contactNames())
        ch <- ch[recentOrder(unname(ch), db())]   # most recent conversation first
        sel <- isolate(input$contact)
        filt <- isolate(input$contactFilter)
        lapply(seq_along(ch), function(i) {
            handle <- unname(ch[i])
            label <- names(ch)[i]
            search <- tolower(paste(label, handle))
            hidden <- !is.null(filt) && nzchar(filt) && !grepl(tolower(filt), search, fixed = TRUE)
            div(class = paste("contact-item",
                              if (identical(handle, sel)) "active",
                              if (hidden) "hidden-by-filter"),
                tabindex = 0, role = "option",
                `data-handle` = handle, `data-search` = search, label)
        })
    })
    
    # Avatars: local SVGs served from www/ (no external requests)
    avatar_received <- "avatar-contact.svg"
    avatar_sent     <- "avatar-me.svg"

    # Messages for the selected contact (newest first)
    parsed <- reactive({
        req(input$contact)
        parser(db(), input$contact)
    })

    # Friendly name for a handle (falls back to the handle)
    nameOf <- function(who) displayName(who, contactNames())

    output$name <- renderText(nameOf(input$contact))
    output$handle <- renderText(input$contact)
    output$f <- renderText(nrow(parsed()))
    # parsed() is sorted newest first: first row = last message, last row = first
    output$firstDate <- renderText(localTime(tail(parsed()$xdate, 1)))
    output$lastDate  <- renderText(localTime(head(parsed()$xdate, 1)))

    # The whole conversation is rendered in one go (a single message to the
    # browser) instead of one updateUserMessages() call per message.
    output$messageStream <- renderUI({
        p <- parsed()
        msgs <- lapply(seq_len(nrow(p)), function(i) {
            received <- p$sent[i] == 0
            userMessage(
                author = if (received) nameOf(p$who[i]) else "Me",
                date   = localTime(p$xdate[i]),
                image  = if (received) avatar_received else avatar_sent,
                type   = if (received) "received" else "sent",
                # attachments / empty messages have NA text
                if (is.na(p$text[i])) "" else p$text[i]
            )
        })
        userMessages(width = NULL, status = "danger", msgs)
    })

    # Export: single-file HTML of the selected conversation
    output$exportInfo <- renderUI({
        if (is.null(input$contact)) return(p(em("Select a contact in the sidebar first.")))
        p(strong(nameOf(input$contact)), " - ", nrow(parsed()), " messages")
    })
    output$exportHtml <- downloadHandler(
        filename = function() exportFileName(nameOf(req(input$contact))),
        content = function(file) {
            writeLines(buildChatHtml(parsed(), nameOf(input$contact), input$contact),
                       file, useBytes = TRUE)
        },
        contentType = "text/html"
    )

    # Keyword search across all contacts, newest first (debounced typing)
    keyword <- debounce(reactive(input$keyword), 400)
    output$searchResults <- DT::renderDT({
        res <- searchMessages(parser(db()), keyword())
        data.frame(
            Name   = nameOf(res$who),
            Handle = res$who,
            Date   = localTime(res$xdate),
            Text   = res$text,
            `Sent/Received` = ifelse(res$sent == 1, "Sent", "Received"),
            check.names = FALSE
        )
    }, rownames = FALSE, options = list(pageLength = 25,
                                        language = list(emptyTable = "No matching messages")))

    # Expand the boxes once a contact is selected
    observeEvent(input$contact, {
        req(input$contact)
        if (isTRUE(input$messageBox$collapsed)) updateBox("messageBox", action = "toggle")
        if (isTRUE(input$profile$collapsed))    updateBox("profile",    action = "toggle")
    })
}
# Run the application
shinyApp(ui = ui, server = server)
