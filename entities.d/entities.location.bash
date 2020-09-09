#!/bin/bash
#X Function: entities.location
#X Desc    : Return with current setting for ENTITIES and PATH.
entities.location() { echo -n "ENTITIES=\"$ENTITIES\";PATH=\"$PATH\""; }
declare -fx entities.location
#fin
