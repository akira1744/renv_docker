# rocker/rstudio:4.3.3 をベースにtidyverse, 日本語設定等を追加する（amd64/arm64共通）
#   ENV CRAN=https://p3m.dev/cran/__linux__/jammy/2024-04-23

# rocker/tidyverse:4.3.3 の Dockerfile を参考にベースを構築
#  https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.3.3.Dockerfile
#  https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/tidyverse_4.3.3.Dockerfile

# FROM rocker/rstudio:4.3.3 AS my_rstudio

# COPY my_scripts/install_tidyverse.sh /my_scripts/install_tidyverse.sh
# RUN chmod 775 /my_scripts/install_tidyverse.sh \
#     && /my_scripts/install_tidyverse.sh

# CMD ["/init"]

# 上記の rocker/tidyverse 相当のイメージに日本語設定などを追加

# FROM tidyverse AS my_rstudio

FROM rocker/geospatial:4.3.3

# 日本語設定と必要なライブラリ（Rパッケージ用は別途スクリプト内で導入）
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    language-pack-ja-base \
    libxt6 \
    ssh \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" \
    && /bin/bash -c "source /etc/default/locale" \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# setup script
# 各スクリプトは改行コード LF(UNIX) でないとエラーになる
COPY my_scripts /my_scripts
RUN chmod 775 my_scripts/*
# RUN /my_scripts/install_r_packages.sh
RUN /my_scripts/install_radian.sh
RUN /my_scripts/install_notojp.sh
RUN /my_scripts/install_coding_fonts.sh

# FROM my_rstudio AS add_tinytex
# USER rstudio
# RUN /my_scripts/install_tinytex.sh
# RUN /my_scripts/install_tex_packages.sh
# USER root

# install DuckDB
RUN set -x \
    && apt-get update \
    && apt-get install -y \
    wget \
    unzip \
    curl \
    && wget https://github.com/duckdb/duckdb/releases/download/v0.10.2/duckdb_cli-linux-amd64.zip \
    && unzip duckdb_cli-linux-amd64.zip -d /usr/local/bin \
    && rm duckdb_cli-linux-amd64.zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add packages 20240505
# quartoの公式documentでrenv::restore()をした際にerror発生
# Rのterraパッケージのinstallに失敗
# 以下のパッケージを追加することでterraをインストールできるようになった。
# RUN set -x \
#     && apt-get update \
#     && apt-get install -y \
#     libproj-dev \
#     libgdal-dev \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
# RUN set -x \
#     && apt-get update \
#     && apt-get install -y \
#     libproj-dev \
#     libgdal-dev \
#     libmagick++-dev \
#     libxslt1-dev \
#     libudunits2-dev \
#     libgsl-dev \
#     libpoppler-cpp-dev \
#     default-jdk \
#     librsvg2-dev \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('renv', repos = 'http://cran.rstudio.com/')"
RUN R -e "install.packages('languageserver', repos = 'http://cran.rstudio.com/')"

# QuartoをTypst対応の1.4系に更新（2024-04時点の最新で 1.4.553）
RUN QUARTO_VERSION=1.4.553 /rocker_scripts/install_quarto.sh


# Enable Github copilot
RUN echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf

USER rstudio

# ${R_HOME}/etc/Renviron のタイムゾーン指定（Etc/UTC）を上書き
RUN echo "TZ=Asia/Tokyo" >> /home/rstudio/.Renviron

USER root

# RUN mkdir -p /home/rstudio/.cache/R/renv \
#     && chown -R rstudio:rstudio /home/rstudio/.cache/R/renv \
#     && chmod 777 /home/rstudio/.cache/R/renv \
#     && mkdir -p /home/rstudio/work \
#     && chown -R rstudio:rstudio /home/rstudio/work \
#     && chmod 777 /home/rstudio/work

# Copy RStudio settings
COPY --chown=rstudio:rstudio rstudio-prefs_mysettings.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio dotRprofile /home/rstudio/.Rprofile

ENV ROOT=TRUE \
    TZ=Asia/Tokyo \
    PASSWORD=rs \
    DISABLE_AUTH=true \
    RUNROOTLESS=false

# Amd64版との整合性のためrootlessモードは解除しておく

CMD ["/init"]
