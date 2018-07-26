FROM debian:9.5-slim as builder

# install our needed libraries
RUN apt-get update -y && apt-get install -y curl dumb-init build-essential git make cmake clang

# Create the workdir
WORKDIR /app

# Make a shallow clone of the source / master branch
RUN git clone --depth 1 --recursive https://github.com/cuberite/cuberite.git .

# create the build directory
RUN mkdir -p /app/release

# Set our build type
# ENV BUILD=RELEASE
ENV BUILD=DEBUG

# Run the configuration step
RUN cd /app/release && cmake -DCMAKE_BUILD_TYPE=${BUILD} ..

# Build the release
RUN cd /app/release && make -j`nproc`

# We want to make a clean image without all the extraneous stuff above so start stage 2
FROM debian:9.5-slim

ENV PORT=25565

# Copy our entrypoint.sh
COPY ./configs/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

# Copy our tools and server from the build image
COPY --from=builder /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=builder /app/Server /app

# Copy our local webadmin.ini to the server
COPY ./configs/webadmin.ini /app/webadmin.ini
# COPY ./configs/settings.ini /app/settings.ini

# Our working directory
WORKDIR /app

# expose our default ports
EXPOSE 25565 8080

# Entrypoing is dumb-init to facilitate handling child process reaping
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]

# How we actually start our app
# CMD ["./Cuberite"]
CMD ["./Cuberite", "--port", "${PORT}", "--config-file", "settings.ini"]
