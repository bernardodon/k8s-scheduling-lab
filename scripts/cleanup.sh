#!/bin/bash
kubectl delete deployment fragment-filler fragment-big --ignore-not-found 2>/dev/null || true
sleep 2
