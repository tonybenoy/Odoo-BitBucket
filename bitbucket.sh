#!/usr/bin/env bash
# ------------------------------------------------------------------
# Author: Tony Benoy
#Script for automating the scaffolding and creating the repository in BitBucket with ease
#Works with Odoo 10.0,11.0,12.0
# ------------------------------------------------------------------

#Path to odoo-bin(All versions work as scaffoling is common for all)
odoobin=""
#Generate and app password fromhttps://bitbucket.org/account/user/$username/app-passwords
apppass=""
#BitBucket Username
username=""
#Project Name
project=""
#Default addons path if any
addonpath=""
#Get project key from https://bitbucket.org/$username/profile/projects
projkey=""
if [ -z "$2" ]
  then
    echo "Using Default addon path"
else
    addonpath=$2
fi
$odoobin scaffold "$1" "$addonpath" 
cd "$addonpath"/"$1"
cat >"$addonpath"/"$1"/.gitignore <<EOL
venv/*
**/.idea
*.pyc
*/*.pyc
*/*/*.pyc
*/*/*/*.pyc
*/*/*/*/*.pyc
*/*/*/*/*/*.pyc
*/*/*/*/*/*/*.pyc

*.~
*/*.~
*/*/*.~
*/*/*/*.~
*/*/*/*/*.~
*/*/*/*/*/*.~
*/*/*/*/*/*/*.~
EOL
rm "$addonpath"/"$1"/__manifest__.py
cat >"$addonpath"/"$1"/__manifest__.py <<EOL
# -*- coding: utf-8 -*-
{
    'name': "$1",

    'summary': """
        Short (1 phrase/line) summary of the module's purpose, used as
        subtitle on modules listing or apps.openerp.com""",

    'description': """
        Long description of module's purpose
    """,

    'author': "Tony",
    'website': "https://tonybenoy.com",

    # Categories can be used to filter modules in modules listing
    # Check https://github.com/odoo/odoo/blob/12.0/odoo/addons/base/data/ir_module_category_data.xml
    # for the full list
    'category': 'Uncategorized',
    'version': '0.1',
    app
    # any module necessary for this one to work correctly
    'depends': ['base'],

    # always loaded
    'data': [
        # 'security/ir.model.access.csv',
        'views/views.xml',
        'views/templates.xml',
    ],
    # only loaded in demonstration mode
    'demo': [
        'demo/demo.xml',
    ],
}
EOL
curl -X POST  -u "$username":"$apppass" "https://api.bitbucket.org/2.0/repositories/"$project"/"$1"" -H "Content-Type: application/json"  -d '{"has_wiki": true, "is_private": true, "project": {"key":"$projkey"}}'
cd "$addonpath"/"$1"
git init
git add .
git commit -m "Initial Commit"
git remote add origin git@bitbucket.org:$project/$1.git
git push -u origin master
echo "All Done. See your repo at https://bitbucket.org/$project/$1"
