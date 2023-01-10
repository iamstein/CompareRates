#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(scales)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$errorbarPlot <- renderPlot({
    
    #input = list(x1 = 1, x2 = 5, n1 = 10, n2 = 10)
    b = binom::binom.exact(c(input$x1,input$x2),
                           c(input$n1,input$n2))
    b$id = factor(c(1,2), levels = c(1,2))
    b$text = paste0(b$x,"/",b$n)
    
    g = ggplot(b,aes(x = id, y = mean, ymin = lower, ymax = upper))
    g = g + geom_point()
    g = g + geom_errorbar()
    g = g + geom_text(aes(label=text), nudge_x=.15, size=8)
    g = g + labs(x = "Arm", y = "Event Rate")
    g = g + theme_bw()
    g = g + theme(text = element_text(size=16))
    g = g + ggtitle("Dots show the observed event rate\nError bars show the 95% confidence interval")
    print(g)    
  })
  
  output$histogramPlot <- renderPlot({
    n_events = input$x1 + input$x2
    data = data.frame(x = 1:n_events) %>%
      mutate(y1 = choose(n_events,x),
             y1 = y1/sum(y1))
  
    integer_breaks <- function(n = 5, ...) {
      fxn <- function(x) {
        breaks <- floor(pretty(x, n, ...))
        names(breaks) <- attr(breaks, "labels")
        breaks
      }
      return(fxn)
    }
        
    g = ggplot(data, aes(x = x, y = y1))
    g = g + geom_bar(stat = "identity")
    g = g + scale_x_continuous(breaks = pretty_breaks())
    g = g + scale_y_continuous(labels = scales::percent)
    g = g + theme_bw()
    g = g + labs(x = "Number of Events in Arm 1", 
                 y = "Percentage of Permutations")
    g = g + theme(text = element_text(size=16))
    g = g + ggtitle("Percentage of time Arm 1 has a particular number of events\nunder permutation test")
    print(g)
    
  })
})
