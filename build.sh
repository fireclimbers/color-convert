#!/bin/bash
npm run build;
rm -R docs;
mv dist docs;
cd docs;
sed -i '' 's/src=\//src=/g' index.html;
sed -i '' 's/href=\//href=/g' index.html;
exit;