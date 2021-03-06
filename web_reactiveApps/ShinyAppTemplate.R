# SHINY APPS TEMPLATE
# based on http://shiny.rstudio.com/tutorial/


# load the library for shiny
library(shiny)

# UI component
# add elements as arguments to fluidPage()
ui <- fluidPage(
  # *Input() functions to create reactive inputs
  #NB: inputId not inputID!! LOWERCASE 'd' at end of inputId! Else it won't work!
  
  # functionInput(inputId= input name, label=label to display, ... (additional inputs))
  
  # create a slider input via sliderInput() function
  sliderInput(inputId="num",
              label="Choose a number",
              value=25, min=1, max=100)
  
  textInput
  
  # other input functions:
  #actionButton()
  #submitButton()
  #checkboxInput()
  #checkboxGroupInput()
  #dateInput()
  #dateRangeInput()
  #fileInput()
  #numericInput()
  #passwordInput()
  #radioButtons()
  #selectInput()
  #sliderInput()
  #textInput()
  
  
  # MAKE SURE THIS COMMA SEPARATES INPUT AND OUTPUT FUNCTIONS
  # 
  ,
  # 
  
  
  # *Output() functions to display reactive results
  # various functions create different kinds of outputs
  # eg. plotOutput() creats plots in your app, imageOutput() -> images, etc
  
  # functionOutput(outputId= output name, ...)
  
  plotOutput(outputId="hist")
  
  # other output functions:
  #dataTableOutput() - an interactive table
  #htmlOutput() - raw HTML
  #imageOutput() - image
  #plotOutput() - plot
  #tableOutput() - table
  #textOutput() - text
  #uiOutput() - a Shiny UI element
  #verbatimTextOutput() - text
  
  
  )

# server function assembles inputs into outputs
server <- function(input, output) {
  # 3 rules of server function:
  
  # 1) save objects to display, to output$
    # eg. output$hist <- [code]
  
  # 2) build objeccts to display with render*() function
    # eg. output$hist <- renderPlot({  })
  
  # render*() functions: 
  #renderDataTable() - an interactive table
  #renderImage() - an image, saved as a link to a source file
  #renderPlot() - a plot
  #renderPrint() - a code block of printed output
  #renderTable() - a table
  #renderText() - a character string
  #renderUI() - a Shiny UI element
  
  # plot histogram with 100 normally distributed numbers
  # render type of object to build ({ codeblock that builds object, in braces to
  # allow as many lines of code as required })
  #renderPlot({ hist(rnorm(100)) })
  
  # multi-line codeblock inside renderFunction braces!
  #output$hist <- renderPlot({
  #  title <- "100 random normal values"
  #  hist(rnorm(100), main=title)
  #})
  
  # 3) use input values with input$
    # eg. sliderInput(inputId="num", ...) 
      # => input$num
  
  # input values change whenever user changes the input!
  # so to make output depend on input, use input$... 
  
  output$hist <- renderPlot({
    title <- "Some random normal values"
    hist(rnorm(input$num), main=title)
  })
  
  # reactivity 101: 
  # reactivity automatically occurs whenever you use an input value to render 
    # an output value!
  
  # reactive values act as data streams that flow through your app
  
  # the input list is a list of reactive values, the variables show you the
    # current state of the input objects
  
  # reactive functions require reactive values, otherwise "ERROR: operation not
    # allowed without an active reactive context".  You NEED to use a reactive 
    # function (eg. render*()) with a required reactive value (input$*)
  
  # reactivity is 2-step process
  # 1) reactive values notify the functions that use them when they become 
    # invalid (process k.a. invalidating)
  # 2) the objects created by reactive functions respond
  
  # REACTIVE TOOLKIT
  
  # 1) use a code chunk to build (& rebuild) an object
    # what code will the function use?
  # 2) object will respond to changes in a set of reactive values
    # which reactive values will the object respond to
 
  ## Display output with render*() functions:
  #renderDataTable() - an interactive table
  #renderImage() - an image, saved as a link to a source file
  #renderPlot() - a plot
  #renderPrint() - a code block of printed output
  #renderTable() - a table
  #renderText() - a character string
  #renderUI() - a Shiny UI element
  
}

# knit UI and server components together using shinyApp() function
shinyApp(ui = ui, server = server)

# servers expect your app to be packaged like this: 
# one directory with every file the app needs!
  # app.R (needs that EXACT name! This is the script which ends with a call to 
    # shinyApp() as above)
  # + datasets, images, css, helper scripts, etc


################################################################################

# examples of render*() functions:

output$hist <- renderPlot({
  hist(rnorm(input$num), 
       main = input$title)
})
