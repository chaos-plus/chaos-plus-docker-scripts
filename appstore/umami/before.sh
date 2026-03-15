#!/bin/bash


init_db mysql7 3306 root ${PASSWORD:-} umami
init_db mysql8 3306 root ${PASSWORD:-} umami
