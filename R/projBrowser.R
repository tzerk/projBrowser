#' Browse RStudio Projects
#'
#' A convenient browser for RStudio Projects
#'
#' @export
projectBrowserAddin <- function() {


  ui <- miniPage(

    gadgetTitleBar("Browse RStudio Projects"),
    miniContentPanel(
      miniButtonBlock(
        actionButton("add", "Add", icon = icon("plus-square")),
        tooltip("add", "Scan directory for project files (.Rproj).", placement = "bottom"),
        actionButton("validate", "Validate", icon = icon("check-square")),
        tooltip("validate", "Remove non-existing and duplicate projects", placement = "bottom"),
        actionButton("clean", "Clean", icon = icon("trash")),
        tooltip("clean", "Delete all entries", placement = "bottom")
      ),
      miniButtonBlock(
        actionButton("sortName", "Sort by name", icon = icon("sort-alpha-desc")),
        actionButton("sortDate", "Sort by date", icon = icon("sort-numeric-desc")),
        actionButton("order", "Order", icon = icon("sort"))
      ),
      textInput("filter", "", placeholder = "search", width = "100%"),
      h4("Available Projects"),
      shiny::htmlOutput("document")
    )

  )

  server <- function(input, output, session) {

    values <- reactiveValues(sortName = FALSE, sortDate = TRUE, decreasing = TRUE)

    output$document <- renderUI({
      projects <- get_Projects(values$sortName, values$sortDate, values$decreasing)
      radioButtons("projectList", "Select a project folder", projects, width = 300)
    })

    observeEvent(input$add, {
      entries <- find_Proj()

      if (is.null(entries))
        return(NULL)

      add_Proj(entries)
      updateRadioButtons(session, "projectList", choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })

    observeEvent(input$filter, {

      entries <- get_Projects(values$sortName, values$sortDate, values$decreasing)
      entries.filtered <- entries[grep(input$filter, entries, ignore.case = TRUE)]

      if (length(entries.filtered) == 0)
        entries.filtered <- "No matches"

      updateRadioButtons(session, "projectList", choices = entries.filtered)

    })

    observeEvent(input$validate, {
      validate_ProjList()
      updateRadioButtons(session, "projectList",
                         choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })

    observeEvent(input$clean, {
      clean_ProjList()
      updateRadioButtons(session, "projectList",
                         choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })

    observeEvent(input$meta, {
      values$meta <- !values$meta
      updateRadioButtons(session, "projectList",
                         choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })

    ## SORTING ----
    observeEvent(input$sortName, {
      values$sortName <- TRUE
      values$sortDate <- FALSE
      updateRadioButtons(session, "projectList",
                         choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })

    observeEvent(input$sortDate, {
      values$sortDate <- TRUE
      values$sortName <- FALSE
      updateRadioButtons(session, "projectList",
                         choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })

    observeEvent(input$order, {
      values$decreasing <- !values$decreasing
      updateRadioButtons(session, "projectList",
                         choices = get_Projects(values$sortName, values$sortDate, values$decreasing))
    })


    ## CLOSING ----
    observeEvent(input$done, {
      if (file.exists(input$projectList)) {
        shell.exec(input$projectList)
        stopApp(NULL)
      }
    })

    observeEvent(input$cancel, {
      stopApp(NULL)
    })

  }#EndOf::Server

  viewer <- dialogViewer("Project Browser", width = 450, height = 800)
  runGadget(ui, server, viewer = viewer, stopOnCancel = FALSE)
}
