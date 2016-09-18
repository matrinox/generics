#!/usr/bin/env bash

rm -rf Generics/
rm -rf js/
rm -rf css/
rm *.html
yard
mv doc/* ./
rm -rf doc
