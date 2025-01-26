#!/bin/bash

HOTFOLDER_PATH=$1

rm -rf $HOTFOLDER_PATH/amway/*
mv -v /opt/hybris/data/amway/* $HOTFOLDER_PATH/amway
