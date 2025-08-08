# AirePur-Frontend

## Descripción

Este repositorio contiene el código fuente del frontend de AirePur, una aplicación dedicada a proporcionar información actualizada sobre la calidad del aire y recomendaciones de salud asociadas a las condiciones ambientales. Este repositorio es parte de un proyecto más grande que también incluye un backend, alojado en otro repositorio.

## Estructura del Repositorio

Dentro del repositorio, encontrarás varias carpetas que organizan el proyecto de la siguiente manera:

- **android/**: Contiene los archivos específicos para la compilación de la aplicación en dispositivos Android.
- **assets/**: Almacena recursos gráficos como imágenes y iconos usados en la aplicación.
- **ios/**: Contiene los archivos específicos para la compilación de la aplicación en dispositivos iOS.
- **lib/**: El directorio principal del código Dart de Flutter, donde reside la lógica de la UI y del estado de la aplicación.
- **linux/**, **macos/**, **windows/**, **web/**: Contienen configuraciones y archivos específicos para la compilación de la aplicación en estas plataformas.

Además, hay archivos de configuración y definiciones de dependencias como `pubspec.yaml` y `Dockerfile` para la contenerización de la aplicación si es necesario.

## Tecnologías Utilizadas

- **Flutter**: Utilizado para el desarrollo del frontend. Es un framework de UI que permite una experiencia de usuario fluida en múltiples plataformas.
- **Dart**: Lenguaje de programación usado para desarrollar la lógica de la aplicación.
- **Google Maps Flutter**: Para integrar mapas y realizar seguimientos de ubicación.
- **Shared Preferences**: Para gestionar las preferencias del usuario y guardar estados locales.

## Conexión con el Backend

Este frontend se comunica con un backend, que se encuentra en otro repositorio. Asegúrate de configurar las variables de entorno y las direcciones IP correctas para las llamadas API, según lo documentado en el repositorio de backend.

## Configuración del Entorno

Para configurar el entorno de desarrollo necesario para contribuir a este proyecto, sigue estos pasos:
1. Clona este repositorio.
2. Asegúrate de tener Flutter instalado y configurado.
3. Navega al directorio del proyecto y ejecuta `flutter pub get` para instalar las dependencias.
4. Configura las variables de entorno necesarias para conectar con el backend.


## Soporte

Para obtener soporte, puedes abrir un issue en este repositorio o contactar a los administradores del proyecto.

---

Esperamos que esta guía te ayude a comenzar rápidamente con el desarrollo y contribución al proyecto AirePur. ¡Gracias por tu interés y contribuciones!

