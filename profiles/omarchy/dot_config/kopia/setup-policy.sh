#!/bin/bash
# Run once after connecting to a new Kopia repository
# to set up snapshot policies

kopia policy set ~ \
  --add-ignore=node_modules \
  --add-ignore=.cache \
  --add-ignore=.npm \
  --add-ignore=.gradle \
  --add-ignore=__pycache__ \
  --add-ignore=.rust \
  --add-ignore=target \
  --add-ignore=.cargo/registry \
  --add-ignore=vendor \
  --add-ignore=dist \
  --add-ignore=.next \
  --add-ignore=.nuxt \
  --add-ignore=.DS_Store \
  --add-ignore="*.log" \
  --add-ignore="*.tmp" \
  --add-ignore=.docker/volumes \
  --add-ignore="docker/volumes" \
  --keep-daily 30 \
  --keep-weekly 12 \
  --keep-monthly 12
