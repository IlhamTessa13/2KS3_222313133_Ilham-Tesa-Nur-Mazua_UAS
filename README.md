# 2KS3_222313133_Ilham-Tesa-Nur-Mazua_UAS
📊 Dashboard Sosial Demografi Indonesia (DOSEN)
Selamat datang di Dashboard Sosial Demografi Indonesia, sebuah aplikasi interaktif berbasis R Shiny yang dirancang untuk mengeksplorasi dan menganalisis indikator-indikator demografi penting seperti kemiskinan, pendidikan rendah, dan buta huruf di seluruh provinsi di Indonesia.

🔗 Akses Aplikasi: https://tesa13.shinyapps.io/Dashboard_UAS/

🧭 Fitur Menu Dashboard
1. Menu Beranda
  Menyediakan:
 -Gambaran umum dari data yang tersedia.
 -Informasi mengenai dashboard.
 -Metadata terkait indikator-indikator yang dianalisis.

2. Menu Manajemen Data
  Fungsi utama:
 -Mengubah data kontinu menjadi kategorik untuk memudahkan analisis atau visualisasi tertentu.

3. Menu Eksplorasi Data
a. Statistik Deskriptif
  -Ringkasan statistik seperti mean, median, standar deviasi, minimum, maksimum, dll.

b. Visualisasi Grafik
  -Bar Chart untuk membandingkan nilai antar wilayah.
  -Histogram untuk melihat distribusi satu variabel.
  -Tersedia filter provinsi agar analisis lebih terarah.

c. Peta Choropleth
  -Peta interaktif yang menunjukkan distribusi spasial tiap indikator hingga tingkat kabupaten/kota.
  -Warna pada peta mencerminkan tingkat intensitas nilai indikator.

4. Menu Uji Asumsi
a. Uji Normalitas
  -Untuk memeriksa apakah distribusi data mengikuti sebaran normal.
  -Digunakan: Shapiro-Wilk Test dan Kolmogorov-Smirnov Test.

b. Uji Homogenitas
  -Menguji apakah varians antar kelompok sama.
  -Contoh: Varians kemiskinan di Jawa Timur vs. Sumatera Barat.
  -Digunakan: Levene’s Test.

5. Menu Statistik Inferensia
  Fitur ini mencakup berbagai uji statistik, yaitu:
  -Uji Rata-rata: Untuk membandingkan dua rata-rata (dua kelompok atau satu kelompok dengan nilai tertentu).
  -Uji Varians: Untuk menguji perbedaan varians antar kelompok.
  -Uji Proporsi: Perbandingan proporsi antar kelompok.
  -Uji ANOVA: Untuk membandingkan rata-rata lebih dari dua kelompok.

6. Menu Regresi
  Menganalisis hubungan antar variabel:
  -Meneliti pengaruh variabel independen (X) terhadap variabel dependen (Y) menggunakan regresi linear.

7. Menu About Me
  Menampilkan:
  -Identitas dan informasi pembuat aplikasi.

🎯 Tujuan Dashboard
  Dashboard ini dikembangkan untuk:
  -Menyajikan data indikator demografi secara terintegrasi dan interaktif untuk seluruh provinsi di Indonesia.
  -Merancang visualisasi efektif guna menampilkan pola sebaran dan perbandingan antarprovinsi.
  -Mengidentifikasi wilayah-wilayah yang perlu perhatian khusus berdasarkan analisis indikator demografi.
