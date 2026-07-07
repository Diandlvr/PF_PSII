FROM tomcat:9.0-jdk17-temurin

# Limpiar webapps por defecto
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar fuentes Java y contenido web
COPY src/    /app/src/
COPY WebContent/ /usr/local/tomcat/webapps/ROOT/

# Crear directorios de clases
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/modelo

# Compilar los .java usando servlet-api + JARs del proyecto
RUN javac \
    -encoding UTF-8 \
    -cp "/usr/local/tomcat/lib/servlet-api.jar:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*" \
    -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
    /app/src/modelo/*.java

# Copiar mail.properties (se inyecta desde docker-compose o volumen)
COPY src/mail.properties.example /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/mail.properties

EXPOSE 8080
CMD ["catalina.sh", "run"]
