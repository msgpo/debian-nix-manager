{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.apache-kafka;

  serverProperties =
    if cfg.serverProperties != null then
      cfg.serverProperties
    else
      ''
        # Generated by nixos
        broker.id=${toString cfg.brokerId}
        port=${toString cfg.port}
        host.name=${cfg.hostname}
        log.dirs=${concatStringsSep "," cfg.logDirs}
        zookeeper.connect=${cfg.zookeeper}
        offsets.topic.replication.factor=1
        ${toString cfg.extraProperties}
      '';

  serverConfig = pkgs.writeText "server.properties" serverProperties;
  logConfig = pkgs.writeText "log4j.properties" cfg.log4jProperties;

  PreShell = pkgs.writeScript "run-kafka" ''
          ${pkgs.jre}/bin/java \
            -cp "${cfg.package}/libs/*" \
            -Dlog4j.configuration=file:${logConfig} \
            ${toString cfg.jvmOptions} \
            kafka.Kafka \
            ${serverConfig}
    '';

in {

  options.services.apache-kafka = {
    enable = mkOption {
      description = "Whether to enable Apache Kafka.";
      default = false;
      type = types.bool;
    };

    brokerId = mkOption {
      description = "Broker ID.";
      default = -1;
      type = types.int;
    };

    port = mkOption {
      description = "Port number the broker should listen on.";
      default = 9092;
      type = types.int;
    };

    hostname = mkOption {
      description = "Hostname the broker should bind to.";
      default = "localhost";
      type = types.str;
    };

    logDirs = mkOption {
      description = "Log file directories";
      default = [ "/tmp/kafka-logs" ];
      type = types.listOf types.path;
    };

    zookeeper = mkOption {
      description = "Zookeeper connection string";
      default = "localhost:2181";
      type = types.str;
    };

    extraProperties = mkOption {
      description = "Extra properties for server.properties.";
      type = types.nullOr types.lines;
      default = null;
    };

    serverProperties = mkOption {
      description = ''
        Complete server.properties content. Other server.properties config
        options will be ignored if this option is used.
      '';
      type = types.nullOr types.lines;
      default = null;
    };

    log4jProperties = mkOption {
      description = "Kafka log4j property configuration.";
      default = ''
        log4j.rootLogger=INFO, stdout

        log4j.appender.stdout=org.apache.log4j.ConsoleAppender
        log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
        log4j.appender.stdout.layout.ConversionPattern=[%d] %p %m (%c)%n
      '';
      type = types.lines;
    };

    jvmOptions = mkOption {
      description = "Extra command line options for the JVM running Kafka.";
      default = [
        "-server"
        "-Xmx1G"
        "-Xms1G"
        "-XX:+UseCompressedOops"
        "-XX:+UseParNewGC"
        "-XX:+UseConcMarkSweepGC"
        "-XX:+CMSClassUnloadingEnabled"
        "-XX:+CMSScavengeBeforeRemark"
        "-XX:+DisableExplicitGC"
        "-Djava.awt.headless=true"
        "-Djava.net.preferIPv4Stack=true"
      ];
      type = types.listOf types.str;
      example = [
        "-Djava.net.preferIPv4Stack=true"
        "-Dcom.sun.management.jmxremote"
        "-Dcom.sun.management.jmxremote.local.only=true"
      ];
    };

    package = mkOption {
      description = "The kafka package to use";
      default = pkgs.apacheKafka;
      defaultText = "pkgs.apacheKafka";
      type = types.package;
    };

  };

  config = mkIf cfg.enable {

    home.packages = [cfg.package];

    systemd.user.services.apache-kafka = {
      Unit = {
        description = "Apache Kafka Daemon";
        after = [ "network.target" ];
      };
      Install = { wantedBy = [ "multi-user.target" ];};

      Service = {
        ExecStart = ''
            ${pkgs.bash}/bin/bash ${PreShell}
        '';
      };
    };

  };
}
