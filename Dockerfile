FROM eclipse-temurin:25-jdk AS jdk

# Build JRE with minimal modules
RUN $JAVA_HOME/bin/jlink \
        --verbose \
        --add-modules java.net.http,java.sql,java.naming,java.management \
        --strip-debug \
        --no-man-pages \
        --no-header-files \
        --compress=zip-6 \
        --output /full-jre && \
    rm -rf /full-jre/legal && \
    find /full-jre/bin -type f \
         ! -name java \
         ! -name jcmd \
         -delete

# need base for glibc and ssl
FROM gcr.io/distroless/base-debian13:nonroot

WORKDIR /app
USER nonroot

COPY --from=jdk /full-jre /jre
ARG JAR_FILE=app.jar
COPY ${JAR_FILE} dist.jar

ENV PATH="/jre/bin:$PATH" PORT=8000 ADMIN_PORT=8001

# native access required by sqlite
ENTRYPOINT [ "java", "--enable-native-access=ALL-UNNAMED" ]
CMD [ "-jar", "dist.jar", "start-server" ]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD [ "java", "-jar", "dist.jar", "check-health" ]

EXPOSE 8000
