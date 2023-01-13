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
    g = g + geom_errorbar(width = 0.5)
    g = g + geom_text(aes(label=text), nudge_x=.15, size=8)
    g = g + labs(x = "Arm", y = "Event Rate")
    g = g + theme_bw()
    g = g + theme(text = element_text(size=16))
    g = g + ggtitle("Dots show the observed event rate\nError bars show the 95% confidence interval")
    print(g)    
  })
  
  output$histogramPlot <- renderPlot({
      n1 = input$n1
      n2 = input$n2
      x1 = input$x1
      x2 = input$x2
      
      ntot = n1 + n2
      xtot = x1 + x2
      nmin = min(n1, n2)
      nmax = max(n1, n2)
      x1lb = max(0, xtot-n2) #given xtot, n1, and n2, the lowest x1 could be
      x2lb = max(0, xtot-n1) #given xtot, n1, and n2, the lowest x2 could be
      x1ub = min(n1, xtot)   #given xtot, n1, and n2, the highest x1 could be
      x2ub = min(n2, xtot)   #given xtot, n1, and n2, the highest x2 could be
      
      x1i = x1lb:x1ub
      x2i = xtot - x1i
      Mi = choose(n1, x1i) * choose(n2, x2i) #number of ways (x1i, x2i) events could be divided
      Mtot = sum(Mi)
      prob = Mi/Mtot #probability of (x1i, x2i)
      ratio1_obs = x1/n1
      ratio2_obs = x2/n2
      ratio1i = x1i/n1
      ratio2i = x2i/n2 
      extreme_flag = ifelse(abs(ratio1i - ratio2i) >= abs(ratio1_obs - ratio2_obs), 1, 0)
      prob_df = data.frame(x1i, x2i, Mi, prob, ratio1_obs, ratio2_obs, ratio1i, ratio2i, extreme_flag)
        
      pct_extreme = signif(sum(prob[extreme_flag==1])*100, 2) 
      
      integer_breaks <- function(n = 5, ...) {
        fxn <- function(x) {
          breaks <- floor(pretty(x, n, ...))
          names(breaks) <- attr(breaks, "labels")
          breaks
        }
        return(fxn)
      }
      
      data = data.frame(x1i = x1i, prob = prob)
      g = ggplot(data, aes(x = x1i, y = prob))
      g = g + geom_bar(stat = "identity")
      g = g + scale_x_continuous(breaks = pretty_breaks())
      g = g + scale_y_continuous(labels = scales::percent)
      g = g + theme_bw()
      g = g + labs(x = "Number of Events in Arm 1", 
                   y = "Percentage of Permutations")
      
      #calculate the extremes of the histogram
      prob_noextreme = prob[extreme_flag == 0]
      g = g + theme(text = element_text(size=16))
      
      y  = max(prob)
      if (any(extreme_flag == 0)) {
        xa = x1i[1]
        xb = x1i[extreme_flag == 0][1] - 1 
        xc = x1i[extreme_flag == 0][sum(extreme_flag == 0)] + 1 
        xd = x1i[length(x1i)]

        g = g + annotate("rect", xmin = xa - 0.5, xmax = xb + 0.5,  ymin = 0, ymax = y, alpha = 0.2, fill="red")
        g = g + annotate("rect", xmin = xc - 0.5, xmax = xd + 0.5,  ymin = 0, ymax = y, alpha = 0.2, fill="red")
      } else {
        g = g + annotate("rect", xmin = x1lb - 0.5, xmax = x1ub + 0.5,  ymin = 0, ymax = y, alpha = 0.2, fill="red")
      }
      g = g + ggtitle(paste0("When permuting response (randomly assigning to either arm):\n",
                             pct_extreme, "% of the time, equal or greater imbalance occurs (shaded area)"))
      
      print(g)
  })
})
