#!/usr/bin/env bash
set -euo pipefail

SONAR_HOST_URL="${SONAR_HOST_URL:-http://localhost:9000}"
: "${SONAR_TOKEN:?falta SONAR_TOKEN}"
PROJECT_KEY="$(grep '^sonar.projectKey=' sonar-project.properties | cut -d'=' -f2)"

METRICS="bugs,vulnerabilities,code_smells,security_hotspots,coverage,duplicated_lines_density,duplicated_blocks,ncloc,new_bugs,new_vulnerabilities,new_code_smells,new_coverage,new_duplicated_lines_density"

measures="$(curl -s -u "${SONAR_TOKEN}:" \
  "${SONAR_HOST_URL}/api/measures/component?component=${PROJECT_KEY}&metricKeys=${METRICS}")"

metric() {
  local v
  v="$(echo "$measures" | jq -r --arg k "$1" '.component.measures[]? | select(.metric==$k) | .value')"
  if [ -n "$v" ]; then echo "$v"; else echo "-"; fi
}

gate="$(curl -s -u "${SONAR_TOKEN}:" \
  "${SONAR_HOST_URL}/api/qualitygates/project_status?projectKey=${PROJECT_KEY}")"
gate_status="$(echo "$gate" | jq -r '.projectStatus.status // "UNKNOWN"')"

issues="$(curl -s -u "${SONAR_TOKEN}:" \
  "${SONAR_HOST_URL}/api/issues/search?componentKeys=${PROJECT_KEY}&types=VULNERABILITY,BUG&resolved=false&ps=15")"

{
  echo "## SonarQube — ${PROJECT_KEY}"
  echo
  if [ "$gate_status" = "OK" ]; then
    echo "**Quality Gate: ✅ PASSED**"
  else
    echo "**Quality Gate: ❌ ${gate_status}**"
  fi
  echo
  echo "### Código nuevo (este commit/PR)"
  echo "| Métrica | Valor |"
  echo "|---|---|"
  echo "| Bugs nuevos | $(metric new_bugs) |"
  echo "| Vulnerabilidades nuevas | $(metric new_vulnerabilities) |"
  echo "| Code smells nuevos | $(metric new_code_smells) |"
  echo "| Cobertura | $(metric new_coverage)% |"
  echo "| Duplicación | $(metric new_duplicated_lines_density)% |"
  echo
  echo "### Total del proyecto"
  echo "| Métrica | Valor |"
  echo "|---|---|"
  echo "| Bugs | $(metric bugs) |"
  echo "| Vulnerabilidades | $(metric vulnerabilities) |"
  echo "| Code smells | $(metric code_smells) |"
  echo "| Security hotspots | $(metric security_hotspots) |"
  echo "| Cobertura | $(metric coverage)% |"
  echo "| Líneas duplicadas | $(metric duplicated_lines_density)% ($(metric duplicated_blocks) bloques) |"
  echo "| Líneas de código (ncloc) | $(metric ncloc) |"
  echo

  issue_count="$(echo "$issues" | jq '.issues | length')"
  if [ "$issue_count" -gt 0 ]; then
    echo "### Bugs y vulnerabilidades abiertas (máx. 15)"
    echo "| Severidad | Tipo | Archivo | Mensaje |"
    echo "|---|---|---|---|"
    echo "$issues" | jq -r '.issues[] | "| \(.severity) | \(.type) | \(.component | split(":")[-1]):\(.line // "-") | \(.message) |"'
  else
    echo "_Sin bugs ni vulnerabilidades abiertas._"
  fi
} >> "$GITHUB_STEP_SUMMARY"

echo "Resumen publicado en el Job Summary de esta corrida."
