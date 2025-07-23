
library(shiny)
library(shinydashboard)
library(DT)
library(openxlsx)
library(writexl)
library(WriteXLS)
library(ggplot2)
library(dplyr)
library(plotly)
library(shinycssloaders)
library(readxl)  
library(leaflet)  
library(sf)       
library(geojsonio) 
library(RColorBrewer) 
library(car)  
library(lmtest)  
library(corrplot)  

# Mengambil data utama
data_path <- "data/data_UAS.xlsx"
data <- read_excel(data_path)


# Mengambil data geojson
geojson_path <- "data/indonesia511.geojson"
map_data <- NULL

tryCatch({
  map_data <- geojson_read(geojson_path, what = "sp")
  cat("Data GeoJSON berhasil dimuat dari:", geojson_path, "\n")
}, error = function(e) {
  cat("Error loading GeoJSON data:", e$message, "\n")
})

# Kode UI
ui <- dashboardPage(
  dashboardHeader(title = "DOSEN"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Beranda", tabName = "beranda", icon = icon("home")),
      menuItem("Manajemen Data", tabName = "manajemen_data", icon = icon("database")),
      menuItem("Eksplorasi Data", tabName = "eksplorasi", icon = icon("chart-line"),
               menuSubItem("Deskriptif", tabName = "deskriptif"),
               menuSubItem("Visualisasi Data", tabName = "visualisasi"),
               menuSubItem("Peta Choropleth", tabName = "choropleth")
      ),
      menuItem("Uji Asumsi", tabName = "uji_asumsi", icon = icon("check-circle"),
               menuSubItem("Uji Normalitas", tabName = "uji_normalitas"),
               menuSubItem("Uji Homogenitas", tabName = "uji_homogenitas")
      ),
      menuItem("Statistik Inferensia", tabName = "inferensia", icon = icon("calculator"),
               menuSubItem("Uji Beda Rata-rata", tabName = "uji_beda_rata"),
               menuSubItem("Uji Varians", tabName = "uji_varians"),
               menuSubItem("Uji Proporsi", tabName = "uji_proporsi"),
               menuSubItem("Uji ANOVA", tabName = "uji_anova")
      ),
      menuItem("Regresi", tabName = "regresi", icon = icon("line-chart")),
      menuItem("About me", tabName = "aboutme", icon = icon("person"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
  .content-wrapper, .right-side {
    background-color: #f4f4f4;
  }
  .box {
    border-radius: 5px;
  }
  .info-box {
    border-radius: 5px;
  }
  
  .skin-blue .main-header .navbar {
    background: linear-gradient(180deg,#8B5CF6 0%, #1E293B 100%)!important
    box-shadow: 0 2px 10px rgba(139, 92, 246, 0.3) !important;
    border: none !important;
  }
  
  .skin-blue .main-header .logo {
    background: #8B5CF6 !important;
    color: white !important;
    font-family: 'Segoe UI', 'Roboto', 'Arial', sans-serif !important;
    font-weight: 700 !important;
    font-size: 22px !important;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3) !important;
    letter-spacing: 0.5px !important;
    border: none !important;
  }
  
  .skin-blue .main-header .navbar .sidebar-toggle {
    background: #8B5CF6 !important;
    color: white !important;
    border: none !important;
    transition: all 0.3s ease !important;
  }
  
  .skin-blue .main-header .navbar .sidebar-toggle:hover {
    background: #7C3AED !important;
    color: white !important;
    transform: scale(1.05) !important;
    box-shadow: 0 4px 15px rgba(139, 92, 246, 0.4) !important;
  }
  
  .main-header .navbar {
    background: #8B5CF6 !important;
    border: none !important;
  }
  
  .main-header .logo {
    background: #8B5CF6 !important;
    color: white !important;
    border: none !important;
  }
  
  .main-header .navbar .sidebar-toggle {
    background: #8B5CF6 !important;
    color: white !important;
    border: none !important;
  }
  
  .main-header .navbar-nav > li > a {
    background: #8B5CF6 !important;
    color: white !important;
    border: none !important;
  }
  
  .main-header .navbar-nav > li > a:hover {
    background: #7C3AED !important;
    color: white !important;
  }
  
  .main-sidebar {
    background: linear-gradient(180deg, #2D1B69 0%, #1E293B 100%) !important;
  }

  .sidebar-menu > li > a {
    background: transparent !important;
    color: #E2E8F0 !important;
    border-radius: 8px !important;
    margin: 2px 8px !important;
    padding: 12px 16px !important;
    transition: all 0.3s ease !important;
    font-weight: 500 !important;
  }

  .sidebar-menu > li > a:hover {
    background: linear-gradient(90deg, #8B5CF6 0%, #3B82F6 100%) !important;
    color: white !important;
    transform: translateX(5px) !important;
    box-shadow: 0 4px 15px rgba(139, 92, 246, 0.4) !important;
  }

  .sidebar-menu > li.active > a {
    background: linear-gradient(90deg, #8B5CF6 0%, #3B82F6 100%) !important;
    color: white !important;
    box-shadow: 0 4px 15px rgba(139, 92, 246, 0.4) !important;
  }

  .sidebar-menu .treeview-menu > li > a {
    background: transparent !important;
    color: #CBD5E1 !important;
    padding: 8px 16px 8px 35px !important;
    margin: 1px 8px !important;
    border-radius: 6px !important;
    transition: all 0.3s ease !important;
  }

  .sidebar-menu .treeview-menu > li > a:hover {
    background: linear-gradient(90deg, rgba(139, 92, 246, 0.7) 0%, rgba(59, 130, 246, 0.7) 100%) !important;
    color: white !important;
    transform: translateX(3px) !important;
  }

  .sidebar-menu .treeview-menu > li.active > a {
    background: linear-gradient(90deg, rgba(139, 92, 246, 0.8) 0%, rgba(59, 130, 246, 0.8) 100%) !important;
    color: white !important;
  }

  .sidebar-menu > li > a > .fa,
  .sidebar-menu > li > a > .glyphicon,
  .sidebar-menu > li > a > .ion {
    margin-right: 10px !important;
    font-size: 16px !important;
  }

  .box.box-primary > .box-header,
  .box.box-info > .box-header,
  .box.box-success > .box-header,
  .box.box-warning > .box-header,
  .box.box-danger > .box-header {
    background: linear-gradient(90deg, #8B5CF6 0%, #3B82F6 100%) !important;
    color: white !important;
    font-weight: 600 !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2) !important;
  }

  .box-header {
    background: linear-gradient(90deg, #8B5CF6 0%, #3B82F6 100%) !important;
    color: white !important;
    font-weight: 600 !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2) !important;
  }
  
  .box-primary .box-header,
  .box-info .box-header,
  .box-success .box-header,
  .box-warning .box-header,
  .box-danger .box-header {
    background: linear-gradient(90deg, #8B5CF6 0%, #3B82F6 100%) !important;
    color: white !important;
    font-weight: 600 !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2) !important;
  }

  .box-title {
    font-family: 'Segoe UI', 'Roboto', 'Arial', sans-serif !important;
    font-weight: 600 !important;
    font-size: 16px !important;
  }
  
  .hypothesis-box {
    background-color: #f8f9fa;
    border-left: 4px solid #8B5CF6;
    padding: 15px;
    margin: 10px 0;
  }
  .decision-box {
    background-color: #f1f8ff;
    border-left: 4px solid #8B5CF6;
    padding: 15px;
    margin: 10px 0;
  }
  .interpretation-box {
    background-color: #fff3cd;
    border-left: 4px solid #8B5CF6;
    padding: 15px;
    margin: 10px 0;
  }
  .test-result {
    font-family: 'Courier New', monospace;
    background-color: #f8f9fa;
    padding: 10px;
    border-radius: 5px;
    margin: 10px 0;
  }
  .map-stats-box {
    background-color: #e8f4fd;
    border-left: 4px solid #8B5CF6;
    padding: 15px;
    margin: 10px 0;
    border-radius: 5px;
  }
  .leaflet-container {
    border-radius: 10px;
  }
  .regression-box {
    background-color: #f0f8ff;
    border-left: 4px solid #8B5CF6;
    padding: 15px;
    margin: 10px 0;
    border-radius: 5px;
  }
  .model-summary {
    background-color: #f5f5f5;
    padding: 15px;
    border-radius: 5px;
    font-family: 'Courier New', monospace;
  }

  .profile-card {
    transition: all 0.3s ease !important;
  }
  
  .profile-card:hover {
    transform: translateY(-5px) !important;
    box-shadow: 0 15px 50px rgba(139, 92, 246, 0.25) !important;
  }

  .profile-photo-container img {
    transition: all 0.3s ease !important;
  }
  
  .profile-photo-container:hover img {
    transform: scale(1.05) !important;
    box-shadow: 0 12px 40px rgba(139, 92, 246, 0.4) !important;
  }
  
  .details-card {
    transition: all 0.3s ease !important;
  }
  
  .details-card:hover {
    transform: translateY(-3px) !important;
    box-shadow: 0 15px 50px rgba(139, 92, 246, 0.25) !important;
  }
  
  .info-item {
    transition: all 0.3s ease !important;
    cursor: pointer !important;
  }
  
  .info-item:hover {
    transform: translateX(5px) !important;
    background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(59, 130, 246, 0.1) 100%) !important;
    box-shadow: 0 8px 25px rgba(139, 92, 246, 0.15) !important;
  }
  
  .info-item div:first-child {
    transition: all 0.3s ease !important;
  }
  
  .info-item:hover div:first-child {
    transform: rotate(360deg) scale(1.1) !important;
    box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4) !important;
  }
  
  .about-header {
    animation: fadeInDown 1s ease-out !important;
  }
  
  @keyframes fadeInDown {
    from {
      opacity: 0;
      transform: translateY(-30px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  .profile-card {
    animation: fadeInLeft 1s ease-out 0.2s both !important;
  }
  
  @keyframes fadeInLeft {
    from {
      opacity: 0;
      transform: translateX(-30px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }
  
  .details-card {
    animation: fadeInRight 1s ease-out 0.4s both !important;
  }
  
  @keyframes fadeInRight {
    from {
      opacity: 0;
      transform: translateX(30px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }
  
  .additional-info {
    animation: fadeInUp 1s ease-out 0.6s both !important;
  }
  
  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(30px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  .tech-stack span {
    transition: all 0.3s ease !important;
    cursor: pointer !important;
  }
  
  .tech-stack span:hover {
    transform: translateY(-3px) scale(1.05) !important;
    box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4) !important;
  }
  
  .profile-quote {
    transition: all 0.3s ease !important;
  }
  
  .profile-quote:hover {
    transform: scale(1.02) !important;
    box-shadow: 0 8px 25px rgba(139, 92, 246, 0.2) !important;
  }
  
  @media (max-width: 768px) {
    .profile-card,
    .details-card {
      margin-bottom: 20px !important;
    }
  
    .info-item {
      flex-direction: column !important;
      text-align: center !important;
    }
  
    .info-item div:first-child {
      margin-right: 0 !important;
      margin-bottom: 10px !important;
    }
  
    .tech-stack div {
      justify-content: center !important;
    }
  }
  
  html {
    scroll-behavior: smooth !important;
  }
  
  .about-me-content::-webkit-scrollbar {
    width: 8px !important;
  }
  
  .about-me-content::-webkit-scrollbar-track {
    background: rgba(139, 92, 246, 0.1) !important;
    border-radius: 10px !important;
  }
  
  .about-me-content::-webkit-scrollbar-thumb {
    background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 100%) !important;
    border-radius: 10px !important;
  }
  
  .about-me-content::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(135deg, #7c3aed 0%, #2563eb 100%) !important;
  }
  
  .main-header {
    position: fixed !important;
    top: 0 !important;
    left: 0 !important;
    right: 0 !important;
    z-index: 1030 !important;
    width: 100% !important;
  }
  
  .main-sidebar {
    position: fixed !important;
    top: 50px !important; 
    left: 0 !important;
    bottom: 0 !important;
    z-index: 1020 !important;
    overflow-y: auto !important; 
  }
  
  .content-wrapper {
    margin-top: 50px !important; 
    margin-left: 230px !important; 
    transition: margin-left 0.3s ease !important;
  }
  
  .sidebar-collapse .content-wrapper {
    margin-left: 50px !important; 
  }
  
  @media (max-width: 767px) {
    .main-sidebar {
      transform: translateX(-100%) !important;
      transition: transform 0.3s ease !important;
    }
    
    .sidebar-open .main-sidebar {
      transform: translateX(0) !important;
    }
    
    .content-wrapper {
      margin-left: 0 !important;
    }
  }
  
  .content-header {
    padding-top: 15px !important;
  }
  
  .dropdown-menu {
    z-index: 1040 !important;
  }
  
  .modal {
    z-index: 1050 !important;
  }

  .content-wrapper {
    margin-top: 50px !important;
    margin-left: 230px !important; 
    transition: margin-left 0.3s ease !important;
    background-color: #ecf0f1 !important; 
    min-height: calc(100vh - 50px) !important;
    width: auto !important;
  }
  

  .sidebar-collapse .content-wrapper {
    margin-left: 0 !important;
  }
  
  body, html {
    background-color: #ecf0f1 !important;
  }
  
  .content {
    background-color: #ecf0f1 !important;
    min-height: calc(100vh - 50px) !important;
  }
  
  .sidebar-collapse .main-sidebar {
    margin-left: -230px !important;
  }
  
  .skin-blue .content-wrapper,
  .skin-purple .content-wrapper {
    background-color: #ecf0f1 !important;
  }
  
  .main-footer {
    margin-left: 230px !important;
    transition: margin-left 0.3s ease !important;
  }
  
  .sidebar-collapse .main-footer {
    margin-left: 0 !important;
  }
"))
    ),
    
    tabItems(
      # Frontend Beranda
      tabItem(tabName = "beranda",
              fluidRow(
                box(
                  title = NULL, status = "primary", solidHeader = FALSE, width = 12,
                  div(style = "text-align: center; padding: 20px;",
                      h2("Selamat Datang di DOSEN", 
                         style = "color: #2c3e50; font-weight: bold; margin-bottom: 10px;"),
                      h4("(Dashboard sOSial dEmografi iNdonesia)", 
                         style = "color: #7f8c8d; font-style: italic; margin-bottom: 20px;")
                  )
                )
              ),
              
              fluidRow(
                column(4,
                       div(class = "info-box", style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 10px; padding: 20px; margin: 10px 0;",
                           div(style = "display: flex; align-items: center;",
                               div(style = "flex: 1;",
                                   h4("Rata-rata Penduduk Miskin", style = "margin: 0; font-weight: bold;"),
                                   h2(paste0(round(mean(data$POVERTY, na.rm = TRUE), 2), "%"), 
                                      style = "margin: 10px 0 0 0; font-size: 2.5em; font-weight: bold;"),
                                   p("dari 511 kabupaten/kota", style = "margin: 5px 0 0 0; opacity: 0.9;")
                               ),
                               div(style = "font-size: 3em; opacity: 0.3; margin-left: 20px;",
                                   icon("users")
                               )
                           )
                       )
                ),
                
                column(4,
                       div(class = "info-box", style = "background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; border-radius: 10px; padding: 20px; margin: 10px 0;",
                           div(style = "display: flex; align-items: center;",
                               div(style = "flex: 1;",
                                   h4("Rata-rata Pendidikan Rendah", style = "margin: 0; font-weight: bold;"),
                                   h2(paste0(round(mean(data$LOWEDU, na.rm = TRUE), 2), "%"), 
                                      style = "margin: 10px 0 0 0; font-size: 2.5em; font-weight: bold;"),
                                   p("penduduk usia 15+ tahun", style = "margin: 5px 0 0 0; opacity: 0.9;")
                               ),
                               div(style = "font-size: 3em; opacity: 0.3; margin-left: 20px;",
                                   icon("graduation-cap")
                               )
                           )
                       )
                ),
                
                column(4,
                       div(class = "info-box", style = "background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; border-radius: 10px; padding: 20px; margin: 10px 0;",
                           div(style = "display: flex; align-items: center;",
                               div(style = "flex: 1;",
                                   h4("Rata-rata Buta Huruf", style = "margin: 0; font-weight: bold;"),
                                   h2(paste0(round(mean(data$ILLITERATE, na.rm = TRUE), 2), "%"), 
                                      style = "margin: 10px 0 0 0; font-size: 2.5em; font-weight: bold;"),
                                   p("tidak bisa baca tulis", style = "margin: 5px 0 0 0; opacity: 0.9;")
                               ),
                               div(style = "font-size: 3em; opacity: 0.3; margin-left: 20px;",
                                   icon("book")
                               )
                           )
                       )
                )
              ),
              
              fluidRow(
                box(
                  title = "Informasi Dashboard", status = "primary", solidHeader = TRUE, width = 12,
                  h4("Dashboard Demografi Indonesia"),
                  p("Dashboard ini menyajikan analisis data demografi Indonesia berdasarkan data kabupaten/kota dari seluruh provinsi di Indonesia."),
                  p("Data mencakup informasi kemiskinan, buta huruf, dan tingkat pendidikan rendah di seluruh Indonesia berdasarkan kode kabupaten/kota."),
                  br(),
                  h4("Fitur Dashboard:"),
                  tags$ul(
                    tags$li("Analisis deskriptif (mean, median, dll)"),
                    tags$li("Manajemen data untuk mengubah data kontinu menjadi kategorik"),
                    tags$li("Visualisasi data interaktif (tabel, bar chart, histogram)"),
                    tags$li("Peta choropleth interaktif untuk visualisasi spasial"),
                    tags$li("Uji asumsi statistik (normalitas dan homogenitas)"),
                    tags$li("Analisis inferensia (uji beda rata-rata, proporsi, varians, ANOVA)"),
                    tags$li("Analisis regresi berganda dengan pemeriksaan asumsi"),
                  ),
                  br(),
                  h4("Sumber Data:"),
                  tags$ul(
                    tags$li(HTML("Dataset about the social vulnerability in Indonesia, sumber asli dapat diakses melalui: <a href='https://www.sciencedirect.com/science/article/pii/S2352340921010180' target='_blank'>sciencedirect/indonesia-sovi</a>.")),
                    tags$li(HTML("Data spasial batas wilayah administratif Indonesia (level kabupaten/kota) dalam format GeoJSON, sumber asli dapat diakses melalui: <a href='https://drive.google.com/file/d/1lyjzQOaG-36dAGEt0W6dTVSbqsIIRVy_/view?usp=sharing' target='_blank'>indonesia-geojson</a>."))
                  ),
                  br(),
                  div(class = "alert alert-info",
                      icon("info-circle"),
                      paste(" Dataset berisi", nrow(data), "kabupaten/kota dari",
                            length(unique(data$PROVINCENAME)), "provinsi di Indonesia."))
                )
              ),
              
              fluidRow(
                box(
                  title = "Metadata Variabel", status = "info", solidHeader = TRUE, width = 12,
                  DT::dataTableOutput("metadata_table")
                )
              )
      )
      ,
      
      # Frontend Manajemen Data
      tabItem(tabName = "manajemen_data",
              fluidRow(
                box(
                  title = "Konversi Variabel Kontinu ke Kategorik", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("tags"), " Buat Variabel Kategorik Baru"),
                  p("Fitur ini memungkinkan Anda untuk mengubah variabel kontinu menjadi variabel kategorik dengan range dan label yang dapat disesuaikan.")
                )
              ),
              
              fluidRow(
                column(6,
                       box(
                         title = "Pengaturan Variabel", status = "info", solidHeader = TRUE, width = 12,
                         selectInput("var_to_categorize",
                                     "Pilih Variabel Kontinu:",
                                     choices = c("POVERTY" = "POVERTY",
                                                 "LOWEDU" = "LOWEDU",
                                                 "ILLITERATE" = "ILLITERATE"),
                                     selected = "POVERTY"),
                         
                         textInput("new_var_name",
                                   "Nama Variabel Kategorik Baru:",
                                   value = "POVERTY_CAT",
                                   placeholder = "Contoh: POVERTY_CAT"),
                         
                         htmlOutput("data_range_info"),
                         
                         hr(),
                         
                         numericInput("num_categories",
                                      "Jumlah Kategori:",
                                      value = 3, min = 2, max = 10, step = 1),
                         
                         uiOutput("category_inputs"),
                         
                         br(),
                         actionButton("create_categorical_var",
                                      "Buat Variabel Kategorik",
                                      class = "btn btn-success btn-block",
                                      icon = icon("plus")),
                         
                         br(),
                         actionButton("reset_inputs",
                                      "Reset Pengaturan",
                                      class = "btn btn-warning btn-block",
                                      icon = icon("refresh"))
                       )
                ),
                
                column(6,
                       box(
                         title = "Petunjuk Penggunaan", status = "warning", solidHeader = TRUE, width = 12,
                         h5(icon("info-circle"), " Cara Menggunakan:"),
                         tags$ol(
                           tags$li("Pilih variabel kontinu yang ingin dikategorikan"),
                           tags$li("Beri nama untuk variabel kategorik baru"),
                           tags$li("Tentukan jumlah kategori yang diinginkan"),
                           tags$li("Atur range untuk setiap kategori secara berurutan"),
                           tags$li("Beri label untuk setiap kategori"),
                           tags$li("Pastikan tidak ada error validasi"),
                           tags$li("Klik 'Buat Variabel Kategorik'")
                         ),
                         
                         h5(icon("exclamation-triangle"), " Aturan Range:"),
                         tags$ul(
                           tags$li("Range harus berurutan dan tidak tumpang tindih"),
                           tags$li("Range pertama dimulai dari nilai minimum data"),
                           tags$li("Range terakhir berakhir di nilai maksimum data")
                        
                         )
                       ),
                       
                       box(
                         title = "Preview dan Validasi", status = "success", solidHeader = TRUE, width = 12,
                         h6("Validasi Kategorisasi:"),
                         htmlOutput("categorization_preview"),
                         br(),
                         h6("Status Validasi:"),
                         htmlOutput("validation_messages")
                       )
                )
              ),
              
              fluidRow(
                box(
                  title = "Data Setelah Kategorisasi", status = "primary", solidHeader = TRUE, width = 12,
                  p("Tabel ini akan menampilkan data terbaru setelah variabel kategorik berhasil dibuat."),
                  DT::dataTableOutput("updated_data_preview")
                )
              )
      ),
      
      # Frontend Deskriptif
      tabItem(tabName = "deskriptif",
              fluidRow(
                box(
                  title = "Statistik Deskriptif", status = "primary", solidHeader = TRUE, width = 12,
                  withSpinner(DT::dataTableOutput("desc_stats"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Interpretasi Statistik Deskriptif", status = "info", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("desc_interpretation"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Ringkasan per Provinsi", status = "warning", solidHeader = TRUE, width = 12,
                  withSpinner(DT::dataTableOutput("province_summary"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Download Laporan", status = "success", solidHeader = TRUE, width = 12,
                  downloadButton("download_deskriptif_report", "Download Laporan (HTML)",
                                 class = "btn-success btn-lg btn-block", icon = icon("file-alt"))
                )
              )
      ),
      
      # Frontend Visualisasi Data
      tabItem(tabName = "visualisasi",
              fluidRow(
                box(
                  title = "Kontrol Visualisasi", status = "primary", solidHeader = TRUE, width = 4,
                  selectInput("selected_variable", "Pilih Variabel:",
                              choices = c("POVERTY" = "POVERTY",
                                          "ILLITERATE" = "ILLITERATE",
                                          "LOWEDU" = "LOWEDU")),
                  selectInput("selected_province", "Pilih Provinsi:",
                              choices = NULL),
                  selectInput("chart_type", "Jenis Grafik:",
                              choices = c("Tabel" = "table",
                                          "Bar Chart" = "bar",
                                          "Histogram" = "histogram")),
                  br(),
                  div(class = "alert alert-warning",
                      icon("exclamation-triangle"),
                      " Pilih variabel dan provinsi untuk melihat visualisasi yang sesuai.")
                ),
                
                box(
                  title = "Visualisasi Data", status = "success", solidHeader = TRUE, width = 8,
                  withSpinner(uiOutput("main_visualization"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Interpretasi", status = "info", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("chart_interpretation"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Visualisasi Agregat per Provinsi", status = "warning", solidHeader = TRUE, width = 12,
                  withSpinner(plotlyOutput("aggregate_plot"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Download Laporan", status = "success", solidHeader = TRUE, width = 12,
                  downloadButton("download_visualisasi_report", "Download Laporan (HTML)",
                                 class = "btn-info btn-block", icon = icon("chart-bar"))
                )
              )
      ),
      
      # Frontend Choropleth
      tabItem(tabName = "choropleth",
              fluidRow(
                box(
                  title = "Peta Choropleth", status = "primary", solidHeader = TRUE, width = 4,
                  h4(icon("map"), " Pengaturan Peta"),
                  selectInput("map_variable", "Pilih Variabel untuk Peta:",
                              choices = c("Kemiskinan" = "POVERTY", 
                                          "Buta Huruf" = "ILLITERATE", 
                                          "Pendidikan Rendah" = "LOWEDU"),
                              selected = "POVERTY"),
                  br(),
                  selectInput("color_scheme", "Skema Warna:",
                              choices = c("Reds" = "Reds",
                                          "Blues" = "Blues", 
                                          "Greens" = "Greens",
                                          "Oranges" = "Oranges",
                                          "Purples" = "Purples"),
                              selected = "Reds"),
                  br(),
                  div(class = "alert alert-info",
                      icon("info-circle"), 
                      " Klik pada wilayah di peta untuk melihat detail informasi."),
                  br(),
                  div(class = "map-stats-box",
                      h5(icon("chart-bar"), " Statistik Peta"),
                      withSpinner(htmlOutput("map_statistics"))
                  )
                ),
                
                box(
                  title = "Peta Choropleth Indonesia", status = "success", solidHeader = TRUE, width = 8,
                  withSpinner(leafletOutput("choropleth_map", height = "600px"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Interpretasi Peta Choropleth", status = "info", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("map_interpretation"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Ranking Kabupaten/Kota", status = "warning", solidHeader = TRUE, width = 6,
                  h5("Top 10 Tertinggi"),
                  withSpinner(DT::dataTableOutput("top_districts"))
                ),
                
                box(
                  title = "Ranking Kabupaten/Kota", status = "success", solidHeader = TRUE, width = 6,
                  h5("Top 10 Terendah"),
                  withSpinner(DT::dataTableOutput("bottom_districts"))
                )
              )
      ),
      
      # Frontend Uji Normalitas
      tabItem(tabName = "uji_normalitas",
              fluidRow(
                box(
                  title = "Uji Normalitas Data", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("chart-line"), " Uji Normalitas Dinamis"),
                  p("Menguji apakah data berdistribusi normal menggunakan uji yang sesuai berdasarkan ukuran sampel:"),
                  tags$ul(
                    tags$li(strong("Kolmogorov-Smirnov:"), " untuk sampel > 50 observasi"),
                    tags$li(strong("Shapiro-Wilk:"), " untuk sampel ≤ 50 observasi")
                  )
                )
              ),
              
              fluidRow(
                column(3,
                       box(
                         title = "Pengaturan", status = "info", solidHeader = TRUE, width = 12,
                         selectInput("var_normalitas",
                                     "Pilih Variabel:",
                                     choices = c("POVERTY" = "POVERTY",
                                                 "LOWEDU" = "LOWEDU",
                                                 "ILLITERATE" = "ILLITERATE"),
                                     selected = "POVERTY"),
                         
                         selectInput("province_normalitas",
                                     "Pilih Provinsi:",
                                     choices = NULL,  
                                     selected = NULL),
                         
                         div(class = "alert alert-info",
                             icon("info-circle"),
                             " Pilih 'Semua Provinsi' untuk uji normalitas keseluruhan data atau pilih provinsi tertentu untuk uji per provinsi."),
                         br(),
                         htmlOutput("sample_info_box"),
                         
                         br(),
                         actionButton("run_test_normalitas", "Jalankan Uji",
                                      class = "btn btn-primary btn-block",
                                      icon = icon("play"))
                       )
                ),
                
                column(9,
                       box(
                         title = "Visualisasi Normalitas", status = "success", solidHeader = TRUE, width = 12,
                         splitLayout(
                           cellWidths = c("50%", "50%"),
                           withSpinner(plotOutput("qq_plot_normalitas")),
                           withSpinner(plotOutput("hist_normalitas"))
                         )
                       )
                )
              ),
              conditionalPanel(
                condition = "input.run_test_normalitas > 0",
                
                fluidRow(
                  box(
                    title = "Hasil Uji Normalitas", status = "warning", solidHeader = TRUE, width = 12,
                    withSpinner(verbatimTextOutput("normality_test_result")),
                    withSpinner(htmlOutput("normality_interpretation"))
                  )
                ),
                fluidRow(
                  box(
                    title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                    br(),
                    downloadButton("download_normalitas_report", "Download Laporan Uji Normalitas (HTML)",
                                   class = "btn-success btn-lg", icon = icon("download")),
                    br(), br()
                  )
                )
              )
      )
      ,
      
      # Frontend Uji Homogenitas
      tabItem(tabName = "uji_homogenitas",
              fluidRow(
                box(
                  title = "Uji Homogenitas Varians", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("balance-scale"), " Uji Homogenitas Varians (Levene Test)"),
                  p("Menguji apakah varians antar kelompok (provinsi) homogen menggunakan uji Levene:"),
                  tags$ul(
                    tags$li(strong("Uji Levene:"), " data tidak harus berdistribusi normal"),
                    tags$li(strong("Asumsi:"), " data independen antar kelompok"),
                    tags$li(strong("Minimal:"), " 2 provinsi dengan minimal 3 observasi per provinsi")
                  )
                )
              ),
              
              fluidRow(
                column(4,
                       box(
                         title = "Pengaturan", status = "info", solidHeader = TRUE, width = 12,
                         selectInput("var_homogenitas",
                                     "Pilih Variabel:",
                                     choices = c("POVERTY" = "POVERTY",
                                                 "LOWEDU" = "LOWEDU",
                                                 "ILLITERATE" = "ILLITERATE"),
                                     selected = "POVERTY"),
                         
                         checkboxGroupInput("provinces_homogenitas",
                                            "Pilih Provinsi untuk Dibandingkan:",
                                            choices = NULL, 
                                            selected = NULL),
                         
                         div(class = "alert alert-warning",
                             icon("exclamation-triangle"),
                             " Pilih minimal 2 provinsi untuk perbandingan varians. Semakin banyak provinsi yang dipilih, semakin komprehensif analisisnya."),
                         
                         br(),
                         
                         htmlOutput("sample_info_homogenitas"),
                         
                         br(),
                         actionButton("run_test_homogenitas", "Jalankan Uji Homogenitas",
                                      class = "btn btn-primary btn-block",
                                      icon = icon("play"))
                       )
                ),
                
                column(8,
                       box(
                         title = "Visualisasi Perbandingan Varians", status = "success", solidHeader = TRUE, width = 12,
                         splitLayout(
                           cellWidths = c("50%", "50%"),
                           withSpinner(plotOutput("boxplot_homogenitas")),
                           withSpinner(plotOutput("variance_plot_homogenitas"))
                         )
                       )
                )
              ),
              
              conditionalPanel(
                condition = "input.run_test_homogenitas > 0",
                
                fluidRow(
                  box(
                    title = "Hasil Uji Homogenitas Varians", status = "warning", solidHeader = TRUE, width = 12,
                    withSpinner(verbatimTextOutput("homogeneity_test_result")),
                    withSpinner(htmlOutput("homogeneity_interpretation"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                    br(),
                    downloadButton("download_homogenitas_report", "Download Laporan Uji Homogenitas (HTML)",
                                   class = "btn-success btn-lg", icon = icon("download")),
                    br(), br()
                    
                  )
                )
              )
      ),
      
      # Frontend Uji Beda Rata-rata
      tabItem(tabName = "uji_beda_rata",
              fluidRow(
                box(
                  title = "Uji Beda Rata-rata Dinamis", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("chart-line"), " Uji Hipotesis Rata-rata Populasi"),
                  p("Pilih jenis uji dan parameter sesuai kebutuhan analisis Anda")
                )
              ),
              
              fluidRow(
                column(4,
                       box(
                         title = "Pengaturan Uji", status = "info", solidHeader = TRUE, width = 12,
                         
                         radioButtons("test_type_mean", "Jenis Uji:",
                                      choices = list(
                                        "Uji 1 Kelompok (One-Sample)" = "one_sample",
                                        "Uji 2 Kelompok (Two-Sample)" = "two_sample"
                                      ),
                                      selected = "one_sample"),
                         
                         hr(),
                         selectInput("variable_mean", "Pilih Variabel:",
                                     choices = c("POVERTY" = "POVERTY",
                                                 "LOWEDU" = "LOWEDU",
                                                 "ILLITERATE" = "ILLITERATE"),
                                     selected = "POVERTY"),
                         
                         conditionalPanel(
                           condition = "input.test_type_mean == 'one_sample'",
                           numericInput("mu0_mean", "Nilai μ₀ (Hipotesis):",
                                        value = 10, min = 0, max = 100, step = 0.1),
                           
                           radioButtons("alternative_mean_one", "Jenis Uji:",
                                        choices = list(
                                          "Dua Arah (≠)" = "two.sided",
                                          "Arah Kiri (<)" = "less",
                                          "Arah Kanan (>)" = "greater"
                                        ),
                                        selected = "two.sided")
                         ),
                         
                         conditionalPanel(
                           condition = "input.test_type_mean == 'two_sample'",
                           selectInput("province1_mean", "Provinsi 1:",
                                       choices = NULL),
                           selectInput("province2_mean", "Provinsi 2:",
                                       choices = NULL),
                           
                           radioButtons("alternative_mean_two", "Jenis Uji:",
                                        choices = list(
                                          "Dua Arah (≠)" = "two.sided",
                                          "Provinsi 1 < Provinsi 2" = "less",
                                          "Provinsi 1 > Provinsi 2" = "greater"
                                        ),
                                        selected = "two.sided")
                         ),
                         
                         br(),
                         actionButton("run_test_mean", "Jalankan Uji",
                                      class = "btn btn-primary btn-block",
                                      icon = icon("play"))
                       )
                ),
                
                column(8,
                       box(
                         title = "Informasi Uji", status = "warning", solidHeader = TRUE, width = 12,
                         withSpinner(htmlOutput("test_info_mean"))
                       )
                )
              ),
              conditionalPanel(
                condition = "input.run_test_mean > 0",
              # Hasil Uji
              fluidRow(
                box(
                  title = "Hipotesis", status = "info", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("hypothesis_mean"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Hasil Uji Statistik", status = "success", solidHeader = TRUE, width = 8,
                  withSpinner(verbatimTextOutput("test_result_mean"))
                ),
                box(
                  title = "Statistik Deskriptif", status = "warning", solidHeader = TRUE, width = 4,
                  withSpinner(verbatimTextOutput("descriptive_mean"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Keputusan dan Interpretasi", status = "primary", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("interpretation_mean"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                  br(),
                  downloadButton("download_mean_report", "Download Laporan Uji Rata-rata (HTML)",
                                 class = "btn-success btn-lg", icon = icon("download")),
                  br(), br()
                 
                )
              )
      ))
      ,
      # Frontend Uji Proporsi
      
      tabItem(tabName = "uji_proporsi",
              fluidRow(
                box(
                  title = "Uji Proporsi Dinamis", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("pie-chart"), " Uji Hipotesis Proporsi Populasi"),
                  p("Pilih jenis uji dan parameter sesuai kebutuhan analisis Anda")
                )
              ),
              fluidRow(
                column(4,
                       box(
                         title = "Pengaturan Uji", status = "info", solidHeader = TRUE, width = 12,
                         radioButtons("test_type_prop", "Jenis Uji:",
                                      choices = list(
                                        "Uji 1 Kelompok (One-Sample)" = "one_sample",
                                        "Uji 2 Kelompok (Two-Sample)" = "two_sample"
                                      ),
                                      selected = "one_sample"),
                         
                         hr(),
                         selectInput("variable_prop", "Pilih Variabel Kategorik:",
                                     choices = c("LOWEDU_CAT" = "LOWEDU_CAT",
                                                 "POVERTY_CAT" = "POVERTY_CAT",
                                                 "ILLITERATE_CAT" = "ILLITERATE_CAT"),
                                     selected = "LOWEDU_CAT"),
                         selectInput("status_prop", "Pilih Status/Kategori:",
                                     choices = c("Rendah" = "Rendah",
                                                 "Sedang" = "Sedang", 
                                                 "Tinggi" = "Tinggi"),
                                     selected = "Tinggi"),
                         
                         conditionalPanel(
                           condition = "input.test_type_prop == 'one_sample'",
                           numericInput("p0_prop", "Nilai p₀ (Proporsi Hipotesis):",
                                        value = 0.3, min = 0, max = 1, step = 0.01),
                           
                           radioButtons("alternative_prop_one", "Jenis Uji:",
                                        choices = list(
                                          "Dua Arah (≠)" = "two.sided",
                                          "Arah Kiri (<)" = "less", 
                                          "Arah Kanan (>)" = "greater"
                                        ),
                                        selected = "two.sided")
                         ),
                         
                         conditionalPanel(
                           condition = "input.test_type_prop == 'two_sample'",
                           selectInput("province1_prop", "Provinsi 1:",
                                       choices = NULL),
                           selectInput("province2_prop", "Provinsi 2:", 
                                       choices = NULL),
                           
                           radioButtons("alternative_prop_two", "Jenis Uji:",
                                        choices = list(
                                          "Dua Arah (≠)" = "two.sided",
                                          "Proporsi Provinsi 1 < Provinsi 2" = "less",
                                          "Proporsi Provinsi 1 > Provinsi 2" = "greater"
                                        ),
                                        selected = "two.sided")
                         ),
                         
                         br(),
                         actionButton("run_test_prop", "Jalankan Uji", 
                                      class = "btn btn-primary btn-block",
                                      icon = icon("play"))
                       )
                ),
                
                column(8,
                       box(
                         title = "Informasi Uji", status = "warning", solidHeader = TRUE, width = 12,
                         withSpinner(htmlOutput("test_info_prop"))
                       )
                )
              ),
              
              conditionalPanel(
                condition = "input.run_test_prop > 0",
                
                fluidRow(
                  box(
                    title = "Hipotesis", status = "info", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("hypothesis_prop"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Hasil Uji Statistik", status = "success", solidHeader = TRUE, width = 8,
                    withSpinner(verbatimTextOutput("test_result_prop"))
                  ),
                  box(
                    title = "Statistik Deskriptif", status = "warning", solidHeader = TRUE, width = 4,
                    withSpinner(verbatimTextOutput("descriptive_prop"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Keputusan dan Interpretasi", status = "primary", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("interpretation_prop"))
                  )
                ),
                fluidRow(
                  box(
                    title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                    br(),
                    downloadButton("download_proporsi_report", "Download Laporan Proporsi (HTML)",
                                   class = "btn-success btn-lg", icon = icon("download")),
                    br(), br()
                   
                  )
                )
              )
      )
      
      ,
      # Frontend Uji Varians
      tabItem(tabName = "uji_varians",
              fluidRow(
                box(
                  title = "Uji Varians Dinamis", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("chart-area"), " Uji Hipotesis Varians Populasi"),
                  p("Pilih jenis uji dan parameter sesuai kebutuhan analisis Anda")
                )
              ),
              fluidRow(
                column(4,
                       box(
                         title = "Pengaturan Uji", status = "info", solidHeader = TRUE, width = 12,
                         radioButtons("test_type_var", "Jenis Uji:",
                                      choices = list(
                                        "Uji 1 Kelompok (One-Sample)" = "one_sample",
                                        "Uji 2 Kelompok (Two-Sample)" = "two_sample"
                                      ),
                                      selected = "one_sample"),
                         
                         hr(),
                         selectInput("variable_var", "Pilih Variabel:",
                                     choices = c("POVERTY" = "POVERTY",
                                                 "LOWEDU" = "LOWEDU",
                                                 "ILLITERATE" = "ILLITERATE"),
                                     selected = "POVERTY"),

                         conditionalPanel(
                           condition = "input.test_type_var == 'one_sample'",
                           numericInput("sigma2_0", "Nilai σ²₀ (Hipotesis):",
                                        value = 100, min = 0, max = 1000, step = 1),
                           
                           radioButtons("alternative_var_one", "Jenis Uji:",
                                        choices = list(
                                          "Dua Arah (≠)" = "two.sided",
                                          "Arah Kiri (<)" = "less",
                                          "Arah Kanan (>)" = "greater"
                                        ),
                                        selected = "two.sided")
                         ),
                         
                         conditionalPanel(
                           condition = "input.test_type_var == 'two_sample'",
                           selectInput("province1_var", "Provinsi 1:",
                                       choices = NULL),
                           selectInput("province2_var", "Provinsi 2:",
                                       choices = NULL),
                           
                           radioButtons("alternative_var_two", "Jenis Uji:",
                                        choices = list(
                                          "Dua Arah (≠)" = "two.sided",
                                          "Varians Provinsi 1 < Provinsi 2" = "less",
                                          "Varians Provinsi 1 > Provinsi 2" = "greater"
                                        ),
                                        selected = "two.sided")
                         ),
                         
                         br(),
                         actionButton("run_test_var", "Jalankan Uji",
                                      class = "btn btn-primary btn-block",
                                      icon = icon("play"))
                       )
                ),
                
                column(8,
                       box(
                         title = "Informasi Uji", status = "warning", solidHeader = TRUE, width = 12,
                         withSpinner(htmlOutput("test_info_var"))
                       )
                )
              ),
              conditionalPanel(
                condition = "input.run_test_var > 0",
              fluidRow(
                box(
                  title = "Hipotesis", status = "info", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("hypothesis_var"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Hasil Uji Statistik", status = "success", solidHeader = TRUE, width = 8,
                  withSpinner(verbatimTextOutput("test_result_var"))
                ),
                box(
                  title = "Statistik Deskriptif", status = "warning", solidHeader = TRUE, width = 4,
                  withSpinner(verbatimTextOutput("descriptive_var"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Keputusan dan Interpretasi", status = "primary", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("interpretation_var"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                  br(),
                  downloadButton("download_varians_report", "Download Laporan Uji Varians (HTML)",
                                 class = "btn-success btn-lg", icon = icon("download")),
                  br(), br()
                  
                )
              )
      ))
      ,
      
      # Frontend Anova
      tabItem(tabName = "uji_anova",
              fluidRow(
                box(
                  title = "Uji ANOVA dengan Uji Asumsi", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("chart-bar"), " Analisis Varians (ANOVA)"),
                  p("Menguji apakah rata-rata beberapa kelompok sama menggunakan ANOVA dengan uji asumsi terlebih dahulu")
                )
              ),
              
              fluidRow(
                box(
                  title = "Pengaturan ANOVA", status = "info", solidHeader = TRUE, width = 12,
                  fluidRow(
                    column(4,
                           selectInput("anova_type", "Jenis ANOVA:",
                                       choices = list(
                                         "One-Way ANOVA" = "oneway",
                                         "Two-Way ANOVA" = "twoway"
                                       ),
                                       selected = "oneway")
                    ),
                    column(4,
                           selectInput("anova_variable", "Variabel Dependen:",
                                       choices = list(
                                         "POVERTY (Kemiskinan)" = "POVERTY",
                                         "LOWEDU (Pendidikan Rendah)" = "LOWEDU",
                                         "ILLITERATE (Buta Huruf)" = "ILLITERATE"
                                       ),
                                       selected = "LOWEDU")
                    ),
                    column(4,
                           numericInput("anova_alpha", "Tingkat Signifikansi (α):",
                                        value = 0.05, min = 0.01, max = 0.10, step = 0.01)
                    )
                  ),
                  
                  fluidRow(
                    column(12,
                           h5("Pilih Provinsi (minimal 3, maksimal 34):"),
                           checkboxGroupInput("anova_provinces", NULL,
                                              choices = list(
                                                "ACEH" = "ACEH",
                                                "SUMATERA UTARA" = "SUMATERA UTARA",
                                                "SUMATERA BARAT" = "SUMATERA BARAT",
                                                "RIAU" = "RIAU",
                                                "JAMBI" = "JAMBI",
                                                "SUMATERA SELATAN" = "SUMATERA SELATAN",
                                                "BENGKULU" = "BENGKULU",
                                                "LAMPUNG" = "LAMPUNG",
                                                "KEP. BANGKA BELITUNG" = "KEP. BANGKA BELITUNG",
                                                "KEP. RIAU" = "KEP. RIAU",
                                                "DKI JAKARTA" = "DKI JAKARTA",
                                                "JAWA BARAT" = "JAWA BARAT",
                                                "JAWA TENGAH" = "JAWA TENGAH",
                                                "DI YOGYAKARTA" = "DI YOGYAKARTA",
                                                "JAWA TIMUR" = "JAWA TIMUR",
                                                "BANTEN" = "BANTEN",
                                                "BALI" = "BALI",
                                                "NUSA TENGGARA BARAT" = "NUSA TENGGARA BARAT",
                                                "NUSA TENGGARA TIMUR" = "NUSA TENGGARA TIMUR",
                                                "KALIMANTAN BARAT" = "KALIMANTAN BARAT",
                                                "KALIMANTAN TENGAH" = "KALIMANTAN TENGAH",
                                                "KALIMANTAN SELATAN" = "KALIMANTAN SELATAN",
                                                "KALIMANTAN TIMUR" = "KALIMANTAN TIMUR",
                                                "KALIMANTAN UTARA" = "KALIMANTAN UTARA",
                                                "SULAWESI UTARA" = "SULAWESI UTARA",
                                                "SULAWESI TENGAH" = "SULAWESI TENGAH",
                                                "SULAWESI SELATAN" = "SULAWESI SELATAN",
                                                "SULAWESI TENGGARA" = "SULAWESI TENGGARA",
                                                "GORONTALO" = "GORONTALO",
                                                "SULAWESI BARAT" = "SULAWESI BARAT",
                                                "MALUKU" = "MALUKU",
                                                "MALUKU UTARA" = "MALUKU UTARA",
                                                "PAPUA BARAT" = "PAPUA BARAT",
                                                "PAPUA" = "PAPUA"
                                              ),
                                              selected = c("DKI JAKARTA", "JAWA BARAT", "JAWA TENGAH"),
                                              inline = FALSE)
                    )
                  ),
                  
                  conditionalPanel(
                    condition = "input.anova_type == 'twoway'",
                    div(class = "alert alert-info",
                        h5(icon("info-circle"), " Two-Way ANOVA"),
                        p("Untuk Two-Way ANOVA, variabel kategori akan dibuat otomatis:"),
                        tags$ul(
                          tags$li("POVERTY → POVERTY_CAT (Rendah/Sedang/Tinggi)"),
                          tags$li("LOWEDU → LOWEDU_CAT (Rendah/Sedang/Tinggi)"),
                          tags$li("ILLITERATE → ILLITERATE_CAT (Rendah/Sedang/Tinggi)")
                        )
                    )
                  ),
                  
                  br(),
                  actionButton("run_anova", "Jalankan Uji ANOVA",
                               class = "btn-primary", icon = icon("play"))
                )
              ),
              
              conditionalPanel(
                condition = "input.run_anova > 0",
                
                fluidRow(
                  box(
                    title = "Uji Normalitas Data", status = "warning", solidHeader = TRUE, width = 12,
                    withSpinner(verbatimTextOutput("anova_normality_test")),
                    withSpinner(htmlOutput("anova_normality_interpretation"))
                  )
                ),

                fluidRow(
                  box(
                    title = "Uji Homogenitas Varians", status = "danger", solidHeader = TRUE, width = 12,
                    withSpinner(verbatimTextOutput("anova_homogeneity_test")),
                    withSpinner(htmlOutput("anova_homogeneity_interpretation"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Status Kelayakan ANOVA", status = "info", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("anova_feasibility_status"))
                  )
                )
              ),
              
              conditionalPanel(
                condition = "input.run_anova > 0 && output.anova_can_proceed == true",
                
                fluidRow(
                  box(
                    title = "Hipotesis", status = "success", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("anova_hypothesis"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Hasil ANOVA", status = "primary", solidHeader = TRUE, width = 12,
                    withSpinner(verbatimTextOutput("anova_result"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Keputusan dan Interpretasi", status = "success", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("anova_interpretation"))
                  )
                ),
                
                conditionalPanel(
                  condition = "output.show_posthoc == true",
                  fluidRow(
                    box(
                      title = "Uji Lanjutan (Post-Hoc)", status = "danger", solidHeader = TRUE, width = 12,
                      withSpinner(verbatimTextOutput("anova_posthoc")),
                      withSpinner(htmlOutput("anova_posthoc_interpretation"))
                    )
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Visualisasi ANOVA", status = "info", solidHeader = TRUE, width = 12,
                    withSpinner(plotlyOutput("anova_plot", height = "500px"))
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                    conditionalPanel(
                      condition = "output.anova_can_proceed == true",
                      downloadButton("download_anova_report", "Download Laporan ANOVA (HTML)",
                                     class = "btn-success", icon = icon("download"))
                    )
                  )
                )
              )
      )
      ,

      # Frontend Regresi
      tabItem(tabName = "regresi",
              fluidRow(
                box(
                  title = "Analisis Regresi Linear", status = "primary", solidHeader = TRUE, width = 12,
                  h4(icon("chart-line"), " Analisis Regresi Linear Berganda"),
                  p("Menganalisis hubungan antara variabel dependen dengan satu atau lebih variabel independen")
                )
              ),
              
              fluidRow(
                box(
                  title = "Pengaturan Model Regresi", status = "info", solidHeader = TRUE, width = 12,
                  fluidRow(
                    column(4,
                           selectInput("reg_dependent", "Variabel Dependen (Y):",
                                       choices = list(
                                         "POVERTY (Kemiskinan)" = "POVERTY",
                                         "LOWEDU (Pendidikan Rendah)" = "LOWEDU",
                                         "ILLITERATE (Buta Huruf)" = "ILLITERATE"
                                       ),
                                       selected = "POVERTY")
                    ),
                    column(8,
                           checkboxGroupInput("reg_independent", "Variabel Independen (X):",
                                              choices = list(
                                                "POVERTY (Kemiskinan)" = "POVERTY",
                                                "LOWEDU (Pendidikan Rendah)" = "LOWEDU",
                                                "ILLITERATE (Buta Huruf)" = "ILLITERATE"
                                              ),
                                              selected = c("LOWEDU", "ILLITERATE"),
                                              inline = TRUE)
                    )
                  ),
                  
                  fluidRow(
                    column(6,
                           numericInput("reg_alpha", "Tingkat Signifikansi (α):",
                                        value = 0.05, min = 0.01, max = 0.10, step = 0.01)
                    ),
                    column(6,
                           checkboxInput("reg_include_assumptions", "Uji Asumsi Regresi",
                                         value = TRUE)
                    )
                  ),

                  conditionalPanel(
                    condition = "input.reg_independent.indexOf(input.reg_dependent) > -1",
                    div(class = "alert alert-danger",
                        h5(icon("exclamation-triangle"), " Peringatan"),
                        p("Variabel dependen tidak boleh sama dengan variabel independen!")
                    )
                  ),
                  
                  conditionalPanel(
                    condition = "input.reg_independent.length == 0",
                    div(class = "alert alert-warning",
                        h5(icon("exclamation-triangle"), " Peringatan"),
                        p("Pilih minimal satu variabel independen!")
                    )
                  ),
                  
                  br(),
                  actionButton("run_regression", "Jalankan Regresi",
                               class = "btn-primary", icon = icon("play"))
                )
              ),

              conditionalPanel(
                condition = "input.run_regression > 0",

                fluidRow(
                  box(
                    title = "Model dan Hipotesis", status = "warning", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("regression_model_hypothesis"))
                  )
                ),

                fluidRow(
                  box(
                    title = "Ringkasan Model Regresi", status = "success", solidHeader = TRUE, width = 12,
                    withSpinner(verbatimTextOutput("regression_summary"))
                  )
                ),

                fluidRow(
                  box(
                    title = "Keputusan dan Interpretasi", status = "primary", solidHeader = TRUE, width = 12,
                    withSpinner(htmlOutput("regression_interpretation"))
                  )
                )
                ,
                

                conditionalPanel(
                  condition = "input.reg_include_assumptions == true",
                  fluidRow(
                    box(
                      title = "Uji Asumsi Regresi", status = "danger", solidHeader = TRUE, width = 12,
                      withSpinner(verbatimTextOutput("regression_assumptions")),
                      withSpinner(htmlOutput("regression_assumptions_interpretation"))
                    )
                  )
                ),

                fluidRow(
                  box(
                    title = "Visualisasi Regresi", status = "info", solidHeader = TRUE, width = 12,
                    withSpinner(plotlyOutput("regression_plot", height = "500px"))
                  )
                ),

                conditionalPanel(
                  condition = "input.reg_include_assumptions == true",
                  fluidRow(
                    box(
                      title = "Plot Diagnostik", status = "warning", solidHeader = TRUE, width = 12,
                      withSpinner(plotOutput("regression_diagnostic_plots", height = "600px"))
                    )
                  )
                ),

                fluidRow(
                  box(
                    title = "Download Hasil", status = "success", solidHeader = TRUE, width = 12,
                    conditionalPanel(
                      condition = "output.regression_completed == true",
                      downloadButton("download_regression_report", "Download Laporan Regresi (HTML)",
                                     class = "btn-success", icon = icon("download"))
                    )
                  )
                )
              )
      )
      ,
      
      # Frontend About Me
      tabItem(tabName = "aboutme",
              fluidRow(
                box(
                  title = NULL, status = "primary", solidHeader = FALSE, width = 12,
                  div(
                    class = "about-header",
                    style = "background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 100%); 
                 color: white; 
                 padding: 40px 20px; 
                 text-align: center; 
                 border-radius: 15px; 
                 margin-bottom: 20px;
                 box-shadow: 0 8px 32px rgba(139, 92, 246, 0.3);",
                    h1("Profil Pembuat Dashboard", 
                       style = "font-size: 3em; 
                    font-weight: 700; 
                    margin-bottom: 10px; 
                    text-shadow: 0 2px 4px rgba(0,0,0,0.3);"),
                    h3("Yang rela mengorbankan jam tidur demi pembuatan dashboard ini", 
                       style = "font-weight: 300; 
                    opacity: 0.9; 
                    font-style: italic;")
                  )
                )
              ),
              
              fluidRow(
                column(4,
                       div(
                         class = "profile-card",
                         style = "background: white; 
                 border-radius: 20px; 
                 padding: 30px; 
                 text-align: center; 
                 box-shadow: 0 10px 40px rgba(139, 92, 246, 0.15);
                 border: 1px solid rgba(139, 92, 246, 0.1);
                 height: 100%;",
                         
                         div(
                           class = "profile-photo-container",
                           style = "margin-bottom: 25px;",
                           div(
                             style = "width: 200px; 
                     height: 200px; 
                     margin: 0 auto; 
                     border-radius: 50%; 
                     background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 100%); 
                     padding: 5px; 
                     box-shadow: 0 8px 32px rgba(139, 92, 246, 0.3);",
                             img(
                               src = "fotoilham.jpg",  
                               alt = "Foto Profil",
                               style = "width: 100%; 
                       height: 100%; 
                       border-radius: 50%; 
                       object-fit: cover; 
                       border: 3px solid white;"
                             )
                           )
                         ),
                         
                         h2("Ilham Tesa Nur Mazua", 
                            style = "color: #2D1B69; 
                    font-weight: 700; 
                    margin-bottom: 10px; 
                    font-size: 2.2em;"),
                         
                         p("Mahasiswa D-IV Komputasi Statistik", 
                           style = "color: #8B5CF6; 
                   font-size: 1.2em; 
                   font-weight: 500; 
                   margin-bottom: 20px;"),

                         div(
                           class = "profile-quote",
                           style = "background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(59, 130, 246, 0.1) 100%); 
                   padding: 20px; 
                   border-radius: 15px; 
                   border-left: 4px solid #8B5CF6; 
                   margin-top: 20px;",
                           p('"When you lose something, you can`t replace."', 
                             style = "font-style: italic; 
                     color: #4A5568; 
                     margin: 0; 
                     font-size: 1.1em; 
                     line-height: 1.6;")
                         )
                       )
                ),
                
                column(8,
                       div(
                         class = "details-card",
                         style = "background: white; 
                 border-radius: 20px; 
                 padding: 30px; 
                 box-shadow: 0 10px 40px rgba(139, 92, 246, 0.15);
                 border: 1px solid rgba(139, 92, 246, 0.1);
                 height: 100%;",
                         
                         h3("Identitas Mahasiswa", 
                            style = "color: #2D1B69; 
                    font-weight: 700; 
                    margin-bottom: 30px; 
                    font-size: 2em; 
                    border-bottom: 3px solid #8B5CF6; 
                    padding-bottom: 10px;"),
                         
                         div(
                           class = "identity-info",
                           div(
                             class = "info-item",
                             style = "display: flex; 
                     align-items: center; 
                     margin-bottom: 20px; 
                     padding: 15px; 
                     background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(59, 130, 246, 0.05) 100%); 
                     border-radius: 12px; 
                     border-left: 4px solid #8B5CF6;",
                             div(
                               style = "background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 100%); 
                       color: white; 
                       width: 50px; 
                       height: 50px; 
                       border-radius: 50%; 
                       display: flex; 
                       align-items: center; 
                       justify-content: center; 
                       margin-right: 20px; 
                       font-size: 1.5em;",
                               icon("user")
                             ),
                             div(
                               h4("Nama Lengkap", 
                                  style = "margin: 0; 
                          color: #2D1B69; 
                          font-weight: 600; 
                          font-size: 1.1em;"),
                               p("Ilham Tesa Nur Mazua", 
                                 style = "margin: 5px 0 0 0; 
                         color: #4A5568; 
                         font-size: 1.2em; 
                         font-weight: 500;")
                             )
                           ),
                           
                           div(
                             class = "info-item",
                             style = "display: flex; 
                     align-items: center; 
                     margin-bottom: 20px; 
                     padding: 15px; 
                     background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(59, 130, 246, 0.05) 100%); 
                     border-radius: 12px; 
                     border-left: 4px solid #3B82F6;",
                             div(
                               style = "background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%); 
                       color: white; 
                       width: 50px; 
                       height: 50px; 
                       border-radius: 50%; 
                       display: flex; 
                       align-items: center; 
                       justify-content: center; 
                       margin-right: 20px; 
                       font-size: 1.5em;",
                               icon("id-card")
                             ),
                             div(
                               h4("NIM", 
                                  style = "margin: 0; 
                          color: #2D1B69; 
                          font-weight: 600; 
                          font-size: 1.1em;"),
                               p("222313133", 
                                 style = "margin: 5px 0 0 0; 
                         color: #4A5568; 
                         font-size: 1.2em; 
                         font-weight: 500; 
                         font-family: 'Courier New', monospace;")
                             )
                           ),
                           div(
                             class = "info-item",
                             style = "display: flex; 
                     align-items: center; 
                     margin-bottom: 20px; 
                     padding: 15px; 
                     background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(59, 130, 246, 0.05) 100%); 
                     border-radius: 12px; 
                     border-left: 4px solid #8B5CF6;",
                             div(
                               style = "background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 100%); 
                       color: white; 
                       width: 50px; 
                       height: 50px; 
                       border-radius: 50%; 
                       display: flex; 
                       align-items: center; 
                       justify-content: center; 
                       margin-right: 20px; 
                       font-size: 1.5em;",
                               icon("users")
                             ),
                             div(
                               h4("Kelas", 
                                  style = "margin: 0; 
                          color: #2D1B69; 
                          font-weight: 600; 
                          font-size: 1.1em;"),
                               p("2KS3",
                                 style = "margin: 5px 0 0 0; 
                         color: #4A5568; 
                         font-size: 1.2em; 
                         font-weight: 500;")
                             )
                           ),
                           
                           div(
                             class = "info-item",
                             style = "display: flex; 
                     align-items: center; 
                     margin-bottom: 20px; 
                     padding: 15px; 
                     background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(59, 130, 246, 0.05) 100%); 
                     border-radius: 12px; 
                     border-left: 4px solid #3B82F6;",
                             div(
                               style = "background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%); 
                       color: white; 
                       width: 50px; 
                       height: 50px; 
                       border-radius: 50%; 
                       display: flex; 
                       align-items: center; 
                       justify-content: center; 
                       margin-right: 20px; 
                       font-size: 1.5em;",
                               icon("list-ol")
                             ),
                             div(
                               h4("No. Presensi", 
                                  style = "margin: 0; 
                          color: #2D1B69; 
                          font-weight: 600; 
                          font-size: 1.1em;"),
                               p("17", 
                                 style = "margin: 5px 0 0 0; 
                         color: #4A5568; 
                         font-size: 1.2em; 
                         font-weight: 500; 
                         font-family: 'Courier New', monospace;")
                             )
                           )
                         )
                       )
                )
              )
              

      )
      
    )
  )
)

# Kode Server
server <- function(input, output, session) {
  
  regression_model <- reactive({
    lm(POVERTY ~ LOWEDU + ILLITERATE, data = data)
  })
  
  observe({
    province_choices <- c("Semua Provinsi" = "all", 
                          setNames(sort(unique(data$PROVINCENAME)), sort(unique(data$PROVINCENAME))))
    updateSelectInput(session, "selected_province", choices = province_choices)
  })
  
  #  Server Manajemen Data
  categorical_created <- reactiveVal(FALSE)
  
  current_data <- reactiveVal(data)
  
  output$data_range_info <- renderUI({
    req(input$var_to_categorize)
    
    var_data <- current_data()[[input$var_to_categorize]]
    
    decimal_places <- if(input$var_to_categorize == "POVERTY") 2 else 5
    
    min_val <- round(min(var_data, na.rm = TRUE), decimal_places)
    max_val <- round(max(var_data, na.rm = TRUE), decimal_places)
    mean_val <- round(mean(var_data, na.rm = TRUE), decimal_places)
    median_val <- round(median(var_data, na.rm = TRUE), decimal_places)
    
    HTML(paste0(
      '<div class="alert alert-info">',
      '<h6><i class="fa fa-info-circle"></i> Informasi Data ', input$var_to_categorize, ':</h6>',
      '<div class="row">',
      '<div class="col-md-6">',
      '<p><strong>Minimum:</strong> ', min_val, '</p>',
      '<p><strong>Maksimum:</strong> ', max_val, '</p>',
      '</div>',
      '<div class="col-md-6">',
      '<p><strong>Rata-rata:</strong> ', mean_val, '</p>',
      '<p><strong>Median:</strong> ', median_val, '</p>',
      '</div>',
      '</div>',
      '<p><strong>Jumlah observasi:</strong> ', length(var_data), '</p>',
      '<p><strong>Presisi desimal:</strong> ', decimal_places, ' digit</p>',
      '</div>'
    ))
  })
  
  observeEvent(input$var_to_categorize, {
    new_name <- paste0(input$var_to_categorize, "_CAT")
    updateTextInput(session, "new_var_name", value = new_name)
  })
  
  output$category_inputs <- renderUI({
    req(input$num_categories, input$var_to_categorize)
    
    var_data <- current_data()[[input$var_to_categorize]]
    
    if(input$var_to_categorize == "POVERTY") {
      decimal_places <- 2
      step_val <- 0.01
    } else {
      decimal_places <- 5
      step_val <- 0.00001
    }
    
    min_val <- round(min(var_data, na.rm = TRUE), decimal_places)
    max_val <- round(max(var_data, na.rm = TRUE), decimal_places)
    
    breaks <- seq(min_val, max_val, length.out = input$num_categories + 1)
    breaks <- round(breaks, decimal_places)
    
    if(input$var_to_categorize == "POVERTY") {
      suggested_labels <- c("Rendah", "Sedang", "Tinggi", "Sangat Tinggi", "Ekstrem")[1:input$num_categories]
    } else if(input$var_to_categorize == "LOWEDU") {
      suggested_labels <- c("Baik", "Sedang", "Buruk", "Sangat Buruk", "Kritis")[1:input$num_categories]
    } else {
      suggested_labels <- c("Rendah", "Sedang", "Tinggi", "Sangat Tinggi", "Ekstrem")[1:input$num_categories]
    }
    
    input_list <- list()
    
    for(i in 1:input$num_categories) {
      input_list[[paste0("cat_", i)]] <- div(
        style = "border: 1px solid #ddd; padding: 15px; margin: 8px 0; border-radius: 8px; background-color: #f9f9f9;",
        h6(paste("Kategori", i), style = "color: #2c3e50; font-weight: bold;"),
        fluidRow(
          column(6,
                 numericInput(paste0("range_start_", i),
                              "Batas Bawah:",
                              value = breaks[i],
                              step = step_val,
                              min = min_val,
                              max = max_val)
          ),
          column(6,
                 numericInput(paste0("range_end_", i),
                              "Batas Atas:",
                              value = breaks[i+1],
                              step = step_val,
                              min = min_val,
                              max = max_val)
          )
        ),
        textInput(paste0("label_", i),
                  "Label Kategori:",
                  value = suggested_labels[i],
                  placeholder = paste("Label untuk kategori", i))
      )
    }
    
    do.call(tagList, input_list)
  })

  output$categorization_preview <- renderUI({
    req(input$num_categories, input$var_to_categorize)
    
    ranges <- list()
    labels <- list()
    
    for(i in 1:input$num_categories) {
      start_input <- paste0("range_start_", i)
      end_input <- paste0("range_end_", i)
      label_input <- paste0("label_", i)
      
      if(!is.null(input[[start_input]]) && !is.null(input[[end_input]]) && !is.null(input[[label_input]])) {
        ranges[[i]] <- c(input[[start_input]], input[[end_input]])
        labels[[i]] <- input[[label_input]]
      }
    }
    
    if(length(ranges) == input$num_categories && length(labels) == input$num_categories) {
      decimal_places <- if(input$var_to_categorize == "POVERTY") 2 else 5
      
      preview_html <- '<div class="alert alert-secondary"><h6><i class="fa fa-eye"></i> Validasi Kategorisasi:</h6><ul>'
      
      for(i in 1:length(ranges)) {
        if(i == length(ranges)) {
          preview_html <- paste0(preview_html,
                                 '<li><strong>', labels[[i]], ':</strong> [',
                                 format(ranges[[i]][1], nsmall = decimal_places), ', ', 
                                 format(ranges[[i]][2], nsmall = decimal_places), '] (termasuk batas atas)</li>')
        } else {
          preview_html <- paste0(preview_html,
                                 '<li><strong>', labels[[i]], ':</strong> [',
                                 format(ranges[[i]][1], nsmall = decimal_places), ', ', 
                                 format(ranges[[i]][2], nsmall = decimal_places), ') (tidak termasuk batas atas)</li>')
        }
      }
      
      preview_html <- paste0(preview_html, '</ul></div>')
      HTML(preview_html)
    } else {
      HTML('<div class="alert alert-light"><p><i>Preview akan muncul setelah semua kategori diatur...</i></p></div>')
    }
  })
  
  output$validation_messages <- renderUI({
    req(input$num_categories, input$var_to_categorize)
    
    var_data <- current_data()[[input$var_to_categorize]]
    
    decimal_places <- if(input$var_to_categorize == "POVERTY") 2 else 5
    tolerance <- 10^(-decimal_places)
    
    min_val <- round(min(var_data, na.rm = TRUE), decimal_places)
    max_val <- round(max(var_data, na.rm = TRUE), decimal_places)
    
    ranges <- list()
    labels <- list()
    
    for(i in 1:input$num_categories) {
      start_input <- paste0("range_start_", i)
      end_input <- paste0("range_end_", i)
      label_input <- paste0("label_", i)
      
      if(!is.null(input[[start_input]]) && !is.null(input[[end_input]]) && !is.null(input[[label_input]])) {
        ranges[[i]] <- c(round(input[[start_input]], decimal_places), round(input[[end_input]], decimal_places))
        labels[[i]] <- input[[label_input]]
      }
    }
    
    if(length(ranges) == input$num_categories && length(labels) == input$num_categories) {
      errors <- c()
      warnings <- c()
      
      if(abs(ranges[[1]][1] - min_val) > tolerance) {
        errors <- c(errors, paste("Range pertama harus dimulai dari", format(min_val, nsmall = decimal_places)))
      }
      
      if(abs(ranges[[length(ranges)]][2] - max_val) > tolerance) {
        errors <- c(errors, paste("Range terakhir harus berakhir di", format(max_val, nsmall = decimal_places)))
      }
      
      for(i in 1:(length(ranges)-1)) {
        if(abs(ranges[[i]][2] - ranges[[i+1]][1]) > tolerance) {
          errors <- c(errors, paste("Gap atau overlap antara kategori", i, "dan", i+1))
        }
      }
      
      for(i in 1:length(ranges)) {
        if(ranges[[i]][1] >= ranges[[i]][2]) {
          errors <- c(errors, paste("Kategori", i, ": Batas bawah harus lebih kecil dari batas atas"))
        }
      }

      for(i in 1:length(labels)) {
        if(is.null(labels[[i]]) || labels[[i]] == "" || trimws(labels[[i]]) == "") {
          errors <- c(errors, paste("Label kategori", i, "tidak boleh kosong"))
        }
      }

      if(length(unique(labels)) != length(labels)) {
        errors <- c(errors, "Label kategori tidak boleh sama/duplikat")
      }
      
      if(is.null(input$new_var_name) || input$new_var_name == "" || trimws(input$new_var_name) == "") {
        errors <- c(errors, "Nama variabel baru tidak boleh kosong")
      }
      
      if(length(errors) > 0) {
        error_html <- '<div class="alert alert-danger"><h6><i class="fa fa-exclamation-triangle"></i> Error Validasi:</h6><ul>'
        for(error in errors) {
          error_html <- paste0(error_html, "<li>", error, "</li>")
        }
        error_html <- paste0(error_html, "</ul></div>")
        HTML(error_html)
      } else {
        HTML('<div class="alert alert-success"><h6><i class="fa fa-check-circle"></i> Validasi Berhasil!</h6><p>Semua pengaturan sudah benar. Siap untuk membuat variabel kategorik.</p></div>')
      }
    } else {
      HTML('<div class="alert alert-warning"><p><i class="fa fa-hourglass-half"></i> Menunggu pengaturan kategori...</p></div>')
    }
  })
  
  observeEvent(input$create_categorical_var, {
    req(input$num_categories, input$var_to_categorize, input$new_var_name)
    
    current_df <- current_data()
    var_data <- current_df[[input$var_to_categorize]]
    
    decimal_places <- if(input$var_to_categorize == "POVERTY") 2 else 5
    tolerance <- 10^(-decimal_places)
    
    min_val <- round(min(var_data, na.rm = TRUE), decimal_places)
    max_val <- round(max(var_data, na.rm = TRUE), decimal_places)
    
    ranges <- list()
    labels <- list()
    
    for(i in 1:input$num_categories) {
      start_input <- paste0("range_start_", i)
      end_input <- paste0("range_end_", i)
      label_input <- paste0("label_", i)
      
      ranges[[i]] <- c(round(input[[start_input]], decimal_places), round(input[[end_input]], decimal_places))
      labels[[i]] <- input[[label_input]]
    }
    
    valid <- TRUE
    error_msg <- ""
    
    if(abs(ranges[[1]][1] - min_val) > tolerance || abs(ranges[[length(ranges)]][2] - max_val) > tolerance) {
      valid <- FALSE
      error_msg <- "Range tidak sesuai dengan batas data"
    }

    for(i in 1:(length(ranges)-1)) {
      if(abs(ranges[[i]][2] - ranges[[i+1]][1]) > tolerance) {
        valid <- FALSE
        error_msg <- "Range tidak berkesinambungan"
      }
    }
    
    if(length(unique(labels)) != length(labels) || any(sapply(labels, function(x) is.null(x) || x == ""))) {
      valid <- FALSE
      error_msg <- "Label tidak valid"
    }
    
    if(valid) {
      new_var <- rep(NA, length(var_data))
      
      for(i in 1:length(ranges)) {
        if(i == length(ranges)) {
          mask <- var_data >= ranges[[i]][1] & var_data <= ranges[[i]][2]
        } else {
          mask <- var_data >= ranges[[i]][1] & var_data < ranges[[i]][2]
        }
        new_var[mask] <- labels[[i]]
      }
      
      current_df[[input$new_var_name]] <- as.factor(new_var)
      
      current_data(current_df)
      
      data <<- current_df

      tryCatch({
        write.xlsx(current_df, "data/data_UAS.xlsx", overwrite = TRUE)
        
        categorical_created(TRUE)
        
        showNotification(
          HTML(paste0(
            "<strong>Berhasil!</strong><br>",
            "Variabel kategorik <strong>", input$new_var_name, "</strong> berhasil dibuat dan disimpan ke file Excel."
          )),
          type = "success",
          duration = 8
        )
      }, error = function(e) {
        showNotification(
          HTML(paste0(
            "<strong>Peringatan!</strong><br>",
            "Variabel berhasil dibuat ", e$message
          )),
          type = "warning",
          duration = 8
        )
      })
    } else {
      showNotification(
        HTML(paste0(
          "<strong>Validasi Gagal!</strong><br>",
          error_msg, ". Periksa kembali pengaturan."
        )),
        type = "error",
        duration = 5
      )
    }
  })
  
  observeEvent(input$reset_inputs, {
    updateNumericInput(session, "num_categories", value = 3)
    updateTextInput(session, "new_var_name", value = paste0(input$var_to_categorize, "_CAT"))
    
    showNotification(
      "Pengaturan telah direset.",
      type = "message",
      duration = 3
    )
  })

  output$updated_data_preview <- DT::renderDataTable({
    current_df <- current_data()
    
    DT::datatable(current_df,
                  options = list(
                    scrollX = TRUE,
                    pageLength = 15,
                    lengthMenu = c(10, 15, 25, 50),
                    dom = 'Bfrtip',
                    buttons = c('copy', 'csv', 'excel')
                  ),
                  class = 'cell-border stripe hover',
                  rownames = FALSE)
  })
  
  
  #Server Beranda
  output$metadata_table <- DT::renderDataTable({
    metadata <- data.frame(
      "Variabel" = c("DISTRICTCODE", "LOWEDU", "POVERTY", "ILLITERATE", "DISTRICTNAME", "PROVINCENAME","LOWEDU_CAT","POVERTY_CAT","ILLITERATE_CAT"),
      "Nama Lengkap" = c("Kode Kabupaten/Kota", "Persentase Penduduk Pendidikan Rendah",
                         "Persentase Penduduk Miskin", "Persentase Penduduk Buta Huruf",
                         "Nama Kabupaten/Kota", "Nama Provinsi","Kategori Persentase Penduduk Pendidikan Rendah","Kategori Persentase Penduduk Miskin","Kategori Persentase Penduduk Buta Huruf"),
      "Tipe Data" = c("Numeric", "Numeric", "Numeric", "Numeric", "Character", "Character","Character","Character","Character"),
      "Measure" = c("Nominal", "Ratio", "Ratio", "Ratio", "Nominal", "Nominal","Ordinal","Ordinal","Ordinal"),
      "Unit Data" = c("Kode", "Persen (%)", "Persen (%)", "Persen (%)", "Nama", "Nama", "Status","Status","Status"),
      "Deskripsi" = c("Kode unik untuk setiap kabupaten/kota",
                      "Persentase penduduk usia 15+ dengan pendidikan rendah",
                      "Persentase penduduk yang berada di bawah garis kemiskinan",
                      "Persentase penduduk yang tidak bisa membaca dan menulis",
                      "Nama resmi kabupaten atau kota",
                      "Nama provinsi tempat kabupaten/kota berada",
                      "Kategori persentase penduduk usia 15+ dengan pendidikan rendah",
                      "Kategori persentase penduduk miskin",
                      "Kategori persentase penduduk yang tidak bisa baca tulis")
    )
    
    DT::datatable(metadata, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  
  output$desc_stats <- DT::renderDataTable({
    desc_data <- data %>%
      select(POVERTY, ILLITERATE, LOWEDU) %>%
      summarise_all(list(
        Mean = ~round(mean(., na.rm = TRUE), 3),
        Median = ~round(median(., na.rm = TRUE), 3),
        Min = ~round(min(., na.rm = TRUE), 3),
        Max = ~round(max(., na.rm = TRUE), 3),
        SD = ~round(sd(., na.rm = TRUE), 3),
        Q1 = ~round(quantile(., 0.25, na.rm = TRUE), 3),
        Q3 = ~round(quantile(., 0.75, na.rm = TRUE), 3)
      )) %>%
      tidyr::pivot_longer(everything(), names_to = "Statistik", values_to = "Nilai") %>%
      tidyr::separate(Statistik, into = c("Variabel", "Measure"), sep = "_") %>%
      tidyr::pivot_wider(names_from = Measure, values_from = Nilai)
    
    DT::datatable(desc_data, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$province_summary <- DT::renderDataTable({
    province_data <- data %>%
      group_by(PROVINCENAME) %>%
      summarise(
        Jumlah_Kabkota = n(),
        Rata_rata_POVERTY = round(mean(POVERTY, na.rm = TRUE), 2),
        Rata_rata_ILLITERATE = round(mean(ILLITERATE, na.rm = TRUE), 2),
        Rata_rata_LOWEDU = round(mean(LOWEDU, na.rm = TRUE), 2),
        .groups = 'drop'
      ) %>%
      arrange(desc(Rata_rata_POVERTY))
    
    DT::datatable(province_data, options = list(pageLength = 15, scrollX = TRUE))
  })
  
  output$desc_interpretation <- renderUI({
    poverty_mean <- round(mean(data$POVERTY, na.rm = TRUE), 2)
    illiterate_mean <- round(mean(data$ILLITERATE, na.rm = TRUE), 2)
    lowedu_mean <- round(mean(data$LOWEDU, na.rm = TRUE), 2)
    
    poverty_median <- round(median(data$POVERTY, na.rm = TRUE), 2)
    illiterate_median <- round(median(data$ILLITERATE, na.rm = TRUE), 2)
    lowedu_median <- round(median(data$LOWEDU, na.rm = TRUE), 2)
    
    HTML(paste0(
      "<h4>Interpretasi Statistik Deskriptif:</h4>",
      "<p><strong>POVERTY (Kemiskinan):</strong> Rata-rata persentase penduduk miskin adalah ", poverty_mean, "% dengan median ", poverty_median, "%. 
      Hal ini menunjukkan tingkat kemiskinan di Indonesia cenderung cukup kecil serta bervariasi antar kabupaten/kota di Indonesia.</p>",
      "<p><strong>ILLITERATE (Buta Huruf):</strong> Rata-rata persentase penduduk buta huruf adalah ", illiterate_mean, "% dengan median ", illiterate_median, "%. 
      Angka ini mencerminkan tingkat penduduk yang buta huruf di Indonesia tergolong cukup kecil dan variasi antar daerahnya juga cukup kecil.</p>",
      "<p><strong>LOWEDU (Pendidikan Rendah):</strong> Rata-rata persentase penduduk dengan pendidikan rendah adalah ", lowedu_mean, "% dengan median ", lowedu_median, "%. 
      Ini menggambarkan kondisi pendidikan di Indonesia yang masih perlu ditingkatkan secara signifikan karena persentase penduduk yang berpendidikan rendah masih sangat tinggi.</p>",
      "<p><strong>Kesimpulan:</strong> Terdapat variasi yang cukup besar antar daerah dalam ketiga indikator demografi ini, menunjukkan perlunya kebijakan yang sesuai dari pemerintah untuk mengatasi permasalahan di sektor tersebut.</p>"
    ))
  })
  
  # Server Deskriptif
  output$download_deskriptif_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Statistik_Deskriptif_", Sys.Date(), ".html")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "template_deskriptif.Rmd")
      file.copy("template_deskriptif.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        data = data
      )
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  # Server Visualisasi Data
  observe({
    province_choices <- c("Semua Provinsi" = "all",
                          setNames(sort(unique(data$PROVINCENAME)), sort(unique(data$PROVINCENAME))))
    updateSelectInput(session, "selected_province", choices = province_choices)
  })
  
  output$main_visualization <- renderUI({
    if(input$chart_type == "table") {
      DT::dataTableOutput("data_table")
    } else if(input$chart_type == "bar") {
      plotlyOutput("bar_chart")
    } else if(input$chart_type == "histogram") {
      plotlyOutput("histogram_chart")
    }
  })

  output$data_table <- DT::renderDataTable({
    filtered_data <- if(input$selected_province == "all") data else filter(data, PROVINCENAME == input$selected_province)
    DT::datatable(filtered_data, options = list(pageLength = 15, scrollX = TRUE))
  })

  output$bar_chart <- renderPlotly({
    filtered_data <- if(input$selected_province == "all") data else filter(data, PROVINCENAME == input$selected_province)
    
    if(input$selected_province == "all") {
      plot_data <- filtered_data %>%
        group_by(PROVINCENAME) %>%
        summarise(avg_value = mean(get(input$selected_variable), na.rm = TRUE), .groups = 'drop') %>%
        arrange(desc(avg_value))  
      
      p <- ggplot(plot_data, aes(x = reorder(PROVINCENAME, avg_value), y = avg_value)) +
        geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
        coord_flip() +
        labs(title = paste("Semua Provinsi -", input$selected_variable),
             x = "Provinsi", y = paste("Rata-rata", input$selected_variable, "(%)")) +
        theme_minimal() +
        theme(axis.text.y = element_text(size = 8))
    } else {
      plot_data <- filtered_data %>%
        arrange(desc(get(input$selected_variable))) 
      
      p <- ggplot(plot_data, aes(x = reorder(DISTRICTNAME, get(input$selected_variable)),
                                 y = get(input$selected_variable))) +
        geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
        coord_flip() +
        labs(title = paste("Semua Kabupaten/Kota", input$selected_variable, "di", input$selected_province),
             x = "Kabupaten/Kota", y = paste(input$selected_variable, "(%)")) +
        theme_minimal() +
        theme(axis.text.y = element_text(size = 6)) 
    }
    
    ggplotly(p)
  })
  
  output$histogram_chart <- renderPlotly({
    filtered_data <- if(input$selected_province == "all") data else filter(data, PROVINCENAME == input$selected_province)
    
    p <- ggplot(filtered_data, aes(x = get(input$selected_variable))) +
      geom_histogram(bins = 30, fill = "lightblue", color = "black", alpha = 0.7) +
      labs(title = paste("Distribusi", input$selected_variable,
                         ifelse(input$selected_province == "all", "- Seluruh Indonesia",
                                paste("- Provinsi", input$selected_province))),
           x = paste(input$selected_variable, "(%)"), y = "Frekuensi") +
      theme_minimal()
    
    ggplotly(p)
  })
  

  output$chart_interpretation <- renderUI({
    variable_name <- switch(input$selected_variable,
                            "POVERTY" = "Kemiskinan",
                            "ILLITERATE" = "Buta Huruf",
                            "LOWEDU" = "Pendidikan Rendah")
    
    province_text <- if(input$selected_province == "all") "seluruh Indonesia" else paste("Provinsi", input$selected_province)
    
    filtered_data <- if(input$selected_province == "all") data else filter(data, PROVINCENAME == input$selected_province)
    
    if(input$selected_province == "all") {
      data_count <- length(unique(filtered_data$PROVINCENAME))
      data_type <- "provinsi"
    } else {
      data_count <- nrow(filtered_data)
      data_type <- "kabupaten/kota"
    }
    
    interpretation <- switch(input$chart_type,
                             "table" = paste("Tabel menampilkan data lengkap", variable_name, "untuk", province_text,
                                             "yang dapat digunakan untuk analisis detail per", 
                                             ifelse(input$selected_province == "all", "kabupaten/kota", "kabupaten/kota"), "."),
                             "bar" = paste("Grafik batang menunjukkan perbandingan", variable_name, "untuk SEMUA", data_count, data_type, "di", province_text,
                                           ". Semakin tinggi batang, semakin tinggi persentase", tolower(variable_name), "di wilayah tersebut.",
                                           "Data diurutkan dari tertinggi ke terendah untuk memudahkan identifikasi wilayah dengan kondisi terburuk dan terbaik."),
                             "histogram" = paste("Histogram menampilkan distribusi frekuensi", variable_name, "di", province_text,
                                                 ". Grafik ini membantu memahami sebaran data dan mengidentifikasi pola distribusi untuk",
                                                 data_count, data_type, "yang dianalisis.")
    )
    
    HTML(paste0("<p><strong>Interpretasi:</strong> ", interpretation, "</p>"))
  })
  
  output$aggregate_plot <- renderPlotly({
    agg_data <- data %>%
      group_by(PROVINCENAME) %>%
      summarise(
        Kemiskinan = mean(POVERTY, na.rm = TRUE),
        `Buta Huruf` = mean(ILLITERATE, na.rm = TRUE),
        `Pendidikan Rendah` = mean(LOWEDU, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      tidyr::pivot_longer(-PROVINCENAME, names_to = "Indikator", values_to = "Nilai") %>%
      arrange(desc(Nilai))
    
    p <- ggplot(agg_data, aes(x = reorder(PROVINCENAME, Nilai), y = Nilai, fill = Indikator)) +
      geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
      coord_flip() +
      labs(title = "Rata-rata Indikator Demografi per Provinsi",
           x = "Provinsi", y = "Persentase (%)") +
      theme_minimal() +
      theme(legend.position = "bottom", axis.text.y = element_text(size = 8)) +
      scale_fill_brewer(type = "qual", palette = "Set2")
    
    ggplotly(p)
  })
  
  output$download_visualisasi_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Visualisasi_", input$selected_variable, "_", 
             if(input$selected_province == "all") "Nasional" else input$selected_province, "_", 
             Sys.Date(), ".html")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "template_visualisasi.Rmd")
      file.copy("template_visualisasi.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        variable = input$selected_variable,
        province = input$selected_province,
        chart_type = input$chart_type,
        data = data
      )
      

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  # Server Choropleth
  
  current_map_data <- reactive({
    if(!is.null(map_data) && !is.null(map_data@data)) {
      map_df <- map_data@data
      
      var_col <- switch(input$map_variable,
                        "POVERTY" = "POVERTY",
                        "ILLITERATE" = "ILLITERATE", 
                        "LOWEDU" = "LOWEDU")
      
      if(var_col %in% names(map_df)) {
        values <- as.numeric(map_df[[var_col]])
        values[is.na(values)] <- 0
        return(values)
      }
    }
    
    return(runif(100, 0, 30))
  })
  
  output$choropleth_map <- renderLeaflet({
    if(!is.null(map_data)) {
      values <- current_map_data()
      
      pal <- colorNumeric(
        palette = input$color_scheme,
        domain = values,
        na.color = "#808080"
      )
      
      variable_name <- switch(input$map_variable,
                              "POVERTY" = "Kemiskinan",
                              "ILLITERATE" = "Buta Huruf", 
                              "LOWEDU" = "Pendidikan Rendah")
      
      district_names <- if("nmkab" %in% names(map_data@data)) {
        map_data@data$nmkab
      } else {
        paste("Daerah", 1:length(values))
      }
      
      district_codes <- if("kodeprkab" %in% names(map_data@data)) {
        map_data@data$kodeprkab
      } else {
        paste("Kode", 1:length(values))
      }
      
      labels <- paste0(
        "<strong>", district_names, "</strong><br/>",
        "<strong>", variable_name, ":</strong> ", round(values, 2), "%<br/>",
        "<strong>Kode:</strong> ", district_codes
      ) %>% lapply(htmltools::HTML)
      
      leaflet(map_data) %>%
        addTiles() %>%
        addPolygons(
          fillColor = ~pal(values),
          weight = 1,
          opacity = 1,
          color = "white",
          dashArray = "2",
          fillOpacity = 0.7,
          highlight = highlightOptions(
            weight = 3,
            color = "#666",
            dashArray = "",
            fillOpacity = 0.9,
            bringToFront = TRUE
          ),
          label = labels,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "13px",
            direction = "auto"
          )
        ) %>%
        addLegend(
          pal = pal, 
          values = values,
          opacity = 0.7, 
          title = paste(variable_name, "(%)")
        ) %>%
        setView(lng = 118, lat = -2, zoom = 5)
    } else {
      leaflet() %>%
        addTiles() %>%
        setView(lng = 118, lat = -2, zoom = 5) %>%
        addMarkers(lng = 118, lat = -2, 
                   popup = "Data GeoJSON tidak tersedia. Silakan periksa file data/indonesia511.geojson")
    }
  })
  
  output$map_statistics <- renderUI({
    values <- current_map_data()
    
    if(!is.null(map_data) && !is.null(map_data@data)) {
      max_idx <- which.max(values)
      min_idx <- which.min(values)
      
      highest_district <- if("nmkab" %in% names(map_data@data)) {
        map_data@data$nmkab[max_idx]
      } else {
        "Data tidak tersedia"
      }
      
      lowest_district <- if("nmkab" %in% names(map_data@data)) {
        map_data@data$nmkab[min_idx]
      } else {
        "Data tidak tersedia"
      }
      
      highest_value <- round(values[max_idx], 2)
      lowest_value <- round(values[min_idx], 2)
    } else {
      highest_district <- "Data tidak tersedia"
      lowest_district <- "Data tidak tersedia"
      highest_value <- 0
      lowest_value <- 0
    }
    
    mean_value <- round(mean(values, na.rm = TRUE), 2)
    median_value <- round(median(values, na.rm = TRUE), 2)
    
    HTML(paste0(
      "<p><strong>Rata-rata:</strong> ", mean_value, "%</p>",
      "<p><strong>Median:</strong> ", median_value, "%</p>",
      "<hr>",
      "<p><strong>Tertinggi:</strong><br>", 
      highest_district, " (", highest_value, "%)</p>",
      "<p><strong>Terendah:</strong><br>", 
      lowest_district, " (", lowest_value, "%)</p>"
    ))
  })
  
  output$map_interpretation <- renderUI({
    values <- current_map_data()
    mean_value <- round(mean(values, na.rm = TRUE), 2)
    sd_value <- round(sd(values, na.rm = TRUE), 2)
    
    variable_name <- switch(input$map_variable,
                            "POVERTY" = "kemiskinan",
                            "ILLITERATE" = "buta huruf", 
                            "LOWEDU" = "pendidikan rendah")
    
    variable_title <- switch(input$map_variable,
                             "POVERTY" = "Kemiskinan",
                             "ILLITERATE" = "Buta Huruf", 
                             "LOWEDU" = "Pendidikan Rendah")
    
    variation_level <- if(sd_value < mean_value * 0.3) {
      "relatif homogen"
    } else if(sd_value < mean_value * 0.6) {
      "cukup bervariasi"
    } else {
      "sangat bervariasi"
    }
    
    HTML(paste0(
      "<h4>Interpretasi Peta Choropleth - ", variable_title, "</h4>",
      "<p><strong>Pola Spasial:</strong> Peta menunjukkan distribusi geografis tingkat ", variable_name, 
      " di seluruh kabupaten/kota Indonesia. Warna yang lebih gelap menunjukkan nilai yang lebih tinggi.</p>",
      "<p><strong>Variabilitas:</strong> Data menunjukkan tingkat ", variable_name, " yang ", variation_level, 
      " antar wilayah dengan rata-rata ", mean_value, "% dan standar deviasi ", sd_value, ".</p>",
      "<p><strong>Implikasi Kebijakan:</strong> ",
      if(variation_level == "sangat bervariasi") {
        paste("Variasi yang tinggi menunjukkan perlunya pendekatan kebijakan yang disesuaikan dengan kondisi spesifik setiap daerah untuk mengatasi masalah", variable_name, ".")
      } else if(variation_level == "cukup bervariasi") {
        paste("Variasi yang cukup signifikan menunjukkan adanya perbedaan kondisi antar daerah yang perlu dipertimbangkan dalam perumusan kebijakan", variable_name, ".")
      } else {
        paste("Kondisi yang relatif homogen menunjukkan bahwa pendekatan kebijakan yang seragam mungkin dapat diterapkan untuk mengatasi masalah", variable_name, ".")
      },
      "</p>"
    ))
  })
  output$top_districts <- DT::renderDataTable({
    if(!is.null(map_data) && !is.null(map_data@data)) {
      values <- current_map_data()
      
      district_names <- if("nmkab" %in% names(map_data@data)) {
        map_data@data$nmkab
      } else {
        paste("Daerah", 1:length(values))
      }
      
      top_indices <- order(values, decreasing = TRUE)[1:min(10, length(values))]
      
      top_data <- data.frame(
        Ranking = 1:length(top_indices),
        Kabupaten_Kota = district_names[top_indices],
        Nilai = round(values[top_indices], 2)
      )
      
      names(top_data)[3] <- paste(switch(input$map_variable,
                                         "POVERTY" = "Kemiskinan",
                                         "ILLITERATE" = "Buta Huruf", 
                                         "LOWEDU" = "Pendidikan Rendah"), "(%)")
    } else {
      top_data <- data.frame(
        Ranking = 1:10,
        Kabupaten_Kota = paste("Data tidak tersedia", 1:10),
        Nilai = rep(0, 10)
      )
    }
    
    DT::datatable(top_data, 
                  options = list(pageLength = 10, searching = FALSE, info = FALSE),
                  rownames = FALSE)
  })
  
  output$bottom_districts <- DT::renderDataTable({
    if(!is.null(map_data) && !is.null(map_data@data)) {
      values <- current_map_data()
      
      district_names <- if("nmkab" %in% names(map_data@data)) {
        map_data@data$nmkab
      } else {
        paste("Daerah", 1:length(values))
      }
      
      bottom_indices <- order(values)[1:min(10, length(values))]
      
      bottom_data <- data.frame(
        Ranking = 1:length(bottom_indices),
        Kabupaten_Kota = district_names[bottom_indices],
        Nilai = round(values[bottom_indices], 2)
      )
      
      names(bottom_data)[3] <- paste(switch(input$map_variable,
                                            "POVERTY" = "Kemiskinan",
                                            "ILLITERATE" = "Buta Huruf", 
                                            "LOWEDU" = "Pendidikan Rendah"), "(%)")
    } else {
      bottom_data <- data.frame(
        Ranking = 1:10,
        Kabupaten_Kota = paste("Data tidak tersedia", 1:10),
        Nilai = rep(0, 10)
      )
    }
    
    DT::datatable(bottom_data, 
                  options = list(pageLength = 10, searching = FALSE, info = FALSE),
                  rownames = FALSE)
  })
  
  #Server uji Normalitas
  normality_values <- reactiveValues(
    completed = FALSE,
    test_result = NULL,
    variable = NULL,
    province = NULL,
    data_used = NULL,
    test_type = NULL
  )
  
  observe({
    province_choices <- c("Semua Provinsi" = "all",
                          setNames(sort(unique(data$PROVINCENAME)), sort(unique(data$PROVINCENAME))))
    updateSelectInput(session, "province_normalitas",
                      choices = province_choices,
                      selected = "all")
  })
  
  output$sample_info_box <- renderUI({
    req(input$var_normalitas, input$province_normalitas)
    
    if(input$province_normalitas == "all") {
      filtered_data <- data
      location_text <- "Seluruh Indonesia"
    } else {
      filtered_data <- data %>% filter(PROVINCENAME == input$province_normalitas)
      location_text <- paste("Provinsi", input$province_normalitas)
    }
    
    sample_size <- nrow(filtered_data)
    test_method <- if(sample_size > 50) "Kolmogorov-Smirnov" else "Shapiro-Wilk"
    
    box_class <- if(sample_size > 50) "alert-primary" else "alert-success"
    
    HTML(paste0(
      '<div class="', box_class, '">',
      '<h6><i class="fa fa-info-circle"></i> Informasi Sampel</h6>',
      '<p><strong>Lokasi:</strong> ', location_text, '</p>',
      '<p><strong>Jumlah observasi:</strong> ', sample_size, '</p>',
      '<p><strong>Uji yang digunakan:</strong> ', test_method, '</p>',
      '<p><strong>Alasan:</strong> ',
      if(sample_size > 50) {
        'Sampel besar (> 50), menggunakan Kolmogorov-Smirnov'
      } else {
        'Sampel kecil (≤ 50), menggunakan Shapiro-Wilk'
      },
      '</p>',
      '</div>'
    ))
  })
  
  output$qq_plot_normalitas <- renderPlot({
    req(input$var_normalitas, input$province_normalitas)

    if(input$province_normalitas == "all") {
      filtered_data <- data
      title_suffix <- "- Seluruh Indonesia"
    } else {
      filtered_data <- data %>% filter(PROVINCENAME == input$province_normalitas)
      title_suffix <- paste("- Provinsi", input$province_normalitas)
    }
    
    var_data <- filtered_data[[input$var_normalitas]]
    sample_size <- length(var_data)
    
    ggplot(data.frame(sample = var_data), aes(sample = sample)) +
      stat_qq(color = "#2c7fb8", size = 2, alpha = 0.7) +
      stat_qq_line(color = "#d73027", linetype = "dashed", size = 1) +
      labs(
        title = paste("Q-Q Plot:", input$var_normalitas, title_suffix),
        subtitle = paste("n =", sample_size),
        x = "Theoretical Quantiles",
        y = "Sample Quantiles"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        panel.grid.minor = element_blank()
      )
  })
  
  output$hist_normalitas <- renderPlot({
    req(input$var_normalitas, input$province_normalitas)
    
    if(input$province_normalitas == "all") {
      filtered_data <- data
      title_suffix <- "- Seluruh Indonesia"
    } else {
      filtered_data <- data %>% filter(PROVINCENAME == input$province_normalitas)
      title_suffix <- paste("- Provinsi", input$province_normalitas)
    }
    
    var_data <- filtered_data[[input$var_normalitas]]
    sample_size <- length(var_data)
    
    ggplot(data.frame(x = var_data), aes(x = x)) +
      geom_histogram(aes(y = ..density..), bins = 30, fill = "#74c476",
                     color = "white", alpha = 0.8) +
      geom_density(color = "#d73027", size = 1.2) +
      stat_function(fun = dnorm,
                    args = list(mean = mean(var_data, na.rm = TRUE),
                                sd = sd(var_data, na.rm = TRUE)),
                    color = "#2c7fb8", size = 1.2, linetype = "dashed") +
      labs(
        title = paste("Histogram dan Kurva Normal:", input$var_normalitas, title_suffix),
        subtitle = paste("n =", sample_size),
        x = input$var_normalitas,
        y = "Density"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        panel.grid.minor = element_blank()
      )
  })
  
  output$normality_test_result <- renderPrint({
    req(input$run_test_normalitas > 0)
    
    isolate({
      if(input$province_normalitas == "all") {
        filtered_data <- data
        location_text <- "Seluruh Indonesia"
      } else {
        filtered_data <- data %>% filter(PROVINCENAME == input$province_normalitas)
        location_text <- paste("Provinsi", input$province_normalitas)
      }
      
      var_data <- filtered_data[[input$var_normalitas]]
      sample_size <- length(var_data)
      
      cat("UJI NORMALITAS DINAMIS\n")
      cat("======================\n\n")
      
      cat("Variabel:", input$var_normalitas, "\n")
      cat("Lokasi:", location_text, "\n")
      cat("Jumlah observasi:", sample_size, "\n\n")
      
      if(sample_size > 50) {
        cat("MENGGUNAKAN UJI KOLMOGOROV-SMIRNOV\n")
        cat("(Sampel besar: n > 50)\n")
        cat("==================================\n\n")
        
        test_result <- ks.test(var_data, "pnorm",
                               mean = mean(var_data, na.rm = TRUE),
                               sd = sd(var_data, na.rm = TRUE))
        
        cat("Hipotesis:\n")
        cat("H₀: Data berdistribusi normal\n")
        cat("H₁: Data tidak berdistribusi normal\n\n")
        
        cat("Hasil Uji Kolmogorov-Smirnov:\n")
        cat("D-statistik:", round(test_result$statistic, 6), "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n\n")
        
        test_type <- "Kolmogorov-Smirnov"
        
      } else {
        cat("MENGGUNAKAN UJI SHAPIRO-WILK\n")
        cat("(Sampel kecil: n ≤ 50)\n")
        cat("=============================\n\n")
        
        test_result <- shapiro.test(var_data)
        
        cat("Hipotesis:\n")
        cat("H₀: Data berdistribusi normal\n")
        cat("H₁: Data tidak berdistribusi normal\n\n")
        
        cat("Hasil Uji Shapiro-Wilk:\n")
        cat("W-statistik:", round(test_result$statistic, 6), "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n\n")
        
        test_type <- "Shapiro-Wilk"
      }
      
      cat("Keputusan (α = 0.05):\n")
      if(test_result$p.value > 0.05) {
        cat("GAGAL TOLAK H₀\n")
        cat("Kesimpulan: Data berdistribusi normal ✓\n")
      } else {
        cat("TOLAK H₀\n")
        cat("Kesimpulan: Data TIDAK berdistribusi normal ✗\n")
      }
      
      normality_values$test_result <- test_result
      normality_values$variable <- input$var_normalitas
      normality_values$province <- input$province_normalitas
      normality_values$data_used <- filtered_data
      normality_values$test_type <- test_type
      normality_values$completed <- TRUE
    })
  })
  output$normality_interpretation <- renderUI({
    req(input$run_test_normalitas > 0)
    
    isolate({
      if(input$province_normalitas == "all") {
        filtered_data <- data
        location_text <- "seluruh Indonesia"
      } else {
        filtered_data <- data %>% filter(PROVINCENAME == input$province_normalitas)
        location_text <- paste("Provinsi", input$province_normalitas)
      }
      
      var_data <- filtered_data[[input$var_normalitas]]
      sample_size <- length(var_data)
      
      if(sample_size > 50) {
        test_result <- ks.test(var_data, "pnorm",
                               mean = mean(var_data, na.rm = TRUE),
                               sd = sd(var_data, na.rm = TRUE))
        test_name <- "Kolmogorov-Smirnov"
      } else {
        test_result <- shapiro.test(var_data)
        test_name <- "Shapiro-Wilk"
      }
      
      is_normal <- test_result$p.value > 0.05
      status_class <- if(is_normal) "decision-box" else "interpretation-box"
      status_icon <- if(is_normal) "check-circle" else "times-circle"
      status_text <- if(is_normal) "NORMAL" else "TIDAK NORMAL"
      
      var_name <- switch(input$var_normalitas,
                         "POVERTY" = "kemiskinan",
                         "LOWEDU" = "pendidikan rendah",
                         "ILLITERATE" = "buta huruf")
      
      interpretation <- if(is_normal) {
        paste("Dari uji", test_name, "didapatkan bahwa data", var_name, "di", location_text, "MENGIKUTI distribusi normal. Asumsi normalitas terpenuhi untuk analisis parametrik.")
      } else {
        paste("Dari uji", test_name, "didapatkan bahwa data", var_name, "di", location_text, "TIDAK MENGIKUTI distribusi normal. Pertimbangkan transformasi data atau gunakan uji non-parametrik.")
      }
      
      test_explanation <- if(sample_size > 50) {
        paste("Uji Kolmogorov-Smirnov dipilih karena ukuran sampel besar (n =", sample_size, "> 50). Uji ini lebih sesuai untuk sampel besar dan memiliki hasil yang baik untuk mendeteksi penyimpangan dari normalitas.")
      } else {
        paste("Uji Shapiro-Wilk dipilih karena ukuran sampel kecil (n =", sample_size, "≤ 50). Uji ini merupakan uji normalitas yang sesuai untuk sampel kecil.")
      }
      
      HTML(paste0(
        '<div class="', status_class, '">',
        '<h5><i class="fa fa-', status_icon, '"></i> Status: ', status_text, '</h5>',
        '<p><strong>Uji yang digunakan:</strong> ', test_name, '</p>',
        '<p><strong>Ukuran sampel:</strong> ', sample_size, ' observasi</p>',
        '<p><strong>p-value:</strong> ', format(test_result$p.value, scientific = TRUE), '</p>',
        '<p><strong>Interpretasi:</strong> ', interpretation, '</p>',
        '<hr>',
        '<p><strong>Penjelasan Pemilihan Uji:</strong> ', test_explanation, '</p>',
        '</div>'
      ))
    })
  })
  
  output$download_normalitas_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Uji_Normalitas_", Sys.Date(), ".html")
    },
    content = function(file) {
      if(!normality_values$completed) {
        showNotification("Jalankan uji normalitas terlebih dahulu sebelum download!", type = "error")
        return()
      }
      
      tempReport <- file.path(tempdir(), "template_uji_normalitas.Rmd")
      file.copy("template_uji_normalitas.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        variable = normality_values$variable,
        province = normality_values$province,
        test_type = normality_values$test_type,
        data = normality_values$data_used
      )
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  #Uji Homogenitas
  homogeneity_values <- reactiveValues(
    completed = FALSE,
    test_result = NULL,
    variable = NULL,
    provinces = NULL,
    data_used = NULL
  )
  
  observe({
    province_choices <- setNames(sort(unique(data$PROVINCENAME)), sort(unique(data$PROVINCENAME)))
    updateCheckboxGroupInput(session, "provinces_homogenitas",
                             choices = province_choices,
                             selected = head(names(province_choices), 3))  # Select first 3 by default
  })
  
  output$sample_info_homogenitas <- renderUI({
    req(input$var_homogenitas, input$provinces_homogenitas)
    
    if(length(input$provinces_homogenitas) < 2) {
      return(HTML('<div class="alert alert-danger">
                <h6><i class="fa fa-exclamation-triangle"></i> Peringatan</h6>
                <p>Pilih minimal <strong>2 provinsi</strong> untuk uji homogenitas!</p>
                </div>'))
    }
    
    filtered_data <- data %>% filter(PROVINCENAME %in% input$provinces_homogenitas)
    
    total_obs <- nrow(filtered_data)
    num_provinces <- length(input$provinces_homogenitas)
    avg_per_province <- round(total_obs / num_provinces, 1)
    
    province_counts <- filtered_data %>%
      group_by(PROVINCENAME) %>%
      summarise(count = n(), .groups = 'drop')
    
    min_obs_per_province <- min(province_counts$count)
    
    box_class <- if(min_obs_per_province >= 2 && total_obs >= 6) "alert-success" else "alert-warning"
    
    HTML(paste0(
      '<div class="', box_class, '">',
      '<h6><i class="fa fa-info-circle"></i> Informasi Sampel</h6>',
      '<p><strong>Jumlah provinsi:</strong> ', num_provinces, '</p>',
      '<p><strong>Total observasi:</strong> ', total_obs, '</p>',
      '<p><strong>Rata-rata per provinsi:</strong> ', avg_per_province, '</p>',
      '<p><strong>Minimum per provinsi:</strong> ', min_obs_per_province, '</p>',
      '<p><strong>Status:</strong> ',
      if(min_obs_per_province >= 2 && total_obs >= 6) {
        '<span class="text-success">✓ Memenuhi syarat untuk uji Levene</span>'
      } else {
        '<span class="text-warning">⚠ Perlu minimal 2 obs per provinsi dan 6 total obs</span>'
      },
      '</p>',
      '</div>'
    ))
  })
  
  output$boxplot_homogenitas <- renderPlot({
    req(input$var_homogenitas, input$provinces_homogenitas)
    
    if(length(input$provinces_homogenitas) < 2) {
      return(ggplot() + 
               annotate("text", x = 0.5, y = 0.5, label = "Pilih minimal 2 provinsi", size = 6) +
               theme_void())
    }
    
    filtered_data <- data %>% filter(PROVINCENAME %in% input$provinces_homogenitas)
    
    var_data <- filtered_data[[input$var_homogenitas]]
    provinces_data <- filtered_data$PROVINCENAME
    
    plot_data <- data.frame(
      value = var_data,
      province = as.factor(provinces_data)
    )
    
    ggplot(plot_data, aes(x = province, y = value, fill = province)) +
      geom_boxplot(alpha = 0.7, outlier.color = "red", outlier.size = 2) +
      geom_jitter(width = 0.2, alpha = 0.5, size = 1.5) +
      scale_fill_brewer(type = "qual", palette = "Set2") +
      labs(
        title = paste("Boxplot", input$var_homogenitas, "berdasarkan Provinsi"),
        subtitle = paste("Perbandingan", length(input$provinces_homogenitas), "provinsi"),
        x = "Provinsi",
        y = paste(input$var_homogenitas, "(%)")
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.minor = element_blank()
      )
  })
  
  output$variance_plot_homogenitas <- renderPlot({
    req(input$var_homogenitas, input$provinces_homogenitas)
    
    if(length(input$provinces_homogenitas) < 2) {
      return(ggplot() + 
               annotate("text", x = 0.5, y = 0.5, label = "Pilih minimal 2 provinsi", size = 6) +
               theme_void())
    }
    
    filtered_data <- data %>% filter(PROVINCENAME %in% input$provinces_homogenitas)

    variance_data <- filtered_data %>%
      group_by(PROVINCENAME) %>%
      summarise(
        Variance = var(.data[[input$var_homogenitas]], na.rm = TRUE),
        Count = n(),
        .groups = 'drop'
      ) %>%
      arrange(desc(Variance))
    
    ggplot(variance_data, aes(x = reorder(PROVINCENAME, Variance), y = Variance, fill = PROVINCENAME)) +
      geom_col(alpha = 0.8) +
      geom_text(aes(label = paste0(round(Variance, 2), "\n(n=", Count, ")")),
                hjust = -0.1, fontface = "bold", size = 3) +
      scale_fill_brewer(type = "qual", palette = "Set1") +
      coord_flip() +
      labs(
        title = "Perbandingan Varians antar Provinsi",
        subtitle = paste("Variabel:", input$var_homogenitas),
        x = "Provinsi",
        y = "Varians"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        legend.position = "none",
        panel.grid.minor = element_blank()
      )
  })
  

  output$homogeneity_test_result <- renderPrint({
    req(input$run_test_homogenitas > 0)
    
    isolate({
      if(length(input$provinces_homogenitas) < 2) {
        cat("ERROR: Pilih minimal 2 provinsi untuk uji homogenitas!\n")
        return()
      }

      filtered_data <- data %>% filter(PROVINCENAME %in% input$provinces_homogenitas)
      
      if(nrow(filtered_data) < 6) {
        cat("ERROR: Data tidak mencukupi untuk uji Levene (minimal 6 observasi total)!\n")
        return()
      }
      
      var_data <- filtered_data[[input$var_homogenitas]]
      provinces_factor <- as.factor(filtered_data$PROVINCENAME)
      
      cat("UJI HOMOGENITAS VARIANS (LEVENE TEST)\n")
      cat("=====================================\n\n")
      
      cat("Variabel:", input$var_homogenitas, "\n")
      cat("Provinsi yang dibandingkan:", paste(input$provinces_homogenitas, collapse = ", "), "\n")
      cat("Jumlah provinsi:", length(input$provinces_homogenitas), "\n")
      cat("Total observasi:", length(var_data), "\n\n")
      
      cat("STATISTIK DESKRIPTIF PER PROVINSI\n")
      cat("==================================\n")
      stats_summary <- filtered_data %>%
        group_by(PROVINCENAME) %>%
        summarise(
          N = n(),
          Mean = round(mean(.data[[input$var_homogenitas]], na.rm = TRUE), 4),
          Variance = round(var(.data[[input$var_homogenitas]], na.rm = TRUE), 4),
          Std_Dev = round(sd(.data[[input$var_homogenitas]], na.rm = TRUE), 4),
          .groups = 'drop'
        ) %>%
        arrange(desc(Variance))
      
      for(i in 1:nrow(stats_summary)) {
        cat(sprintf("%-20s: n=%2d, Mean=%8.4f, Var=%8.4f, SD=%8.4f\n",
                    stats_summary$PROVINCENAME[i],
                    stats_summary$N[i],
                    stats_summary$Mean[i],
                    stats_summary$Variance[i],
                    stats_summary$Std_Dev[i]))
      }
      
      cat("\nHipotesis:\n")
      cat("H₀: σ₁² = σ₂² = σ₃² = ... (Varians antar provinsi homogen)\n")
      cat("H₁: Minimal ada satu varians yang berbeda\n\n")
      
      tryCatch({
        library(car)
        levene_result <- leveneTest(var_data, provinces_factor)
        
        cat("HASIL UJI LEVENE\n")
        cat("================\n")
        cat("F-statistik:", round(levene_result$`F value`[1], 6), "\n")
        cat("df1 (between groups):", levene_result$Df[1], "\n")
        cat("df2 (within groups):", levene_result$Df[2], "\n")
        cat("p-value:", format(levene_result$`Pr(>F)`[1], scientific = TRUE), "\n\n")
        
        cat("Keputusan (α = 0.05):\n")
        if(levene_result$`Pr(>F)`[1] > 0.05) {
          cat("GAGAL TOLAK H₀\n")
          cat("Kesimpulan: Varians antar provinsi HOMOGEN ✓\n")
        } else {
          cat("TOLAK H₀\n")
          cat("Kesimpulan: Varians antar provinsi TIDAK HOMOGEN ✗\n")
        }
        
        homogeneity_values$test_result <- levene_result
        homogeneity_values$variable <- input$var_homogenitas
        homogeneity_values$provinces <- input$provinces_homogenitas
        homogeneity_values$data_used <- filtered_data
        homogeneity_values$completed <- TRUE
        
      }, error = function(e) {
        cat("ERROR dalam perhitungan uji Levene:", e$message, "\n")
        homogeneity_values$completed <- FALSE
      })
    })
  })

  output$homogeneity_interpretation <- renderUI({
    req(input$run_test_homogenitas > 0)
    
    isolate({
      if(length(input$provinces_homogenitas) < 2) {
        return(HTML('<div class="alert alert-danger">
                  <h5><i class="fa fa-times-circle"></i> Error</h5>
                  <p>Pilih minimal 2 provinsi untuk uji homogenitas!</p>
                  </div>'))
      }
      
      filtered_data <- data %>% filter(PROVINCENAME %in% input$provinces_homogenitas)
      
      if(nrow(filtered_data) < 6) {
        return(HTML('<div class="alert alert-warning">
                  <h5><i class="fa fa-exclamation-triangle"></i> Data Tidak Mencukupi</h5>
                  <p>Minimal 6 observasi total diperlukan untuk uji Levene!</p>
                  </div>'))
      }
      
      var_data <- filtered_data[[input$var_homogenitas]]
      provinces_factor <- as.factor(filtered_data$PROVINCENAME)
      
      tryCatch({
        library(car)
        levene_result <- leveneTest(var_data, provinces_factor)
        
        is_homogen <- levene_result$`Pr(>F)`[1] > 0.05
        status_class <- if(is_homogen) "decision-box" else "interpretation-box"
        status_icon <- if(is_homogen) "check-circle" else "times-circle"
        status_text <- if(is_homogen) "HOMOGEN" else "TIDAK HOMOGEN"
        

        var_name <- switch(input$var_homogenitas,
                           "POVERTY" = "kemiskinan",
                           "LOWEDU" = "pendidikan rendah",
                           "ILLITERATE" = "buta huruf")
        
        interpretation <- if(is_homogen) {
          paste("Dari uji Levene didapatkan bahwa varians", var_name, "antar provinsi yang dipilih HOMOGEN. Asumsi homogenitas varians terpenuhi untuk analisis parametrik seperti ANOVA.")
        } else {
          paste("Dari uji Levene didapatkan bahwa varians", var_name, "antar provinsi yang dipilih TIDAK HOMOGEN. Pertimbangkan transformasi data atau gunakan uji yang tidak mengasumsikan varians homogen (uji non-parametrik).")
        }
        
        variance_data <- filtered_data %>%
          group_by(PROVINCENAME) %>%
          summarise(
            Variance = var(.data[[input$var_homogenitas]], na.rm = TRUE),
            .groups = 'drop'
          ) %>%
          arrange(desc(Variance))
        
        max_var <- variance_data$Variance[1]
        min_var <- variance_data$Variance[nrow(variance_data)]
        var_ratio <- round(max_var / min_var, 2)
        
        HTML(paste0(
          '<div class="', status_class, '">',
          '<h5><i class="fa fa-', status_icon, '"></i> Status: ', status_text, '</h5>',
          '<p><strong>Jumlah provinsi:</strong> ', length(input$provinces_homogenitas), '</p>',
          '<p><strong>Total observasi:</strong> ', length(var_data), '</p>',
          '<p><strong>F-statistik:</strong> ', round(levene_result$`F value`[1], 4), '</p>',
          '<p><strong>p-value:</strong> ', format(levene_result$`Pr(>F)`[1], scientific = TRUE), '</p>',
          '<p><strong>Interpretasi:</strong> ', interpretation, '</p>',
          '<hr>',
          '<p><strong>Analisis Varians:</strong></p>',
          '<p>• Varians tertinggi: ', variance_data$PROVINCENAME[1], ' (', round(max_var, 4), ')</p>',
          '<p>• Varians terendah: ', variance_data$PROVINCENAME[nrow(variance_data)], ' (', round(min_var, 4), ')</p>',
          '<p>• Rasio varians: ', var_ratio, if(var_ratio > 4) ' <span class="text-warning">(⚠ Sangat heterogen)</span>' else '', '</p>',
          '</div>'
        ))
        
      }, error = function(e) {
        HTML(paste0('<div class="alert alert-danger">
                  <h5><i class="fa fa-times-circle"></i> Error</h5>
                  <p>Terjadi kesalahan dalam perhitungan: ', e$message, '</p>
                  </div>'))
      })
    })
  })
  
  output$download_homogenitas_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Uji_Homogenitas_", Sys.Date(), ".html")
    },
    content = function(file) {
      if(!homogeneity_values$completed) {
        showNotification("Jalankan uji homogenitas terlebih dahulu sebelum download!", type = "error")
        return()
      }
      
      tempReport <- file.path(tempdir(), "template_uji_homogenitas.Rmd")
      file.copy("template_uji_homogenitas.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        variable = homogeneity_values$variable,
        provinces = homogeneity_values$provinces,
        data = homogeneity_values$data_used
      )
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  #Server Uji Rata-rata
  mean_values <- reactiveValues(
    completed = FALSE,
    test_result = NULL,
    test_type = NULL,
    variable = NULL,
    data_used = NULL
  )

  observe({
    province_choices <- sort(unique(data$PROVINCENAME))
    updateSelectInput(session, "province1_mean", choices = province_choices, selected = province_choices[1])
    updateSelectInput(session, "province2_mean", choices = province_choices, selected = province_choices[2])
  })

  output$test_info_mean <- renderUI({
    req(input$test_type_mean, input$variable_mean)
    
    var_name <- switch(input$variable_mean,
                       "POVERTY" = "Kemiskinan",
                       "LOWEDU" = "Pendidikan Rendah",
                       "ILLITERATE" = "Buta Huruf")
    
    if(input$test_type_mean == "one_sample") {
      info_text <- paste("Uji satu sampel untuk menguji apakah rata-rata", var_name,
                         "berbeda dari nilai hipotesis yang ditentukan.")
    } else {
      info_text <- paste("Uji dua sampel untuk membandingkan rata-rata", var_name,
                         "antara dua provinsi yang dipilih.")
    }
    
    HTML(paste0(
      '<div class="alert alert-info">',
      '<h5><i class="fa fa-info-circle"></i> Informasi Uji</h5>',
      '<p>', info_text, '</p>',
      '<p><strong>Catatan:</strong> Uji t digunakan jika n < 30, uji z jika n ≥ 30 (untuk dua sampel).</p>',
      '</div>'
    ))
  })
  
  output$hypothesis_mean <- renderUI({
    req(input$test_type_mean, input$variable_mean)
    
    var_name <- switch(input$variable_mean,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    if(input$test_type_mean == "one_sample") {
      req(input$mu0_mean, input$alternative_mean_one)
      
      h0_text <- paste("H₀: μ =", input$mu0_mean, "(Rata-rata", var_name, "sama dengan", input$mu0_mean, "%)")
      
      h1_text <- switch(input$alternative_mean_one,
                        "two.sided" = paste("H₁: μ ≠", input$mu0_mean, "(Rata-rata", var_name, "tidak sama dengan", input$mu0_mean, "%)"),
                        "less" = paste("H₁: μ <", input$mu0_mean, "(Rata-rata", var_name, "kurang dari", input$mu0_mean, "%)"),
                        "greater" = paste("H₁: μ >", input$mu0_mean, "(Rata-rata", var_name, "lebih dari", input$mu0_mean, "%)"))
      
    } else {
      req(input$province1_mean, input$province2_mean, input$alternative_mean_two)
      
      h0_text <- paste("H₀: μ₁ = μ₂ (Rata-rata", var_name, "di", input$province1_mean, "sama dengan di", input$province2_mean, ")")
      
      h1_text <- switch(input$alternative_mean_two,
                        "two.sided" = paste("H₁: μ₁ ≠ μ₂ (Rata-rata", var_name, "di", input$province1_mean, "tidak sama dengan di", input$province2_mean, ")"),
                        "less" = paste("H₁: μ₁ < μ₂ (Rata-rata", var_name, "di", input$province1_mean, "kurang dari di", input$province2_mean, ")"),
                        "greater" = paste("H₁: μ₁ > μ₂ (Rata-rata", var_name, "di", input$province1_mean, "lebih dari di", input$province2_mean, ")"))
    }
    
    HTML(paste0(
      '<div class="hypothesis-box">',
      '<h5><i class="fa fa-question-circle"></i> Hipotesis:</h5>',
      '<p><strong>', h0_text, '</strong></p>',
      '<p><strong>', h1_text, '</strong></p>',
      '</div>'
    ))
  })
  
  output$test_result_mean <- renderPrint({
    req(input$run_test_mean)
    
    isolate({
      if(input$test_type_mean == "one_sample") {
        req(input$variable_mean, input$mu0_mean, input$alternative_mean_one)
        
        var_data <- data[[input$variable_mean]]
        
        cat("UJI T SATU SAMPEL\n")
        cat("================\n\n")
        
        test_result <- t.test(var_data, mu = input$mu0_mean, alternative = input$alternative_mean_one)
        
        cat("Data Summary:\n")
        cat("Jumlah observasi (n):", length(var_data), "\n")
        cat("Rata-rata sampel (x̄):", round(mean(var_data), 4), "\n")
        cat("Standar deviasi (s):", round(sd(var_data), 4), "\n")
        cat("Standard error:", round(sd(var_data)/sqrt(length(var_data)), 4), "\n\n")
        
        cat("Hasil Uji t:\n")
        cat("t-statistik:", round(test_result$statistic, 4), "\n")
        cat("df (derajat bebas):", test_result$parameter, "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n")
        
        if(input$alternative_mean_one == "two.sided") {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to", round(test_result$conf.int[2], 4), "\n\n")
        } else if(input$alternative_mean_one == "less") {
          cat("Confidence interval (95%): -Inf to", round(test_result$conf.int[2], 4), "\n\n")
        } else {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to Inf\n\n")
        }
        
        cat("Keputusan (α = 0.05):\n")
        if(test_result$p.value < 0.05) {
          cat("TOLAK H₀ - Ada bukti yang cukup untuk mendukung H₁\n")
        } else {
          cat("GAGAL TOLAK H₀ - Tidak ada bukti yang cukup untuk mendukung H₁\n")
        }
        
      } else {
        req(input$variable_mean, input$province1_mean, input$province2_mean, input$alternative_mean_two)
        
        data1 <- data %>% filter(PROVINCENAME == input$province1_mean) %>% pull(input$variable_mean)
        data2 <- data %>% filter(PROVINCENAME == input$province2_mean) %>% pull(input$variable_mean)
        
        if(length(data1) == 0 || length(data2) == 0) {
          cat("Data tidak tersedia untuk salah satu atau kedua provinsi.\n")
          return()
        }
        
        n1 <- length(data1)
        n2 <- length(data2)
        
        if(n1 >= 30 && n2 >= 30) {
          test_type <- "UJI Z DUA SAMPEL"
          cat(test_type, "\n")
          cat("================\n\n")
          
          test_result <- t.test(data1, data2, alternative = input$alternative_mean_two, var.equal = FALSE)
          
          cat("Catatan: Menggunakan uji t yang mendekati distribusi z untuk sampel besar\n\n")
        } else {
          test_type <- "UJI T DUA SAMPEL"
          cat(test_type, "\n")
          cat("================\n\n")
          
          test_result <- t.test(data1, data2, alternative = input$alternative_mean_two, var.equal = FALSE)
        }
        
        cat("Data Summary:\n")
        cat(input$province1_mean, "- n:", n1, ", mean:", round(mean(data1), 4), ", sd:", round(sd(data1), 4), "\n")
        cat(input$province2_mean, "- n:", n2, ", mean:", round(mean(data2), 4), ", sd:", round(sd(data2), 4), "\n\n")
        
        cat("Hasil Uji:\n")
        cat("t-statistik:", round(test_result$statistic, 4), "\n")
        cat("df:", round(test_result$parameter, 2), "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n")
        
        if(input$alternative_mean_two == "two.sided") {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to", round(test_result$conf.int[2], 4), "\n\n")
        } else if(input$alternative_mean_two == "less") {
          cat("Confidence interval (95%): -Inf to", round(test_result$conf.int[2], 4), "\n\n")
        } else {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to Inf\n\n")
        }
        
        cat("Keputusan (α = 0.05):\n")
        if(test_result$p.value < 0.05) {
          cat("TOLAK H₀ - Ada perbedaan signifikan antara kedua provinsi\n")
        } else {
          cat("GAGAL TOLAK H₀ - Tidak ada perbedaan signifikan antara kedua provinsi\n")
        }
      }
      mean_values$test_result <- test_result
      mean_values$test_type <- input$test_type_mean
      mean_values$variable <- input$variable_mean
      mean_values$data_used <- data
      mean_values$completed <- TRUE
    })
  })
  
  output$descriptive_mean <- renderPrint({
    req(input$run_test_mean)
    
    isolate({
      if(input$test_type_mean == "one_sample") {
        var_data <- data[[input$variable_mean]]
        
        cat("STATISTIK DESKRIPTIF\n")
        cat("===================\n\n")
        cat("N:", length(var_data), "\n")
        cat("Mean:", round(mean(var_data), 4), "\n")
        cat("Median:", round(median(var_data), 4), "\n")
        cat("Std Dev:", round(sd(var_data), 4), "\n")
        cat("Min:", round(min(var_data), 4), "\n")
        cat("Max:", round(max(var_data), 4), "\n")
        cat("Q1:", round(quantile(var_data, 0.25), 4), "\n")
        cat("Q3:", round(quantile(var_data, 0.75), 4), "\n")
        
      } else {
        data1 <- data %>% filter(PROVINCENAME == input$province1_mean) %>% pull(input$variable_mean)
        data2 <- data %>% filter(PROVINCENAME == input$province2_mean) %>% pull(input$variable_mean)
        
        cat("STATISTIK DESKRIPTIF\n")
        cat("===================\n\n")
        cat(input$province1_mean, ":\n")
        cat("  N:", length(data1), "\n")
        cat("  Mean:", round(mean(data1), 4), "\n")
        cat("  Std Dev:", round(sd(data1), 4), "\n\n")
        
        cat(input$province2_mean, ":\n")
        cat("  N:", length(data2), "\n")
        cat("  Mean:", round(mean(data2), 4), "\n")
        cat("  Std Dev:", round(sd(data2), 4), "\n")
      }
    })
  })
  
  output$interpretation_mean <- renderUI({
    req(input$run_test_mean)
    
    isolate({
      var_name <- switch(input$variable_mean,
                         "POVERTY" = "kemiskinan",
                         "LOWEDU" = "pendidikan rendah",
                         "ILLITERATE" = "buta huruf")
      
      if(input$test_type_mean == "one_sample") {
        var_data <- data[[input$variable_mean]]
        test_result <- t.test(var_data, mu = input$mu0_mean, alternative = input$alternative_mean_one)
        
        mean_val <- round(mean(var_data), 2)
        is_significant <- test_result$p.value < 0.05
        
        decision_class <- if(is_significant) "decision-box" else "interpretation-box"
        
        decision_text <- if(is_significant) {
          direction <- switch(input$alternative_mean_one,
                              "two.sided" = "berbeda secara signifikan dari",
                              "less" = "secara signifikan kurang dari",
                              "greater" = "secara signifikan lebih dari")
          paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Rata-rata", var_name, "(", mean_val, "%)", direction, input$mu0_mean, "%.")
        } else {
          paste("Dengan tingkat signifikansi 5%, kita GAGAL MENOLAK H₀. Tidak ada bukti yang cukup bahwa rata-rata", var_name, "(", mean_val, "%) berbeda dari", input$mu0_mean, "%.")
        }
        
      } else {
        data1 <- data %>% filter(PROVINCENAME == input$province1_mean) %>% pull(input$variable_mean)
        data2 <- data %>% filter(PROVINCENAME == input$province2_mean) %>% pull(input$variable_mean)
        
        test_result <- t.test(data1, data2, alternative = input$alternative_mean_two, var.equal = FALSE)
        
        mean1 <- round(mean(data1), 2)
        mean2 <- round(mean(data2), 2)
        is_significant <- test_result$p.value < 0.05
        
        decision_class <- if(is_significant) "decision-box" else "interpretation-box"
        
        decision_text <- if(is_significant) {
          direction <- switch(input$alternative_mean_two,
                              "two.sided" = "berbeda secara signifikan",
                              "less" = paste("di", input$province1_mean, "secara signifikan lebih rendah daripada di", input$province2_mean),
                              "greater" = paste("di", input$province1_mean, "secara signifikan lebih tinggi daripada di", input$province2_mean))
          
          if(input$alternative_mean_two == "two.sided") {
            paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Rata-rata", var_name, "di", input$province1_mean, "(", mean1, "%) dan", input$province2_mean, "(", mean2, "%)", direction, ".")
          } else {
            paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Rata-rata", var_name, direction, ".")
          }
        } else {
          paste("Dengan tingkat signifikansi 5%, kita GAGAL MENOLAK H₀. Tidak ada perbedaan yang signifikan dalam rata-rata", var_name, "antara", input$province1_mean, "(", mean1, "%) dan", input$province2_mean, "(", mean2, "%).")
        }
      }
      
      practical_interpretation <- if(input$test_type_mean == "one_sample") {
        if(is_significant) {
          paste("Hasil ini menunjukkan bahwa kondisi", var_name, "di Indonesia berbeda dari nilai yang diuji (", input$mu0_mean, "%), sehingga perlu di uji dengan nilai yang lain.")
        } else {
          paste("Hasil ini menunjukkan bahwa kondisi", var_name, "di Indonesia sesuai dengan nilai yang diuji (", input$mu0_mean, "%).")
        }
      } else {
        if(is_significant) {
          paste("Hasil ini menunjukkan bahwa kondisi", var_name, "di kedua provinsi berbeda secara signifikan, sehingga memerlukan pendekatan kebijakan yang disesuaikan dengan kondisi spesifik masing-masing daerah.")
        } else {
          paste("Hasil ini menunjukkan bahwa kondisi", var_name, "di kedua provinsi relatif serupa, sehingga dapat menggunakan pendekatan kebijakan yang sama.")
        }
      }
      
      HTML(paste0(
        '<div class="', decision_class, '">',
        '<h5><i class="fa fa-gavel"></i> Keputusan dan Interpretasi:</h5>',
        '<p><strong>Keputusan:</strong> ', decision_text, '</p>',
        '<p><strong>Interpretasi Praktis:</strong> ', practical_interpretation, '</p>',
        '</div>'
      ))
    })
  })
  
  output$download_mean_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Uji_Rata_rata_", Sys.Date(), ".html")
    },
    content = function(file) {
      if(!mean_values$completed) {
        showNotification("Jalankan uji rata-rata terlebih dahulu sebelum download!", type = "error")
        return()
      }
      
      tempReport <- file.path(tempdir(), "template_uji_rata_rata.Rmd")
      file.copy("template_uji_rata_rata.Rmd", tempReport, overwrite = TRUE)
      params <- list(
        test_type = mean_values$test_type,
        variable = mean_values$variable,
        mu0 = if(mean_values$test_type == "one_sample") input$mu0_mean else NULL,
        alternative_one = if(mean_values$test_type == "one_sample") input$alternative_mean_one else NULL,
        province1 = if(mean_values$test_type == "two_sample") input$province1_mean else NULL,
        province2 = if(mean_values$test_type == "two_sample") input$province2_mean else NULL,
        alternative_two = if(mean_values$test_type == "two_sample") input$alternative_mean_two else NULL,
        data = mean_values$data_used
      )
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  #Server Uji Proporsi
  proportion_values <- reactiveValues(
    completed = FALSE,
    test_result = NULL,
    test_type = NULL,
    variable = NULL,
    status = NULL,
    data_used = NULL
  )
  
  observe({
    province_choices <- sort(unique(data$PROVINCENAME))
    updateSelectInput(session, "province1_prop", choices = province_choices, selected = province_choices[1])
    updateSelectInput(session, "province2_prop", choices = province_choices, selected = province_choices[2])
  })
  
  observe({
    req(input$variable_prop)
    
    if(input$variable_prop %in% names(data)) {
      available_levels <- levels(as.factor(data[[input$variable_prop]]))
      if(length(available_levels) > 0) {
        updateSelectInput(session, "status_prop", choices = available_levels, selected = available_levels[1])
      }
    } else {
      updateSelectInput(session, "status_prop", 
                        choices = c("Rendah" = "Rendah", "Sedang" = "Sedang", "Tinggi" = "Tinggi"),
                        selected = "Tinggi")
    }
  })
  
  output$test_info_prop <- renderUI({
    req(input$test_type_prop, input$variable_prop, input$status_prop)
    
    var_name <- switch(input$variable_prop,
                       "LOWEDU_CAT" = "Pendidikan Rendah",
                       "POVERTY_CAT" = "Kemiskinan", 
                       "ILLITERATE_CAT" = "Buta Huruf")
    
    if(input$test_type_prop == "one_sample") {
      info_text <- paste("Uji z untuk menguji apakah proporsi", var_name, "dengan status", input$status_prop,
                         "berbeda dari nilai hipotesis yang ditentukan.")
    } else {
      info_text <- paste("Uji z untuk membandingkan proporsi", var_name, "dengan status", input$status_prop,
                         "antara dua provinsi yang dipilih.")
    }
    
    var_exists <- input$variable_prop %in% names(data)
    
    warning_text <- if(!var_exists) {
      paste0('<div class="alert alert-warning">',
             '<strong>Peringatan:</strong> Variabel ', input$variable_prop, ' tidak ditemukan dalam data. ',
             'Silakan buat variabel kategorik terlebih dahulu di menu Manajemen Data.',
             '</div>')
    } else {
      ""
    }
    
    HTML(paste0(
      warning_text,
      '<div class="alert alert-info">',
      '<h5><i class="fa fa-info-circle"></i> Informasi Uji</h5>',
      '<p>', info_text, '</p>',
      '<p><strong>Catatan:</strong> Menggunakan uji z untuk proporsi dengan koreksi kontinuitas.</p>',
      '</div>'
    ))
  })
  
  output$hypothesis_prop <- renderUI({
    req(input$run_test_prop > 0)
    req(input$test_type_prop, input$variable_prop, input$status_prop)
    
    var_name <- switch(input$variable_prop,
                       "LOWEDU_CAT" = "pendidikan rendah",
                       "POVERTY_CAT" = "kemiskinan",
                       "ILLITERATE_CAT" = "buta huruf")
    
    if(input$test_type_prop == "one_sample") {
      req(input$p0_prop, input$alternative_prop_one)
      
      h0_text <- paste("H₀: p =", input$p0_prop, "(Proporsi", var_name, "dengan status", input$status_prop, "sama dengan", input$p0_prop, ")")
      
      h1_text <- switch(input$alternative_prop_one,
                        "two.sided" = paste("H₁: p ≠", input$p0_prop, "(Proporsi", var_name, "dengan status", input$status_prop, "tidak sama dengan", input$p0_prop, ")"),
                        "less" = paste("H₁: p <", input$p0_prop, "(Proporsi", var_name, "dengan status", input$status_prop, "kurang dari", input$p0_prop, ")"),
                        "greater" = paste("H₁: p >", input$p0_prop, "(Proporsi", var_name, "dengan status", input$status_prop, "lebih dari", input$p0_prop, ")"))
      
    } else {
      req(input$province1_prop, input$province2_prop, input$alternative_prop_two)
      
      h0_text <- paste("H₀: p₁ = p₂ (Proporsi", var_name, "dengan status", input$status_prop, "di", input$province1_prop, "sama dengan di", input$province2_prop, ")")
      
      h1_text <- switch(input$alternative_prop_two,
                        "two.sided" = paste("H₁: p₁ ≠ p₂ (Proporsi", var_name, "dengan status", input$status_prop, "di", input$province1_prop, "tidak sama dengan di", input$province2_prop, ")"),
                        "less" = paste("H₁: p₁ < p₂ (Proporsi", var_name, "dengan status", input$status_prop, "di", input$province1_prop, "kurang dari di", input$province2_prop, ")"),
                        "greater" = paste("H₁: p₁ > p₂ (Proporsi", var_name, "dengan status", input$status_prop, "di", input$province1_prop, "lebih dari di", input$province2_prop, ")"))
    }
    
    HTML(paste0(
      '<div class="hypothesis-box">',
      '<h5><i class="fa fa-question-circle"></i> Hipotesis:</h5>',
      '<p><strong>', h0_text, '</strong></p>',
      '<p><strong>', h1_text, '</strong></p>',
      '</div>'
    ))
  })
  
  output$test_result_prop <- renderPrint({
    req(input$run_test_prop > 0)
    
    isolate({
      proportion_values$completed <- FALSE
      
      if(!input$variable_prop %in% names(data)) {
        cat("VARIABEL TIDAK DITEMUKAN\n")
        cat("========================\n\n")
        cat("Variabel", input$variable_prop, "tidak ditemukan dalam data.\n")
        cat("Silakan buat variabel kategorik terlebih dahulu di menu Manajemen Data.\n")
        return()
      }
      
      if(input$test_type_prop == "one_sample") {
        req(input$variable_prop, input$status_prop, input$p0_prop, input$alternative_prop_one)
        
        var_data <- data[[input$variable_prop]]
        success_count <- sum(var_data == input$status_prop, na.rm = TRUE)
        total_count <- sum(!is.na(var_data))
        
        if(total_count == 0) {
          cat("Tidak ada data yang valid untuk analisis.\n")
          return()
        }
        
        cat("UJI Z PROPORSI SATU SAMPEL\n")
        cat("==========================\n\n")
        
        test_result <- prop.test(success_count, total_count, p = input$p0_prop, 
                                 alternative = input$alternative_prop_one, correct = TRUE)
        
        sample_prop <- success_count / total_count
        
        cat("Data Summary:\n")
        cat("Jumlah observasi total (n):", total_count, "\n")
        cat("Jumlah dengan status", paste0("'", input$status_prop, "'"), ":", success_count, "\n")
        cat("Proporsi sampel (p̂):", round(sample_prop, 4), "\n")
        cat("Proporsi hipotesis (p₀):", input$p0_prop, "\n\n")
        
        cat("Hasil Uji Z:\n")
        cat("Chi-square statistik:", round(test_result$statistic, 4), "\n")
        cat("df:", test_result$parameter, "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n")
        
        if(input$alternative_prop_one == "two.sided") {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to", round(test_result$conf.int[2], 4), "\n\n")
        }
        
        cat("Keputusan (α = 0.05):\n")
        if(test_result$p.value < 0.05) {
          cat("TOLAK H₀ - Ada bukti yang cukup untuk mendukung H₁\n")
        } else {
          cat("GAGAL TOLAK H₀ - Tidak ada bukti yang cukup untuk mendukung H₁\n")
        }
        
        proportion_values$test_result <- test_result
        proportion_values$test_type <- input$test_type_prop
        proportion_values$variable <- input$variable_prop
        proportion_values$status <- input$status_prop
        proportion_values$data_used <- data
        proportion_values$completed <- TRUE
        
      } else {
        req(input$variable_prop, input$status_prop, input$province1_prop, input$province2_prop, input$alternative_prop_two)
        
        if(input$province1_prop == input$province2_prop) {
          cat("ERROR: Pilih provinsi yang berbeda untuk perbandingan!\n")
          return()
        }
        
        data1 <- data %>% filter(PROVINCENAME == input$province1_prop) %>% pull(input$variable_prop)
        data2 <- data %>% filter(PROVINCENAME == input$province2_prop) %>% pull(input$variable_prop)
        
        if(length(data1) == 0 || length(data2) == 0) {
          cat("Data tidak tersedia untuk salah satu atau kedua provinsi.\n")
          return()
        }
        
        success1 <- sum(data1 == input$status_prop, na.rm = TRUE)
        total1 <- sum(!is.na(data1))
        success2 <- sum(data2 == input$status_prop, na.rm = TRUE)
        total2 <- sum(!is.na(data2))
        
        if(total1 == 0 || total2 == 0) {
          cat("Tidak ada data yang valid untuk salah satu atau kedua provinsi.\n")
          return()
        }
        
        cat("UJI Z PROPORSI DUA SAMPEL\n")
        cat("=========================\n\n")
        
        test_result <- prop.test(c(success1, success2), c(total1, total2), 
                                 alternative = input$alternative_prop_two, correct = TRUE)
        
        prop1 <- success1 / total1
        prop2 <- success2 / total2
        
        cat("Data Summary:\n")
        cat(input$province1_prop, "- n:", total1, ", sukses:", success1, ", proporsi:", round(prop1, 4), "\n")
        cat(input$province2_prop, "- n:", total2, ", sukses:", success2, ", proporsi:", round(prop2, 4), "\n\n")
        
        cat("Hasil Uji Z:\n")
        cat("Chi-square statistik:", round(test_result$statistic, 4), "\n")
        cat("df:", test_result$parameter, "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n")
        
        if(input$alternative_prop_two == "two.sided") {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to", round(test_result$conf.int[2], 4), "\n\n")
        }
        
        cat("Keputusan (α = 0.05):\n")
        if(test_result$p.value < 0.05) {
          cat("TOLAK H₀ - Ada perbedaan signifikan antara proporsi kedua provinsi\n")
        } else {
          cat("GAGAL TOLAK H₀ - Tidak ada perbedaan signifikan antara proporsi kedua provinsi\n")
        }
        
        proportion_values$test_result <- test_result
        proportion_values$test_type <- input$test_type_prop
        proportion_values$variable <- input$variable_prop
        proportion_values$status <- input$status_prop
        proportion_values$data_used <- data
        proportion_values$completed <- TRUE
      }
    })
  })
  
  output$descriptive_prop <- renderPrint({
    req(input$run_test_prop > 0)
    
    isolate({
      if(!input$variable_prop %in% names(data)) {
        cat("Variabel tidak ditemukan.\n")
        return()
      }
      
      if(input$test_type_prop == "one_sample") {
        var_data <- data[[input$variable_prop]]
        
        cat("STATISTIK DESKRIPTIF\n")
        cat("===================\n\n")

        freq_table <- table(var_data, useNA = "ifany")
        prop_table <- prop.table(freq_table)
        
        cat("Tabel Frekuensi:\n")
        for(i in 1:length(freq_table)) {
          cat(names(freq_table)[i], ":", freq_table[i], "(", round(prop_table[i] * 100, 2), "%)\n")
        }
        
        cat("\nTotal observasi:", sum(freq_table), "\n")
        
      } else {
        data1 <- data %>% filter(PROVINCENAME == input$province1_prop) %>% pull(input$variable_prop)
        data2 <- data %>% filter(PROVINCENAME == input$province2_prop) %>% pull(input$variable_prop)
        
        cat("STATISTIK DESKRIPTIF\n")
        cat("===================\n\n")
        
        cat(input$province1_prop, ":\n")
        freq1 <- table(data1, useNA = "ifany")
        prop1 <- prop.table(freq1)
        for(i in 1:length(freq1)) {
          cat("  ", names(freq1)[i], ":", freq1[i], "(", round(prop1[i] * 100, 2), "%)\n")
        }
        cat("  Total:", sum(freq1), "\n\n")
        
        cat(input$province2_prop, ":\n")
        freq2 <- table(data2, useNA = "ifany")
        prop2 <- prop.table(freq2)
        for(i in 1:length(freq2)) {
          cat("  ", names(freq2)[i], ":", freq2[i], "(", round(prop2[i] * 100, 2), "%)\n")
        }
        cat("  Total:", sum(freq2), "\n")
      }
    })
  })
  
  output$interpretation_prop <- renderUI({
    req(input$run_test_prop > 0)
    
    isolate({
      if(!input$variable_prop %in% names(data)) {
        return(HTML('<div class="interpretation-box">
                  <h5><i class="fa fa-exclamation-triangle"></i> Variabel Tidak Ditemukan</h5>
                  <p>Variabel kategorik yang dipilih tidak tersedia dalam data.</p>
                  <p>Silakan buat variabel kategorik terlebih dahulu di menu <strong>Manajemen Data</strong>.</p>
                  </div>'))
      }
      
      var_name <- switch(input$variable_prop,
                         "LOWEDU_CAT" = "pendidikan rendah",
                         "POVERTY_CAT" = "kemiskinan",
                         "ILLITERATE_CAT" = "buta huruf")
      
      if(input$test_type_prop == "one_sample") {
        var_data <- data[[input$variable_prop]]
        success_count <- sum(var_data == input$status_prop, na.rm = TRUE)
        total_count <- sum(!is.na(var_data))
        
        if(total_count == 0) {
          return(HTML('<div class="interpretation-box">
                    <h5><i class="fa fa-exclamation-triangle"></i> Data Tidak Valid</h5>
                    <p>Tidak ada data yang valid untuk analisis.</p>
                    </div>'))
        }
        
        test_result <- prop.test(success_count, total_count, p = input$p0_prop, 
                                 alternative = input$alternative_prop_one, correct = TRUE)
        
        sample_prop <- round(success_count / total_count, 3)
        is_significant <- test_result$p.value < 0.05
        
        decision_class <- if(is_significant) "decision-box" else "interpretation-box"
        
        decision_text <- if(is_significant) {
          direction <- switch(input$alternative_prop_one,
                              "two.sided" = "berbeda secara signifikan dari",
                              "less" = "secara signifikan kurang dari", 
                              "greater" = "secara signifikan lebih dari")
          paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Proporsi", var_name, "dengan status", input$status_prop, "(", sample_prop, ")", direction, input$p0_prop, ".")
        } else {
          paste("Dengan tingkat signifikansi 5%, kita GAGAL MENOLAK H₀. Tidak ada bukti yang cukup bahwa proporsi", var_name, "dengan status", input$status_prop, "(", sample_prop, ") berbeda dari", input$p0_prop, ".")
        }
        
      } else {
        data1 <- data %>% filter(PROVINCENAME == input$province1_prop) %>% pull(input$variable_prop)
        data2 <- data %>% filter(PROVINCENAME == input$province2_prop) %>% pull(input$variable_prop)
        
        success1 <- sum(data1 == input$status_prop, na.rm = TRUE)
        total1 <- sum(!is.na(data1))
        success2 <- sum(data2 == input$status_prop, na.rm = TRUE)
        total2 <- sum(!is.na(data2))
        
        if(total1 == 0 || total2 == 0) {
          return(HTML('<div class="interpretation-box">
                    <h5><i class="fa fa-exclamation-triangle"></i> Data Tidak Valid</h5>
                    <p>Tidak ada data yang valid untuk salah satu atau kedua provinsi.</p>
                    </div>'))
        }
        
        test_result <- prop.test(c(success1, success2), c(total1, total2), 
                                 alternative = input$alternative_prop_two, correct = TRUE)
        
        prop1 <- round(success1 / total1, 3)
        prop2 <- round(success2 / total2, 3)
        is_significant <- test_result$p.value < 0.05
        
        decision_class <- if(is_significant) "decision-box" else "interpretation-box"
        
        decision_text <- if(is_significant) {
          direction <- switch(input$alternative_prop_two,
                              "two.sided" = "berbeda secara signifikan",
                              "less" = paste("di", input$province1_prop, "secara signifikan lebih rendah daripada di", input$province2_prop),
                              "greater" = paste("di", input$province1_prop, "secara signifikan lebih tinggi daripada di", input$province2_prop))
          
          if(input$alternative_prop_two == "two.sided") {
            paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Proporsi", var_name, "dengan status", input$status_prop, "di", input$province1_prop, "(", prop1, ") dan", input$province2_prop, "(", prop2, ")", direction, ".")
          } else {
            paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Proporsi", var_name, "dengan status", input$status_prop, direction, ".")
          }
        } else {
          paste("Dengan tingkat signifikansi 5%, kita GAGAL MENOLAK H₀. Tidak ada perbedaan yang signifikan dalam proporsi", var_name, "dengan status", input$status_prop, "antara", input$province1_prop, "(", prop1, ") dan", input$province2_prop, "(", prop2, ").")
        }
      }
      
      practical_interpretation <- if(input$test_type_prop == "one_sample") {
        if(is_significant) {
          paste("Hasil ini menunjukkan bahwa proporsi", var_name, "dengan status", input$status_prop, "di Indonesia berbeda dari nilai yang diuji, sehingga perlu diuji dengan nilai yang lain.")
        } else {
          paste("Hasil ini menunjukkan bahwa proporsi", var_name, "dengan status", input$status_prop, "di Indonesia sesuai dengan nilai yang diuji.")
        }
      } else {
        if(is_significant) {
          paste("Hasil ini menunjukkan bahwa proporsi", var_name, "dengan status", input$status_prop, "di kedua provinsi berbeda secara signifikan, sehingga memerlukan pendekatan kebijakan yang disesuaikan dengan kondisi spesifik masing-masing daerah.")
        } else {
          paste("Hasil ini menunjukkan bahwa proporsi", var_name, "dengan status", input$status_prop, "di kedua provinsi relatif serupa, sehingga dapat menggunakan pendekatan kebijakan yang sama.")
        }
      }
      
      HTML(paste0(
        '<div class="', decision_class, '">',
        '<h5><i class="fa fa-gavel"></i> Keputusan dan Interpretasi:</h5>',
        '<p><strong>Keputusan:</strong> ', decision_text, '</p>',
        '<p><strong>Interpretasi Praktis:</strong> ', practical_interpretation, '</p>',
        '</div>'
      ))
    })
  })
  
  output$download_proporsi_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Proporsi_", Sys.Date(), ".html")
    },
    content = function(file) {
      if(!proportion_values$completed) {
        showNotification("Jalankan uji proporsi terlebih dahulu sebelum download!", type = "error")
        return()
      }
      
      tempReport <- file.path(tempdir(), "template_proporsi.Rmd")
      file.copy("template_proporsi.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        test_type = proportion_values$test_type,
        variable = proportion_values$variable,
        status = proportion_values$status,
        p0 = if(proportion_values$test_type == "one_sample") input$p0_prop else NULL,
        alternative_one = if(proportion_values$test_type == "one_sample") input$alternative_prop_one else NULL,
        province1 = if(proportion_values$test_type == "two_sample") input$province1_prop else NULL,
        province2 = if(proportion_values$test_type == "two_sample") input$province2_prop else NULL,
        alternative_two = if(proportion_values$test_type == "two_sample") input$alternative_prop_two else NULL,
        data = proportion_values$data_used
      )

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  # Server Uji Varians
  
  variance_values <- reactiveValues(
    completed = FALSE,
    test_result = NULL,
    test_type = NULL,
    variable = NULL,
    data_used = NULL
  )
  
  observe({
    province_choices <- sort(unique(data$PROVINCENAME))
    updateSelectInput(session, "province1_var", choices = province_choices, selected = province_choices[1])
    updateSelectInput(session, "province2_var", choices = province_choices, selected = province_choices[2])
  })
  
  output$test_info_var <- renderUI({
    req(input$test_type_var, input$variable_var)
    
    var_name <- switch(input$variable_var,
                       "POVERTY" = "Kemiskinan",
                       "LOWEDU" = "Pendidikan Rendah",
                       "ILLITERATE" = "Buta Huruf")
    
    if(input$test_type_var == "one_sample") {
      info_text <- paste("Uji Chi-square untuk menguji apakah varians", var_name,
                         "berbeda dari nilai hipotesis yang ditentukan.")
    } else {
      info_text <- paste("Uji F untuk membandingkan varians", var_name,
                         "antara dua provinsi yang dipilih.")
    }
    
    HTML(paste0(
      '<div class="alert alert-info">',
      '<h5><i class="fa fa-info-circle"></i> Informasi Uji</h5>',
      '<p>', info_text, '</p>',
      '<p><strong>Catatan:</strong> Uji Chi-square untuk satu sampel, uji F untuk dua sampel.</p>',
      '</div>'
    ))
  })
  
  output$hypothesis_var <- renderUI({
    req(input$test_type_var, input$variable_var)
    
    var_name <- switch(input$variable_var,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    if(input$test_type_var == "one_sample") {
      req(input$sigma2_0, input$alternative_var_one)
      
      h0_text <- paste("H₀: σ² =", input$sigma2_0, "(Varians", var_name, "sama dengan", input$sigma2_0, ")")
      
      h1_text <- switch(input$alternative_var_one,
                        "two.sided" = paste("H₁: σ² ≠", input$sigma2_0, "(Varians", var_name, "tidak sama dengan", input$sigma2_0, ")"),
                        "less" = paste("H₁: σ² <", input$sigma2_0, "(Varians", var_name, "kurang dari", input$sigma2_0, ")"),
                        "greater" = paste("H₁: σ² >", input$sigma2_0, "(Varians", var_name, "lebih dari", input$sigma2_0, ")"))
      
    } else {
      req(input$province1_var, input$province2_var, input$alternative_var_two)
      
      h0_text <- paste("H₀: σ₁² = σ₂² (Varians", var_name, "di", input$province1_var, "sama dengan di", input$province2_var, ")")
      
      h1_text <- switch(input$alternative_var_two,
                        "two.sided" = paste("H₁: σ₁² ≠ σ₂² (Varians", var_name, "di", input$province1_var, "tidak sama dengan di", input$province2_var, ")"),
                        "less" = paste("H₁: σ₁² < σ₂² (Varians", var_name, "di", input$province1_var, "kurang dari di", input$province2_var, ")"),
                        "greater" = paste("H₁: σ₁² > σ₂² (Varians", var_name, "di", input$province1_var, "lebih dari di", input$province2_var, ")"))
    }
    
    HTML(paste0(
      '<div class="hypothesis-box">',
      '<h5><i class="fa fa-question-circle"></i> Hipotesis:</h5>',
      '<p><strong>', h0_text, '</strong></p>',
      '<p><strong>', h1_text, '</strong></p>',
      '</div>'
    ))
  })
  
  output$test_result_var <- renderPrint({
    req(input$run_test_var)
    
    isolate({
      if(input$test_type_var == "one_sample") {
        req(input$variable_var, input$sigma2_0, input$alternative_var_one)
        
        var_data <- data[[input$variable_var]]
        sample_var <- var(var_data, na.rm = TRUE)
        n <- length(var_data)
        
        cat("UJI CHI-SQUARE SATU SAMPEL\n")
        cat("=========================\n\n")
        
        chi_stat <- (n - 1) * sample_var / input$sigma2_0

        if(input$alternative_var_one == "two.sided") {
          p_value <- 2 * min(pchisq(chi_stat, df = n-1), 1 - pchisq(chi_stat, df = n-1))
        } else if(input$alternative_var_one == "less") {
          p_value <- pchisq(chi_stat, df = n-1)
        } else {
          p_value <- 1 - pchisq(chi_stat, df = n-1)
        }
        
        cat("Data Summary:\n")
        cat("Jumlah observasi (n):", n, "\n")
        cat("Varians sampel (s²):", round(sample_var, 4), "\n")
        cat("Varians hipotesis (σ₀²):", input$sigma2_0, "\n\n")
        
        cat("Hasil Uji Chi-square:\n")
        cat("Chi-square statistik:", round(chi_stat, 4), "\n")
        cat("df (derajat bebas):", n-1, "\n")
        cat("p-value:", format(p_value, scientific = TRUE), "\n\n")
        
        cat("Keputusan (α = 0.05):\n")
        if(p_value < 0.05) {
          cat("TOLAK H₀ - Ada bukti yang cukup untuk mendukung H₁\n")
        } else {
          cat("GAGAL TOLAK H₀ - Tidak ada bukti yang cukup untuk mendukung H₁\n")
        }
        
        test_result <- list(statistic = chi_stat, p.value = p_value, parameter = n-1)
        
      } else {
        req(input$variable_var, input$province1_var, input$province2_var, input$alternative_var_two)
        
        data1 <- data %>% filter(PROVINCENAME == input$province1_var) %>% pull(input$variable_var)
        data2 <- data %>% filter(PROVINCENAME == input$province2_var) %>% pull(input$variable_var)
        
        if(length(data1) == 0 || length(data2) == 0) {
          cat("Data tidak tersedia untuk salah satu atau kedua provinsi.\n")
          return()
        }
        
        cat("UJI F DUA SAMPEL\n")
        cat("================\n\n")
        
        test_result <- var.test(data1, data2, alternative = input$alternative_var_two)
        
        cat("Data Summary:\n")
        cat(input$province1_var, "- n:", length(data1), ", varians:", round(var(data1), 4), "\n")
        cat(input$province2_var, "- n:", length(data2), ", varians:", round(var(data2), 4), "\n\n")
        
        cat("Hasil Uji F:\n")
        cat("F-statistik:", round(test_result$statistic, 4), "\n")
        cat("df1:", test_result$parameter[1], ", df2:", test_result$parameter[2], "\n")
        cat("p-value:", format(test_result$p.value, scientific = TRUE), "\n")
        
        if(input$alternative_var_two == "two.sided") {
          cat("Confidence interval (95%):", round(test_result$conf.int[1], 4), "to", round(test_result$conf.int[2], 4), "\n\n")
        }
        
        cat("Keputusan (α = 0.05):\n")
        if(test_result$p.value < 0.05) {
          cat("TOLAK H₀ - Ada perbedaan signifikan antara varians kedua provinsi\n")
        } else {
          cat("GAGAL TOLAK H₀ - Tidak ada perbedaan signifikan antara varians kedua provinsi\n")
        }
      }
      
      variance_values$test_result <- test_result
      variance_values$test_type <- input$test_type_var
      variance_values$variable <- input$variable_var
      variance_values$data_used <- data
      variance_values$completed <- TRUE
    })
  })
  
  output$descriptive_var <- renderPrint({
    req(input$run_test_var)
    
    isolate({
      if(input$test_type_var == "one_sample") {
        var_data <- data[[input$variable_var]]
        
        cat("STATISTIK DESKRIPTIF\n")
        cat("===================\n\n")
        cat("N:", length(var_data), "\n")
        cat("Mean:", round(mean(var_data), 4), "\n")
        cat("Variance:", round(var(var_data), 4), "\n")
        cat("Std Dev:", round(sd(var_data), 4), "\n")
        cat("Min:", round(min(var_data), 4), "\n")
        cat("Max:", round(max(var_data), 4), "\n")
        
      } else {
        data1 <- data %>% filter(PROVINCENAME == input$province1_var) %>% pull(input$variable_var)
        data2 <- data %>% filter(PROVINCENAME == input$province2_var) %>% pull(input$variable_var)
        
        cat("STATISTIK DESKRIPTIF\n")
        cat("===================\n\n")
        cat(input$province1_var, ":\n")
        cat("  N:", length(data1), "\n")
        cat("  Mean:", round(mean(data1), 4), "\n")
        cat("  Variance:", round(var(data1), 4), "\n")
        cat("  Std Dev:", round(sd(data1), 4), "\n\n")
        
        cat(input$province2_var, ":\n")
        cat("  N:", length(data2), "\n")
        cat("  Mean:", round(mean(data2), 4), "\n")
        cat("  Variance:", round(var(data2), 4), "\n")
        cat("  Std Dev:", round(sd(data2), 4), "\n")
      }
    })
  })

  output$interpretation_var <- renderUI({
    req(input$run_test_var)
    
    isolate({
      var_name <- switch(input$variable_var,
                         "POVERTY" = "kemiskinan",
                         "LOWEDU" = "pendidikan rendah",
                         "ILLITERATE" = "buta huruf")
      
      if(input$test_type_var == "one_sample") {
        var_data <- data[[input$variable_var]]
        sample_var <- var(var_data, na.rm = TRUE)
        n <- length(var_data)
        
        chi_stat <- (n - 1) * sample_var / input$sigma2_0
        
        if(input$alternative_var_one == "two.sided") {
          p_value <- 2 * min(pchisq(chi_stat, df = n-1), 1 - pchisq(chi_stat, df = n-1))
        } else if(input$alternative_var_one == "less") {
          p_value <- pchisq(chi_stat, df = n-1)
        } else {
          p_value <- 1 - pchisq(chi_stat, df = n-1)
        }
        
        is_significant <- p_value < 0.05
        decision_class <- if(is_significant) "decision-box" else "interpretation-box"
        
        decision_text <- if(is_significant) {
          direction <- switch(input$alternative_var_one,
                              "two.sided" = "berbeda secara signifikan dari",
                              "less" = "secara signifikan kurang dari",
                              "greater" = "secara signifikan lebih dari")
          paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Varians", var_name, "(", round(sample_var, 2), ")", direction, input$sigma2_0, ".")
        } else {
          paste("Dengan tingkat signifikansi 5%, kita GAGAL MENOLAK H₀. Tidak ada bukti yang cukup bahwa varians", var_name, "(", round(sample_var, 2), ") berbeda dari", input$sigma2_0, ".")
        }
        
      } else {
        data1 <- data %>% filter(PROVINCENAME == input$province1_var) %>% pull(input$variable_var)
        data2 <- data %>% filter(PROVINCENAME == input$province2_var) %>% pull(input$variable_var)
        
        test_result <- var.test(data1, data2, alternative = input$alternative_var_two)
        
        var1 <- round(var(data1), 2)
        var2 <- round(var(data2), 2)
        is_significant <- test_result$p.value < 0.05
        
        decision_class <- if(is_significant) "decision-box" else "interpretation-box"
        
        decision_text <- if(is_significant) {
          direction <- switch(input$alternative_var_two,
                              "two.sided" = "berbeda secara signifikan",
                              "less" = paste("di", input$province1_var, "secara signifikan lebih kecil daripada di", input$province2_var),
                              "greater" = paste("di", input$province1_var, "secara signifikan lebih besar daripada di", input$province2_var))
          
          if(input$alternative_var_two == "two.sided") {
            paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Varians", var_name, "di", input$province1_var, "(", var1, ") dan", input$province2_var, "(", var2, ")", direction, ".")
          } else {
            paste("Dengan tingkat signifikansi 5%, kita MENOLAK H₀. Varians", var_name, direction, ".")
          }
        } else {
          paste("Dengan tingkat signifikansi 5%, kita GAGAL MENOLAK H₀. Tidak ada perbedaan yang signifikan dalam varians", var_name, "antara", input$province1_var, "(", var1, ") dan", input$province2_var, "(", var2, ").")
        }
      }
      
      practical_interpretation <- if(input$test_type_var == "one_sample") {
        if(is_significant) {
          paste("Hasil ini menunjukkan bahwa variabilitas", var_name, "di Indonesia berbeda dari nilai yang diuji, sehingga perlu diuji dengan nilai yang lain.")
        } else {
          paste("Hasil ini menunjukkan bahwa variabilitas", var_name, "di Indonesia sesuai dengan nilai yang diuji.")
        }
      } else {
        if(is_significant) {
          paste("Hasil ini menunjukkan bahwa variabilitas", var_name, "di kedua provinsi berbeda secara signifikan, sehingga memerlukan pendekatan kebijakan yang mempertimbangkan tingkat variabilitas yang berbeda.")
        } else {
          paste("Hasil ini menunjukkan bahwa variabilitas", var_name, "di kedua provinsi serupa, sehingga dapat menggunakan pendekatan kebijakan yang sama dalam hal konsistensi program.")
        }
      }
      
      HTML(paste0(
        '<div class="', decision_class, '">',
        '<h5><i class="fa fa-gavel"></i> Keputusan dan Interpretasi:</h5>',
        '<p><strong>Keputusan:</strong> ', decision_text, '</p>',
        '<p><strong>Interpretasi Praktis:</strong> ', practical_interpretation, '</p>',
        '</div>'
      ))
    })
  })
  
  output$download_varians_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Uji_Varians_", Sys.Date(), ".html")
    },
    content = function(file) {
      if(!variance_values$completed) {
        showNotification("Jalankan uji varians terlebih dahulu sebelum download!", type = "error")
        return()
      }
      
      tempReport <- file.path(tempdir(), "template_uji_varians.Rmd")
      file.copy("template_uji_varians.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(
        test_type = variance_values$test_type,
        variable = variance_values$variable,
        sigma2_0 = if(variance_values$test_type == "one_sample") input$sigma2_0 else NULL,
        alternative_one = if(variance_values$test_type == "one_sample") input$alternative_var_one else NULL,
        province1 = if(variance_values$test_type == "two_sample") input$province1_var else NULL,
        province2 = if(variance_values$test_type == "two_sample") input$province2_var else NULL,
        alternative_two = if(variance_values$test_type == "two_sample") input$alternative_var_two else NULL,
        data = variance_values$data_used
      )

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  # Server Anova 

  library(rmarkdown)
  library(officer)
  library(agricolae)
  
  anova_values <- reactiveValues(
    data = NULL,
    result = NULL,
    posthoc_needed = FALSE,
    posthoc_result = NULL,
    normality_ok = FALSE,
    homogeneity_ok = FALSE,
    can_proceed = FALSE
  )
  
  observe({
    if(length(input$anova_provinces) < 3) {
      showNotification("Pilih minimal 3 provinsi untuk ANOVA", type = "warning")
    }
    if(length(input$anova_provinces) > 34) {
      showNotification("Maksimal 34 provinsi dapat dipilih", type = "warning")
    }
  })
  
  observeEvent(input$run_anova, {
    req(length(input$anova_provinces) >= 3)
    req(length(input$anova_provinces) <= 34)
    
    anova_data <- data %>%
      filter(PROVINCENAME %in% input$anova_provinces) %>%
      filter(!is.na(get(input$anova_variable)))
    
    if(nrow(anova_data) == 0) {
      showNotification("Data tidak tersedia untuk kombinasi yang dipilih", type = "error")
      return()
    }
    
    if(input$anova_type == "twoway") {
      var_values <- anova_data[[input$anova_variable]]
      anova_data[[paste0(input$anova_variable, "_CAT")]] <- cut(
        var_values,
        breaks = quantile(var_values, c(0, 0.33, 0.67, 1), na.rm = TRUE),
        labels = c("Rendah", "Sedang", "Tinggi"),
        include.lowest = TRUE
      )
    }
    
    anova_values$data <- anova_data
    
    anova_values$normality_ok <- FALSE
    anova_values$homogeneity_ok <- FALSE
    anova_values$can_proceed <- FALSE
  })
  
  output$anova_normality_test <- renderPrint({
    req(anova_values$data)
    
    cat("UJI NORMALITAS DATA UNTUK ANOVA\n")
    cat("================================\n\n")
    
    var_name <- switch(input$anova_variable,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    cat("Variabel:", input$anova_variable, "(", var_name, ")\n")
    cat("Jenis ANOVA:", if(input$anova_type == "oneway") "One-Way" else "Two-Way", "\n")
    cat("Jumlah provinsi:", length(input$anova_provinces), "\n\n")
    
    normality_results <- list()
    all_normal <- TRUE
    
    if(input$anova_type == "oneway") {
      cat("UJI NORMALITAS PER PROVINSI (One-Way ANOVA)\n")
      cat("===========================================\n\n")
      
      for(province in input$anova_provinces) {
        province_data <- anova_values$data %>% 
          filter(PROVINCENAME == province) %>% 
          pull(input$anova_variable)
        
        if(length(province_data) < 3) {
          cat(province, "- Data tidak mencukupi (n < 3)\n")
          all_normal <- FALSE
          next
        }
        
        if(length(province_data) > 50) {
          test_result <- ks.test(province_data, "pnorm",
                                 mean = mean(province_data, na.rm = TRUE),
                                 sd = sd(province_data, na.rm = TRUE))
          test_name <- "Kolmogorov-Smirnov"
          stat_name <- "D"
        } else {
          test_result <- shapiro.test(province_data)
          test_name <- "Shapiro-Wilk"
          stat_name <- "W"
        }
        
        is_normal <- test_result$p.value > input$anova_alpha
        normality_results[[province]] <- is_normal
        
        cat(province, ":\n")
        cat("  n =", length(province_data), "\n")
        cat("  Uji:", test_name, "\n")
        cat(" ", stat_name, "=", round(test_result$statistic, 6), "\n")
        cat("  p-value =", format(test_result$p.value, scientific = TRUE), "\n")
        cat("  Status:", if(is_normal) "NORMAL ✓" else "TIDAK NORMAL ✗", "\n\n")
        
        if(!is_normal) all_normal <- FALSE
      }
      
    } else {
      cat("UJI NORMALITAS PER PROVINSI DAN KATEGORI (Two-Way ANOVA)\n")
      cat("========================================================\n\n")
      
      cat_var <- paste0(input$anova_variable, "_CAT")
      
      for(province in input$anova_provinces) {
        cat("PROVINSI:", province, "\n")
        cat(paste(rep("-", nchar(province) + 9), collapse = ""), "\n")
        
        province_data <- anova_values$data %>% filter(PROVINCENAME == province)
        
        for(category in c("Rendah", "Sedang", "Tinggi")) {
          cat_data <- province_data %>% 
            filter(get(cat_var) == category) %>% 
            pull(input$anova_variable)
          
          if(length(cat_data) < 3) {
            cat("  ", category, "- Data tidak mencukupi (n < 3)\n")
            all_normal <- FALSE
            next
          }
          
          if(length(cat_data) > 50) {
            test_result <- ks.test(cat_data, "pnorm",
                                   mean = mean(cat_data, na.rm = TRUE),
                                   sd = sd(cat_data, na.rm = TRUE))
            test_name <- "KS"
            stat_name <- "D"
          } else {
            test_result <- shapiro.test(cat_data)
            test_name <- "SW"
            stat_name <- "W"
          }
          
          is_normal <- test_result$p.value > input$anova_alpha
          group_key <- paste(province, category, sep = "_")
          normality_results[[group_key]] <- is_normal
          
          cat("  ", category, "- n =", length(cat_data),
              ", ", test_name, ":", stat_name, "=", round(test_result$statistic, 4),
              ", p =", format(test_result$p.value, scientific = TRUE),
              if(is_normal) " ✓" else " ✗", "\n")
          
          if(!is_normal) all_normal <- FALSE
        }
        cat("\n")
      }
    }
    
    cat("RINGKASAN UJI NORMALITAS:\n")
    cat("=========================\n")
    cat("Status keseluruhan:", if(all_normal) "SEMUA KELOMPOK NORMAL ✓" else "ADA KELOMPOK TIDAK NORMAL ✗", "\n")
    cat("Kelayakan untuk ANOVA:", if(all_normal) "LAYAK" else "TIDAK LAYAK", "\n")
    
    anova_values$normality_ok <- all_normal
  })
  
  output$anova_normality_interpretation <- renderUI({
    req(anova_values$data)
    
    status_class <- if(anova_values$normality_ok) "decision-box" else "interpretation-box"
    status_icon <- if(anova_values$normality_ok) "check-circle" else "times-circle"
    status_text <- if(anova_values$normality_ok) "LOLOS UJI NORMALITAS" else "TIDAK LOLOS UJI NORMALITAS"
    
    interpretation <- if(anova_values$normality_ok) {
      "Semua kelompok data berdistribusi normal. Asumsi normalitas untuk ANOVA terpenuhi."
    } else {
      "Beberapa kelompok data tidak berdistribusi normal. ANOVA parametrik tidak dapat dilakukan karena melanggar asumsi normalitas. Pertimbangkan transformasi data atau gunakan uji non-parametrik seperti Kruskal-Wallis."
    }
    
    HTML(paste0(
      '<div class="', status_class, '">',
      '<h5><i class="fa fa-', status_icon, '"></i> ', status_text, '</h5>',
      '<p><strong>Interpretasi:</strong> ', interpretation, '</p>',
      '</div>'
    ))
  })
  
  output$anova_homogeneity_test <- renderPrint({
    req(anova_values$data)
    
    cat("UJI HOMOGENITAS VARIANS UNTUK ANOVA\n")
    cat("====================================\n\n")
    
    var_name <- switch(input$anova_variable,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    cat("Variabel:", input$anova_variable, "(", var_name, ")\n")
    cat("Jenis ANOVA:", if(input$anova_type == "oneway") "One-Way" else "Two-Way", "\n\n")
    
    homogeneity_ok <- TRUE
    
    if(input$anova_type == "oneway") {
      cat("UJI LEVENE UNTUK ONE-WAY ANOVA\n")
      cat("===============================\n\n")
      
      var_data <- anova_values$data[[input$anova_variable]]
      provinces <- as.factor(anova_values$data$PROVINCENAME)
      
      tryCatch({
        levene_result <- leveneTest(var_data, provinces)
        
        cat("Hipotesis:\n")
        cat("H₀: Varians antar provinsi homogen\n")
        cat("H₁: Varians antar provinsi tidak homogen\n\n")
        
        cat("Hasil Uji Levene:\n")
        cat("F-statistik:", round(levene_result$`F value`[1], 4), "\n")
        cat("df1:", levene_result$Df[1], "\n")
        cat("df2:", levene_result$Df[2], "\n")
        cat("p-value:", format(levene_result$`Pr(>F)`[1], scientific = TRUE), "\n\n")
        
        homogeneity_ok <- levene_result$`Pr(>F)`[1] > input$anova_alpha
        
        cat("Keputusan (α =", input$anova_alpha, "):\n")
        if(homogeneity_ok) {
          cat("GAGAL TOLAK H₀ - Varians homogen ✓\n")
        } else {
          cat("TOLAK H₀ - Varians TIDAK homogen ✗\n")
        }
        
      }, error = function(e) {
        cat("Error dalam uji Levene:", e$message, "\n")
        homogeneity_ok <- FALSE
      })
      
    } else {
      cat("UJI LEVENE UNTUK TWO-WAY ANOVA\n")
      cat("===============================\n\n")
      
      cat_var <- paste0(input$anova_variable, "_CAT")
      
      cat("1. HOMOGENITAS ANTAR PROVINSI:\n")
      var_data <- anova_values$data[[input$anova_variable]]
      provinces <- as.factor(anova_values$data$PROVINCENAME)
      
      tryCatch({
        levene_province <- leveneTest(var_data, provinces)
        
        cat("   F =", round(levene_province$`F value`[1], 4),
            ", p =", format(levene_province$`Pr(>F)`[1], scientific = TRUE))
        
        province_ok <- levene_province$`Pr(>F)`[1] > input$anova_alpha
        cat(if(province_ok) " ✓\n" else " ✗\n")
        
      }, error = function(e) {
        cat("   Error:", e$message, "\n")
        province_ok <- FALSE
      })
      
      cat("2. HOMOGENITAS ANTAR KATEGORI:\n")
      categories <- as.factor(anova_values$data[[cat_var]])
      
      tryCatch({
        levene_category <- leveneTest(var_data, categories)
        
        cat("   F =", round(levene_category$`F value`[1], 4),
            ", p =", format(levene_category$`Pr(>F)`[1], scientific = TRUE))
        
        category_ok <- levene_category$`Pr(>F)`[1] > input$anova_alpha
        cat(if(category_ok) " ✓\n" else " ✗\n")
        
      }, error = function(e) {
        cat("   Error:", e$message, "\n")
        category_ok <- FALSE
      })
      
      cat("3. HOMOGENITAS UNTUK INTERAKSI:\n")
      interaction_groups <- as.factor(paste(anova_values$data$PROVINCENAME,
                                            anova_values$data[[cat_var]], sep = "_"))
      
      tryCatch({
        levene_interaction <- leveneTest(var_data, interaction_groups)
        
        cat("   F =", round(levene_interaction$`F value`[1], 4),
            ", p =", format(levene_interaction$`Pr(>F)`[1], scientific = TRUE))
        
        interaction_ok <- levene_interaction$`Pr(>F)`[1] > input$anova_alpha
        cat(if(interaction_ok) " ✓\n" else " ✗\n")
        
        homogeneity_ok <- province_ok && category_ok && interaction_ok
        
      }, error = function(e) {
        cat("   Error:", e$message, "\n")
        homogeneity_ok <- FALSE
      })
      
      cat("\nRINGKASAN:\n")
      cat("Provinsi:", if(exists("province_ok") && province_ok) "Homogen ✓" else "Tidak Homogen ✗", "\n")
      cat("Kategori:", if(exists("category_ok") && category_ok) "Homogen ✓" else "Tidak Homogen ✗", "\n")
      cat("Interaksi:", if(exists("interaction_ok") && interaction_ok) "Homogen ✓" else "Tidak Homogen ✗", "\n")
    }
    
    cat("\nSTATUS HOMOGENITAS KESELURUHAN:", if(homogeneity_ok) "HOMOGEN ✓" else "TIDAK HOMOGEN ✗", "\n")
    cat("Kelayakan untuk ANOVA:", if(homogeneity_ok) "LAYAK" else "TIDAK LAYAK", "\n")
    
    anova_values$homogeneity_ok <- homogeneity_ok
  })
  
  output$anova_homogeneity_interpretation <- renderUI({
    req(anova_values$data)
    
    status_class <- if(anova_values$homogeneity_ok) "decision-box" else "interpretation-box"
    status_icon <- if(anova_values$homogeneity_ok) "check-circle" else "times-circle"
    status_text <- if(anova_values$homogeneity_ok) "LOLOS UJI HOMOGENITAS" else "TIDAK LOLOS UJI HOMOGENITAS"
    
    interpretation <- if(anova_values$homogeneity_ok) {
      "Varians antar kelompok homogen. Asumsi homogenitas varians untuk ANOVA terpenuhi."
    } else {
      "Varians antar kelompok tidak homogen. ANOVA klasik tidak dapat dilakukan karena melanggar asumsi homogenitas varians. Pertimbangkan transformasi data.."
    }
    
    HTML(paste0(
      '<div class="', status_class, '">',
      '<h5><i class="fa fa-', status_icon, '"></i> ', status_text, '</h5>',
      '<p><strong>Interpretasi:</strong> ', interpretation, '</p>',
      '</div>'
    ))
  })
  
  output$anova_feasibility_status <- renderUI({
    req(anova_values$data)
    
    can_proceed <- anova_values$normality_ok && anova_values$homogeneity_ok
    anova_values$can_proceed <- can_proceed
    
    if(can_proceed) {
      HTML(paste0(
        '<div class="decision-box">',
        '<h5><i class="fa fa-check-circle"></i> ANOVA DAPAT DILAKUKAN</h5>',
        '<p><strong>Status:</strong> Semua asumsi ANOVA terpenuhi</p>',
        '<ul>',
        '<li>✅ Normalitas: Semua kelompok berdistribusi normal</li>',
        '<li>✅ Homogenitas: Varians antar kelompok homogen</li>',
        '</ul>',
        '<p><strong>Kesimpulan:</strong> Uji ANOVA dapat dilanjutkan.</p>',
        '</div>'
      ))
    } else {
      reasons <- c()
      if(!anova_values$normality_ok) reasons <- c(reasons, "❌ Normalitas: Ada kelompok yang tidak berdistribusi normal")
      if(!anova_values$homogeneity_ok) reasons <- c(reasons, "❌ Homogenitas: Varians antar kelompok tidak homogen")
      
      HTML(paste0(
        '<div class="interpretation-box">',
        '<h5><i class="fa fa-times-circle"></i> ANOVA TIDAK DAPAT DILAKUKAN</h5>',
        '<p><strong>Status:</strong> Asumsi ANOVA tidak terpenuhi</p>',
        '<ul>',
        paste0('<li>', reasons, '</li>', collapse = ''),
        '</ul>',
        '<p><strong>Rekomendasi:</strong></p>',
        '<ul>',
        '<li>Lakukan transformasi data (log, sqrt, dll.)</li>',
        '<li>Gunakan uji non-parametrik (Kruskal-Wallis)</li>',
        '<li>Pertimbangkan mengurangi jumlah kelompok</li>',
        '</ul>',
        '</div>'
      ))
    }
  })
  
  output$anova_can_proceed <- reactive({
    anova_values$can_proceed
  })
  outputOptions(output, "anova_can_proceed", suspendWhenHidden = FALSE)
  
  output$anova_hypothesis <- renderUI({
    req(anova_values$can_proceed)
    
    var_name <- switch(input$anova_variable,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    provinces_text <- paste(input$anova_provinces, collapse = ", ")
    
    if(input$anova_type == "oneway") {
      HTML(paste0(
        '<div class="hypothesis-box">',
        '<h5><i class="fa fa-question-circle"></i> Hipotesis One-Way ANOVA:</h5>',
        '<p><strong>H₀:</strong> μ₁ = μ₂ = μ₃ = ... (Rata-rata ', var_name, ' sama di semua provinsi)</p>',
        '<p><strong>H₁:</strong> Minimal ada satu rata-rata yang berbeda</p>',
        '<p><strong>Provinsi yang dibandingkan:</strong> ', provinces_text, '</p>',
        '<p><strong>Tingkat signifikansi:</strong> α = ', input$anova_alpha, '</p>',
        '</div>'
      ))
    } else {
      cat_var <- paste0(input$anova_variable, "_CAT")
      HTML(paste0(
        '<div class="hypothesis-box">',
        '<h5><i class="fa fa-question-circle"></i> Hipotesis Two-Way ANOVA:</h5>',
        '<p><strong>H₀₁:</strong> Tidak ada perbedaan rata-rata ', var_name, ' antar provinsi</p>',
        '<p><strong>H₀₂:</strong> Tidak ada perbedaan rata-rata ', var_name, ' antar kategori ', cat_var, '</p>',
        '<p><strong>H₀₃:</strong> Tidak ada interaksi antara provinsi dan kategori ', cat_var, '</p>',
        '<p><strong>H₁:</strong> Minimal ada satu hipotesis nol yang ditolak</p>',
        '<p><strong>Provinsi yang dibandingkan:</strong> ', provinces_text, '</p>',
        '<p><strong>Tingkat signifikansi:</strong> α = ', input$anova_alpha, '</p>',
        '</div>'
      ))
    }
  })
  
  observe({
    req(anova_values$can_proceed)
    
    if(input$anova_type == "oneway") {
      formula_str <- paste(input$anova_variable, "~ PROVINCENAME")
      anova_values$result <- aov(as.formula(formula_str), data = anova_values$data)
    } else {
      cat_var <- paste0(input$anova_variable, "_CAT")
      formula_str <- paste(input$anova_variable, "~ PROVINCENAME *", cat_var)
      anova_values$result <- aov(as.formula(formula_str), data = anova_values$data)
    }
    
    anova_summary <- summary(anova_values$result)
    p_values <- anova_summary[[1]][["Pr(>F)"]]
    anova_values$posthoc_needed <- any(p_values < input$anova_alpha, na.rm = TRUE)
  })
  
  output$anova_result <- renderPrint({
    req(anova_values$result)
    req(anova_values$can_proceed)
    
    cat("HASIL ANALISIS VARIANS (ANOVA)\n")
    cat("==============================\n\n")
    
    if(input$anova_type == "oneway") {
      summary_stats <- anova_values$data %>%
        group_by(PROVINCENAME) %>%
        summarise(
          n = n(),
          mean = round(mean(get(input$anova_variable), na.rm = TRUE), 4),
          sd = round(sd(get(input$anova_variable), na.rm = TRUE), 4),
          .groups = 'drop'
        )
      
      cat("Ringkasan Data per Provinsi:\n")
      for(i in 1:nrow(summary_stats)) {
        cat(summary_stats$PROVINCENAME[i], "- n:", summary_stats$n[i],
            ", mean:", summary_stats$mean[i], ", sd:", summary_stats$sd[i], "\n")
      }
    } else {
      cat_var <- paste0(input$anova_variable, "_CAT")
      summary_stats <- anova_values$data %>%
        group_by(PROVINCENAME, get(cat_var)) %>%
        summarise(
          n = n(),
          mean = round(mean(get(input$anova_variable), na.rm = TRUE), 4),
          .groups = 'drop'
        )
      names(summary_stats)[2] <- cat_var
      
      cat("Ringkasan Data per Provinsi dan Kategori:\n")
      print(summary_stats)
    }
    
    cat("\nHasil ANOVA:\n")
    print(summary(anova_values$result))
  })
  
  output$anova_interpretation <- renderUI({
    req(anova_values$result)
    req(anova_values$can_proceed)
    
    anova_summary <- summary(anova_values$result)[[1]]
    p_values <- anova_summary[["Pr(>F)"]]
    
    var_name <- switch(input$anova_variable,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    if(input$anova_type == "oneway") {
      p_value <- p_values[1]
      decision_class <- if(p_value < input$anova_alpha) "decision-box" else "interpretation-box"
      
      decision_text <- if(p_value < input$anova_alpha) {
        paste("TOLAK H₀ - Terdapat perbedaan yang signifikan dalam rata-rata", var_name,
              "di antara provinsi yang dipilih (p-value =", format(p_value, scientific = TRUE), ").")
      } else {
        paste("GAGAL TOLAK H₀ - Tidak terdapat perbedaan yang signifikan dalam rata-rata", var_name,
              "di antara provinsi yang dipilih (p-value =", format(p_value, scientific = TRUE), ").")
      }
      
      interpretation <- if(p_value < input$anova_alpha) {
        paste("Hasil menunjukkan bahwa kondisi", var_name, "tidak homogen antar provinsi. Diperlukan uji lanjutan untuk mengetahui provinsi mana yang berbeda secara signifikan.")
      } else {
        paste("Hasil menunjukkan bahwa kondisi", var_name, "relatif homogen antar provinsi, sehingga dapat menggunakan kebijakan yang seragam.")
      }
      
      HTML(paste0(
        '<div class="', decision_class, '">',
        '<h5><i class="fa fa-gavel"></i> Keputusan dan Interpretasi:</h5>',
        '<p><strong>Keputusan:</strong> ', decision_text, '</p>',
        '<p><strong>Interpretasi Praktis:</strong> ', interpretation, '</p>',
        '</div>'
      ))
      
    } else {
      p_province <- p_values[1]
      p_category <- p_values[2] 
      p_interaction <- p_values[3]
      
      sig_province <- p_province < input$anova_alpha
      sig_category <- p_category < input$anova_alpha
      sig_interaction <- p_interaction < input$anova_alpha
      
      decision_class <- if(sig_province || sig_category || sig_interaction) "decision-box" else "interpretation-box"
      
      HTML(paste0(
        '<div class="', decision_class, '">',
        '<h5><i class="fa fa-gavel"></i> Keputusan dan Interpretasi Two-Way ANOVA:</h5>',
        '<p><strong>Efek Provinsi:</strong> ',
        if(sig_province) {
          paste('SIGNIFIKAN (p =', format(p_province, scientific = TRUE), '). Ada perbedaan rata-rata', var_name, 'antar provinsi.')
        } else {
          paste('TIDAK SIGNIFIKAN (p =', format(p_province, scientific = TRUE), '). Tidak ada perbedaan rata-rata', var_name, 'antar provinsi.')
        },
        '</p>',
        '<p><strong>Efek Kategori:</strong> ',
        if(sig_category) {
          paste('SIGNIFIKAN (p =', format(p_category, scientific = TRUE), '). Ada perbedaan rata-rata', var_name, 'antar kategori.')
        } else {
          paste('TIDAK SIGNIFIKAN (p =', format(p_category, scientific = TRUE), '). Tidak ada perbedaan rata-rata', var_name, 'antar kategori.')
        },
        '</p>',
        '<p><strong>Efek Interaksi:</strong> ',
        if(sig_interaction) {
          paste('SIGNIFIKAN (p =', format(p_interaction, scientific = TRUE), '). Ada interaksi antara provinsi dan kategori.')
        } else {
          paste('TIDAK SIGNIFIKAN (p =', format(p_interaction, scientific = TRUE), '). Tidak ada interaksi antara provinsi dan kategori.')
        },
        '</p>',
        '<p><strong>Interpretasi Praktis:</strong> ',
        if(sig_province && sig_category && sig_interaction) {
          paste('Terdapat perbedaan yang kompleks dalam', var_name, 'yang dipengaruhi oleh provinsi, kategori, dan interaksi keduanya. Diperlukan analisis lebih mendalam.')
        } else if(sig_province || sig_category) {
          paste('Terdapat perbedaan signifikan yang memerlukan kebijakan yang disesuaikan berdasarkan faktor yang berpengaruh.')
        } else {
          paste('Tidak ada perbedaan signifikan, menunjukkan kondisi yang relatif homogen antar provinsi dan kategori.')
        },
        '</p></div>'
      ))
    }
  })
  
  output$show_posthoc <- reactive({
    req(anova_values$can_proceed)
    anova_values$posthoc_needed
  })
  outputOptions(output, "show_posthoc", suspendWhenHidden = FALSE)
  

  output$anova_posthoc <- renderPrint({
    req(anova_values$posthoc_needed)
    req(anova_values$result)
    req(anova_values$can_proceed)
    
    cat("UJI LANJUTAN (POST-HOC) - UJI HSD\n")
    cat("=================================\n\n")
    
    if(input$anova_type == "oneway") {
      cat("Menggunakan uji HSD (Honestly Significant Difference) untuk membandingkan antar provinsi:\n\n")
      
      tryCatch({

        hsd_result <- HSD.test(anova_values$result, "PROVINCENAME", alpha = input$anova_alpha)
        anova_values$posthoc_result <- hsd_result
        
        cat("HASIL UJI HSD:\n")
        cat("==============\n\n")
        
        cat("Statistik HSD:\n")
        cat("MSE (Mean Square Error):", round(hsd_result$statistics$MSerror, 6), "\n")
        cat("Df Error:", hsd_result$statistics$Df, "\n")
        cat("HSD Value:", round(hsd_result$statistics$HSD, 6), "\n")
        cat("Alpha:", hsd_result$statistics$alpha, "\n\n")
        
        cat("PENGELOMPOKAN PROVINSI:\n")
        cat("======================\n")
        groups_df <- hsd_result$groups
        groups_df <- groups_df[order(-groups_df[,1]), ]  #
        
        for(i in 1:nrow(groups_df)) {
          province_name <- rownames(groups_df)[i]
          mean_val <- round(groups_df[i, 1], 4)
          group_letter <- groups_df[i, 2]
          cat(sprintf("%-25s: Mean = %8.4f, Grup = %s\n", province_name, mean_val, group_letter))
        }
        
        
        if(!is.null(hsd_result$comparison)) {
          cat("PERBANDINGAN BERPASANGAN:\n")
          cat("========================\n")
          comparison_df <- hsd_result$comparison
          comparison_df$signif <- ifelse(abs(comparison_df$difference) > hsd_result$statistics$HSD, "***", "ns")
          print(comparison_df)
        }
        
      }, error = function(e) {
        cat("Error dalam uji HSD. Menggunakan TukeyHSD sebagai alternatif:\n\n")
        tukey_result <- TukeyHSD(anova_values$result, conf.level = 1 - input$anova_alpha)
        anova_values$posthoc_result <- tukey_result
        print(tukey_result)
      })
      
    } else {
      anova_summary <- summary(anova_values$result)[[1]]
      p_values <- anova_summary[["Pr(>F)"]]
      
      if(p_values[1] < input$anova_alpha) {
        cat("UJI LANJUTAN HSD UNTUK EFEK PROVINSI:\n")
        cat("====================================\n")
        tryCatch({
          hsd_province <- HSD.test(anova_values$result, "PROVINCENAME", alpha = input$anova_alpha)
          
          cat("Pengelompokan Provinsi:\n")
          groups_df <- hsd_province$groups
          groups_df <- groups_df[order(-groups_df[,1]), ]
          
          for(i in 1:nrow(groups_df)) {
            province_name <- rownames(groups_df)[i]
            mean_val <- round(groups_df[i, 1], 4)
            group_letter <- groups_df[i, 2]
            cat(sprintf("%-25s: Mean = %8.4f, Grup = %s\n", province_name, mean_val, group_letter))
          }
          
        }, error = function(e) {
          cat("Menggunakan TukeyHSD untuk provinsi:\n")
          print(TukeyHSD(anova_values$result, "PROVINCENAME"))
        })
        cat("\n")
      }
      
      cat_var <- paste0(input$anova_variable, "_CAT")
      if(p_values[2] < input$anova_alpha) {
        cat("UJI LANJUTAN HSD UNTUK EFEK KATEGORI:\n")
        cat("====================================\n")
        tryCatch({
          hsd_category <- HSD.test(anova_values$result, cat_var, alpha = input$anova_alpha)
          
          cat("Pengelompokan Kategori:\n")
          groups_df <- hsd_category$groups
          groups_df <- groups_df[order(-groups_df[,1]), ]
          
          for(i in 1:nrow(groups_df)) {
            category_name <- rownames(groups_df)[i]
            mean_val <- round(groups_df[i, 1], 4)
            group_letter <- groups_df[i, 2]
            cat(sprintf("%-15s: Mean = %8.4f, Grup = %s\n", category_name, mean_val, group_letter))
          }
          
        }, error = function(e) {
          cat("Menggunakan TukeyHSD untuk kategori:\n")
          print(TukeyHSD(anova_values$result, cat_var))
        })
        cat("\n")
      }
      
      if(p_values[3] < input$anova_alpha) {
        cat("UJI LANJUTAN UNTUK EFEK INTERAKSI:\n")
        cat("----------------------------------\n")
        cat("Karena ada interaksi signifikan, perlu dilakukan analisis simple effects\n")
        cat("atau interpretasi plot interaksi untuk memahami pola yang terjadi.\n\n")
      }
    }
  })
  
  output$anova_posthoc_interpretation <- renderUI({
    req(anova_values$posthoc_needed)
    req(anova_values$can_proceed)
    
    var_name <- switch(input$anova_variable,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    if(input$anova_type == "oneway") {
      HTML(paste0(
        '<div class="decision-box">',
        '<h5><i class="fa fa-search"></i> Interpretasi Uji Lanjutan HSD:</h5>',
        '<p><strong>Hasil Pengelompokan:</strong> Uji HSD (Honestly Significant Difference) mengelompokkan provinsi berdasarkan kesamaan rata-rata ', var_name, '.</p>',
        '<p><strong>Keunggulan HSD:</strong> Uji HSD lebih konservatif dibandingkan uji lain dan memberikan kontrol yang baik terhadap tingkat kesalahan tipe I.</p>',
        '<p><strong>Implikasi Kebijakan:</strong> Provinsi yang berada dalam kelompok berbeda memerlukan pendekatan kebijakan yang disesuaikan dengan kondisi spesifik masing-masing.</p>',
        '</div>'
      ))
    } else {
      anova_summary <- summary(anova_values$result)[[1]]
      p_values <- anova_summary[["Pr(>F)"]]
      p_interaction <- p_values[3]
      
      HTML(paste0(
        '<div class="decision-box">',
        '<h5><i class="fa fa-search"></i> Interpretasi Uji Lanjutan HSD:</h5>',
        '<p><strong>Hasil Pengelompokan:</strong> Uji HSD mengelompokkan provinsi dan/atau kategori berdasarkan kesamaan rata-rata ', var_name, '.</p>',
        '<p><strong>Keunggulan HSD:</strong> Memberikan kontrol kesalahan yang lebih baik dalam perbandingan berganda.</p>',
        '<p><strong>Implikasi Kebijakan:</strong> ',
        if(p_interaction < input$anova_alpha) {
          'Karena ada interaksi signifikan, kebijakan harus mempertimbangkan kombinasi spesifik antara provinsi dan kategori.'
        } else {
          'Kebijakan dapat dirancang berdasarkan faktor utama yang berpengaruh tanpa perlu mempertimbangkan interaksi yang kompleks.'
        },
        '</p></div>'
      ))
    }
  })
  
  output$anova_plot <- renderPlotly({
    req(anova_values$data)
    req(anova_values$can_proceed)
    
    if(input$anova_type == "oneway") {
      p <- ggplot(anova_values$data, aes(x = PROVINCENAME, y = get(input$anova_variable))) +
        geom_boxplot(fill = "lightblue", alpha = 0.7) +
        geom_jitter(width = 0.2, alpha = 0.5) +
        labs(
          title = paste("Boxplot", input$anova_variable, "per Provinsi"),
          x = "Provinsi",
          y = paste(input$anova_variable, "(%)")
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      
    } else {
      cat_var <- paste0(input$anova_variable, "_CAT")
      p <- ggplot(anova_values$data, aes(x = PROVINCENAME, y = get(input$anova_variable),
                                         fill = get(cat_var))) +
        geom_boxplot(alpha = 0.7) +
        scale_fill_brewer(type = "qual", palette = "Set2") +
        labs(
          title = paste("Boxplot", input$anova_variable, "berdasarkan Provinsi dan Kategori"),
          x = "Provinsi",
          y = paste(input$anova_variable, "(%)"),
          fill = cat_var
        ) +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "bottom"
        )
    }
    
    ggplotly(p)
  })
  
  output$download_anova_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_ANOVA_", Sys.Date(), ".html")
    },
    content = function(file) {
      tempReport<-file.path(tempdir(),"template_anova.Rmd")
      file.copy("template_anova.Rmd",tempReport, overwrite=TRUE)
      req(anova_values$result)
      req(anova_values$can_proceed)
      
      params <- list(
        anova_type = input$anova_type,
        variable = input$anova_variable,
        provinces = input$anova_provinces,
        alpha = input$anova_alpha,
        data = anova_values$data,
        result = anova_values$result,
        posthoc_needed = anova_values$posthoc_needed,
        posthoc_result = anova_values$posthoc_result,
        normality_ok = anova_values$normality_ok,
        homogeneity_ok = anova_values$homogeneity_ok
      )
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
  
  # Server Regresi

  library(rmarkdown)
  library(car)
  library(lmtest)
  library(broom)
  
  regression_values <- reactiveValues(
    model = NULL,
    data = NULL,
    formula_text = NULL,
    completed = FALSE
  )
  
  observe({
    if(input$reg_dependent %in% input$reg_independent) {
      showNotification("Variabel dependen tidak boleh sama dengan variabel independen!", type = "error")
    }
    
    if(length(input$reg_independent) == 0) {
      showNotification("Pilih minimal satu variabel independen!", type = "warning")
    }
  })
  
  output$regression_model_hypothesis <- renderUI({
    req(input$run_regression > 0)
    req(length(input$reg_independent) > 0)
    req(!(input$reg_dependent %in% input$reg_independent))
    
    dep_name <- switch(input$reg_dependent,
                       "POVERTY" = "Kemiskinan",
                       "LOWEDU" = "Pendidikan Rendah",
                       "ILLITERATE" = "Buta Huruf")
    
    indep_names <- sapply(input$reg_independent, function(x) {
      switch(x,
             "POVERTY" = "Kemiskinan",
             "LOWEDU" = "Pendidikan Rendah",
             "ILLITERATE" = "Buta Huruf")
    })
    
    formula_text <- paste(input$reg_dependent, "~", paste(input$reg_independent, collapse = " + "))
    
    HTML(paste0(
      '<div class="hypothesis-box">',
      '<h5><i class="fa fa-formula"></i> Model Regresi:</h5>',
      '<p><strong>Formula:</strong> ', formula_text, '</p>',
      '<p><strong>Variabel Dependen:</strong> ', dep_name, ' (', input$reg_dependent, ')</p>',
      '<p><strong>Variabel Independen:</strong> ', paste(indep_names, collapse = ", "), '</p>',
      '<h5><i class="fa fa-question-circle"></i> Hipotesis:</h5>',
      '<p><strong>H₀:</strong> β₁ = β₂ = ... = 0 (Tidak ada pengaruh signifikan variabel independen terhadap ', dep_name, ')</p>',
      '<p><strong>H₁:</strong> Minimal ada satu βᵢ ≠ 0 (Ada pengaruh signifikan minimal satu variabel independen terhadap ', dep_name, ')</p>',
      '<p><strong>Tingkat signifikansi:</strong> α = ', input$reg_alpha, '</p>',
      '</div>'
    ))
  })
  
  observeEvent(input$run_regression, {
    req(length(input$reg_independent) > 0)
    req(!(input$reg_dependent %in% input$reg_independent))
    
    reg_data <- data %>%
      select(all_of(c(input$reg_dependent, input$reg_independent))) %>%
      na.omit()
    
    if(nrow(reg_data) == 0) {
      showNotification("Data tidak tersedia untuk kombinasi variabel yang dipilih", type = "error")
      regression_values$completed <- FALSE
      return()
    }

    formula_text <- paste(input$reg_dependent, "~", paste(input$reg_independent, collapse = " + "))
    
    model <- lm(as.formula(formula_text), data = reg_data)
    
    regression_values$model <- model
    regression_values$data <- reg_data
    regression_values$formula_text <- formula_text
    regression_values$completed <- TRUE
  })
  
  output$regression_completed <- reactive({
    regression_values$completed
  })
  outputOptions(output, "regression_completed", suspendWhenHidden = FALSE)
  
  output$regression_summary <- renderPrint({
    req(regression_values$model)
    
    cat("RINGKASAN MODEL REGRESI LINEAR\n")
    cat("==============================\n\n")
    
    cat("Formula:", regression_values$formula_text, "\n\n")

    model_summary <- summary(regression_values$model)
    print(model_summary)
    
    cat("\nPersamaan Regresi:\n")
    coef <- round(coef(regression_values$model), 4)
    
    equation <- paste(input$reg_dependent, "=", coef[1])
    for(i in 2:length(coef)) {
      sign <- if(coef[i] >= 0) " + " else " - "
      equation <- paste0(equation, sign, abs(coef[i]), " × ", names(coef)[i])
    }
    cat(equation, "\n")
  })
  
  output$regression_interpretation <- renderUI({
    req(regression_values$model)
    
    model_summary <- summary(regression_values$model)
    f_stat <- model_summary$fstatistic
    p_value_model <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
    
    coef_summary <- model_summary$coefficients
    coef_df <- data.frame(
      Variabel = rownames(coef_summary),
      Koefisien = round(coef_summary[, 1], 4),
      P_Value = coef_summary[, 4],
      Signifikan = ifelse(coef_summary[, 4] < input$reg_alpha, "Ya", "Tidak")
    )
    
    dep_name <- switch(input$reg_dependent,
                       "POVERTY" = "kemiskinan",
                       "LOWEDU" = "pendidikan rendah",
                       "ILLITERATE" = "buta huruf")
    
    decision_class <- if(p_value_model < input$reg_alpha) "decision-box" else "interpretation-box"
    
    coef_interpretations <- ""
    for(i in 2:nrow(coef_df)) {
      var_name <- switch(coef_df$Variabel[i],
                         "POVERTY" = "kemiskinan",
                         "LOWEDU" = "pendidikan rendah",
                         "ILLITERATE" = "buta huruf")
      
      coef_val <- coef_df$Koefisien[i]
      is_sig <- coef_df$Signifikan[i] == "Ya"
      
      interpretation <- if(is_sig) {
        if(coef_val > 0) {
          paste("Setiap peningkatan 1% pada", var_name, "akan meningkatkan", dep_name, "sebesar", abs(coef_val), "%")
        } else {
          paste("Setiap peningkatan 1% pada", var_name, "akan menurunkan", dep_name, "sebesar", abs(coef_val), "%")
        }
      } else {
        paste("Variabel", var_name, "tidak berpengaruh signifikan terhadap", dep_name)
      }
      
      coef_interpretations <- paste0(coef_interpretations, "<li>", interpretation, "</li>")
    }
    
    HTML(paste0(
      '<div class="', decision_class, '">',
      '<h5><i class="fa fa-gavel"></i> Keputusan dan Interpretasi:</h5>',
      '<p><strong>Keputusan Model:</strong> ',
      if(p_value_model < input$reg_alpha) {
        paste("TOLAK H₀ - Model regresi signifikan karena p-value < α")
      } else {
        paste("GAGAL TOLAK H₀ - Model regresi tidak signifikan karena p-value > α ")
      },
      '</p>',
      '<p><strong>R-squared:</strong> ', round(model_summary$r.squared, 4),
      ' (Model menjelaskan ', round(model_summary$r.squared * 100, 2), '% variasi dalam ', dep_name, ')</p>',
      '<p><strong>Interpretasi Koefisien:</strong></p>',
      '<ul>', coef_interpretations, '</ul>',
      '</div>'
    ))
  })
  

  output$regression_assumptions <- renderPrint({
    req(regression_values$model)
    req(input$reg_include_assumptions)
    
    cat("UJI ASUMSI REGRESI LINEAR\n")
    cat("=========================\n\n")
    
    cat("1. UJI NORMALITAS RESIDUAL\n")
    cat("--------------------------\n")
    residuals_model <- residuals(regression_values$model)
    shapiro_result <- shapiro.test(residuals_model)
    cat("Shapiro-Wilk Test:\n")
    cat("W =", round(shapiro_result$statistic, 6), "\n")
    cat("p-value =", format(shapiro_result$p.value, scientific = TRUE), "\n")
    cat("Keputusan:", if(shapiro_result$p.value > input$reg_alpha) "Residual berdistribusi normal" else "Residual TIDAK berdistribusi normal", "\n\n")
    
    cat("2. UJI HOMOSKEDASTISITAS\n")
    cat("------------------------\n")
    bp_result <- bptest(regression_values$model)
    cat("Breusch-Pagan Test:\n")
    cat("BP =", round(bp_result$statistic, 6), "\n")
    cat("p-value =", format(bp_result$p.value, scientific = TRUE), "\n")
    cat("Keputusan:", if(bp_result$p.value > input$reg_alpha) "Varians residual homogen" else "Varians residual TIDAK homogen", "\n\n")
    

    cat("3. UJI AUTOKORELASI\n")
    cat("-------------------\n")
    dw_result <- dwtest(regression_values$model)
    cat("Durbin-Watson Test:\n")
    cat("DW =", round(dw_result$statistic, 6), "\n")
    cat("p-value =", format(dw_result$p.value, scientific = TRUE), "\n")
    cat("Keputusan:", if(dw_result$p.value > input$reg_alpha) "Tidak ada autokorelasi" else "Terdapat autokorelasi", "\n\n")
 
    if(length(input$reg_independent) > 1) {
      cat("4. UJI MULTIKOLINEARITAS\n")
      cat("------------------------\n")
      vif_result <- vif(regression_values$model)
      cat("Variance Inflation Factor (VIF):\n")
      for(i in 1:length(vif_result)) {
        cat(names(vif_result)[i], ":", round(vif_result[i], 4), "\n")
      }
      cat("Keputusan:", if(all(vif_result < 10)) "Tidak ada multikolinearitas" else "Terdapat multikolinearitas", "\n\n")
    }
  })

  output$regression_assumptions_interpretation <- renderUI({
    req(regression_values$model)
    req(input$reg_include_assumptions)

    residuals_model <- residuals(regression_values$model)
    shapiro_result <- shapiro.test(residuals_model)
    bp_result <- bptest(regression_values$model)
    dw_result <- dwtest(regression_values$model)

    normality_ok <- shapiro_result$p.value > input$reg_alpha
    homoscedasticity_ok <- bp_result$p.value > input$reg_alpha
    autocorrelation_ok <- dw_result$p.value > input$reg_alpha
    
    multicollinearity_ok <- TRUE
    if(length(input$reg_independent) > 1) {
      vif_result <- vif(regression_values$model)
      multicollinearity_ok <- all(vif_result < 10)
    }
    
    all_assumptions_met <- normality_ok && homoscedasticity_ok && autocorrelation_ok && multicollinearity_ok
    
    assumption_class <- if(all_assumptions_met) "decision-box" else "interpretation-box"
    
    HTML(paste0(
      '<div class="', assumption_class, '">',
      '<h5><i class="fa fa-check-circle"></i> Ringkasan Uji Asumsi:</h5>',
      '<ul>',
      '<li><strong>Normalitas Residual:</strong> ', if(normality_ok) "✅ Terpenuhi" else "❌ Tidak Terpenuhi", '</li>',
      '<li><strong>Homoskedastisitas:</strong> ', if(homoscedasticity_ok) "✅ Terpenuhi" else "❌ Tidak Terpenuhi", '</li>',
      '<li><strong>Tidak Ada Autokorelasi:</strong> ', if(autocorrelation_ok) "✅ Terpenuhi" else "❌ Tidak Terpenuhi", '</li>',
      if(length(input$reg_independent) > 1) {
        paste('<li><strong>Tidak Ada Multikolinearitas:</strong> ', if(multicollinearity_ok) "✅ Terpenuhi" else "❌ Tidak Terpenuhi", '</li>')
      } else "",
      '</ul>',
      '<p><strong>Kesimpulan:</strong> ',
      if(all_assumptions_met) {
        'Semua asumsi regresi linear terpenuhi. Model dapat digunakan untuk prediksi dan inferensi.'
      } else {
        'Beberapa asumsi tidak terpenuhi. Pertimbangkan transformasi data atau metode regresi alternatif.'
      },
      '</p></div>'
    ))
  })
  

  output$regression_plot <- renderPlotly({
    req(regression_values$model)
    
    if(length(input$reg_independent) == 1) {
      plot_data <- regression_values$data
      x_var <- input$reg_independent[1]
      y_var <- input$reg_dependent
      
      p <- ggplot(plot_data, aes(x = get(x_var), y = get(y_var))) +
        geom_point(alpha = 0.6) +
        geom_smooth(method = "lm", se = TRUE, color = "red") +
        labs(
          title = paste("Regresi Linear:", y_var, "vs", x_var),
          x = paste(x_var, "(%)"),
          y = paste(y_var, "(%)")
        ) +
        theme_minimal()
      
    } else {

      fitted_vals <- fitted(regression_values$model)
      actual_vals <- regression_values$data[[input$reg_dependent]]
      
      plot_data <- data.frame(
        Fitted = fitted_vals,
        Actual = actual_vals
      )
      
      p <- ggplot(plot_data, aes(x = Fitted, y = Actual)) +
        geom_point(alpha = 0.6) +
        geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
        labs(
          title = "Fitted vs Actual Values",
          x = "Fitted Values",
          y = "Actual Values"
        ) +
        theme_minimal()
    }
    
    ggplotly(p)
  })
  
  output$regression_diagnostic_plots <- renderPlot({
    req(regression_values$model)
    req(input$reg_include_assumptions)
    
    par(mfrow = c(2, 2))
    plot(regression_values$model)
  })
  
  output$download_regression_report <- downloadHandler(
    filename = function() {
      paste0("Laporan_Regresi_", Sys.Date(), ".html")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "template_regresi.Rmd")
      file.copy("template_regresi.Rmd", tempReport, overwrite = TRUE)
      req(regression_values$model)
      req(regression_values$completed)
      
      params <- list(
        dependent = input$reg_dependent,
        independent = input$reg_independent,
        alpha = input$reg_alpha,
        include_assumptions = input$reg_include_assumptions,
        model = regression_values$model,
        data = regression_values$data,
        formula_text = regression_values$formula_text
      )
           
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
  
}

# Jalankan Aplikasi
shinyApp(ui = ui, server = server)