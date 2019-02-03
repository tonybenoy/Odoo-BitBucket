#!/usr/bin/env bash
# ------------------------------------------------------------------
# Author: Tony Benoy
#Script for automating the scaffolding and creating the repository in BitBucket with ease
#Works with Odoo 10.0,11.0,12.0
# ------------------------------------------------------------------

#Path to odoo-bin(All versions work as scaffoling is common for all)
odoobin="./odoo-bin"
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
#Python Environment to use
pyenv=""
#Company Name for Manifest
companyname="tonybenoy"i
#Company Url For Manifest
companyurl="https://tonybenoy.com"
if [ -z "$2" ]
  then
    echo "Using Default addon path"
else
    addonpath=$2
fi
if [ -d "$addonpath""$$1" ]; then
    echo "Addon Exists"
    exit 1
fi
source $pyenv/bin/activate
$odoobin scaffold "$1" "$addonpath"
deactivate
$odoobin scaffold "$1" "$addonpath"

cd "$addonpath"/"$1"
cat >"$addonpath"/"$1"/.gitignore <<EOL
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

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

    'author': "$company",
    'website': "$companyurl",

    # Categories can be used to filter modules in modules listing
    # Check https://github.com/odoo/odoo/blob/12.0/odoo/addons/base/data/ir_module_category_data.xml
    # for the full list
    'category': 'Uncategorized',
    'version': '0.1',
    'applications' : True
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
curl -X POST -v  -u "$username":"$apppass" "https://api.bitbucket.org/2.0/repositories/"$project"/"$1"" -H "Content-Type: application/json"  -d "{\"has_wiki\": true, \"is_private\": true, \"project\": {\"key\": \""$projkey"\"}}"
cd "$addonpath"/"$1"
git init
git add .
git commit -m "Initial Commit"
git remote add origin git@bitbucket.org:$project/$1.git
git push -u origin master
echo "___________________________________________________________________________________________________________"
echo "All Done. See your repo at https://bitbucket.org/$project/$1"
echo "Module $1 created at $addonpath$1"
exit 0