require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'cgi'

# Muestra archivos estaticos CSS
# set :public_folder, 'public'

# Ruta para la página principal
get '/' do
  # Si hay un parámetro de búsqueda 'buscador', lo usamos. Si no, 'acción' como predeterminado
  categoria = params['buscador'] || ' '

  # URL de la página a hacer scraping, que incluye la categoría de búsqueda
  url = "https://www.themoviedb.org/search?query=#{CGI.escape(categoria)}"

  # Abrir la página web y hacer el scraping
  doc = Nokogiri::HTML(URI.open(url))

  # Inicializa arrays para almacenar la información
  titles = []
  images = []
  release_dates = []
  descriptions = []

  # Extraer los títulos de las películas
  doc.search('.card .title h2').each do |movie|
    titles << movie.text.strip
  end

  # Extraer las imágenes de las películas
  doc.search('.card .poster img').each do |image|
    images << image['src']
  end

  # Extraer las fechas de lanzamiento
  doc.search('.release_date').each do |release|
    release_dates << release.text.strip
  end

  # Extraer las descripciones
  doc.search('.overview p').each do |overview|
    descriptions << overview.text.strip
  end

  # Imprimir los datos extraídos para depuración
  puts "Títulos: #{titles}"
  puts "Imágenes: #{images}"
  puts "Fechas de lanzamiento: #{release_dates}"
  puts "Descripciones: #{descriptions}"

  # Filtrar solo las películas con todos los datos completos (título, imagen, descripción)
  valid_movies = []

  titles.each_with_index do |title, index|
    # Verificamos que el título, la imagen y la descripción no estén vacíos o sean nil
    if title && !title.empty? && images[index] && !images[index].empty? && descriptions[index] && !descriptions[index].empty?
      valid_movies << {
        title: title,
        image: images[index],
        release_date: release_dates[index],
        description: descriptions[index]
      }
    end
  end

  # Renderiza el archivo HTML con los resultados
  erb :index, locals: {
    valid_movies: valid_movies,
    categoria: categoria
  }
end
