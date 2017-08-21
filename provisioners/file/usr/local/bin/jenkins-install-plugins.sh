#!/bin/sh

# This installs Jenkins plugins we want

set -o errexit -o nounset

JENKINS_UPDATE_SERVER="https://updates.jenkins.io/"
JENKINS_VERSION="${JENKINS_VERSION:-$(java -jar /usr/lib/jenkins/jenkins.war --version | cut -d. -f1,2)}"

JENKINS_HOME="$(awk -F'\"' '$1 == "JENKINS_HOME=" { print $2 }' /etc/sysconfig/jenkins)"
mkdir -p "${JENKINS_HOME}/plugins"
chown jenkins:jenkins "${JENKINS_HOME}" "${JENKINS_HOME}/plugins"

get_plugin_url() {
    if test -z "${JENKINS_UPDATE_URL:-}" ; then
        # Jenkins LTS releases have forked plugin directories
        if curl --silent --location --fail -o /dev/null "${JENKINS_UPDATE_SERVER}/${JENKINS_VERSION}" ; then
            JENKINS_UPDATE_URL="${JENKINS_UPDATE_SERVER%/}/${JENKINS_VERSION}/"
        else
            JENKINS_UPDATE_URL="${JENKINS_UPDATE_SERVER%/}/"
        fi
    fi
    echo "${JENKINS_UPDATE_URL%/}/latest/${plugin}.hpi"
}

for plugin in $(cat <<EOF
        ace-editor
        ansicolor
        antisamy-markup-formatter
        authentication-tokens
        aws-java-sdk
        blueocean-autofavorite
        blueocean-commons
        blueocean-config
        blueocean-dashboard
        blueocean-display-url
        blueocean-events
        blueocean-github-pipeline
        blueocean-git-pipeline
        blueocean-i18n
        blueocean
        blueocean-jwt
        blueocean-personalization
        blueocean-pipeline-api-impl
        blueocean-pipeline-editor
        blueocean-pipeline-scm-api
        blueocean-rest-impl
        blueocean-rest
        blueocean-web
        bouncycastle-api
        branch-api
        build-timeout
        cloudbees-folder
        credentials-binding
        credentials
        display-url-api
        docker-commons
        docker-workflow
        durable-task
        external-monitor-job
        favorite
        git-client
        github-api
        github-branch-source
        github
        git
        git-server
        handlebars
        icon-shim
        jackson2-api
        jquery-detached
        junit
        ldap
        mailer
        matrix-auth
        matrix-project
        metrics
        momentjs
        pam-auth
        pipeline-aws
        pipeline-build-step
        pipeline-github-lib
        pipeline-graph-analysis
        pipeline-input-step
        pipeline-milestone-step
        pipeline-model-api
        pipeline-model-declarative-agent
        pipeline-model-definition
        pipeline-model-extensions
        pipeline-rest-api
        pipeline-stage-step
        pipeline-stage-tags-metadata
        pipeline-stage-view
        pipeline-utility-steps
        plain-credentials
        pubsub-light
        resource-disposer
        scm-api
        script-security
        sse-gateway
        ssh-credentials
        ssh-slaves
        structs
        timestamper
        token-macro
        variant
        windows-slaves
        workflow-aggregator
        workflow-api
        workflow-basic-steps
        workflow-cps-global-lib
        workflow-cps
        workflow-durable-task-step
        workflow-job
        workflow-multibranch
        workflow-scm-step
        workflow-step-api
        workflow-support
        ws-cleanup
EOF
    ) ; do
    plugin_file="${JENKINS_HOME}/plugins/${plugin}.jpi"
    if test -e "${plugin_file}" ; then
        printf "Plugin %s already installed, skipping\n" "${plugin}"
        continue
    fi
    wget -O "${plugin_file}" "$(get_plugin_url "${plugin}")"
    chown jenkins:jenkins "${plugin_file}"
done
