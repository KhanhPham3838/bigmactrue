library(shiny)
library(shinythemes)
library(shinyWidgets)
library(tidyverse)
library(plotly)
library(stringr)

ui <- fluidPage(theme = shinytheme("paper"),

                titlePanel(HTML("The <span style='color: #FFC72C;'>Big</span> <span style='color: #DA291C;'>Mac</span> Index 🍔: Do all currency valuations eventually converge? 🤔"),
                           windowTitle = "The Big Mac Index"),

                tabsetPanel(
                  tabPanel(
                    title = HTML("<b>World currencies valuation based on the Big Mac index (2000 - 2020)</b>"),
                    sidebarLayout(
                      sidebarPanel(
                        selectInput("raw_cur",
                                    label = "Choose the base currency:",
                                    choices = c("EUR - Euro",
                                                "USD - US dollar",
                                                "GBP - British pound",
                                                "JPY - Japanese yen",
                                                "CNY - Chinese yuan"),
                                    selected = "USD - US dollar"),
                        h6(HTML("<b>Explanation: </b><br>
                                <b>A Big Mac</b> is made of the same ingredients regardless of locations so they should be priced the same. <br>
                                Meaning that if a Big Mac costs $6 in the US, it should <b>cost the same in another country times with the exchange rate right?</b> <br><br>
                                <b>BUT NOPE</b>, this is not the case, a Big Mac in some countries, when converted into USD, is more/less than the its US price</b><br><br>
                                When hovering over a country, the displayed <b>%Percentage</b> indicates:<br><br> How much the base currency is being <b>undervalued</b> (if negative) <br>OR <b>overvalued</b> (if positive) according to the Big Mac Index <br><br>
                                What do you notice about the <b>overall</b> trend? 🤔 Try changing the base currency around."
                        ))
                      ),

                      mainPanel(
                        plotlyOutput("lineplot")
                      )
                    )
                  ),



                  ##plot 3 (but moved to 2)
                  tabPanel(
                    title = HTML("<b>World currencies against base currency for each year</b>"),
                    sidebarLayout(
                      sidebarPanel(
                        selectInput("raw_cur_2",
                                    label = "Choose the base currency:",
                                    choices = c("EUR - Euro",
                                                "USD - US dollar",
                                                "GBP - British pound",
                                                "JPY - Japanese yen",
                                                "CNY - Chinese yuan"),
                                    selected = "USD - US dollar"),
                        selectInput("date_select",
                                    label = "Choose a date:",
                                    choices = c("April 2000", "April 2001", "April 2002", "April 2003", "May 2004", "June 2005",
                                                "January 2006", "May 2006", "January 2007", "June 2007", "June 2008", "July 2009",
                                                "January 2010", "July 2010", "July 2011", "January 2012", "July 2012", "January 2013",
                                                "July 2013", "January 2014", "July 2014", "January 2015", "July 2015", "January 2016",
                                                "July 2016", "January 2017", "July 2017", "January 2018", "July 2018", "January 2019",
                                                "July 2019", "January 2020", "July 2020"),
                                    selected = "April 2000"
                        ),

                        h6(HTML("When hovering over a country, the displayed <b>%Percentage</b> indicates:
                                <br><br> How much the base currency is being <b>undervalued</b> (if negative)
                                <br>OR <b>overvalued</b> (if positive) according to the Big Mac Index
                                <br><br> Notice how the 0% shifts when changing the base currency? 🔎<br><br>
                                Which base currency is the most overvalued against (or cheapest to buy a Big Mac 😋)? <br><b>Hint:</b> one with the most blue bars 🧧"))),

                      mainPanel(
                        plotlyOutput("histPlot")
                      )
                    )
                  ),

                  tabPanel(

                    title = HTML("<b>Inflation rate by local price versus dollar price</b>"),
                    sidebarLayout(
                      sidebarPanel(
                        radioButtons("inflachoice",
                                     "Price change in local versus dollar price",
                                     choices = c("Local currency", "Dollar price"),
                                     selected = "Dollar price"),
                        h6(
                          HTML("This plot shows the price change from 2000 to 2020 for A Big Mac for countries with <b>20 years data.</b><br><br>
       For example, <b>Australia</b> shows <b>2.5X for local currency</b>, meaning that their price has <b>increased by 2.5 times in the 20-year period</b><br><br>
                               When <b>dollar price</b> is used as the base currency,<b> an Australian Big Mac increased by 3x</b>, meaning that <br><br>
                               The <b>exchange rate growth is 1.2X</b>, indicating the <b>AUD depreciated against the USD</b>
                               <br><br>Can you see Argentina's hyper inflation? 🫣 but what about its dollar price? 🤔")
                        )
                      ),

                      mainPanel(
                        plotlyOutput("inflaPlot")
                      )
                    )
                  ),

                  tabPanel(
                    title = HTML("<span style='background: linear-gradient(to right, #FFC72C, #DA291C); -webkit-background-clip: text; -webkit-text-fill-color: transparent;'>About</span>"),
                    titlePanel(HTML("<span style='background: linear-gradient(to right, #FFC72C, #DA291C); -webkit-background-clip: text; -webkit-text-fill-color: transparent;'>About</span>")),
                    "Created with R Shiny, using Rstudio IDE",
                    br(),
                    "2023 August",
                    uiOutput("about")
                  )
                )
,
includeCSS("styles.css"))


server <- function(input, output) {

  ### Data

  data <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-12-22/big-mac.csv")

  data <- data %>%
    select(1:12, -iso_a3)

  ###### plot 1
  output$lineplot <- renderPlotly({

    data_p1 <- data %>%
      rename(Date = date) %>%
      mutate(Percentage = case_when(
        input$raw_cur == "EUR - Euro" ~ eur_raw * 100,
        input$raw_cur == "USD - US dollar" ~ usd_raw * 100,
        input$raw_cur == "GBP - British pound" ~ gbp_raw * 100,
        input$raw_cur == "JPY - Japanese yen" ~ jpy_raw * 100,
        input$raw_cur == "CNY - Chinese yuan" ~ cny_raw * 100,
        TRUE ~ usd_raw * 100
      ))

    data_p1$Currency <- str_c(data_p1$currency_code, ' - ', data_p1$name)

    d <- highlight_key(data_p1, ~Currency)


    p <- ggplot(d, aes(y = Percentage, x = Date, colour = Currency), size = 0.5) +
          geom_line() +
          geom_point(size = 1) +
          geom_hline(yintercept = 0, linetype = "dashed", color = "black", size = 1) +
          expand_limits(y = 0) +
          theme_bw(base_size = 14) +
          theme(legend.position = "none", text = element_text(size = 9)) +
          labs(x = "",
           y = paste0("% of Over/Undervaluation difference against ", input$raw_cur),
           title = paste0("Over/Undervaluation change over time (against ", input$raw_cur, ")"))

    gg <- ggplotly( p, tooltips = "text") %>%
      layout(annotations = list(
        list(xref = "paper", yref = "y", x = 0.05, y = 15, text = "0% base line", showarrow = FALSE)
      ))

    highlight( gg, on="plotly_hover", off = "plotly_deselect", color = "black")
  })




  # plot 2: inflation

  output$inflaPlot <- renderPlotly({

    # Process data
    data_test <- data %>%
      group_by(name) %>%
      count(name) %>%
      filter(n == 33)

    dt <- data %>%
      inner_join(data_test, by = "name") %>%
      select(name, price = ifelse(input$inflachoice == "Dollar price", "dollar_price", "local_price")) %>%
      mutate(name = fct_reorder(name, price, function (x) last(x)/first(x))) %>%
      group_by(name) %>%
      summarise(Inflation = last(price)/first(price))

    ggplotly(
      dt %>%
        ggplot(aes(y = Inflation, x = name)) +
        geom_hline(aes(yintercept = median(Inflation)), col = "#c97ef6") +
        geom_segment(aes(x = name, y = 0.9, xend = name, yend = Inflation)) +
        geom_point(size=2, color="aquamarine4") +
        geom_text(aes(label = paste0(round(Inflation, 1), "X")), position = position_nudge(y = 0.03)) +
        annotate("text", x = 3, y = median(dt$Inflation) + 0.5, label = paste0("Median: ", round(median(dt$Inflation), 1)), hjust = -0.1, col = "#c97ef6") +
        coord_flip() +
        scale_y_log10(breaks = c(1,3,10, 30, 100)) +
        theme_bw(base_size = 16) +
        theme(legend.position = "none", text = element_text(size = 9)) +
        labs(x = "", y = "Inflation rate over time",
             title = paste0("Price changes from 2000-2020 (", input$inflachoice, ")"))
    )
  })


### plot 3

  output$histPlot <- renderPlotly({

    data$formatted_date <- format(data$date, format = "%B %Y")


    data_p3 <- data %>%
      rename(Date = date) %>%
      mutate(Percentage = case_when(
        input$raw_cur_2 == "EUR - Euro" ~ eur_raw * 100,
        input$raw_cur_2 == "USD - US dollar" ~ usd_raw * 100,
        input$raw_cur_2 == "GBP - British pound" ~ gbp_raw * 100,
        input$raw_cur_2 == "JPY - Japanese yen" ~ jpy_raw * 100,
        input$raw_cur_2 == "CNY - Chinese yuan" ~ cny_raw * 100,
        TRUE ~ usd_raw * 100
      ))

    data_p3$Currency <- str_c(data_p3$currency_code, ' - ', data_p3$name)
    data_p3$formatted_date <- as.factor(data_p3$formatted_date)

    selected_date <- input$date_select

    subset_df <- data_p3[data_p3$formatted_date == selected_date, ]

    ggplotly(
      subset_df %>%
        group_by(Currency, formatted_date) %>%
        ggplot(aes(x = reorder(Currency,Percentage), y = Percentage)) +
        geom_bar(width = 0.5, stat = "identity", aes(fill = ifelse(Percentage < 0, "blue", "red")), position = position_dodge()) +
        coord_flip() +
        theme_bw(base_size = 20) +
        theme(legend.position = "none", text = element_text(size = 7), title = element_text(size = 9)) +
        labs(x = "", y = "Valuation %",
             title = paste0("Undervaluation/Overvaluation <br>against ",input$raw_cur_2," in ", input$date_select))
      )



    })


    ## the about section
    output$about <- renderUI({
      knitr::knit("about.Rmd", quiet = TRUE) %>%
        markdown::markdownToHTML(fragment.only = TRUE) %>%
        HTML()
    })
}

shinyApp(ui = ui, server = server)
