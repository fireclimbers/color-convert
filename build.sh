#!/bin/bash
npm run build;
rm -R docs;
mv dist docs;
exit;