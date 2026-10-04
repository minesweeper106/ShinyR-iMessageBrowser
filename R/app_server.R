# Server logic
app_server <- function(input, output, session) {
  
  
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
    avatar_received <- "imb-assets/avatar-contact.svg"
    avatar_sent     <- "imb-assets/avatar-me.svg"

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
