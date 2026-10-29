# Aplicación Shiny para diseñar y exportar una curva de crecimiento de von Bertalanffy
# Ejecutar con: shiny::runApp("ruta/a/von_bertalanffy_shiny")

library(shiny)
library(ggplot2)
library(colourpicker)
library(svglite)

ui <- fluidPage(
  tags$head(
    tags$meta(charset = "utf-8"),
    tags$style(HTML("
      body {
        background: #f3f5f7;
        color: #202733;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }
      .app-header {
        background: #202733;
        color: #ffffff;
        padding: 24px 30px;
        margin: -15px -15px 24px -15px;
        border-bottom: 4px solid #4b87a8;
      }
      .app-header h1 { margin: 0 0 8px 0; font-size: 27px; font-weight: 650; }
      .app-header p { margin: 0; color: #d7e0e8; font-size: 14px; }
      .well {
        background: #ffffff;
        border: 1px solid #e0e5ea;
        border-radius: 10px;
        box-shadow: none;
      }
      .nav-tabs { margin-bottom: 16px; }
      .nav-tabs > li > a { font-weight: 600; }
      .preview-card {
        background: #ffffff;
        border: 1px solid #e0e5ea;
        border-radius: 10px;
        padding: 20px 22px 16px 22px;
        box-shadow: 0 2px 8px rgba(25, 39, 52, 0.035);
      }
      .preview-card h3 { margin-top: 0; font-size: 18px; font-weight: 650; }
      .field-note { color: #697586; font-size: 12px; line-height: 1.45; }
      .section-label {
        font-size: 12px; text-transform: uppercase; letter-spacing: .08em;
        color: #718096; font-weight: 700; margin: 8px 0 12px 0;
      }
      .btn { border-radius: 6px; font-weight: 600; white-space: normal; }
      .btn-primary { background: #245d7a; border-color: #245d7a; }
      .btn-primary:hover, .btn-primary:focus { background: #19445b; border-color: #19445b; }
      .btn-default { border-color: #ccd4dc; }
      .export-button { width: 100%; margin: 5px 0; }
      .formula-box {
        background: #f6f8fa; border: 1px solid #e4e9ee; border-radius: 7px;
        padding: 10px 12px; color: #354052; margin: 12px 0;
      }
      .shiny-input-container { width: 100%; }
      .control-label { font-weight: 600; }
      .footer-note { color: #697586; font-size: 12px; margin-top: 12px; }
      @media (max-width: 767px) {
        .app-header { padding: 20px; margin-bottom: 16px; }
        .app-header h1 { font-size: 23px; }
        .preview-card { padding: 14px; }
      }
    "))
  ),
  
  div(
    class = "app-header",
    h1("Curva de crecimiento de von Bertalanffy"),
    p("Diseña la figura, ajusta los parámetros y exporta una figura en formato vectorial.")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 4,
      tabsetPanel(
        id = "control_tabs",
        type = "tabs",
        
        tabPanel(
          title = "Modelo",
          br(),
          div(class = "section-label", "Parámetros biológicos"),
          numericInput("Linf", HTML("L∞ · longitud asintótica"), value = 120, min = 0.001, step = 1),
          numericInput("K", "K · coeficiente de crecimiento", value = 0.35, min = 0.0001, step = 0.01),
          numericInput("t0", HTML("t₀ · edad teórica a longitud cero"), value = -0.2, step = 0.1),
          div(class = "field-note", "Los valores iniciales son ilustrativos. Sustitúyelos por las estimaciones correspondientes a tu especie."),
          hr(),
          div(class = "section-label", "Intervalo y resolución"),
          fluidRow(
            column(6, numericInput("age_min", "Edad mínima", value = 0, step = 0.5)),
            column(6, numericInput("age_max", "Edad máxima", value = 25, step = 0.5))
          ),
          sliderInput("n_points", "Suavidad de la curva", min = 5, max = 1000, value = 500, step = 5),
          div(class = "field-note", "Un mayor número de puntos genera una curva más suave; normalmente 300–700 puntos son suficientes.")
        ),
        
        tabPanel(
          title = "Diseño",
          br(),
          div(class = "section-label", "Textos"),
          textInput("plot_title", "Título", value = "Curva de crecimiento"),
          textInput("plot_subtitle", "Subtítulo (opcional)", value = ""),
          textInput("x_label", "Eje X", value = "Edad (años)"),
          textInput("y_label", "Eje Y", value = "Longitud del manto (cm)"),
          hr(),
          div(class = "section-label", "Apariencia"),
          colourpicker::colourInput(
            "curve_color", "Color de la curva", value = "#245D7A",
            showColour = "both", palette = "square", allowTransparent = FALSE
          ),
          sliderInput("line_width", "Grosor de línea", min = 0.2, max = 4, value = 1, step = 0.01),
          selectInput(
            "line_type", "Tipo de línea",
            choices = c("Continua" = "solid", "Discontinua" = "dashed", "Punteada" = "dotted",
                        "Trazo y punto" = "dotdash", "Trazo largo" = "longdash"),
            selected = "solid"
          ),
          selectInput(
            "font_family", "Familia tipográfica",
            choices = c("Sans serif (Arial/Helvetica)" = "sans",
                        "Serif (Times)" = "serif",
                        "Monoespaciada" = "mono"),
            selected = "sans"
          ),
          sliderInput("base_size", "Tamaño tipográfico base", min = 8, max = 22, value = 12, step = 1),
          selectInput(
            "theme_style", "Estilo de ejes y fondo",
            choices = c("Clásico · sin cuadrícula" = "classic",
                        "Minimalista" = "minimal",
                        "Cuadrícula ligera" = "light"),
            selected = "classic"
          ),
          checkboxInput("show_asymptote", HTML("Mostrar L∞ como línea discontinua"), value = FALSE)
        ),
        
        tabPanel(
          title = "Exportar",
          br(),
          div(class = "section-label", "Tamaño de la figura"),
          fluidRow(
            column(6, numericInput("export_width", "Ancho", value = 8, min = 1, max = 40, step = 0.5)),
            column(6, numericInput("export_height", "Alto", value = 5, min = 1, max = 40, step = 0.5))
          ),
          selectInput("export_units", "Unidad", choices = c("Pulgadas" = "in", "Centímetros" = "cm", "Milímetros" = "mm"), selected = "in"),
          selectInput("background", "Fondo del archivo", choices = c("Blanco" = "white", "Transparente" = "transparent"), selected = "white"),
          textInput("file_name", "Nombre de archivo (sin extensión)", value = "curva_von_bertalanffy"),
          div(class = "field-note", "SVG y PDF conservan la curva, los ejes y los textos como elementos vectoriales. El fondo transparente puede resultar útil al maquetar."),
          hr(),
          downloadButton("download_svg", "Descargar SVG vectorial", class = "btn btn-primary export-button"),
          downloadButton("download_pdf", "Descargar PDF vectorial", class = "btn btn-default export-button"),
          div(class = "footer-note", "Los archivos se generan con las dimensiones indicadas arriba, no con el tamaño de la vista previa.")
        )
      )
    ),
    
    mainPanel(
      width = 8,
      div(
        class = "preview-card",
        h3("Vista previa"),
        plotOutput("curve_plot", height = "590px", width = "100%"),
        textOutput("model_info"),
        div(class = "footer-note", "La vista previa de Shiny se muestra en pantalla. Usa los botones de exportación para obtener archivos vectoriales para Illustrator.")
      )
    )
  )
)

server <- function(input, output, session) {
  
  background_fill <- reactive({
    if (identical(input$background, "transparent")) "transparent" else "white"
  })
  
  curve_plot <- reactive({
    validate(
      need(is.finite(input$Linf) && input$Linf > 0, "L∞ debe ser mayor que cero."),
      need(is.finite(input$K) && input$K > 0, "K debe ser mayor que cero."),
      need(is.finite(input$t0), "Introduce un valor válido para t₀."),
      need(is.finite(input$age_min) && is.finite(input$age_max) && input$age_max > input$age_min,
           "La edad máxima debe ser mayor que la edad mínima."),
      need(is.finite(input$export_width) && input$export_width > 0, "El ancho de exportación debe ser mayor que cero."),
      need(is.finite(input$export_height) && input$export_height > 0, "El alto de exportación debe ser mayor que cero.")
    )
    
    ages <- seq(input$age_min, input$age_max, length.out = input$n_points)
    curve_data <- data.frame(
      age = ages,
      length = input$Linf * (1 - exp(-input$K * (ages - input$t0)))
    )
    
    base_theme <- switch(
      input$theme_style,
      minimal = theme_minimal(base_size = input$base_size, base_family = input$font_family),
      light = theme_light(base_size = input$base_size, base_family = input$font_family),
      theme_classic(base_size = input$base_size, base_family = input$font_family)
    )
    
    plot_background <- background_fill()
    
    p <- ggplot(curve_data, aes(x = age, y = length))
    
    if (isTRUE(input$show_asymptote)) {
      p <- p + geom_hline(
        yintercept = input$Linf,
        color = "#7B8794",
        linetype = "dashed",
        linewidth = 0.45
      )
    }
    
    p <- p +
      geom_line(
        color = input$curve_color,
        linewidth = input$line_width,
        linetype = input$line_type,
        lineend = "round"
      ) +
      scale_x_continuous(expand = expansion(mult = c(0.015, 0.035))) +
      scale_y_continuous(expand = expansion(mult = c(0.035, 0.09))) +
      labs(
        title = if (nzchar(trimws(input$plot_title))) input$plot_title else NULL,
        subtitle = if (nzchar(trimws(input$plot_subtitle))) input$plot_subtitle else NULL,
        x = input$x_label,
        y = input$y_label
      ) +
      base_theme +
      theme(
        plot.title = element_text(face = "bold", size = input$base_size * 1.25, color = "#202733", margin = margin(b = 7)),
        plot.subtitle = element_text(size = input$base_size, color = "#5D6875", margin = margin(b = 10)),
        axis.title = element_text(color = "#202733"),
        axis.text = element_text(color = "#333B45"),
        plot.background = element_rect(fill = plot_background, color = NA),
        panel.background = element_rect(fill = plot_background, color = NA),
        legend.background = element_rect(fill = plot_background, color = NA),
        plot.margin = margin(t = 12, r = 15, b = 12, l = 12)
      )
    
    p
  })
  
  output$curve_plot <- renderPlot({
    curve_plot()
  }, res = 96)
  
  output$model_info <- renderText({
    curve_plot()
    sprintf(
      "Parámetros actuales: L∞ = %s · K = %s · t₀ = %s",
      format(input$Linf, trim = TRUE),
      format(input$K, trim = TRUE),
      format(input$t0, trim = TRUE)
    )
  })
  
  safe_file_name <- function(x) {
    x <- trimws(x)
    x <- gsub("[^[:alnum:]_-]+", "_", x)
    x <- gsub("_+", "_", x)
    x <- gsub("^[_-]+|[_-]+$", "", x)
    if (!nzchar(x)) x <- "curva_von_bertalanffy"
    x
  }
  
  output$download_svg <- downloadHandler(
    filename = function() paste0(safe_file_name(input$file_name), ".svg"),
    content = function(file) {
      ggsave(
        filename = file,
        plot = curve_plot(),
        device = svglite::svglite,
        width = input$export_width,
        height = input$export_height,
        units = input$export_units,
        bg = background_fill(),
        limitsize = FALSE
      )
    },
    contentType = "image/svg+xml"
  )
  
  output$download_pdf <- downloadHandler(
    filename = function() paste0(safe_file_name(input$file_name), ".pdf"),
    content = function(file) {
      ggsave(
        filename = file,
        plot = curve_plot(),
        device = grDevices::pdf,
        width = input$export_width,
        height = input$export_height,
        units = input$export_units,
        bg = background_fill(),
        useDingbats = FALSE,
        limitsize = FALSE
      )
    },
    contentType = "application/pdf"
  )
}

shinyApp(ui = ui, server = server)
