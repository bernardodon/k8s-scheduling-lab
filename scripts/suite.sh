#!/bin/bash
set -e

DIR="$(dirname "$0")"
mkdir -p "$DIR/../results"

"$DIR/run-scenario.sh" default 2>&1 | tee "$DIR/../results/default.txt"
DEFAULT=$(kubectl get pods -l app=fragment-big -o jsonpath='{.items[0].status.phase}')

echo ""

"$DIR/run-scenario.sh" spread 2>&1 | tee "$DIR/../results/spread.txt"
SPREAD=$(kubectl get pods -l app=fragment-big -o jsonpath='{.items[0].status.phase}')

echo ""

"$DIR/run-scenario.sh" binpack 2>&1 | tee "$DIR/../results/binpack.txt"
BINPACK=$(kubectl get pods -l app=fragment-big -o jsonpath='{.items[0].status.phase}')

echo ""
echo "=== RESUMO ==="
echo "Default: $DEFAULT"
echo "Spread:  $SPREAD"
echo "Binpack: $BINPACK"
