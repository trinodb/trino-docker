#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM centos:centos8

ENV JAVA_HOME /usr/lib/jvm/zulu11

RUN \
    set -xeu && \
    # dependencies
    dnf -y -q install https://cdn.azul.com/zulu/bin/zulu-repo-1.0.0-1.noarch.rpm && \
    dnf -y -q install zulu11 less python3 && \
    alternatives --set python /usr/bin/python3 && \
    dnf -q clean all && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/* && \
    # set up user
    groupadd trino --gid 1000 && \
    useradd trino --uid 1000 --gid 1000

ENV TRINO_VERSION 369

ENV TRINO_LOCATION="https://repo1.maven.org/maven2/io/trino/trino-server/${TRINO_VERSION}/trino-server-${TRINO_VERSION}.tar.gz"
ENV CLIENT_LOCATION="https://repo1.maven.org/maven2/io/trino/trino-cli/${TRINO_VERSION}/trino-cli-${TRINO_VERSION}-executable.jar"

RUN \
    set -xeu && \
    # install client
    curl -o /usr/bin/trino ${CLIENT_LOCATION} && \
    chmod +x /usr/bin/trino && \
    # install server
    mkdir -p /usr/lib/trino /data/trino && \
    curl ${TRINO_LOCATION} | tar -C /usr/lib/trino -xz --strip 1 && \
    chown -R "trino:trino" /usr/lib/trino /data/trino

COPY --chown=trino:trino bin /usr/lib/trino/bin
COPY --chown=trino:trino default /usr/lib/trino/default

EXPOSE 8080
USER trino:trino
ENV LANG en_US.UTF-8
CMD ["/usr/lib/trino/bin/run-trino"]
