#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Comparing Event Rates"),
  p("There is often interest in comparing the response rates between two different arms.
     This App provides two ways to visualize this comparison.
     1) Event rate with 95% confidence intervals that are calculated using the",
     a(href='https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Clopper%E2%80%93Pearson_interval','Pearson-Klopper Exact method.'),
     "2) Randomly permute the responses between the two different arms and calculate the percentage of time an outcome as extreme or more is obsesrved.",
     "This page was created by", a(href='https://sites.google.com/site/andrewsteinphd/home', 'Andy Stein')),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       numericInput("x1",
                    "Arm 1: Number of Events",
                    value = 4),
       numericInput("n1",
                    "Arm 1: Number of Patients",
                    value = 40),
       numericInput("x2",
                    "Arm 2: Number of Events",
                    value = 8),
       numericInput("n2",
                    "Arm 2: Number of Patients",
                    value = 40)
       
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("errorbarPlot"),
       plotOutput("histogramPlot"),
    )
  ),
))
