# Etapa 1: Construir la imagen de Flutter personalizada
FROM debian:buster-slim AS flutter-builder

# Instala las dependencias necesarias para Flutter
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Clona Flutter del repositorio de GitHub
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable

# Establece el PATH para incluir el binario de Flutter 
ENV PATH="$PATH:/usr/local/flutter/bin"

# Ejecuta flutter doctor para descargar las dependencias de Flutter y Dart SDK
RUN flutter doctor

# Pre-cachear dependencias de Flutter y Dart SDK
RUN flutter precache

# Verifica la versión de Flutter y Dart
RUN flutter --version
RUN dart --version

# Etapa 2: Construir tu aplicación Flutter usando la imagen de Flutter personalizada
FROM flutter-builder AS app-builder

WORKDIR /app

# Copia tu código fuente de Flutter a /app
COPY . /app

# Navega a la carpeta de tu aplicación si es necesario
# Si tu aplicación está en la raíz, puedes omitir este comando
# RUN cd path/to/your/flutter/app

# Obtiene las dependencias de Flutter
RUN flutter pub get

# Construye tu aplicación Flutter
# Ajusta el comando según tu tipo de compilación (por ejemplo, web, apk)
RUN flutter build web

# Etapa 3: Servir la aplicación Flutter usando un servidor web, por ejemplo, nginx
FROM nginx:alpine AS server

# Copia la aplicación construida desde la etapa de app-builder al servidor nginx
COPY --from=app-builder /app/build/web /usr/share/nginx/html

# Expone el puerto 80 para acceder a la aplicación web
EXPOSE 80

# Inicia nginx
CMD ["nginx", "-g", "daemon off;"]
